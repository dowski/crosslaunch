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
    test('no ios or android folder has no supported platforms', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      // Web isn't supported so this should have no impact.
      final webDir = fileSystem.directory('/foo/bar/web');
      await webDir.create();

      final project = await Project.fromKey(projectDir);
      expect(project.supportedPlatforms, isEmpty);
    });

    test('ios folder leads to ios platform being present', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      final iosDir = fileSystem.directory('/foo/bar/ios');
      await iosDir.create();

      final project = await Project.fromKey(projectDir);
      expect(project.supportedPlatforms, contains(SupportedPlatform.ios));
    });

    test('android folder leads to android platform being present', () async {
      final projectDir = fileSystem.directory('/foo/bar');
      await projectDir.create(recursive: true);

      final androidDir = fileSystem.directory('/foo/bar/android');
      await androidDir.create();

      final project = await Project.fromKey(projectDir);
      expect(
        project.supportedPlatforms,
        contains(SupportedPlatform.android),
      );
    });

    test(
      'android and ios folder leads to both platforms being present',
      () async {
        final projectDir = fileSystem.directory('/foo/bar');
        await projectDir.create(recursive: true);

        final androidDir = fileSystem.directory('/foo/bar/android');
        await androidDir.create();
        final iosDir = fileSystem.directory('/foo/bar/ios');
        await iosDir.create();

        final project = await Project.fromKey(projectDir);
        expect(
          project.supportedPlatforms,
          containsAll([SupportedPlatform.android, SupportedPlatform.ios]),
        );
      },
    );
  });
}
