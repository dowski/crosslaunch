const iosInfoPlist = r'''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>$(DEVELOPMENT_LANGUAGE)</string>
        <key>CFBundleDisplayName</key>
        <string>flutter_app</string>
        <key>CFBundleExecutable</key>
        <string>$(EXECUTABLE_NAME)</string>
        <key>CFBundleIdentifier</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>flutter_app</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>$(FLUTTER_BUILD_NAME)</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>CFBundleVersion</key>
        <string>$(FLUTTER_BUILD_NUMBER)</string>
        <key>LSRequiresIPhoneOS</key>
        <true/>
        <key>UILaunchStoryboardName</key>
        <string>LaunchScreen</string>
        <key>UIMainStoryboardFile</key>
        <string>Main</string>
        <key>UISupportedInterfaceOrientations</key>
        <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
        </array>
        <key>UISupportedInterfaceOrientations~ipad</key>
        <array>
                <string>UIInterfaceOrientationPortrait</string>
                <string>UIInterfaceOrientationPortraitUpsideDown</string>
                <string>UIInterfaceOrientationLandscapeLeft</string>
                <string>UIInterfaceOrientationLandscapeRight</string>
        </array>
        <key>CADisableMinimumFrameDurationOnPhone</key>
        <true/>
        <key>UIApplicationSupportsIndirectInputEvents</key>
        <true/>
</dict>
</plist>
''';

const androidManifest = r'''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="flutter_app"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
''';

const androidAppBuildGradle = r'''
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
''';

const iosXcodeProjectSrc = r'''
// !$*UTF8*$!
{
        archiveVersion = 1;
        classes = {
        };
        objectVersion = 54;
        objects = {

/* Begin PBXBuildFile section */
                1498D2341E8E89220040F4C2 /* GeneratedPluginRegistrant.m in Sources */ = {isa = PBXBuildFile; fileRef = 1498D2331E8E89220040F4C2 /* GeneratedPluginRegistrant.m */; };
                331C808B294A63AB00263BE5 /* RunnerTests.swift in Sources */ = {isa = PBXBuildFile; fileRef = 331C807B294A618700263BE5 /* RunnerTests.swift */; };
                3B3967161E833CAA004F5970 /* AppFrameworkInfo.plist in Resources */ = {isa = PBXBuildFile; fileRef = 3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */; };
                5B2CE16267DFDCC6F8DA5EDD /* Pods_Runner.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 8418F77604F9D5E868FFAD46 /* Pods_Runner.framework */; };
                74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = 74858FAE1ED2DC5600515810 /* AppDelegate.swift */; };
                97C146FC1CF9000F007C117D /* Main.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FA1CF9000F007C117D /* Main.storyboard */; };
                97C146FE1CF9000F007C117D /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FD1CF9000F007C117D /* Assets.xcassets */; };
                97C147011CF9000F007C117D /* LaunchScreen.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = 97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */; };
                9B097992A01151F4DDCC6BA6 /* Pods_RunnerTests.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = D6EC864A7F478CE45023EC9E /* Pods_RunnerTests.framework */; };
/* End PBXBuildFile section */

/* Begin PBXContainerItemProxy section */
                331C8085294A63A400263BE5 /* PBXContainerItemProxy */ = {
                        isa = PBXContainerItemProxy;
                        containerPortal = 97C146E61CF9000F007C117D /* Project object */;
                        proxyType = 1;
                        remoteGlobalIDString = 97C146ED1CF9000F007C117D;
                        remoteInfo = Runner;
                };
/* End PBXContainerItemProxy section */

/* Begin PBXCopyFilesBuildPhase section */
                9705A1C41CF9048500538489 /* Embed Frameworks */ = {
                        isa = PBXCopyFilesBuildPhase;
                        buildActionMask = 2147483647;
                        dstPath = "";
                        dstSubfolderSpec = 10;
                        files = (
                        );
                        name = "Embed Frameworks";
                        runOnlyForDeploymentPostprocessing = 0;
                };
/* End PBXCopyFilesBuildPhase section */

/* Begin PBXFileReference section */
                0C53DFEEFB42B51826FB45E3 /* Pods-RunnerTests.release.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.release.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.release.xcconfig"; sourceTree = "<group>"; };
                1498D2321E8E86230040F4C2 /* GeneratedPluginRegistrant.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = GeneratedPluginRegistrant.h; sourceTree = "<group>"; };
                1498D2331E8E89220040F4C2 /* GeneratedPluginRegistrant.m */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.c.objc; path = GeneratedPluginRegistrant.m; sourceTree = "<group>"; };
                331C807B294A618700263BE5 /* RunnerTests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = RunnerTests.swift; sourceTree = "<group>"; };
                331C8081294A63A400263BE5 /* RunnerTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = RunnerTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
                3A8F2DA6DEB62FFC2E8D2164 /* Pods-Runner.debug.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.debug.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"; sourceTree = "<group>"; };
                3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; name = AppFrameworkInfo.plist; path = Flutter/AppFrameworkInfo.plist; sourceTree = "<group>"; };
                486594D03E86941A37299F1C /* Pods-RunnerTests.profile.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.profile.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.profile.xcconfig"; sourceTree = "<group>"; };
                58A5E47B0B4670E2069A1355 /* Pods-Runner.profile.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.profile.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"; sourceTree = "<group>"; };
                74858FAD1ED2DC5600515810 /* Runner-Bridging-Header.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = "Runner-Bridging-Header.h"; sourceTree = "<group>"; };
                74858FAE1ED2DC5600515810 /* AppDelegate.swift */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
                77B58FA963D428A1AB029571 /* Pods-RunnerTests.debug.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-RunnerTests.debug.xcconfig"; path = "Target Support Files/Pods-RunnerTests/Pods-RunnerTests.debug.xcconfig"; sourceTree = "<group>"; };
                7AFA3C8E1D35360C0083082E /* Release.xcconfig */ = {isa = PBXFileReference; lastKnownFileType = text.xcconfig; name = Release.xcconfig; path = Flutter/Release.xcconfig; sourceTree = "<group>"; };
                8418F77604F9D5E868FFAD46 /* Pods_Runner.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_Runner.framework; sourceTree = BUILT_PRODUCTS_DIR; };
                9740EEB21CF90195004384FC /* Debug.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; name = Debug.xcconfig; path = Flutter/Debug.xcconfig; sourceTree = "<group>"; };
                9740EEB31CF90195004384FC /* Generated.xcconfig */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.xcconfig; name = Generated.xcconfig; path = Flutter/Generated.xcconfig; sourceTree = "<group>"; };
                97C146EE1CF9000F007C117D /* Runner.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Runner.app; sourceTree = BUILT_PRODUCTS_DIR; };
                97C146FB1CF9000F007C117D /* Base */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; name = Base; path = Base.lproj/Main.storyboard; sourceTree = "<group>"; };
                97C146FD1CF9000F007C117D /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
                97C147001CF9000F007C117D /* Base */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; name = Base; path = Base.lproj/LaunchScreen.storyboard; sourceTree = "<group>"; };
                97C147021CF9000F007C117D /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
                CE5635382C6EED5EF16D4DAB /* Pods-Runner.release.xcconfig */ = {isa = PBXFileReference; includeInIndex = 1; lastKnownFileType = text.xcconfig; name = "Pods-Runner.release.xcconfig"; path = "Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"; sourceTree = "<group>"; };
                D6EC864A7F478CE45023EC9E /* Pods_RunnerTests.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = Pods_RunnerTests.framework; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
                97C146EB1CF9000F007C117D /* Frameworks */ = {
                        isa = PBXFrameworksBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                                5B2CE16267DFDCC6F8DA5EDD /* Pods_Runner.framework in Frameworks */,
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
                DF7547F8A7FE047CD8BA3558 /* Frameworks */ = {
                        isa = PBXFrameworksBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                                9B097992A01151F4DDCC6BA6 /* Pods_RunnerTests.framework in Frameworks */,
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
                014B30AE4D9DF1E11EB1540F /* Pods */ = {
                        isa = PBXGroup;
                        children = (
                                3A8F2DA6DEB62FFC2E8D2164 /* Pods-Runner.debug.xcconfig */,
                                CE5635382C6EED5EF16D4DAB /* Pods-Runner.release.xcconfig */,
                                58A5E47B0B4670E2069A1355 /* Pods-Runner.profile.xcconfig */,
                                77B58FA963D428A1AB029571 /* Pods-RunnerTests.debug.xcconfig */,
                                0C53DFEEFB42B51826FB45E3 /* Pods-RunnerTests.release.xcconfig */,
                                486594D03E86941A37299F1C /* Pods-RunnerTests.profile.xcconfig */,
                        );
                        name = Pods;
                        path = Pods;
                        sourceTree = "<group>";
                };
                331C8082294A63A400263BE5 /* RunnerTests */ = {
                        isa = PBXGroup;
                        children = (
                                331C807B294A618700263BE5 /* RunnerTests.swift */,
                        );
                        path = RunnerTests;
                        sourceTree = "<group>";
                };
                8D8C5D78CB0507F11343C797 /* Frameworks */ = {
                        isa = PBXGroup;
                        children = (
                                8418F77604F9D5E868FFAD46 /* Pods_Runner.framework */,
                                D6EC864A7F478CE45023EC9E /* Pods_RunnerTests.framework */,
                        );
                        name = Frameworks;
                        sourceTree = "<group>";
                };
                9740EEB11CF90186004384FC /* Flutter */ = {
                        isa = PBXGroup;
                        children = (
                                3B3967151E833CAA004F5970 /* AppFrameworkInfo.plist */,
                                9740EEB21CF90195004384FC /* Debug.xcconfig */,
                                7AFA3C8E1D35360C0083082E /* Release.xcconfig */,
                                9740EEB31CF90195004384FC /* Generated.xcconfig */,
                        );
                        name = Flutter;
                        sourceTree = "<group>";
                };
                97C146E51CF9000F007C117D = {
                        isa = PBXGroup;
                        children = (
                                9740EEB11CF90186004384FC /* Flutter */,
                                97C146F01CF9000F007C117D /* Runner */,
                                97C146EF1CF9000F007C117D /* Products */,
                                331C8082294A63A400263BE5 /* RunnerTests */,
                                014B30AE4D9DF1E11EB1540F /* Pods */,
                                8D8C5D78CB0507F11343C797 /* Frameworks */,
                        );
                        sourceTree = "<group>";
                };
                97C146EF1CF9000F007C117D /* Products */ = {
                        isa = PBXGroup;
                        children = (
                                97C146EE1CF9000F007C117D /* Runner.app */,
                                331C8081294A63A400263BE5 /* RunnerTests.xctest */,
                        );
                        name = Products;
                        sourceTree = "<group>";
                };
                97C146F01CF9000F007C117D /* Runner */ = {
                        isa = PBXGroup;
                        children = (
                                97C146FA1CF9000F007C117D /* Main.storyboard */,
                                97C146FD1CF9000F007C117D /* Assets.xcassets */,
                                97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */,
                                97C147021CF9000F007C117D /* Info.plist */,
                                1498D2321E8E86230040F4C2 /* GeneratedPluginRegistrant.h */,
                                1498D2331E8E89220040F4C2 /* GeneratedPluginRegistrant.m */,
                                74858FAE1ED2DC5600515810 /* AppDelegate.swift */,
                                74858FAD1ED2DC5600515810 /* Runner-Bridging-Header.h */,
                        );
                        path = Runner;
                        sourceTree = "<group>";
                };
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
                331C8080294A63A400263BE5 /* RunnerTests */ = {
                        isa = PBXNativeTarget;
                        buildConfigurationList = 331C8087294A63A400263BE5 /* Build configuration list for PBXNativeTarget "RunnerTests" */;
                        buildPhases = (
                                522646005079AEE8BC779476 /* [CP] Check Pods Manifest.lock */,
                                331C807D294A63A400263BE5 /* Sources */,
                                331C807F294A63A400263BE5 /* Resources */,
                                DF7547F8A7FE047CD8BA3558 /* Frameworks */,
                        );
                        buildRules = (
                        );
                        dependencies = (
                                331C8086294A63A400263BE5 /* PBXTargetDependency */,
                        );
                        name = RunnerTests;
                        productName = RunnerTests;
                        productReference = 331C8081294A63A400263BE5 /* RunnerTests.xctest */;
                        productType = "com.apple.product-type.bundle.unit-test";
                };
                97C146ED1CF9000F007C117D /* Runner */ = {
                        isa = PBXNativeTarget;
                        buildConfigurationList = 97C147051CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */;
                        buildPhases = (
                                DA20E0DA1A80EFC334C59C1D /* [CP] Check Pods Manifest.lock */,
                                9740EEB61CF901F6004384FC /* Run Script */,
                                97C146EA1CF9000F007C117D /* Sources */,
                                97C146EB1CF9000F007C117D /* Frameworks */,
                                97C146EC1CF9000F007C117D /* Resources */,
                                9705A1C41CF9048500538489 /* Embed Frameworks */,
                                3B06AD1E1E4923F5004D2608 /* Thin Binary */,
                                82BE3BC9DE1CB09B66449333 /* [CP] Embed Pods Frameworks */,
                        );
                        buildRules = (
                        );
                        dependencies = (
                        );
                        name = Runner;
                        productName = Runner;
                        productReference = 97C146EE1CF9000F007C117D /* Runner.app */;
                        productType = "com.apple.product-type.application";
                };
/* End PBXNativeTarget section */

/* Begin PBXProject section */
                97C146E61CF9000F007C117D /* Project object */ = {
                        isa = PBXProject;
                        attributes = {
                                BuildIndependentTargetsInParallel = YES;
                                LastUpgradeCheck = 1510;
                                ORGANIZATIONNAME = "";
                                TargetAttributes = {
                                        331C8080294A63A400263BE5 = {
                                                CreatedOnToolsVersion = 14.0;
                                                TestTargetID = 97C146ED1CF9000F007C117D;
                                        };
                                        97C146ED1CF9000F007C117D = {
                                                CreatedOnToolsVersion = 7.3.1;
                                                LastSwiftMigration = 1100;
                                        };
                                };
                        };
                        buildConfigurationList = 97C146E91CF9000F007C117D /* Build configuration list for PBXProject "Runner" */;
                        compatibilityVersion = "Xcode 9.3";
                        developmentRegion = en;
                        hasScannedForEncodings = 0;
                        knownRegions = (
                                en,
                                Base,
                        );
                        mainGroup = 97C146E51CF9000F007C117D;
                        productRefGroup = 97C146EF1CF9000F007C117D /* Products */;
                        projectDirPath = "";
                        projectRoot = "";
                        targets = (
                                97C146ED1CF9000F007C117D /* Runner */,
                                331C8080294A63A400263BE5 /* RunnerTests */,
                        );
                };
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
                331C807F294A63A400263BE5 /* Resources */ = {
                        isa = PBXResourcesBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
                97C146EC1CF9000F007C117D /* Resources */ = {
                        isa = PBXResourcesBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                                97C147011CF9000F007C117D /* LaunchScreen.storyboard in Resources */,
                                3B3967161E833CAA004F5970 /* AppFrameworkInfo.plist in Resources */,
                                97C146FE1CF9000F007C117D /* Assets.xcassets in Resources */,
                                97C146FC1CF9000F007C117D /* Main.storyboard in Resources */,
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
/* End PBXResourcesBuildPhase section */

/* Begin PBXShellScriptBuildPhase section */
                3B06AD1E1E4923F5004D2608 /* Thin Binary */ = {
                        isa = PBXShellScriptBuildPhase;
                        alwaysOutOfDate = 1;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        inputPaths = (
                                "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}",
                        );
                        name = "Thin Binary";
                        outputPaths = (
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                        shellPath = /bin/sh;
                        shellScript = "/bin/sh \"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\" embed_and_thin";
                };
                522646005079AEE8BC779476 /* [CP] Check Pods Manifest.lock */ = {
                        isa = PBXShellScriptBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        inputFileListPaths = (
                        );
                        inputPaths = (
                                "${PODS_PODFILE_DIR_PATH}/Podfile.lock",
                                "${PODS_ROOT}/Manifest.lock",
                        );
                        name = "[CP] Check Pods Manifest.lock";
                        outputFileListPaths = (
                        );
                        outputPaths = (
                                "$(DERIVED_FILE_DIR)/Pods-RunnerTests-checkManifestLockResult.txt",
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                        shellPath = /bin/sh;
                        shellScript = "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n";
                        showEnvVarsInLog = 0;
                };
                82BE3BC9DE1CB09B66449333 /* [CP] Embed Pods Frameworks */ = {
                        isa = PBXShellScriptBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        inputFileListPaths = (
                                "${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks-${CONFIGURATION}-input-files.xcfilelist",
                        );
                        name = "[CP] Embed Pods Frameworks";
                        outputFileListPaths = (
                                "${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks-${CONFIGURATION}-output-files.xcfilelist",
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                        shellPath = /bin/sh;
                        shellScript = "\"${PODS_ROOT}/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh\"\n";
                        showEnvVarsInLog = 0;
                };
                9740EEB61CF901F6004384FC /* Run Script */ = {
                        isa = PBXShellScriptBuildPhase;
                        alwaysOutOfDate = 1;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        inputPaths = (
                        );
                        name = "Run Script";
                        outputPaths = (
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                        shellPath = /bin/sh;
                        shellScript = "/bin/sh \"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh\" build";
                };
                DA20E0DA1A80EFC334C59C1D /* [CP] Check Pods Manifest.lock */ = {
                        isa = PBXShellScriptBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                        );
                        inputFileListPaths = (
                        );
                        inputPaths = (
                                "${PODS_PODFILE_DIR_PATH}/Podfile.lock",
                                "${PODS_ROOT}/Manifest.lock",
                        );
                        name = "[CP] Check Pods Manifest.lock";
                        outputFileListPaths = (
                        );
                        outputPaths = (
                                "$(DERIVED_FILE_DIR)/Pods-Runner-checkManifestLockResult.txt",
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                        shellPath = /bin/sh;
                        shellScript = "diff \"${PODS_PODFILE_DIR_PATH}/Podfile.lock\" \"${PODS_ROOT}/Manifest.lock\" > /dev/null\nif [ $? != 0 ] ; then\n    # print error to STDERR\n    echo \"error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.\" >&2\n    exit 1\nfi\n# This output is used by Xcode 'outputs' to avoid re-running this script phase.\necho \"SUCCESS\" > \"${SCRIPT_OUTPUT_FILE_0}\"\n";
                        showEnvVarsInLog = 0;
                };
/* End PBXShellScriptBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
                331C807D294A63A400263BE5 /* Sources */ = {
                        isa = PBXSourcesBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                                331C808B294A63AB00263BE5 /* RunnerTests.swift in Sources */,
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
                97C146EA1CF9000F007C117D /* Sources */ = {
                        isa = PBXSourcesBuildPhase;
                        buildActionMask = 2147483647;
                        files = (
                                74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */,
                                1498D2341E8E89220040F4C2 /* GeneratedPluginRegistrant.m in Sources */,
                        );
                        runOnlyForDeploymentPostprocessing = 0;
                };
/* End PBXSourcesBuildPhase section */

/* Begin PBXTargetDependency section */
                331C8086294A63A400263BE5 /* PBXTargetDependency */ = {
                        isa = PBXTargetDependency;
                        target = 97C146ED1CF9000F007C117D /* Runner */;
                        targetProxy = 331C8085294A63A400263BE5 /* PBXContainerItemProxy */;
                };
/* End PBXTargetDependency section */

/* Begin PBXVariantGroup section */
                97C146FA1CF9000F007C117D /* Main.storyboard */ = {
                        isa = PBXVariantGroup;
                        children = (
                                97C146FB1CF9000F007C117D /* Base */,
                        );
                        name = Main.storyboard;
                        sourceTree = "<group>";
                };
                97C146FF1CF9000F007C117D /* LaunchScreen.storyboard */ = {
                        isa = PBXVariantGroup;
                        children = (
                                97C147001CF9000F007C117D /* Base */,
                        );
                        name = LaunchScreen.storyboard;
                        sourceTree = "<group>";
                };
/* End PBXVariantGroup section */

/* Begin XCBuildConfiguration section */
                249021D3217E4FDB00AE95B9 /* Profile */ = {
                        isa = XCBuildConfiguration;
                        buildSettings = {
                                ALWAYS_SEARCH_USER_PATHS = NO;
                                ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
                                CLANG_ANALYZER_NONNULL = YES;
                                CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
                                CLANG_CXX_LIBRARY = "libc++";
                                CLANG_ENABLE_MODULES = YES;
                                CLANG_ENABLE_OBJC_ARC = YES;
                                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                                CLANG_WARN_BOOL_CONVERSION = YES;
                                CLANG_WARN_COMMA = YES;
                                CLANG_WARN_CONSTANT_CONVERSION = YES;
                                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                                CLANG_WARN_EMPTY_BODY = YES;
                                CLANG_WARN_ENUM_CONVERSION = YES;
                                CLANG_WARN_INFINITE_RECURSION = YES;
                                CLANG_WARN_INT_CONVERSION = YES;
                                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                                CLANG_WARN_STRICT_PROTOTYPES = YES;
                                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                                CLANG_WARN_UNREACHABLE_CODE = YES;
                                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                                "CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
                                COPY_PHASE_STRIP = NO;
                                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                                ENABLE_NS_ASSERTIONS = NO;
                                ENABLE_STRICT_OBJC_MSGSEND = YES;
                                ENABLE_USER_SCRIPT_SANDBOXING = NO;
                                GCC_C_LANGUAGE_STANDARD = gnu99;
                                GCC_NO_COMMON_BLOCKS = YES;
                                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                                GCC_WARN_UNDECLARED_SELECTOR = YES;
                                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                                GCC_WARN_UNUSED_FUNCTION = YES;
                                GCC_WARN_UNUSED_VARIABLE = YES;
                                IPHONEOS_DEPLOYMENT_TARGET = 12.0;
                                MTL_ENABLE_DEBUG_INFO = NO;
                                SDKROOT = iphoneos;
                                SUPPORTED_PLATFORMS = iphoneos;
                                TARGETED_DEVICE_FAMILY = "1,2";
                                VALIDATE_PRODUCT = YES;
                        };
                        name = Profile;
                };
                249021D4217E4FDB00AE95B9 /* Profile */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
                        buildSettings = {
                                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                                CLANG_ENABLE_MODULES = YES;
                                CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
                                DEVELOPMENT_TEAM = TEAM_ID_PLACEHOLDER;
                                ENABLE_BITCODE = NO;
                                INFOPLIST_FILE = Runner/Info.plist;
                                LD_RUNPATH_SEARCH_PATHS = (
                                        "$(inherited)",
                                        "@executable_path/Frameworks",
                                );
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
                                SWIFT_VERSION = 5.0;
                                VERSIONING_SYSTEM = "apple-generic";
                        };
                        name = Profile;
                };
                331C8088294A63A400263BE5 /* Debug */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 77B58FA963D428A1AB029571 /* Pods-RunnerTests.debug.xcconfig */;
                        buildSettings = {
                                BUNDLE_LOADER = "$(TEST_HOST)";
                                CODE_SIGN_STYLE = Automatic;
                                CURRENT_PROJECT_VERSION = 1;
                                GENERATE_INFOPLIST_FILE = YES;
                                MARKETING_VERSION = 1.0;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
                                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                                SWIFT_VERSION = 5.0;
                                TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Runner.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Runner";
                        };
                        name = Debug;
                };
                331C8089294A63A400263BE5 /* Release */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 0C53DFEEFB42B51826FB45E3 /* Pods-RunnerTests.release.xcconfig */;
                        buildSettings = {
                                BUNDLE_LOADER = "$(TEST_HOST)";
                                CODE_SIGN_STYLE = Automatic;
                                CURRENT_PROJECT_VERSION = 1;
                                GENERATE_INFOPLIST_FILE = YES;
                                MARKETING_VERSION = 1.0;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_VERSION = 5.0;
                                TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Runner.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Runner";
                        };
                        name = Release;
                };
                331C808A294A63A400263BE5 /* Profile */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 486594D03E86941A37299F1C /* Pods-RunnerTests.profile.xcconfig */;
                        buildSettings = {
                                BUNDLE_LOADER = "$(TEST_HOST)";
                                CODE_SIGN_STYLE = Automatic;
                                CURRENT_PROJECT_VERSION = 1;
                                GENERATE_INFOPLIST_FILE = YES;
                                MARKETING_VERSION = 1.0;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_VERSION = 5.0;
                                TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Runner.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Runner";
                        };
                        name = Profile;
                };
                97C147031CF9000F007C117D /* Debug */ = {
                        isa = XCBuildConfiguration;
                        buildSettings = {
                                ALWAYS_SEARCH_USER_PATHS = NO;
                                ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;
                                CLANG_ANALYZER_NONNULL = YES;
                                CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
                                CLANG_CXX_LIBRARY = "libc++";
                                CLANG_ENABLE_MODULES = YES;
                                CLANG_ENABLE_OBJC_ARC = YES;
                                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                                CLANG_WARN_BOOL_CONVERSION = YES;
                                CLANG_WARN_COMMA = YES;
                                CLANG_WARN_CONSTANT_CONVERSION = YES;
                                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                                CLANG_WARN_EMPTY_BODY = YES;
                                CLANG_WARN_ENUM_CONVERSION = YES;
                                CLANG_WARN_INFINITE_RECURSION = YES;
                                CLANG_WARN_INT_CONVERSION = YES;
                                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                                CLANG_WARN_STRICT_PROTOTYPES = YES;
                                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                                CLANG_WARN_UNREACHABLE_CODE = YES;
                                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                                "CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
                                COPY_PHASE_STRIP = NO;
                                DEBUG_INFORMATION_FORMAT = dwarf;
                                ENABLE_STRICT_OBJC_MSGSEND = YES;
                                ENABLE_TESTABILITY = YES;
                                ENABLE_USER_SCRIPT_SANDBOXING = NO;
                                GCC_C_LANGUAGE_STANDARD = gnu99;
                                GCC_DYNAMIC_NO_PIC = NO;
                                GCC_NO_COMMON_BLOCKS = YES;
                                GCC_OPTIMIZATION_LEVEL = 0;
                                GCC_PREPROCESSOR_DEFINITIONS = (
                                        "DEBUG=1",
                                        "$(inherited)",
                                );
                                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                                GCC_WARN_UNDECLARED_SELECTOR = YES;
                                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                                GCC_WARN_UNUSED_FUNCTION = YES;
                                GCC_WARN_UNUSED_VARIABLE = YES;
                                IPHONEOS_DEPLOYMENT_TARGET = 12.0;
                                MTL_ENABLE_DEBUG_INFO = YES;
                                ONLY_ACTIVE_ARCH = YES;
                                SDKROOT = iphoneos;
                                TARGETED_DEVICE_FAMILY = "1,2";
                        };
                        name = Debug;
                };
                97C147041CF9000F007C117D /* Release */ = {
                        isa = XCBuildConfiguration;
                        buildSettings = {
                                ALWAYS_SEARCH_USER_PATHS = NO;
                                ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;
                                CLANG_ANALYZER_NONNULL = YES;
                                CLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";
                                CLANG_CXX_LIBRARY = "libc++";
                                CLANG_ENABLE_MODULES = YES;
                                CLANG_ENABLE_OBJC_ARC = YES;
                                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                                CLANG_WARN_BOOL_CONVERSION = YES;
                                CLANG_WARN_COMMA = YES;
                                CLANG_WARN_CONSTANT_CONVERSION = YES;
                                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                                CLANG_WARN_EMPTY_BODY = YES;
                                CLANG_WARN_ENUM_CONVERSION = YES;
                                CLANG_WARN_INFINITE_RECURSION = YES;
                                CLANG_WARN_INT_CONVERSION = YES;
                                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                                CLANG_WARN_STRICT_PROTOTYPES = YES;
                                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                                CLANG_WARN_UNREACHABLE_CODE = YES;
                                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                                "CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";
                                COPY_PHASE_STRIP = NO;
                                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                                ENABLE_NS_ASSERTIONS = NO;
                                ENABLE_STRICT_OBJC_MSGSEND = YES;
                                ENABLE_USER_SCRIPT_SANDBOXING = NO;
                                GCC_C_LANGUAGE_STANDARD = gnu99;
                                GCC_NO_COMMON_BLOCKS = YES;
                                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                                GCC_WARN_UNDECLARED_SELECTOR = YES;
                                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                                GCC_WARN_UNUSED_FUNCTION = YES;
                                GCC_WARN_UNUSED_VARIABLE = YES;
                                IPHONEOS_DEPLOYMENT_TARGET = 12.0;
                                MTL_ENABLE_DEBUG_INFO = NO;
                                SDKROOT = iphoneos;
                                SUPPORTED_PLATFORMS = iphoneos;
                                SWIFT_COMPILATION_MODE = wholemodule;
                                SWIFT_OPTIMIZATION_LEVEL = "-O";
                                TARGETED_DEVICE_FAMILY = "1,2";
                                VALIDATE_PRODUCT = YES;
                        };
                        name = Release;
                };
                97C147061CF9000F007C117D /* Debug */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 9740EEB21CF90195004384FC /* Debug.xcconfig */;
                        buildSettings = {
                                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                                CLANG_ENABLE_MODULES = YES;
                                CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
                                DEVELOPMENT_TEAM = TEAM_ID_PLACEHOLDER;
                                ENABLE_BITCODE = NO;
                                INFOPLIST_FILE = Runner/Info.plist;
                                LD_RUNPATH_SEARCH_PATHS = (
                                        "$(inherited)",
                                        "@executable_path/Frameworks",
                                );
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
                                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                                SWIFT_VERSION = 5.0;
                                VERSIONING_SYSTEM = "apple-generic";
                        };
                        name = Debug;
                };
                97C147071CF9000F007C117D /* Release */ = {
                        isa = XCBuildConfiguration;
                        baseConfigurationReference = 7AFA3C8E1D35360C0083082E /* Release.xcconfig */;
                        buildSettings = {
                                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                                CLANG_ENABLE_MODULES = YES;
                                CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";
                                DEVELOPMENT_TEAM = TEAM_ID_PLACEHOLDER;
                                ENABLE_BITCODE = NO;
                                INFOPLIST_FILE = Runner/Info.plist;
                                LD_RUNPATH_SEARCH_PATHS = (
                                        "$(inherited)",
                                        "@executable_path/Frameworks",
                                );
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
                                PRODUCT_NAME = "$(TARGET_NAME)";
                                SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h";
                                SWIFT_VERSION = 5.0;
                                VERSIONING_SYSTEM = "apple-generic";
                        };
                        name = Release;
                };
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
                331C8087294A63A400263BE5 /* Build configuration list for PBXNativeTarget "RunnerTests" */ = {
                        isa = XCConfigurationList;
                        buildConfigurations = (
                                331C8088294A63A400263BE5 /* Debug */,
                                331C8089294A63A400263BE5 /* Release */,
                                331C808A294A63A400263BE5 /* Profile */,
                        );
                        defaultConfigurationIsVisible = 0;
                        defaultConfigurationName = Release;
                };
                97C146E91CF9000F007C117D /* Build configuration list for PBXProject "Runner" */ = {
                        isa = XCConfigurationList;
                        buildConfigurations = (
                                97C147031CF9000F007C117D /* Debug */,
                                97C147041CF9000F007C117D /* Release */,
                                249021D3217E4FDB00AE95B9 /* Profile */,
                        );
                        defaultConfigurationIsVisible = 0;
                        defaultConfigurationName = Release;
                };
                97C147051CF9000F007C117D /* Build configuration list for PBXNativeTarget "Runner" */ = {
                        isa = XCConfigurationList;
                        buildConfigurations = (
                                97C147061CF9000F007C117D /* Debug */,
                                97C147071CF9000F007C117D /* Release */,
                                249021D4217E4FDB00AE95B9 /* Profile */,
                        );
                        defaultConfigurationIsVisible = 0;
                        defaultConfigurationName = Release;
                };
/* End XCConfigurationList section */
        };
        rootObject = 97C146E61CF9000F007C117D /* Project object */;
}
''';

const pubspecYaml = '''
name: flutter_app
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.3 <4.0.0'
''';