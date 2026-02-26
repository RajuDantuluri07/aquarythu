# 🗺️ Google Sign-In Architecture Overview

## Complete Flow: From App to Supabase

```
┌─────────────────────────────────────────────────────────────────┐
│                        AquaRythu App                            │
│                      (Running on Device)                        │
│                                                                 │
│  1. User taps "Sign in with Google"                            │
│  2. GoogleSignIn() opens Google's authentication dialog        │
│  3. User selects email account                                 │
│  4. User grants permissions                                    │
│  5. Google returns: ID Token + Access Token                    │
│                                                                 │
│  ⚠️  THIS IS WHERE IT FAILS FOR YOU ↓                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ ID Token + Access Token
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              Supabase Auth Service (in Cloud)                   │
│                                                                 │
│  1. Receives ID Token from app                                 │
│  2. Validates token with Google (using Web Client Credentials) │
│  3. ⚠️  IF VALIDATION FAILS → Returns error                   │
│  4. ⚠️  IF VALIDATION SUCCEEDS → Creates user session         │
│  5. Returns session to app                                     │
│                                                                 │
│  🔑 Requirements:                                              │
│    - Google OAuth Provider ENABLED in Supabase                 │
│    - Credentials ID (Client ID) configured                     │
│    - API Secret Key configured                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Session or Error
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        AquaRythu App                            │
│                                                                 │
│  If successful:                                                │
│    → User logged in, navigate to dashboard                     │
│                                                                 │
│  If error:                                                     │
│    → Show error message (now improved!)                        │
│    → User can read what went wrong                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Credentials Flow: Which ID Goes Where?

```
Google Cloud Console
│
├─ OAuth 2.0 Client ID (Android)
│  └─ Used by: google_sign_in package
│  └─ Got: SHA-1 in Google Cloud console
│  └─ NOT needed in code (package handles it)
│
└─ OAuth 2.0 Client ID (Web) ← THIS IS THE IMPORTANT ONE
   │
   ├─ Copy "Client ID"
   │  └─ Paste in: Supabase → Auth → Providers → Google → Credentials ID
   │  └─ Also use in: flutter build --dart-define=GOOGLE_WEB_CLIENT_ID="..."
   │
   └─ Copy "Client Secret"
      └─ Paste in: Supabase → Auth → Providers → Google → API Secret Key
```

---

## Configuration Checklist: What Must Be Set Up

### Google Cloud Console ✅
```
Project: AquaRythu
├─ Google+ API: ENABLED
├─ OAuth Consent Screen: Configured
└─ Credentials:
   ├─ Android Client ID: Created (with your SHA-1)
   └─ Web Client ID: Created ← COPY THIS
```

### Supabase Dashboard ✅
```
Project: AquaRythu
└─ Authentication → Providers → Google:
   ├─ Status: ENABLED (green toggle)
   ├─ Credentials ID: [Paste Web Client ID from Google]
   └─ API Secret: [Paste Client Secret from Google]
```

### AquaRythu App Build ✅
```
Build Command:
  flutter build apk --release \
    --dart-define=SUPABASE_URL="https://vwdzr...supabase.co" \
    --dart-define=SUPABASE_ANON_KEY="sb_publishable_z..." \
    --dart-define=GOOGLE_WEB_CLIENT_ID="[Web Client ID]"
```

---

## Why It's Failing

Your app gets to "selecting email account" because:
- ✅ Android Client ID is working (Google recognized the app)
- ✅ User selected an account

But it fails after because:
- ❌ Supabase doesn't have Google OAuth provider configured, OR
- ❌ Credentials ID / API Secret not filled in Supabase, OR
- ❌ Wrong credentials filled in Supabase, OR
- ❌ Network/permission issue with Supabase

---

## How to Fix It

1. **Go to Supabase**: https://app.supabase.com/project/aquarythu/auth/providers
2. **Check Google provider status**:
   - Is it ENABLED? (green)
   - Are Credentials ID and API Secret FILLED? (not empty)
3. **If empty**, follow GOOGLE_QUICK_FIX.md
4. **Rebuild app** with correct Web Client ID
5. **Test again**

---

## Live Debugging

To see the actual error message:

```bash
./debug_google_signin.sh
```

This shows you exactly what Supabase is returning.

---

## Still Stuck?

Check these files in order:
1. [GOOGLE_QUICK_FIX.md](GOOGLE_QUICK_FIX.md) - 2-minute fix
2. [GOOGLE_OAUTH_CHECKLIST.md](GOOGLE_OAUTH_CHECKLIST.md) - Complete verification
3. [GOOGLE_SIGNIN_SETUP.md](GOOGLE_SIGNIN_SETUP.md) - Detailed reference
