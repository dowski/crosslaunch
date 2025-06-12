# Cross Launch

A tool for simplifying cross-platform Flutter mobile releases.

## Releasing

Official releases will be found only on https://crosslaunch.dev.

### MacOS

Before you release, ensure you have a valid `config.sh` file.
See `config.sh.example` for what it should contain.

To release Cross Launch itself, do the following (yes, the manual steps are somewhat ironic).

1. `flutter build macos --release`
2. `./sign-app.sh` to sign the release
3. `cd build/macos/Build/Products/Release`
4. `ditto -c -k --keepParent "Cross Launch.app" "Cross Launch.zip"`
5. Run the following:

    ```
    xcrun notarytool submit "Cross Launch.zip" \
    --keychain-profile "notarization-profile" \
    --wait
    ```
6. `xcrun stapler staple "Cross Launch.app"`
7. `spctl --assess --verbose "Cross Launch.app"`
8. `../../../../../create-dmg.sh`
9. `xcrun notarytool submit "Cross Launch.dmg" --keychain-profile "notarization-profile" --wait`
10. `xcrun stapler staple "Cross Launch.dmg"`

That DMG file can be distributed as you see fit.

## Terms

Cross Launch - Simplify Flutter Releases

Copyright (C) 2025 Christian Wyglendowski

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.