import 'package:crosslaunch/fs/access.dart';
import 'package:crosslaunch/testing/stub_data.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as pathlib;

void main() {
  group('Existing config files', () {
    late MemoryFileSystem fileSystem;
    late Directory project;
    late Directory weirdProject;

    setUp(() async {
      fileSystem = MemoryFileSystem();
      project = await fileSystem.directory('/project').create();
      final manifestFile = await fileSystem
          .file(
            pathlib.join(
              project.path,
              ConfigFile.androidManifest.projectRelativePath,
            ),
          )
          .create(recursive: true);
      manifestFile.writeAsString(androidManifest);
      final iosInfoPlistFile = await fileSystem
          .file(
            pathlib.join(
              project.path,
              ConfigFile.iosInfoPlist.projectRelativePath,
            ),
          )
          .create(recursive: true);
      iosInfoPlistFile.writeAsString(iosInfoPlist);
      final buildGradleFile = await fileSystem
          .file(
            pathlib.join(
              project.path,
              ConfigFile.appBuildGradle.projectRelativePath,
            ),
          )
          .create(recursive: true);
      buildGradleFile.writeAsString(androidAppBuildGradle);
      final xcodeProjectFile = await fileSystem
          .file(
            pathlib.join(
              project.path,
              ConfigFile.iosXcodeProject.projectRelativePath,
            ),
          )
          .create(recursive: true);
      xcodeProjectFile.writeAsString(iosXcodeProjectSrc);

      weirdProject = await fileSystem.directory('/weird_project').create();
      final weirdManifestFile = await fileSystem
          .file(
            pathlib.join(
              weirdProject.path,
              ConfigFile.androidManifest.projectRelativePath,
            ),
          )
          .create(recursive: true);
      weirdManifestFile.writeAsString(_manifestSingleLineApp);
      final weirdInfoPlistFile = await fileSystem
          .file(
            pathlib.join(
              weirdProject.path,
              ConfigFile.iosInfoPlist.projectRelativePath,
            ),
          )
          .create(recursive: true);
      weirdInfoPlistFile.writeAsString(_infoPlistLeadingTrailingContent);

      final weirdXcodeProjectFile = await fileSystem
          .file(
            pathlib.join(
              weirdProject.path,
              ConfigFile.iosXcodeProject.projectRelativePath,
            ),
          )
          .create(recursive: true);
      weirdXcodeProjectFile.writeAsString(_xcodeProjectSample);
    });

    group(ConfigStore, () {
      test('loads AndroidManifest successfully', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );
        final manifest = await configStore.loadAndroidManifest();

        expect(manifest, isA<AndroidManifest>());
      });

      test('can write and read modified AndroidManifest', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final manifest = await configStore.loadAndroidManifest();

        await configStore.saveAndroidManifest(
          manifest.edit(androidLabel: 'fancy_app'),
        );

        final updatedManifest = await configStore.loadAndroidManifest();

        expect(updatedManifest.androidLabel, 'fancy_app');
      });

      test('writing AndroidManifest only touches correct fields', () async {
        final configStore = ConfigStore(
          appDirectory: weirdProject,
          fileSystem: fileSystem,
        );

        final manifest = await configStore.loadAndroidManifest();

        await configStore.saveAndroidManifest(
          manifest.edit(androidLabel: 'fancy_app'),
        );

        final weirdManifestXml =
            await fileSystem
                .file(
                  pathlib.join(
                    weirdProject.path,
                    ConfigFile.androidManifest.projectRelativePath,
                  ),
                )
                .readAsString();

        expect(weirdManifestXml, _manifestSingleLineUpdated);
      });

      test('loads iOS Info.plist successfully', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final infoPlist = await configStore.loadIosInfoPlist();

        expect(infoPlist, isA<IosInfoPlist>());
      });

      test('can write and read modified iOS Info.plist', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final infoPlist = await configStore.loadIosInfoPlist();

        await configStore.saveIosInfoPlist(
          infoPlist.edit(displayName: 'fancy_app', versionName: '2.0.0', versionNumber: '1'),
        );
        final updatedInfoPlist = await configStore.loadIosInfoPlist();

        expect(updatedInfoPlist.displayName, 'fancy_app');
        expect(updatedInfoPlist.versionName, '2.0.0');
        expect(updatedInfoPlist.versionNumber, '1');
      });

      test('writing Info.plist only touches correct fields', () async {
        final configStore = ConfigStore(
          appDirectory: weirdProject,
          fileSystem: fileSystem,
        );

        final infoPlist = await configStore.loadIosInfoPlist();

        await configStore.saveIosInfoPlist(
          infoPlist.edit(displayName: 'fancy_app'),
        );

        final weirdInfoPlistXml =
            await fileSystem
                .file(
                  pathlib.join(
                    weirdProject.path,
                    ConfigFile.iosInfoPlist.projectRelativePath,
                  ),
                )
                .readAsString();

        expect(weirdInfoPlistXml, _infoPlistLeadingTrailingContentUpdated);
      });

      test('loads AppBuildGradle successfully', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final buildGradle = await configStore.loadAppBuildGradle();

        expect(buildGradle, isA<AppBuildGradle>());
      });

      test('can write and read modified AppBuildGradle', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final buildGradle = await configStore.loadAppBuildGradle();

        await configStore.saveAppBuildGradle(
          buildGradle.edit(appId: 'com.example.fancy_app'),
        );
        final updatedBuildGradle = await configStore.loadAppBuildGradle();

        expect(updatedBuildGradle.applicationId, 'com.example.fancy_app');
      });

      test('loads IosXcodeProject successfully', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final xcodeProject = await configStore.loadIosXcodeProject();

        expect(xcodeProject, isA<IosXcodeProject>());
      });

      test('can write and read modified IosXcodeProject', () async {
        final configStore = ConfigStore(
          appDirectory: project,
          fileSystem: fileSystem,
        );

        final xcodeProject = await configStore.loadIosXcodeProject();

        await configStore.saveIosXcodeProject(
          xcodeProject.edit(bundleId: 'com.example.fancy_app'),
        );
        final updatedXcodeProject = await configStore.loadIosXcodeProject();

        expect(updatedXcodeProject.bundleId, 'com.example.fancy_app');
      });

      test('writing XcodeProject only touches correct fields', () async {
        final configStore = ConfigStore(
          appDirectory: weirdProject,
          fileSystem: fileSystem,
        );

        final xcodeProject = await configStore.loadIosXcodeProject();

        await configStore.saveIosXcodeProject(
          xcodeProject.edit(bundleId: 'com.example.fancyApp'),
        );

        final weirdXcodeProjectXml =
            await fileSystem
                .file(
                  pathlib.join(
                    weirdProject.path,
                    ConfigFile.iosXcodeProject.projectRelativePath,
                  ),
                )
                .readAsString();

        expect(weirdXcodeProjectXml, _xcodeProjectSampleUpdated);
      });
    });
  });

  group(AndroidManifest, () {
    test('reads android:label from XML', () {
      final manifest = AndroidManifest.fromXml(xml: androidManifest);

      expect(manifest.androidLabel, 'flutter_app');
    });

    test('is not marked as modified after creation', () {
      final manifest = AndroidManifest.fromXml(xml: androidManifest);

      expect(manifest.isModified, false);
    });

    test('can modify the label', () {
      final originalManifest = AndroidManifest.fromXml(xml: androidManifest);
      final updatedManifest = originalManifest.edit(androidLabel: 'fancy_app');

      expect(updatedManifest.isModified, true);
      expect(updatedManifest.androidLabel, 'fancy_app');
    });

    test('modification doesn\'t impact the original', () {
      final originalManifest = AndroidManifest.fromXml(xml: androidManifest);
      originalManifest.edit(androidLabel: 'fancy_app');

      expect(originalManifest.isModified, false);
      expect(originalManifest.androidLabel, 'flutter_app');
    });

    test(
      'setting the same or null value for the label returns equivalent instance',
      () {
        final originalManifest = AndroidManifest.fromXml(xml: androidManifest);
        final noopEdit = originalManifest.edit();
        final sameNameEdit = originalManifest.edit(androidLabel: 'flutter_app');

        expect(originalManifest, noopEdit);
        expect(sameNameEdit, originalManifest);
      },
    );

    test('editing and reverting back to original works', () {
      final originalManifest = AndroidManifest.fromXml(xml: androidManifest);
      final changedManifest = originalManifest.edit(androidLabel: 'fancy_app');
      final revertedManifest = changedManifest.edit(
        androidLabel: 'flutter_app',
      );

      expect(revertedManifest.isModified, false);
      expect(revertedManifest.androidLabel, 'flutter_app');
    });
  });

  group(IosInfoPlist, () {
    test('reads CFBundleDisplayName from XML', () {
      final infoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);

      expect(infoPlist.displayName, 'flutter_app');
    });

    test('reads CFBundleShortVersionString from XML', () {
      final infoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);

      expect(infoPlist.versionName, r'$(FLUTTER_BUILD_NAME)');
    });

    test('is not marked as modified after creation', () {
      final infoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);

      expect(infoPlist.isModified, false);
    });

    test('can modify the display name', () {
      final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
      final updatedInfoPlist = originalInfoPlist.edit(displayName: 'fancy_app');

      expect(updatedInfoPlist.isModified, true);
      expect(updatedInfoPlist.displayName, 'fancy_app');
    });

    test('can modify the version name', () {
      final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
      final updatedInfoPlist = originalInfoPlist.edit(versionName: '2.0.0');

      expect(updatedInfoPlist.isModified, true);
      expect(updatedInfoPlist.versionName, '2.0.0');
    });

    test('modification doesn\'t impact the original', () {
      final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
      originalInfoPlist.edit(displayName: 'fancy_app');

      expect(originalInfoPlist.isModified, false);
      expect(originalInfoPlist.displayName, 'flutter_app');
    });

    test(
      'setting the same or null value for the label returns equivalent instance',
      () {
        final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
        final noopEdit = originalInfoPlist.edit();
        final sameNameEdit = originalInfoPlist.edit(displayName: 'flutter_app');

        expect(originalInfoPlist, noopEdit);
        expect(sameNameEdit, originalInfoPlist);
      },
    );

    test(
      'setting the same or null value for the version name returns equivalent instance',
      () {
        final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
        final noopEdit = originalInfoPlist.edit();
        final sameVersionEdit = originalInfoPlist.edit(
          versionName: r'$(FLUTTER_BUILD_NAME)',
        );

        expect(originalInfoPlist, noopEdit);
        expect(sameVersionEdit, originalInfoPlist);
      },
    );

    test('editing and reverting back to original works', () {
      final originalInfoPlist = IosInfoPlist.fromXml(xml: iosInfoPlist);
      final changedInfoPlist = originalInfoPlist.edit(displayName: 'fancy_app');
      final revertedInfoPlist = changedInfoPlist.edit(
        displayName: 'flutter_app',
      );

      expect(revertedInfoPlist.isModified, false);
      expect(revertedInfoPlist.displayName, 'flutter_app');
    });
  });

  group(AppBuildGradle, () {
    test('reads applicationId from build.gradle.kts', () {
      final appBuildGradle = AppBuildGradle.fromKts(kts: androidAppBuildGradle);

      expect(appBuildGradle.applicationId, 'com.example.flutter_app');
    });

    test('is not marked as modified after creation', () {
      final appBuildGradle = AppBuildGradle.fromKts(kts: androidAppBuildGradle);

      expect(appBuildGradle.isModified, false);
    });

    test('can modify the applicationId', () {
      final originalAppBuildGradle = AppBuildGradle.fromKts(
        kts: androidAppBuildGradle,
      );
      final updatedAppBuildGradle = originalAppBuildGradle.edit(
        appId: 'com.example.fancy_app',
      );

      expect(updatedAppBuildGradle.isModified, true);
      expect(updatedAppBuildGradle.applicationId, 'com.example.fancy_app');
    });

    test('modification doesn\'t impact the original', () {
      final originalAppBuildGradle = AppBuildGradle.fromKts(
        kts: androidAppBuildGradle,
      );
      originalAppBuildGradle.edit(appId: 'com.example.fancy_app');

      expect(originalAppBuildGradle.isModified, false);
      expect(originalAppBuildGradle.applicationId, 'com.example.flutter_app');
    });

    test(
      'setting the same or null value for the applicationId returns equivalent instance',
      () {
        final originalAppBuildGradle = AppBuildGradle.fromKts(
          kts: androidAppBuildGradle,
        );
        final noopEdit = originalAppBuildGradle.edit();
        final sameAppIdEdit = originalAppBuildGradle.edit(
          appId: 'com.example.flutter_app',
        );

        expect(originalAppBuildGradle, noopEdit);
        expect(sameAppIdEdit, originalAppBuildGradle);
      },
    );

    test('editing and reverting back to the original works', () {
      final originalAppBuildGradle = AppBuildGradle.fromKts(
        kts: androidAppBuildGradle,
      );
      final changedAppBuildGradle = originalAppBuildGradle.edit(
        appId: 'com.example.fancy_app',
      );
      final revertedAppBuildGradle = changedAppBuildGradle.edit(
        appId: 'com.example.flutter_app',
      );

      expect(revertedAppBuildGradle.isModified, false);
      expect(revertedAppBuildGradle.applicationId, 'com.example.flutter_app');
    });
  });

  group(IosXcodeProject, () {
    test('reads PRODUCT_BUNDLE_IDENTIFIER from pbxproj', () {
      final xcodeProject = IosXcodeProject.fromPbxproj(
        pbxproj: iosXcodeProjectSrc,
      );

      expect(xcodeProject.bundleId, 'com.example.flutterApp');
    });

    test('is not marked as modified after creation', () {
      final xcodeProject = IosXcodeProject.fromPbxproj(
        pbxproj: iosXcodeProjectSrc,
      );

      expect(xcodeProject.isModified, false);
    });

    test('can modify the bundleId', () {
      final originalXcodeProject = IosXcodeProject.fromPbxproj(
        pbxproj: iosXcodeProjectSrc,
      );
      final updatedXcodeProject = originalXcodeProject.edit(
        bundleId: 'com.example.fancy_app',
      );

      expect(updatedXcodeProject.isModified, true);
      expect(updatedXcodeProject.bundleId, 'com.example.fancy_app');
    });

    test('modification doesn\'t impact the original', () {
      final originalXcodeProject = IosXcodeProject.fromPbxproj(
        pbxproj: iosXcodeProjectSrc,
      );
      originalXcodeProject.edit(bundleId: 'com.example.fancy_app');

      expect(originalXcodeProject.isModified, false);
      expect(originalXcodeProject.bundleId, 'com.example.flutterApp');
    });

    test(
      'setting the same or null value for the bundleId returns equivalent instance',
      () {
        final originalXcodeProject = IosXcodeProject.fromPbxproj(
          pbxproj: iosXcodeProjectSrc,
        );
        final noopEdit = originalXcodeProject.edit();
        final sameBundleIdEdit = originalXcodeProject.edit(
          bundleId: 'com.example.flutterApp',
        );

        expect(originalXcodeProject, noopEdit);
        expect(sameBundleIdEdit, originalXcodeProject);
      },
    );

    test('editing and reverting back to the original works', () {
      final originalXcodeProject = IosXcodeProject.fromPbxproj(
        pbxproj: iosXcodeProjectSrc,
      );
      final changedXcodeProject = originalXcodeProject.edit(
        bundleId: 'com.example.fancy_app',
      );
      final revertedXcodeProject = changedXcodeProject.edit(
        bundleId: 'com.example.flutterApp',
      );

      expect(revertedXcodeProject.isModified, false);
      expect(revertedXcodeProject.bundleId, 'com.example.flutterApp');
    });
  });
}

const _manifestSingleLineApp = '''
    <application android:label="flutter_app" android:name="blah" android:icon="@mipmap/launcher_icon">
''';
const _manifestSingleLineUpdated = '''
    <application android:label="fancy_app" android:name="blah" android:icon="@mipmap/launcher_icon">
''';
const _infoPlistLeadingTrailingContent = r'''
        <!-- pre comment --><key>CFBundleDisplayName</key> <!-- post comment -->
        <!-- pre comment --><string>flutter_app</string> <!-- post comment -->
        <!-- pre comment --><key>CFBundleShortVersionString</key> <!-- post comment -->
        <!-- pre comment --><string>$(FLUTTER_BUILD_NAME)</string> <!-- post comment -->
        <!-- pre comment --><key>CFBundleVersion</key> <!-- post comment -->
        <!-- pre comment --><string>$(FLUTTER_BUILD_NUMBER)</string> <!-- post comment -->
''';
const _infoPlistLeadingTrailingContentUpdated = r'''
        <!-- pre comment --><key>CFBundleDisplayName</key> <!-- post comment -->
        <!-- pre comment --><string>fancy_app</string> <!-- post comment -->
        <!-- pre comment --><key>CFBundleShortVersionString</key> <!-- post comment -->
        <!-- pre comment --><string>$(FLUTTER_BUILD_NAME)</string> <!-- post comment -->
        <!-- pre comment --><key>CFBundleVersion</key> <!-- post comment -->
        <!-- pre comment --><string>$(FLUTTER_BUILD_NUMBER)</string> <!-- post comment -->
''';
const _xcodeProjectSample = r'''
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.flutterApp;
''';
const _xcodeProjectSampleUpdated = r'''
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp.RunnerTests;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp;
                                PRODUCT_BUNDLE_IDENTIFIER = com.example.fancyApp;
''';
