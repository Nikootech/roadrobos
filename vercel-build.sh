#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=========================================="
echo "      RoadRobos Vercel Build Script       "
echo "=========================================="

# Define Flutter channel
FLUTTER_CHANNEL="stable"

# 1. Download and set up Flutter SDK if not already present
if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK ($FLUTTER_CHANNEL)..."
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_CHANNEL --depth 1
else
  echo "Flutter SDK directory found. Updating..."
  cd flutter
  git fetch
  git checkout $FLUTTER_CHANNEL
  git pull
  cd ..
fi

# Add Flutter to path
export PATH="$PATH:$(pwd)/flutter/bin"

# Verify Flutter installation
echo "Checking Flutter version..."
flutter --version

# Enable Web support
flutter config --enable-web

# 2. Validate Vercel environment variables
echo "Validating environment variables..."
CRITICAL_MISSING=0

# Critical variables (must be present for the app to function)
for VAR in SUPABASE_URL SUPABASE_ANON_KEY; do
  if [ -z "${!VAR}" ]; then
    echo "  ❌ ERROR: Critical environment variable '$VAR' is not set in Vercel."
    CRITICAL_MISSING=1
  else
    echo "  ✅ $VAR is set."
  fi
done

# Optional/Service integration variables (warnings only)
for VAR in RAZORPAY_KEY_ID GOOGLE_CLIENT_ID MAPS_API_KEY FIREBASE_API_KEY_WEB SENTRY_DSN; do
  if [ -z "${!VAR}" ]; then
    echo "  ⚠️ WARNING: Optional environment variable '$VAR' is not set. Integrations using this key may fail at runtime."
  else
    echo "  ✅ $VAR is set."
  fi
done

if [ "$CRITICAL_MISSING" -eq 1 ]; then
  echo ""
  echo "Build aborted: Critical environment variables are missing."
  echo "Please add SUPABASE_URL and SUPABASE_ANON_KEY in Vercel Dashboard → Project → Settings → Environment Variables."
  exit 1
fi

# 3. Build compile-time configurations (.dart_defines) from Vercel environment variables
echo "Generating .dart_defines file..."
cat <<EOF > .dart_defines
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
MAPS_API_KEY=$MAPS_API_KEY
SENTRY_DSN=$SENTRY_DSN
FIREBASE_API_KEY_WEB=$FIREBASE_API_KEY_WEB
ENV=prod
EOF

# 4. Clean and get dependencies
echo "Cleaning workspace and downloading dependencies..."
flutter clean
flutter pub get

# 5. Build Flutter web release
echo "Building Flutter Web application (Release)..."
flutter build web --release --dart-define-from-file=.dart_defines --no-tree-shake-icons

echo "=========================================="
echo "    Build Completed Successfully!         "
echo "=========================================="
