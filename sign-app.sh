#!/bin/bash

# Source the private config file, exit if it doesn't exist
if [[ -f "./config.sh" ]]; then
    source ./config.sh
else
    echo "Error: config.sh not found. Please create it with your developer credentials."
    echo "Example: echo 'SIGNING_IDENTITY=\"Developer ID Application: Your Name (TEAMID)\"' > config.sh"
    exit 1
fi

# Configuration
APP_NAME="Cross Launch.app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
RELEASE_DIR="$PROJECT_ROOT/build/macos/Build/Products/Release"
ENTITLEMENTS="$PROJECT_ROOT/macos/Runner/Release.entitlements"

# Check if the app exists
if [ ! -d "$RELEASE_DIR/$APP_NAME" ]; then
    echo "Error: $APP_NAME not found in $RELEASE_DIR"
    echo "Please run 'flutter build macos --release' first."
    exit 1
fi

# Check if entitlements file exists
if [ ! -f "$ENTITLEMENTS" ]; then
    echo "Error: Entitlements file not found at $ENTITLEMENTS"
    exit 1
fi

echo "Signing $APP_NAME..."
echo "Release directory: $RELEASE_DIR"
echo "Entitlements: $ENTITLEMENTS"

# Change to the release directory
cd "$RELEASE_DIR"

# Sign all frameworks
echo "Signing frameworks..."
find "$APP_NAME/Contents/Frameworks" -name "*.framework" -exec \
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" {} \;

# Sign the main app
echo "Signing main application..."
codesign --force --options runtime --timestamp \
  --entitlements "$ENTITLEMENTS" \
  --sign "$SIGNING_IDENTITY" \
  "$APP_NAME"

echo "Signing complete. Verifying..."
codesign --verify --deep --strict --verbose=2 "$APP_NAME"

if [ $? -eq 0 ]; then
    echo "✅ App successfully signed and verified!"
    echo "Location: $RELEASE_DIR/$APP_NAME"
else
    echo "❌ Verification failed!"
    exit 1
fi