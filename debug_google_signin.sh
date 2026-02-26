#!/bin/bash

# Google Sign-In Debug Helper
# Usage: ./debug_google_signin.sh

echo "🔍 Google Sign-In Debug Helper"
echo "=============================="
echo ""
echo "This script helps diagnose Google Sign-in failures."
echo ""

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ adb not found. Install Android SDK Platform Tools."
    echo "   Download from: https://developer.android.com/tools/releases/platform-tools"
    exit 1
fi

# Check if device is connected
echo "📱 Checking for connected devices..."
device_count=$(adb devices | grep -c "device$")

if [ "$device_count" -eq 0 ]; then
    echo "❌ No Android device connected."
    echo "   Connect a device via USB and enable Developer Mode."
    exit 1
fi

echo "✅ Device found"
echo ""

# Clear previous logs
echo "🗑️  Clearing logcat..."
adb logcat -c
echo ""

echo "📝 App logs (showing GOOGLE_SIGN_IN messages):"
echo "================================================"
echo ""
echo "Now perform these steps in your app:"
echo "  1. Click 'Sign in with Google'"
echo "  2. Select your Google account"
echo "  3. Watch below for error messages"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Show logs with GOOGLE_SIGN_IN filter
adb logcat | grep -E "GOOGLE_SIGN_IN|auth|error" --color=auto
