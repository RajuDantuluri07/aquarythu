# 🚜 AquaRythu - Production Setup Guide

## Phase 1: Database Setup (Supabase)

### Step 1.1: Verify Your Supabase Project
1. Go to https://app.supabase.com
2. Select your AquaRythu project
3. Note your **Project URL** and **Anon Key** from Settings → API

### Step 1.2: Create/Update Database Schema
Run this in Supabase SQL Editor:

**Option A: Fresh Start (Recommended for new projects)**
```bash
# Copy entire contents of supabase_schema_updated.sql
# Paste in Supabase SQL Editor → Run
```

**Option B: Existing Project (Safe Migration)**
```bash
# Copy entire contents of MIGRATION_SAFE.sql
# Paste in Supabase SQL Editor → Run
```

### Step 1.3: Verify Tables Exist
Run in Supabase SQL Editor:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

Expected output:
```
blind_feed_schedule
farms
feed_logs
harvest_entries
tanks
```

### Step 1.4: Verify RLS Policies
Run in Supabase SQL Editor:
```sql
SELECT tablename, policyname FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename;
```

All tables should have policies listed.

---

## Phase 2: Fix Potential RLS Issues (If App Won't Load)

If the app loads but shows blank screens, try this:

### Temporary: Disable RLS for Testing
```sql
ALTER TABLE blind_feed_schedule DISABLE ROW LEVEL SECURITY;
ALTER TABLE feed_logs DISABLE ROW LEVEL SECURITY;
```

### Then Re-enable with Fixed Policies
```sql
ALTER TABLE blind_feed_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_logs ENABLE ROW LEVEL SECURITY;

-- Recreate policies (from FIX_RLS_POLICIES.sql)
```

---

## Phase 3: Frontend Setup

### Step 3.1: Install Dependencies
```bash
cd /Users/sunny/Documents/aquarythu
flutter pub get
```

### Step 3.2: Test Locally
```bash
# Get your Supabase credentials from Settings → API
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your_anon_key"

# Run debug build
flutter run \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Step 3.3: Check for Errors
Look for red errors in the console. Common issues:
- ❌ "Looking up a deactivated widget" → Already fixed in code
- ❌ "FeedProvider isn't a type" → Already removed
- ❌ "RenderFlex overflow" → Already fixed
- ❌ "Column not found in schema" → Run migration above

---

## Phase 4: Production Build

### Step 4.1: Clean Build
```bash
flutter clean
flutter pub get
```

### Step 4.2: Run Analyzer
```bash
flutter analyze
```

Should show: "No issues found!"

### Step 4.3: Build Release APK
```bash
# Use the helper script
chmod +x build.sh
./build.sh "https://your-project.supabase.co" "your_anon_key"

# OR manual command
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your_anon_key"
```

### Step 4.4: Verify APK
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## Phase 5: Testing Checklist

### Functional Tests
- [ ] Login/logout flow works
- [ ] Can create farm
- [ ] Can create tank in farm
- [ ] Can view tanks list
- [ ] Can add/log feed entries
- [ ] Can view blind feed schedule
- [ ] Can record harvest
- [ ] Can delete farm (should delete all related data)

### Performance Tests
- [ ] App starts in < 3 seconds
- [ ] Loading data takes < 2 seconds
- [ ] No UI freezes when working with data
- [ ] No memory leaks (watch RAM in Android Studio)

### Security Tests
- [ ] Can only see own farm data (after login)
- [ ] Can't access other users' farms via URL tricks
- [ ] RLS policies enforce proper access control

---

## Phase 6: Deployment

### For Testing/Staging
1. Build APK with `flutter build apk --release`
2. Share `build/app/outputs/flutter-apk/app-release.apk` for testing

### For Production
1. Follow [Google Play Store guidelines](https://play.google.com/console)
2. Build App Bundle: `flutter build appbundle --release`
3. Upload to Play Store
4. Monitor crash reports and user feedback

---

## Troubleshooting

### Problem: App Shows Blank Screen
```
Solution:
1. Check Supabase connection in console
2. Run: DIAGNOSTIC.sql in Supabase
3. Verify tables exist and have data
4. Check RLS policies aren't blocking queries
```

### Problem: "Column not found" Error
```
Solution:
1. Run: MIGRATION_SAFE.sql in Supabase
2. Verify schema with DIAGNOSTIC.sql
3. Restart the app
```

### Problem: Login fails
```
Solution:
1. Check Supabase Auth is enabled
2. Verify anon key is correct
3. Check SUPABASE_URL and SUPABASE_ANON_KEY are passed correctly
```

### Problem: RLS Errors
```
Solution:
1. Run: FIX_RLS_POLICIES.sql
2. Verify all tables have policies
3. Test with RLS disabled first, then re-enable
```

---

## Quick Reference

| File | Purpose |
|------|---------|
| `supabase_schema_updated.sql` | Complete schema for fresh projects |
| `MIGRATION_SAFE.sql` | Safe migration for existing projects |
| `DIAGNOSTIC.sql` | Check what exists in your database |
| `FIX_RLS_POLICIES.sql` | Fix RLS policy issues |
| `build.sh` | Helper script to build APK |

---

## Support

If issues persist:
1. Check the console for specific error messages
2. Verify Supabase credentials are correct
3. Run diagnostics: `DIAGNOSTIC.sql`
4. Check network connectivity
5. Verify RLS policies are enabled on all tables
