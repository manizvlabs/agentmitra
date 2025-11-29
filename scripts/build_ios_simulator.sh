#!/bin/bash

# Custom iOS Simulator Build Script
# This script bypasses Flutter's packaging issues by using Xcode directly

set -e

echo "🚀 Building Flutter app for iOS Simulator..."

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$PROJECT_DIR/ios"
WORKSPACE="$IOS_DIR/Runner.xcworkspace"
SCHEME="Runner"

echo "📁 Project directory: $PROJECT_DIR"
echo "📱 iOS directory: $IOS_DIR"

# Ensure we're in the project directory
cd "$PROJECT_DIR"

# Clean Flutter build artifacts
echo "🧹 Cleaning Flutter build artifacts..."
flutter clean

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build using xcodebuild directly with NO_FLUTTER_BUILD flag
echo "🔨 Building with Xcode..."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export NO_FLUTTER_BUILD=true

xcodebuild \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
  -derivedDataPath "$IOS_DIR/build" \
  ONLY_ACTIVE_ARCH=YES \
  build

echo "✅ iOS Simulator build completed successfully!"
echo ""
echo "🎯 To run the app:"
echo "1. Open Xcode: open $WORKSPACE"
echo "2. Select iPhone 15 Pro simulator"
echo "3. Click Run (▶️) or press Cmd+R"
echo ""
echo "📱 The app should launch on the iPhone simulator!"
