import 'package:crosslaunch/platform.dart';
import 'package:crosslaunch/projects.dart';
import 'package:crosslaunch/testing/stub_data.dart';
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
      expect(project.iosInfoPlist?.displayName, 'flutter_app');
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
      expect(project.androidManifest?.androidLabel, 'flutter_app');
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
  await plistFile.writeAsString(iosInfoPlist, flush: true);
}

Future<void> _createAndroidStructure(FileSystem fileSystem) async {
  final androidDir = fileSystem.directory('/foo/bar/android/app/src/main');
  await androidDir.create(recursive: true);
  final manifestFile =
      await androidDir.childFile('AndroidManifest.xml').create();
  await manifestFile.writeAsString(androidManifest, flush: true);
}
