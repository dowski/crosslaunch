#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
RELEASE_DIR="$PROJECT_ROOT/build/macos/Build/Products/Release"

# Create DMG contents directory in the release dir
DMG_CONTENTS="$RELEASE_DIR/dmg_contents"
mkdir -p "$DMG_CONTENTS"

# Copy app and licenses
cp -R "$RELEASE_DIR/Cross Launch.app" "$DMG_CONTENTS/"
cp "$PROJECT_ROOT/LICENSE.txt" "$DMG_CONTENTS/"

# Create DMG in the release directory
cd "$RELEASE_DIR"
hdiutil create -volname "Cross Launch" -srcfolder "dmg_contents" -ov -format UDZO "Cross Launch.dmg"

# Clean up
rm -rf "$DMG_CONTENTS"

echo "DMG created at $RELEASE_DIR/Cross Launch.dmg"