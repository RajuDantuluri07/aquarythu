#!/bin/bash

# ========================================
# AquaRythu Production Setup & Build Guide
# ========================================

echo "🚀 AquaRythu - Production Ready Setup"
echo "======================================"
echo ""

# Step 1: Check Flutter environment
echo "✓ Checking Flutter environment..."
flutter --version

# Step 2: Get dependencies
echo ""
echo "✓ Getting dependencies..."
flutter pub get

# Step 3: Run analyzer to check for errors
echo ""
echo "✓ Running Dart analyzer..."
flutter analyze

# Step 4: Clean build
echo ""
echo "✓ Cleaning previous builds..."
flutter clean

# Step 5: Build APK with required environment variables
echo ""
echo "📱 Building Production APK..."
echo ""
echo "⚠️  IMPORTANT: You need your Supabase credentials and Google Web Client ID:"
echo "   1. Supabase: Go to https://app.supabase.com → Settings → API"
echo "   2. Google: Go to Google Cloud Console → Credentials"
echo "   3. See GOOGLE_SIGNIN_SETUP.md for detailed instructions"
echo ""
echo "Then run:"
echo ""
echo 'flutter build apk --release \'
echo '  --dart-define=SUPABASE_URL=https://your-project.supabase.co \'
echo '  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here \'
echo '  --dart-define=GOOGLE_WEB_CLIENT_ID=your_google_web_client_id'
echo ""
echo "Or run this script with arguments:"
echo "  ./build.sh <SUPABASE_URL> <SUPABASE_ANON_KEY> <GOOGLE_WEB_CLIENT_ID>"
echo ""

# If arguments provided, build automatically
if [ -n "$1" ] && [ -n "$2" ] && [ -n "$3" ]; then
  echo "Building with provided credentials..."
  flutter build apk --release \
    --dart-define=SUPABASE_URL="$1" \
    --dart-define=SUPABASE_ANON_KEY="$2" \
    --dart-define=GOOGLE_WEB_CLIENT_ID="$3"
  
  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
  else
    echo ""
    echo "❌ Build failed. Check the error messages above."
  fi
elif [ -n "$1" ] && [ -n "$2" ]; then
  # Legacy: Only Supabase credentials provided (no Google)
  echo "⚠️  Building without Google Web Client ID (Google Sign-in disabled)"
  flutter build apk --release \
    --dart-define=SUPABASE_URL="$1" \
    --dart-define=SUPABASE_ANON_KEY="$2"
  
  if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "⚠️  Note: Google Sign-in is disabled. See GOOGLE_SIGNIN_SETUP.md to enable it."
  else
    echo ""
    echo "❌ Build failed. Check the error messages above."
  fi
fi
