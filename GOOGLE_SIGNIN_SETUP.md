# 🔐 Google Sign-In Setup Guide for AquaRythu

## Overview
This guide explains how to set up Google Sign-in for your AquaRythu app on Android and iOS.

---

## Part 1: Google Cloud Console Setup

### Step 1: Create/Select Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project named "AquaRythu" or select existing one
3. Enable the Google+ API:
   - Search for "Google+ API"
   - Click "Enable"

### Step 2: Create OAuth 2.0 Credentials

#### For Android:
1. Go to **Credentials** (left sidebar)
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **Android** as application type
4. You need your app's SHA-1 fingerprint. Get it by running:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   Look for the **SHA1** value (will look like: `AA:BB:CC:DD:...`)

5. Enter:
   - **Package name**: `com.example.aquarythu`
   - **SHA-1 certificate fingerprint**: (paste the SHA1 from step 4)
6. Click "Create"
7. **Copy the Web Client ID** - You'll need this!

#### For iOS (Optional - uses web flow):
1. Click **Create Credentials** → **OAuth 2.0 Client ID**
2. Select **Web application**
3. Add authorized redirect URIs:
   ```
   https://[YOUR-SUPABASE-PROJECT].supabase.co/auth/v1/callback
   ```
4. Save the Web Client ID for later

### Step 3: Also Create a Web Client ID (for backend communication)
1. Click **Create Credentials** → **OAuth 2.0 Client ID**
2. Select **Web application**
3. Add authorized redirect URIs:
   ```
   https://[YOUR-SUPABASE-PROJECT].supabase.co/auth/v1/callback
   ```
4. Copy this **Web Client ID** - you'll use it for Android builds

---

## Part 2: Supabase Configuration

Ensure Google OAuth provider is enabled in Supabase:

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your AquaRythu project
3. Go to **Authentication** → **Providers**
4. Enable **Google**
5. Enter your Google OAuth credentials:
   - **Client ID**: The Web Client ID from Google Cloud Console
   - **Client Secret**: Available in Google Cloud Console
6. Save

---

## Part 3: Build Your App

### Option A: Debug Build (Testing)
```bash
cd /Users/sunny/Documents/aquarythu

# Get your Web Client ID from Google Cloud Console
flutter build apk --debug \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your_anon_key" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_GOOGLE_WEB_CLIENT_ID_HERE"
```

### Option B: Release Build (Production)
```bash
cd /Users/sunny/Documents/aquarythu

# For release, you need the RELEASE SHA-1 fingerprint
keytool -list -v -keystore ~/.android/my-release-key.jks -alias my-key-alias

# Then build with release credentials from Google Cloud Console
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your_anon_key" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_RELEASE_WEB_CLIENT_ID"
```

### Option C: Using build.sh Script
```bash
./build.sh "https://your-project.supabase.co" "your_anon_key" "YOUR_WEB_CLIENT_ID"
```

---

## Part 4: Testing Google Sign-In

### Step 1: Install the APK
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Step 2: Run the App
1. Open AquaRythu app on your Android device
2. Tap "Sign in with Google"
3. You should see Google's sign-in screen

### Step 3: Check Logs for Errors
```bash
adb logcat | grep GOOGLE_SIGN_IN
```

Look for messages like:
- `[GOOGLE_SIGN_IN] Starting sign-in with webClientId: ...` ✅ Good
- `[GOOGLE_SIGN_IN_ERROR]` ❌ Error - check message

---

## Troubleshooting

### Error: "Google Sign-In failed after selecting email account"
This happens when Supabase Google OAuth provider isn't configured correctly.
**See [GOOGLE_OAUTH_CHECKLIST.md](GOOGLE_OAUTH_CHECKLIST.md) for step-by-step verification.**

### Error: "GOOGLE_WEB_CLIENT_ID is not configured"
- **Fix**: You didn't pass `--dart-define=GOOGLE_WEB_CLIENT_ID=...` to the build command
- Check your build command matches the examples above

### Error: "Sign-in attempt failed with error: AUTHENTICATION_FAILED"
- **Cause**: SHA-1 fingerprint doesn't match Google Cloud Console
- **Fix**: 
  1. Get your app's SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
  2. Update it in Google Cloud Console
  3. Wait 5-10 minutes for changes to propagate
  4. Rebuild and test again

### Error: "User canceled sign-in"
- **Normal behavior** - user just closed the sign-in dialog
- Try again and complete the sign-in flow

### Error: "Network error"
- **Fix**: Ensure your device has internet connectivity
- Ensure `INTERNET` permission is in AndroidManifest.xml (already added)

### Error: "Cannot sign in - check Supabase config"
- **Fix**: Verify Google provider is enabled in Supabase
- Check your Supabase URL and Anon Key are correct
- Ensure Web Client ID matches between Google Cloud and Supabase

### Error in Console: "[GOOGLE_SIGN_IN] Got Google user: ..."
- But then fails at Supabase sign-in
- **Fix**: Check your Supabase Google provider configuration
- Verify the Web Client ID in Supabase matches Google Cloud Console

---

## Quick Reference: Build Commands

### Development/Testing:
```bash
flutter build apk --debug \
  --dart-define=SUPABASE_URL="https://vwdzrzdvmgoqezatjhbr.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_GOOGLE_WEB_CLIENT_ID"
```

### Release/Production:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://vwdzrzdvmgoqezatjhbr.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_RELEASE_WEB_CLIENT_ID"
```

---

## Next Steps

1. ✅ Add INTERNET permissions (Already done)
2. 📋 Get your Google Web Client ID from Google Cloud Console
3. 🏗️ Rebuild with `--dart-define=GOOGLE_WEB_CLIENT_ID=...`
4. 📱 Test on Android device
5. ✅ Verify in app logs: `[GOOGLE_SIGN_IN]` messages

Good luck! 🚀
