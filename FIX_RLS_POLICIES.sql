-- PERMANENT FIX: Better RLS policies (if policies are the issue)
-- Run this AFTER confirming the app works with RLS disabled

-- Drop old problematic policies
DROP POLICY IF EXISTS "Users can manage feed logs" ON feed_logs;
DROP POLICY IF EXISTS "Users can manage blind feed schedules" ON blind_feed_schedule;

-- Create simpler, more reliable policies for feed_logs
CREATE POLICY "feed_logs_select" ON feed_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM tanks t
      INNER JOIN farms f ON f.id = t.farm_id
      WHERE t.id = feed_logs.tank_id
      AND f.user_id = auth.uid()
    )
  );

CREATE POLICY "feed_logs_insert_update_delete" ON feed_logs
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tanks t
      INNER JOIN farms f ON f.id = t.farm_id
      WHERE t.id = feed_logs.tank_id
      AND f.user_id = auth.uid()
    )
  );

-- Create simpler, more reliable policies for blind_feed_schedule
CREATE POLICY "blind_schedule_select" ON blind_feed_schedule
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM tanks t
      INNER JOIN farms f ON f.id = t.farm_id
      WHERE t.id = blind_feed_schedule.tank_id
      AND f.user_id = auth.uid()
    )
  );

CREATE POLICY "blind_schedule_insert_update_delete" ON blind_feed_schedule
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM tanks t
      INNER JOIN farms f ON f.id = t.farm_id
      WHERE t.id = blind_feed_schedule.tank_id
      AND f.user_id = auth.uid()
    )
  );

-- Re-enable RLS
ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE blind_feed_schedule ENABLE ROW LEVEL SECURITY;
