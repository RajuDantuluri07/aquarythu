-- MIGRATION SCRIPT: Add new columns and tables to match current Dart code
-- This script is SAFE - it adds new columns and tables without dropping existing data
-- Before running: BACKUP YOUR DATABASE

-- ===== STEP 1: Add missing columns to tanks table =====
ALTER TABLE tanks
  ADD COLUMN IF NOT EXISTS size DECIMAL(10,2),
  ADD COLUMN IF NOT EXISTS biomass DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS initial_seed INTEGER,
  ADD COLUMN IF NOT EXISTS pl_size TEXT,
  ADD COLUMN IF NOT EXISTS check_trays INTEGER,
  ADD COLUMN IF NOT EXISTS blind_duration INTEGER,
  ADD COLUMN IF NOT EXISTS blind_week1 INTEGER DEFAULT 2,
  ADD COLUMN IF NOT EXISTS blind_std INTEGER DEFAULT 4,
  ADD COLUMN IF NOT EXISTS health_status TEXT,
  ADD COLUMN IF NOT EXISTS health_notes TEXT,
  ADD COLUMN IF NOT EXISTS dead_count INTEGER DEFAULT 0;

-- ===== STEP 2: Create blind_feed_schedule table =====
CREATE TABLE IF NOT EXISTS blind_feed_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tank_id UUID REFERENCES tanks ON DELETE CASCADE NOT NULL,
  day_of_culture INTEGER NOT NULL,
  daily_feed_amount DECIMAL(10,2) NOT NULL,
  feed_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== STEP 3: Create feed_logs table (replacement for feed_entries) =====
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

-- (Optional) Migrate data from feed_entries to feed_logs if you have existing data:
-- INSERT INTO feed_logs (tank_id, scheduled_at, executed_at, feed_quantity, is_completed, created_at)
-- SELECT tank_id, 
--        COALESCE(date::TIMESTAMPTZ, NOW()),
--        COALESCE(date::TIMESTAMPTZ, NOW()),
--        grams::DECIMAL,
--        TRUE,
--        created_at
-- FROM feed_entries
-- WHERE NOT EXISTS (SELECT 1 FROM feed_logs WHERE feed_logs.tank_id = feed_entries.tank_id);

-- ===== STEP 4: Enable RLS on new tables =====
ALTER TABLE blind_feed_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;

-- ===== STEP 5: Create RLS policies for new tables =====
CREATE POLICY "Users can manage blind feed schedules" ON blind_feed_schedule
  FOR ALL USING (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = blind_feed_schedule.tank_id AND farms.user_id = auth.uid())
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM tanks JOIN farms ON farms.id = tanks.farm_id 
            WHERE tanks.id = blind_feed_schedule.tank_id AND farms.user_id = auth.uid())
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

-- ===== STEP 6: Add performance indexes =====
CREATE INDEX IF NOT EXISTS idx_feed_logs_tank_id ON feed_logs(tank_id);
CREATE INDEX IF NOT EXISTS idx_feed_logs_executed_at ON feed_logs(executed_at);
CREATE INDEX IF NOT EXISTS idx_blind_schedule_tank_id ON blind_feed_schedule(tank_id);
CREATE INDEX IF NOT EXISTS idx_blind_schedule_doc ON blind_feed_schedule(day_of_culture);

-- ===== Migration Complete =====
-- Your database is now compatible with the current Dart code.
-- 
-- OPTIONAL: Keep or drop the old feed_entries table?
-- To remove: DROP TABLE IF EXISTS feed_entries CASCADE;
--
-- Test with: SELECT * FROM information_schema.tables WHERE table_name IN ('tanks', 'feed_logs', 'blind_feed_schedule');
