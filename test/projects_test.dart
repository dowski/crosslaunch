import 'package:crosslaunch/fs/access.dart';
import 'package:crosslaunch/platform.dart';
import 'package:crosslaunch/projects.dart';
import 'package:crosslaunch/testing/stub_data.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as pathlib;

const testProjectPath = '/foo/bar';

void main() {
  late FileSystem fileSystem;

  setUp(() {
    fileSystem = MemoryFileSystem();
  });

  group(Project, () {
    test('no ios or android folder is invalid', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      // Web isn't supported so this should have no impact.
      final webDir = fileSystem.directory(pathlib.join(testProjectPath, 'web'));
      await webDir.create();
      // No pubspec.yaml needed here as it's already invalid due to no platforms

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });

    test('ios folder leads to ios platform being present', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      await _createIosStructure(fileSystem, testProjectPath);
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.supportedPlatforms, contains(SupportedPlatform.ios));
    });

    test('android folder leads to android platform being present', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      await _createAndroidStructure(fileSystem, testProjectPath);
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.supportedPlatforms, contains(SupportedPlatform.android));
    });

    test(
      'android and ios folders lead to both platforms being present',
      () async {
        final projectDir = fileSystem.directory(testProjectPath);
        await projectDir.create(recursive: true);

        await _createAndroidStructure(fileSystem, testProjectPath);
        await _createIosStructure(fileSystem, testProjectPath);
        await _createPubspecYaml(fileSystem, testProjectPath);

        final project = await Project.fromDir(projectDir) as ValidProject;
        expect(
          project.supportedPlatforms,
          containsAll([SupportedPlatform.android, SupportedPlatform.ios]),
        );
      },
    );

    test('ios app name parsed from Info.plist', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      await _createIosStructure(fileSystem, testProjectPath);
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.iosInfoPlist?.displayName, 'flutter_app');
    });

    test('ios project without Info.plist is invalid', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      final iosDir = fileSystem.directory(pathlib.join(testProjectPath, 'ios', 'Runner'));
      await iosDir.create(recursive: true);
      // Do not create Info.plist
      // Create other necessary iOS files so failure is due to Info.plist
      final xcodeProjFile = await fileSystem
          .file(
            pathlib.join(
              testProjectPath,
              ConfigFile.iosXcodeProject.projectRelativePath,
            ),
          )
          .create(recursive: true);
      await xcodeProjFile.writeAsString(iosXcodeProjectSrc, flush: true);
      // Create pubspec.yaml so the invalidity is due to missing Info.plist
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });

    test('android app name parsed from AndroidManifest.xml', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      await _createAndroidStructure(fileSystem, testProjectPath);
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir) as ValidProject;
      expect(project.androidManifest?.androidLabel, 'flutter_app');
    });

    test('android project without AndroidManifest.xml is invalid', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      final androidDir = fileSystem.directory(pathlib.join(testProjectPath, 'android', 'app', 'src', 'main'));
      await androidDir.create(recursive: true);
      // Do not create AndroidManifest.xml
      // Create other necessary Android files so failure is due to AndroidManifest.xml
      final buildGradleFile = await fileSystem
          .file(
            pathlib.join(
              testProjectPath,
              ConfigFile.appBuildGradle.projectRelativePath,
            ),
          )
          .create(recursive: true);
      await buildGradleFile.writeAsString(androidAppBuildGradle, flush: true);
      // Create pubspec.yaml so the invalidity is due to missing AndroidManifest.xml
      await _createPubspecYaml(fileSystem, testProjectPath);

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>());
    });

    test('project without pubspec.yaml is invalid', () async {
      final projectDir = fileSystem.directory(testProjectPath);
      await projectDir.create(recursive: true);

      // Create platform structures
      await _createIosStructure(fileSystem, testProjectPath);
      await _createAndroidStructure(fileSystem, testProjectPath);
      // DO NOT create pubspec.yaml

      final project = await Project.fromDir(projectDir);
      expect(project, isA<InvalidProject>(),
          reason: 'Project should be invalid if pubspec.yaml is missing.');
    });
  });
}

Future<void> _createIosStructure(FileSystem fileSystem, String projectPath) async {
  final iosDir = fileSystem.directory(pathlib.join(projectPath, 'ios', 'Runner'));
  await iosDir.create(recursive: true);
  final plistFile = await iosDir.childFile('Info.plist').create();
  await plistFile.writeAsString(iosInfoPlist, flush: true);
  final xcodeProjFile = await fileSystem
      .file(
        pathlib.join(
          projectPath,
          ConfigFile.iosXcodeProject.projectRelativePath,
        ),
      )
      .create(recursive: true);
  await xcodeProjFile.writeAsString(iosXcodeProjectSrc, flush: true);
}

Future<void> _createAndroidStructure(FileSystem fileSystem, String projectPath) async {
  final androidDir = fileSystem.directory(pathlib.join(projectPath, 'android', 'app', 'src', 'main'));
  await androidDir.create(recursive: true);
  final manifestFile =
      await androidDir.childFile('AndroidManifest.xml').create();
  await manifestFile.writeAsString(androidManifest, flush: true);
  final buildGradleFile = await fileSystem
      .file(
        pathlib.join(
          projectPath,
          ConfigFile.appBuildGradle.projectRelativePath,
        ),
      )
      .create(recursive: true);
  await buildGradleFile.writeAsString(androidAppBuildGradle, flush: true);
}

Future<void> _createPubspecYaml(FileSystem fileSystem, String projectPath) async {
  final pubspecFile = fileSystem.file(pathlib.join(projectPath, ConfigFile.pubspecYaml.projectRelativePath));
  await pubspecFile.parent.create(recursive: true);
  await pubspecFile.writeAsString(pubspecYaml, flush: true);
}
