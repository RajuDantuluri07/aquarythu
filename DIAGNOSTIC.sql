-- DIAGNOSTIC: Check what exists in your database
-- Run this in Supabase SQL Editor to see what's actually there

-- Check all public tables
SELECT 
  table_name,
  (SELECT count(*) FROM information_schema.columns 
   WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check tanks table structure specifically
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'tanks'
ORDER BY ordinal_position;

-- Check if feed_logs exists
SELECT table_name FROM information_schema.tables
WHERE table_name = 'feed_logs';

-- Check if blind_feed_schedule exists
SELECT table_name FROM information_schema.tables
WHERE table_name = 'blind_feed_schedule';

-- Check RLS policies
SELECT schemaname, tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check if old feed_entries table still exists
SELECT table_name FROM information_schema.tables
WHERE table_name = 'feed_entries';
