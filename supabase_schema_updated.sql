-- Drop existing tables (if migrating)
-- DROP TABLE IF EXISTS blind_feed_schedule CASCADE;
-- DROP TABLE IF EXISTS harvest_entries CASCADE;
-- DROP TABLE IF EXISTS feed_logs CASCADE;
-- DROP TABLE IF EXISTS tanks CASCADE;
-- DROP TABLE IF EXISTS farms CASCADE;

-- Create tables
CREATE TABLE IF NOT EXISTS farms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tanks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  farm_id UUID REFERENCES farms ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  stocking_date DATE NOT NULL,
  size DECIMAL(10,2),
  biomass DECIMAL(10,2) DEFAULT 0,
  initial_seed INTEGER,
  pl_size TEXT,
  check_trays INTEGER,
  blind_duration INTEGER,
  blind_week1 INTEGER DEFAULT 2,
  blind_std INTEGER DEFAULT 4,
  health_status TEXT,
  health_notes TEXT,
  dead_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS feed_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tank_id UUID REFERENCES tanks ON DELETE CASCADE NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  executed_at TIMESTAMPTZ,
  feed_quantity DECIMAL(10,2) NOT NULL,
  feed_type TEXT,
  mix_instructions TEXT,
  executed_by UUID REFERENCES auth.users,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS blind_feed_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tank_id UUID REFERENCES tanks ON DELETE CASCADE NOT NULL,
  day_of_culture INTEGER NOT NULL,
  daily_feed_amount DECIMAL(10,2) NOT NULL,
  feed_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS harvest_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tank_id UUID REFERENCES tanks ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  weight_kg DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tanks ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE blind_feed_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE harvest_entries ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can manage their farms" ON farms
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage their tanks" ON tanks
  FOR ALL USING (
    EXISTS (SELECT 1 FROM farms WHERE farms.id = tanks.farm_id AND farms.user_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM farms WHERE farms.id = tanks.farm_id AND farms.user_id = auth.uid())
  );

CREATE POLICY "Users can manage feed logs" ON feed_logs
  FOR ALL USING (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = feed_logs.tank_id AND farms.user_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = feed_logs.tank_id AND farms.user_id = auth.uid())
  );

CREATE POLICY "Users can manage blind feed schedules" ON blind_feed_schedule
  FOR ALL USING (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = blind_feed_schedule.tank_id AND farms.user_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = blind_feed_schedule.tank_id AND farms.user_id = auth.uid())
  );

CREATE POLICY "Users can manage harvest entries" ON harvest_entries
  FOR ALL USING (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = harvest_entries.tank_id AND farms.user_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = harvest_entries.tank_id AND farms.user_id = auth.uid())
  );

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_farms_user_id ON farms(user_id);
CREATE INDEX IF NOT EXISTS idx_tanks_farm_id ON tanks(farm_id);
CREATE INDEX IF NOT EXISTS idx_feed_logs_tank_id ON feed_logs(tank_id);
CREATE INDEX IF NOT EXISTS idx_feed_logs_executed_at ON feed_logs(executed_at);
CREATE INDEX IF NOT EXISTS idx_blind_schedule_tank_id ON blind_feed_schedule(tank_id);
CREATE INDEX IF NOT EXISTS idx_blind_schedule_doc ON blind_feed_schedule(day_of_culture);
CREATE INDEX IF NOT EXISTS idx_harvest_entries_tank_id ON harvest_entries(tank_id);
CREATE INDEX IF NOT EXISTS idx_harvest_entries_date ON harvest_entries(date);
