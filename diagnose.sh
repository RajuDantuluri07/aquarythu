#!/bin/bash

# Simple diagnostic for Google Sign-In issues

echo "🔍 Google Sign-In Diagnostic"
echo "=============================="
echo ""

# Get Android SHA1
echo "1️⃣  Your Android App SHA-1 Fingerprint:"
echo "---"
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep SHA1 || echo "❌ Debug keystore not found"
echo ""

# Check which Google Web Client ID we're using
echo "2️⃣  Google Web Client ID in Supabase:"
echo "---"
echo "782759620106-nbsdbsaqab0hb58iuie1tardmvhhogb1.apps.googleusercontent.com"
echo ""

echo "3️⃣  Steps to debug further:"
echo "---"
echo "a) Check the error message shown on your app screen"
echo "b) Compare your Android SHA-1 (from step 1) with Google Cloud Console:"
echo "   Go to: https://console.cloud.google.com/apis/credentials"
echo "   Look for: OAuth 2.0 Client IDs -> Android"
echo "   Check if SHA1 matches"
echo ""
echo "c) If SHA-1 doesn't match:"
echo "   - Delete the Android client"
echo "   - Create a new one with your correct SHA-1 from step 1"
echo "   - The Web Client ID (for Supabase) should stay the same"
echo ""

