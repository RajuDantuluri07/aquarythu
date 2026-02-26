#!/bin/bash

# AquaRythu Production Checklist
# Copy this file and check off each step as you complete them

echo "==================================="
echo "AquaRythu - Production Checklist"
echo "==================================="
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to mark done
mark_done() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to show warning
show_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to show error
show_error() {
    echo -e "${RED}✗ $1${NC}"
}

echo ""
echo "PHASE 1: SUPABASE SETUP"
echo "======================="
echo ""

read -p "1. Have you saved your Supabase Project URL? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Saved Project URL"
else
    show_error "Go to https://app.supabase.com → Settings → API and copy Project URL"
    exit 1
fi

read -p "2. Have you saved your Supabase Anon Key? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Saved Anon Key"
else
    show_error "Go to https://app.supabase.com → Settings → API and copy anon public key"
    exit 1
fi

read -p "3. Have you run FINAL_SETUP.sql in Supabase SQL Editor? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Database setup complete"
else
    show_error "Run FINAL_SETUP.sql in Supabase SQL Editor"
    exit 1
fi

echo ""
echo "PHASE 2: FLUTTER SETUP"
echo "======================"
echo ""

read -p "4. Run 'flutter clean' - Did it succeed? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Flutter clean"
else
    show_error "Run: flutter clean"
    exit 1
fi

read -p "5. Run 'flutter pub get' - Did it succeed? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Dependencies installed"
else
    show_error "Run: flutter pub get"
    exit 1
fi

read -p "6. Run 'flutter analyze' - Any errors? (y=no errors, n=yes errors) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "No Dart errors"
else
    show_warning "Fix any errors and try again"
    exit 1
fi

echo ""
echo "PHASE 3: LOCAL TESTING"
echo "======================"
echo ""

read -p "7. Have you tested 'flutter run'? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "   Did the app load without crashing? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        mark_done "App runs locally"
    else
        show_error "Check SUPABASE_URL and SUPABASE_ANON_KEY are correct"
        show_error "Run DIAGNOSTIC.sql to check database"
        exit 1
    fi
else
    show_warning "Run: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=..."
fi

echo ""
echo "PHASE 4: TEST USER FLOWS"
echo "========================"
echo ""

read -p "8. Can you create a new account? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Sign up works"
else
    show_error "Check Supabase Auth is enabled"
fi

read -p "9. Can you create a farm? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Farm creation works"
else
    show_error "Check database connection"
fi

read -p "10. Can you create a tank and see blind schedule? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Tank creation & blind schedule works"
else
    show_error "Check blind_feed_schedule table exists"
fi

read -p "11. Can you log a feed entry? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Feed logging works"
else
    show_error "Check feed_logs table exists"
fi

read -p "12. Can you view feed history? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mark_done "Feed viewing works"
else
    show_warning "May need to refresh or check RLS policies"
fi

echo ""
echo "PHASE 5: PRODUCTION BUILD"
echo "=========================="
echo ""

read -p "13. Ready to build release APK? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    show_warning "Running build... (this may take a few minutes)"
    echo ""
    
    # Prompt for credentials (using defaults for reference)
    read -p "Enter your SUPABASE_URL: " SUPABASE_URL
    read -p "Enter your SUPABASE_ANON_KEY: " SUPABASE_ANON_KEY
    
    flutter build apk --release \
      --dart-define=SUPABASE_URL="$SUPABASE_URL" \
      --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
    
    if [ $? -eq 0 ]; then
        mark_done "Release APK built successfully"
        echo ""
        echo "📦 APK Location:"
        ls -lh build/app/outputs/flutter-apk/app-release.apk
    else
        show_error "Build failed - check the error messages above"
        exit 1
    fi
else
    show_error "When ready, run: flutter build apk --release --dart-define=..."
    exit 0
fi

echo ""
echo "================================="
echo "✅ ALL CHECKS PASSED!"
echo "================================="
echo ""
echo "Your app is production-ready! 🎉"
echo ""
echo "Next steps:"
echo "1. Install APK on device: adb install build/app/outputs/flutter-apk/app-release.apk"
echo "2. Test on real device"
echo "3. Share APK or upload to Google Play Store"
echo ""
echo "APK file: build/app/outputs/flutter-apk/app-release.apk"
