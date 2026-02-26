-- TEMPORARY FIX: Disable RLS to isolate the issue
-- This will help us determine if the problem is RLS policies or missing tables
-- DO NOT USE IN PRODUCTION

-- Disable RLS on feed_logs temporarily
ALTER TABLE feed_logs DISABLE ROW LEVEL SECURITY;

-- Disable RLS on blind_feed_schedule temporarily  
ALTER TABLE blind_feed_schedule DISABLE ROW LEVEL SECURITY;

-- If your app works now, the issue is RLS policies
-- If it still doesn't work, the issue is missing tables or columns

-- To re-enable RLS later:
-- ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE blind_feed_schedule ENABLE ROW LEVEL SECURITY;
