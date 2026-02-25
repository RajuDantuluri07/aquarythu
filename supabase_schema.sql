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

-- 2. Create the 'tanks' table
create table public.tanks (
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
  
  constraint tanks_pkey primary key (id)
);

-- 3. Enable Row Level Security (RLS)
alter table public.farms enable row level security;
alter table public.tanks enable row level security;

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

-- 5. RLS Policies for 'tanks'
-- Note: We check if the user owns the parent farm to grant access to the tank.

-- Policy: Users can view tanks belonging to their farms
create policy "Users can view tanks of their farms"
  on public.tanks for select
  using ( exists (
    select 1 from public.farms
    where farms.id = tanks.farm_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can insert tanks into their farms
create policy "Users can insert tanks to their farms"
  on public.tanks for insert
  with check ( exists (
    select 1 from public.farms
    where farms.id = tanks.farm_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can update/delete tanks of their farms
create policy "Users can update tanks of their farms"
  on public.tanks for update
  using ( exists (
    select 1 from public.farms
    where farms.id = tanks.farm_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete tanks of their farms"
  on public.tanks for delete
  using ( exists (
    select 1 from public.farms
    where farms.id = tanks.farm_id
    and farms.user_id = auth.uid()
  ));

-- 6. Create the 'blind_feed_schedule' table
create table public.blind_feed_schedule (
  id uuid not null default uuid_generate_v4(),
  tank_id uuid not null references public.tanks(id) on delete cascade,
  day_of_culture integer not null,
  daily_feed_amount numeric not null,
  feed_type text not null,
  created_at timestamptz not null default now(),
  
  constraint blind_feed_schedule_pkey primary key (id)
);

-- 7. Enable RLS for 'blind_feed_schedule'
alter table public.blind_feed_schedule enable row level security;

-- 8. RLS Policies for 'blind_feed_schedule'

-- Policy: Users can view schedules of their tanks
create policy "Users can view schedules of their tanks"
  on public.blind_feed_schedule for select
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = blind_feed_schedule.tank_id
    and farms.user_id = auth.uid()
  ));

-- 9. Create the 'feed_logs' table (formerly feed_rounds)
create table public.feed_logs (
  id uuid not null default uuid_generate_v4(),
  tank_id uuid not null references public.tanks(id) on delete cascade,
  scheduled_at timestamptz not null,
  executed_at timestamptz,
  feed_quantity numeric not null,
  feed_type text not null,
  mix_instructions text not null,
  executed_by uuid references auth.users(id),
  is_completed boolean not null default false,
  created_at timestamptz not null default now(),
  
  constraint feed_logs_pkey primary key (id)
);

-- 10. Enable RLS for 'feed_logs'
alter table public.feed_logs enable row level security;

-- 11. RLS Policies for 'feed_logs'

create policy "Users can view feed logs of their tanks"
  on public.feed_logs for select
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = feed_logs.tank_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can insert feed logs for their tanks"
  on public.feed_logs for insert
  with check ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = feed_logs.tank_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can update feed logs of their tanks"
  on public.feed_logs for update
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = feed_logs.tank_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete feed logs of their tanks"
  on public.feed_logs for delete
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = feed_logs.tank_id
    and farms.user_id = auth.uid()
  ));

-- 12. Create the 'tray_checks' table (formerly tray_logs)
create table public.tray_checks (
  id uuid not null default uuid_generate_v4(),
  feed_log_id uuid not null references public.feed_logs(id) on delete cascade,
  tray_number integer not null,
  status text not null,
  score numeric not null,
  created_at timestamptz not null default now(),
  
  constraint tray_checks_pkey primary key (id)
);

-- 13. Enable RLS for 'tray_checks'
alter table public.tray_checks enable row level security;

-- 14. RLS Policies for 'tray_checks'

create policy "Users can view tray checks of their feed logs"
  on public.tray_checks for select
  using ( exists (
    select 1 from public.feed_logs
    join public.tanks on tanks.id = feed_logs.tank_id
    join public.farms on farms.id = tanks.farm_id
    where feed_logs.id = tray_checks.feed_log_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can insert tray checks for their feed logs"
  on public.tray_checks for insert
  with check ( exists (
    select 1 from public.feed_logs
    join public.tanks on tanks.id = feed_logs.tank_id
    join public.farms on farms.id = tanks.farm_id
    where feed_logs.id = tray_checks.feed_log_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can update tray checks of their feed logs"
  on public.tray_checks for update
  using ( exists (
    select 1 from public.feed_logs
    join public.tanks on tanks.id = feed_logs.tank_id
    join public.farms on farms.id = tanks.farm_id
    where feed_logs.id = tray_checks.feed_log_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete tray checks of their feed logs"
  on public.tray_checks for delete
  using ( exists (
    select 1 from public.feed_logs
    join public.tanks on tanks.id = feed_logs.tank_id
    join public.farms on farms.id = tanks.farm_id
    where feed_logs.id = tray_checks.feed_log_id
    and farms.user_id = auth.uid()
  ));

-- 15. Create the 'supplements' table
create table public.supplements (
  id uuid not null default uuid_generate_v4(),
  farm_id uuid not null references public.farms(id) on delete cascade,
  name text not null,
  type text not null, -- 'Medicine', 'Mineral', 'Probiotic', 'Disinfectant'
  quantity numeric not null default 0,
  unit text not null, -- 'kg', 'L'
  cost_per_unit numeric,
  created_at timestamptz not null default now(),
  
  constraint supplements_pkey primary key (id)
);

-- 16. Enable RLS for 'supplements'
alter table public.supplements enable row level security;

-- 17. RLS Policies for 'supplements'

create policy "Users can view supplements of their farms"
  on public.supplements for select
  using ( exists (
    select 1 from public.farms
    where farms.id = supplements.farm_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can insert supplements to their farms"
  on public.supplements for insert
  with check ( exists (
    select 1 from public.farms
    where farms.id = supplements.farm_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can update supplements of their farms"
  on public.supplements for update
  using ( exists (
    select 1 from public.farms
    where farms.id = supplements.farm_id
    and farms.user_id = auth.uid()
  ));

create policy "Users can delete supplements of their farms"
  on public.supplements for delete
  using ( exists (
    select 1 from public.farms
    where farms.id = supplements.farm_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can insert schedules for their tanks
create policy "Users can insert schedules for their tanks"
  on public.blind_feed_schedule for insert
  with check ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = blind_feed_schedule.tank_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can update schedules of their tanks
create policy "Users can update schedules of their tanks"
  on public.blind_feed_schedule for update
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = blind_feed_schedule.tank_id
    and farms.user_id = auth.uid()
  ));

-- Policy: Users can delete schedules of their tanks
create policy "Users can delete schedules of their tanks"
  on public.blind_feed_schedule for delete
  using ( exists (
    select 1 from public.tanks
    join public.farms on farms.id = tanks.farm_id
    where tanks.id = blind_feed_schedule.tank_id
    and farms.user_id = auth.uid()
  ));