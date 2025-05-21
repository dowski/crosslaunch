import 'package:crosslaunch/testing/stub_data.dart';
import 'package:crosslaunch/values.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FileSystem fileSystem;
  setUp(() {
    fileSystem = MemoryFileSystem();
  });
  group(PropertyLoader, () {
    test('can load values', () async {
      // Add manifest and plist to file system
      final manifestFile = await fileSystem.file(AndroidPropertySource.manifest.path).create(recursive: true);
      await manifestFile.writeAsString(androidManifest);
      final plistFile = await fileSystem.file(IosPropertySource.infoPlist.path).create(recursive: true);
      await plistFile.writeAsString(iosInfoPlist);

      // Load the values.
      final propertyLoader = PropertyLoader(fileSystem: fileSystem);
      final values = await propertyLoader.load([CommonProperty.appName], directory: fileSystem.currentDirectory, platforms: {SupportedPlatform.android, SupportedPlatform.ios});

      expect(values, hasLength(1));
      expect(values.first?.androidValue?.value, 'flutter_app');
      expect(values.first?.iosValue?.value, 'flutter_app');
    });
  });

  group(AndroidStringProperty, () {
    test('can find label in manifest', () {
      var found = false;
      for (final line in androidManifest.split('\n')) {
        if (AndroidStringProperty.label.shouldLookForValue(line)) {
          found = true;
          break;
        }
      }
      expect(found, true);
    });

    test('can extract label from manifest', () {
      var isLooking = false;
      PlatformValue? label;
      for (final line in androidManifest.split('\n')) {
        if (isLooking || AndroidStringProperty.label.shouldLookForValue(line)) {
          isLooking = true;
          label = AndroidStringProperty.label.valueFromSource(line);
          if (label != null) break;
        }
      }
      expect(label?.value, 'flutter_app');
    });
  });

  group(IosStringProperty, () {
    test('can find label in plist', () {
      var found = false;
      for (final line in iosInfoPlist.split('\n')) {
        if (IosStringProperty.displayName.shouldLookForValue(line)) {
          found = true;
          break;
        }
      }
      expect(found, true);
    });

    test('can extract label from plist', () {
      var isLooking = false;
      PlatformValue? label;
      for (final line in iosInfoPlist.split('\n')) {
        if (isLooking || IosStringProperty.displayName.shouldLookForValue(line)) {
          isLooking = true;
          label = IosStringProperty.displayName.valueFromSource(line);
          if (label != null) break;
        }
      }
      expect(label?.value, 'flutter_app');
    });
  });
}
