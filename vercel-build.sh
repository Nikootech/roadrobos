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

# 2. Build compile-time configurations (.dart_defines) from Vercel environment variables
echo "Generating .dart_defines file..."
cat <<EOF > .dart_defines
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
RAZORPAY_KEY_ID=$RAZORPAY_KEY_ID
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
MAPS_API_KEY=$MAPS_API_KEY
ENV=prod
EOF

# 3. Clean and get dependencies
echo "Cleaning workspace and downloading dependencies..."
flutter clean
flutter pub get

# 4. Build Flutter web release
echo "Building Flutter Web application (Release)..."
flutter build web --release --dart-define-from-file=.dart_defines --no-tree-shake-icons

echo "=========================================="
echo "    Build Completed Successfully!         "
echo "=========================================="
