# Cross Launch

A tool for simplifying cross-platform Flutter mobile releases.

## Releasing

### MacOS

To release Cross Launch itself, do the following.

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
