-- Enable the UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- 1. Create the 'farms' table
create table public.farms (
  id uuid not null default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  
  constraint farms_pkey primary key (id)
);

-- 2. Create the 'ponds' table
create table public.ponds (
  id uuid not null default uuid_generate_v4(),
  farm_id uuid not null references public.farms(id) on delete cascade,
  name text not null,
  acre_size numeric not null,
  stocking_count integer not null,
  pl_per_m2 integer not null,
  stocking_date date not null,
  number_of_trays integer not null,
  aeration_hp numeric not null,
  water_source text not null,
  created_at timestamptz not null default now(),
  
  constraint ponds_pkey primary key (id)
);

-- 3. Enable Row Level Security (RLS)
alter table public.farms enable row level security;
alter table public.ponds enable row level security;

-- 4. RLS Policies for 'farms'

-- Policy: Users can view their own farms
create policy "Users can view their own farms"
  on public.farms for select
  using ( auth.uid() = user_id );

-- Policy: Users can insert their own farms
create policy "Users can insert their own farms"
  on public.farms for insert
  with check ( auth.uid() = user_id );

-- Policy: Users can update their own farms
create policy "Users can update their own farms"
  on public.farms for update
  using ( auth.uid() = user_id );

-- Policy: Users can delete their own farms
create policy "Users can delete their own farms"
  on public.farms for delete
  using ( auth.uid() = user_id );

-- 5. RLS Policies for 'ponds'
-- Note: We check if the user owns the parent farm to grant access to the pond.

-- Policy: Users can view ponds belonging to their farms
create policy "Users can view ponds of their farms"
  on public.ponds for select
  using ( exists (
    select 1 from public.farms
    where farms.id = ponds.farm_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can insert ponds into their farms
create policy "Users can insert ponds to their farms"
  on public.ponds for insert
  with check ( exists (
    select 1 from public.farms
    where farms.id = ponds.farm_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can update/delete ponds of their farms
create policy "Users can update ponds of their farms"
  on public.ponds for update
  using ( exists (
    select 1 from public.farms
    where farms.id = ponds.farm_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete ponds of their farms"
  on public.ponds for delete
  using ( exists (
    select 1 from public.farms
    where farms.id = ponds.farm_id
    and farms.user_id = auth.uid()
  ));

-- 6. Create the 'blind_feed_schedule' table
create table public.blind_feed_schedule (
  id uuid not null default uuid_generate_v4(),
  pond_id uuid not null references public.ponds(id) on delete cascade,
  day_of_culture integer not null,
  daily_feed_amount numeric not null,
  feed_type text not null,
  created_at timestamptz not null default now(),
  
  constraint blind_feed_schedule_pkey primary key (id)
);

-- 7. Enable RLS for 'blind_feed_schedule'
alter table public.blind_feed_schedule enable row level security;

-- 8. RLS Policies for 'blind_feed_schedule'

-- Policy: Users can view schedules of their ponds
create policy "Users can view schedules of their ponds"
  on public.blind_feed_schedule for select
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = blind_feed_schedule.pond_id
    and farms.user_id = auth.uid()
  ));

-- 9. Create the 'feed_rounds' table
create table public.feed_rounds (
  id uuid not null default uuid_generate_v4(),
  pond_id uuid not null references public.ponds(id) on delete cascade,
  scheduled_at timestamptz not null,
  executed_at timestamptz,
  feed_quantity numeric not null,
  feed_type text not null,
  mix_instructions text not null,
  executed_by uuid references auth.users(id),
  is_completed boolean not null default false,
  created_at timestamptz not null default now(),
  
  constraint feed_rounds_pkey primary key (id)
);

-- 10. Enable RLS for 'feed_rounds'
alter table public.feed_rounds enable row level security;

-- 11. RLS Policies for 'feed_rounds'

create policy "Users can view feed rounds of their ponds"
  on public.feed_rounds for select
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = feed_rounds.pond_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can insert feed rounds for their ponds"
  on public.feed_rounds for insert
  with check ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = feed_rounds.pond_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can update feed rounds of their ponds"
  on public.feed_rounds for update
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = feed_rounds.pond_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete feed rounds of their ponds"
  on public.feed_rounds for delete
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = feed_rounds.pond_id
    and farms.user_id = auth.uid()
  ));

-- 12. Create the 'tray_logs' table
create table public.tray_logs (
  id uuid not null default uuid_generate_v4(),
  feed_round_id uuid not null references public.feed_rounds(id) on delete cascade,
  tray_number integer not null,
  status text not null,
  score numeric not null,
  created_at timestamptz not null default now(),
  
  constraint tray_logs_pkey primary key (id)
);

-- 13. Enable RLS for 'tray_logs'
alter table public.tray_logs enable row level security;

-- 14. RLS Policies for 'tray_logs'

create policy "Users can view tray logs of their feed rounds"
  on public.tray_logs for select
  using ( exists (
    select 1 from public.feed_rounds
    join public.ponds on ponds.id = feed_rounds.pond_id
    join public.farms on farms.id = ponds.farm_id
    where feed_rounds.id = tray_logs.feed_round_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can insert tray logs for their feed rounds"
  on public.tray_logs for insert
  with check ( exists (
    select 1 from public.feed_rounds
    join public.ponds on ponds.id = feed_rounds.pond_id
    join public.farms on farms.id = ponds.farm_id
    where feed_rounds.id = tray_logs.feed_round_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can update tray logs of their feed rounds"
  on public.tray_logs for update
  using ( exists (
    select 1 from public.feed_rounds
    join public.ponds on ponds.id = feed_rounds.pond_id
    join public.farms on farms.id = ponds.farm_id
    where feed_rounds.id = tray_logs.feed_round_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete tray logs of their feed rounds"
  on public.tray_logs for delete
  using ( exists (
    select 1 from public.feed_rounds
    join public.ponds on ponds.id = feed_rounds.pond_id
    join public.farms on farms.id = ponds.farm_id
    where feed_rounds.id = tray_logs.feed_round_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can insert schedules for their ponds
create policy "Users can insert schedules for their ponds"
  on public.blind_feed_schedule for insert
  with check ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = blind_feed_schedule.pond_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can update schedules of their ponds
create policy "Users can update schedules of their ponds"
  on public.blind_feed_schedule for update
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = blind_feed_schedule.pond_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can delete schedules of their ponds
create policy "Users can delete schedules of their ponds"
  on public.blind_feed_schedule for delete
  using ( exists (
    select 1 from public.ponds
    join public.farms on farms.id = ponds.farm_id
    where ponds.id = blind_feed_schedule.pond_id
    and farms.user_id = auth.uid()
  ));