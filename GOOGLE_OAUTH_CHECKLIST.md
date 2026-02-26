# 🔍 Google OAuth Supabase Configuration Checklist

## Issue: "Google Sign-In failed after selecting email account"

This happens when Google Accept the Google account selection, but fails to authenticate with Supabase. Follow this checklist to fix it.

---

## ✅ Checklist: Verify Supabase Google OAuth Provider

### Step 1: Login to Supabase Dashboard
```
Go to: https://app.supabase.com
Select: AquaRythu project
```

### Step 2: Navigate to Auth → Providers
```
Left Sidebar → Authentication → Providers
Look for: Google in the list
```

### Step 3: Verify Google is ENABLED
- Check if Google provider has a **green toggle** (enabled)
- If disabled (gray), click to enable it

### Step 4: Check Google OAuth Credentials ⚠️ CRITICAL

**If Google OAuth is enabled:**
1. Click on **Google** to expand the settings
2. You should see two fields:
   - **Credentials ID** (looks like: `...-qboaieml7i0hp645gugql8cveapc81ar.apps.googleusercontent.com`)
   - **API secret key** (long string)

**If either field is EMPTY:**
   - You need to get your Google credentials!
   - See Part 1 & 2 of GOOGLE_SIGNIN_SETUP.md
   - This is likely why sign-in is failing!

### Step 5: Verify Client ID Matches Your Build

Compare these two values:
```
In Supabase Dashboard (Google provider settings):
  Credentials ID = YOUR_SUPABASE_CREDS_ID

In your build command:
  --dart-define=GOOGLE_WEB_CLIENT_ID="..."

They should be the SAME!
```

If they don't match, one is wrong. Update the one that's incorrect.

---

## 🔧 Common Issues & Fixes

### Issue 1: Google Provider Shows as "Not enabled"
**Fix:**
1. Click the Google provider
2. Click the **Enable** button
3. Enter your Credentials ID and API Secret
4. Save

### Issue 2: Credentials ID / API Secret is Empty
**Fix:**
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Select your project
3. Go to **Credentials** section
4. Find your **OAuth 2.0 Client ID** (Web application type)
5. Copy the **Client ID** (Credentials ID in Supabase)
6. Copy the **Client Secret** (API secret key in Supabase)
7. Paste both into Supabase Google provider settings
8. Save

### Issue 3: Wrong Client ID Being Used
**Fix:**
Make sure you're using the **Web Client ID**, not the Android Client ID:
- ❌ Android Client ID (from Google Cloud): Used for native app sign-in
- ✅ Web Client ID (from Google Cloud): Used for backend authentication

Your build should use the **Web Client ID**:
```bash
--dart-define=GOOGLE_WEB_CLIENT_ID="1234567890-abcd...apps.googleusercontent.com"
```

### Issue 4: Supabase Doesn't Have Google Configured at All
**Fix:**
You haven't set up Google OAuth in Supabase yet:
1. Go to Supabase → Authentication → Providers
2. Click **Google**
3. Click **Enable**
4. Enter your Google credentials (see above)
5. Save
6. Rebuild your app
7. Test again

---

## 🧪 Test After Fixing

### Step 1: Rebuild APK with Google Web Client ID
```bash
cd /Users/sunny/Documents/aquarythu
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://vwdzrzdvmgoqezatjhbr.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_WEB_CLIENT_ID"
```

### Step 2: Install on Device
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Test Google Sign-In
1. Open app
2. Click "Sign in with Google"
3. Select your Google account
4. Check for error message

### Step 4: Read Error Message Carefully
- If you see an error message on screen, it tells you what's wrong
- Check logs: `adb logcat | grep GOOGLE_SIGN_IN`

---

## 📋 Complete Setup Flow

If starting from scratch:

1. **Google Cloud Console:**
   - Create project
   - Enable Google+ API
   - Create OAuth 2.0 Client ID (Android)
   - Get SHA-1 from your debug keystore
   - Create OAuth 2.0 Client ID (Web)
   - Copy Web Client ID

2. **Supabase Dashboard:**
   - Authentication → Providers → Google
   - Enable Google
   - Paste Client ID and Client Secret
   - Save

3. **Local Build:**
   - Rebuild APK with `--dart-define=GOOGLE_WEB_CLIENT_ID="..."`
   - Install on device
   - Test sign-in

4. **Debug Logs:**
   - `adb logcat | grep GOOGLE_SIGN_IN`
   - Look for errors after "Got Google user: ..."
   - Fix any reported issues

---

## ❓ Still Failing?

If you've done all these steps and it still fails:

1. **Check app logs:**
   ```bash
   adb logcat | grep -A 5 GOOGLE_SIGN_IN_ERROR
   ```

2. **Check Supabase logs:**
   - Supabase Dashboard → Logs
   - Filter by "auth"
   - See exact error from server

3. **Common remaining issues:**
   - Typo in Web Client ID
   - Supabase Google provider disabled
   - Redirect URI mismatch
   - Network connectivity issue

4. **Nuclear option:**
   - Delete OAuth client in Google Cloud
   - Create new one
   - Update Supabase with new credentials
   - Rebuild and test

---

## Need Help?

Attach the output of:
```bash
adb logcat | grep -E "GOOGLE_SIGN_IN|auth" | tail -20
```

This shows the exact error preventing sign-in!
