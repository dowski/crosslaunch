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
          infoPlist.edit(displayName: 'fancy_app'),
        );
        final updatedInfoPlist = await configStore.loadIosInfoPlist();

        expect(updatedInfoPlist.displayName, 'fancy_app');
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
}

const _manifestSingleLineApp = '''
    <application android:label="flutter_app" android:name="blah" android:icon="@mipmap/launcher_icon">
''';
const _manifestSingleLineUpdated = '''
    <application android:label="fancy_app" android:name="blah" android:icon="@mipmap/launcher_icon">
''';
const _infoPlistLeadingTrailingContent = '''
        <!-- pre comment --><key>CFBundleDisplayName</key> <!-- post comment -->
        <!-- pre comment --><string>flutter_app</string> <!-- post comment -->
''';
const _infoPlistLeadingTrailingContentUpdated = '''
        <!-- pre comment --><key>CFBundleDisplayName</key> <!-- post comment -->
        <!-- pre comment --><string>fancy_app</string> <!-- post comment -->
''';
