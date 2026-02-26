# ⚡ Quick Fix: Google Sign-In Failing After Account Selection

## Most Common Cause
**Google OAuth provider is NOT configured in Supabase.**

---

## 🚀 Quick Fix (2 minutes)

### Step 1: Check Supabase Google Provider
1. Go to: https://app.supabase.com
2. Select: AquaRythu project
3. Click: **Authentication** (left sidebar)
4. Click: **Providers**
5. Look for **Google** in the list

### Step 2: Is Google Provider Enabled?

#### If you see Google with a GREEN toggle/badge:
- ✅ It's enabled
- Check if **Credentials ID** and **API Secret** fields are filled
  - If empty → **See Step 3: Fill in credentials**
  - If filled → Problem is elsewhere, see "Advanced Troubleshooting" below

#### If you see Google but it's DISABLED (gray toggle):
- ❌ Google OAuth isn't enabled
- Click on **Google** to expand it
- Click **Enable**
- Fill in credentials (see Step 3)
- **Save**

#### If you DON'T see Google at all:
- ❌ Google provider isn't configured
- Click **Add New Provider**
- Select **Google**
- Fill in credentials (see Step 3)
- **Save**

### Step 3: Get Your Google Credentials

**You need your Web Client ID and Secret from Google Cloud Console:**

1. Go to: https://console.cloud.google.com/
2. Select your project (AquaRythu)
3. Click **Credentials** (left sidebar)
4. Find your OAuth 2.0 Client ID with type **"Web application"**
5. Click it to open details
6. Copy:
   - **Client ID** → Paste in Supabase as **Credentials ID**
   - **Client Secret** → Paste in Supabase as **API Secret**
7. **Save in Supabase**

### Step 4: Rebuild Your App

```bash
cd /Users/sunny/Documents/aquarythu
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=SUPABASE_URL="https://vwdzrzdvmgoqezatjhbr.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="sb_publishable_z_5942T3HoGRt-eXcVcU5w_Isd3pDVz" \
  --dart-define=GOOGLE_WEB_CLIENT_ID="184259519546-qboaieml7i0hp645gugql8cveapc81ar.apps.googleusercontent.com"
```

### Step 5: Test Again

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Then try signing in with Google again.

---

## 🔍 Advanced Troubleshooting

If the quick fix didn't work, run this to see the actual error:

```bash
cd /Users/sunny/Documents/aquarythu
chmod +x debug_google_signin.sh
./debug_google_signin.sh
```

**While the script is running:**
1. Open the app
2. Click "Sign in with Google"
3. Select your email
4. Watch the logs for error messages

The error message will tell you exactly what's wrong!

---

## 📋 Verify Supabase Configuration

Open this file to verify all settings:
[GOOGLE_OAUTH_CHECKLIST.md](GOOGLE_OAUTH_CHECKLIST.md)

It has a complete checklist of everything that needs to be configured.

---

## Key Points

✅ **Google Web Client ID** (from Google Cloud Console) → Used in app build
  ```
  --dart-define=GOOGLE_WEB_CLIENT_ID="YOUR_WEB_CLIENT_ID"
  ```

✅ **Google OAuth Credentials in Supabase** → Used for backend authentication
  - Client ID (Credentials ID)
  - Client Secret (API Secret Key)

✅ **Both must be configured** for Google Sign-In to work!

---

## Need More Help?

See these detailed guides:
- [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) - Complete setup instructions
- [GOOGLE_OAUTH_CHECKLIST.md](GOOGLE_OAUTH_CHECKLIST.md) - Full verification checklist
