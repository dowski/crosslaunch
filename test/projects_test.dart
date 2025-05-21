import 'package:crosslaunch/projects.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FileSystem fileSystem;

  setUp(() {
    fileSystem = MemoryFileSystem();
  });

  group(Project, () {
    test('no ios or android folder is invalid', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      // Web isn't supported so this should have no impact.
      final webDir = fileSystem.directory('/foo/bar/web');
      await webDir.create();

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });

    test('ios folder leads to ios platform being present', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      await _createIosStructure(fileSystem);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.supportedPlatforms, contains(SupportedPlatform.ios));
    });

    test('android folder leads to android platform being present', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      await _createAndroidStructure(fileSystem);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.supportedPlatforms, contains(SupportedPlatform.android));
    });

    test(
      'android and ios folder leads to both platforms being present',
      () async {
        final projectDir = fileSystem.directory('/foo/bar');
        await projectDir.create(recursive: true);

        await _createAndroidStructure(fileSystem);
        await _createIosStructure(fileSystem);

        final project = await Project.fromDir(projectDir) as ValidProject;
        expect(
          project.supportedPlatforms,
          containsAll([SupportedPlatform.android, SupportedPlatform.ios]),
        );
      },
    );

    test('ios app name parsed from Info.plist', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      await _createIosStructure(fileSystem);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.iosAppName, 'flutter_app');
    });

    test('ios project without Info.plist is invalid', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      final iosDir = fileSystem.directory('/foo/bar/ios/Runner');
      await iosDir.create(recursive: true);

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });

    test('android app name parsed from AndroidManifest.xml', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      await _createAndroidStructure(fileSystem);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.androidAppName, 'flutter_app');
    });

    test('android project without AndroidManifest.xml is invalid', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      final androidDir = fileSystem.directory('/foo/bar/android/app/src/main');
      await androidDir.create(recursive: true);

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });
  });
}

Future<void> _createIosStructure(FileSystem fileSystem) async {
  final iosDir = fileSystem.directory('/foo/bar/ios/Runner');
  await iosDir.create(recursive: true);
  final plistFile = await iosDir.childFile('Info.plist').create();
  await plistFile.writeAsString(_plistContent, flush: true);
}

Future<void> _createAndroidStructure(FileSystem fileSystem) async {
  final androidDir = fileSystem.directory('/foo/bar/android/app/src/main');
  await androidDir.create(recursive: true);
  final manifestFile = await androidDir.childFile('AndroidManifest.xml').create();
  await manifestFile.writeAsString(_androidManifest, flush: true);
}

const _plistContent = r'''
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

const _androidManifest = r'''
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
