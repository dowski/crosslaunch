import 'dart:typed_data';
import 'dart:ui';

import 'package:crosslaunch/fs/icons.dart';
import 'package:crosslaunch/testing/stub_data.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(IconStore, () {
    late Directory tempDir;
    late Directory correctProject;
    late Directory incorrectProject;
    late File androidIcon;
    late File iosIcon;
    late File newIcon;

    setUp(() async {
      final fs = LocalFileSystem();
      tempDir = await fs.systemTempDirectory.createTemp('test_');
      newIcon = await tempDir.childFile('newIcon.png').create();
      await newIcon.writeAsBytes(
        await _generateSolidColorPng(const Color.fromARGB(255, 255, 0, 0)),
      );
      correctProject = await tempDir.childDirectory('good').create();
      final androidManifestFile = await correctProject
          .childFile('android/app/src/main/AndroidManifest.xml')
          .create(recursive: true);
      await androidManifestFile.writeAsString(androidManifest);
      androidIcon = await correctProject
          .childFile(
            'android/app/src/main/res/mipmap-xxxhdpi/launcher_icon.png',
          )
          .create(recursive: true);
      await androidIcon.writeAsBytes(
        await _generateSolidColorPng(Color.fromARGB(255, 0, 255, 0)),
      );
      iosIcon = await correctProject
          .childFile(
            'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
          )
          .create(recursive: true);
      await iosIcon.writeAsBytes(
        await _generateSolidColorPng(Color.fromARGB(255, 0, 0, 255)),
      );
      final iosContentsFile = await correctProject
          .childFile('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json')
          .create(recursive: true);
      await iosContentsFile.writeAsString(iosContentsJson, flush: true);
      final iosPbxprojFile = await correctProject
          .childFile('ios/Runner.xcodeproj/project.pbxproj')
          .create(recursive: true);
      await iosPbxprojFile.writeAsString(iosXcodeProjectSrc, flush: true);
      incorrectProject = await tempDir.childDirectory('bad').create();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('can load icons for good project', () async {
      final iconStore = IconStore(appDirectory: correctProject);
      expect(await iconStore.androidIconImage, isNotNull);
      expect(await iconStore.iosIconImage, isNotNull);
    });

    test('can replace icons for good project', () async {
      final iconStore = IconStore(appDirectory: correctProject);
      final originalAndroidIconBytes =
          await (await iconStore.androidIconImage)?.readAsBytes();
      final originalIosIconBytes =
          await (await iconStore.iosIconImage)?.readAsBytes();
      await iconStore.replaceIcon(newIcon.path);
      expect(
        originalIosIconBytes,
        isNot(await (await iconStore.iosIconImage)?.readAsBytes()),
      );
      expect(
        originalAndroidIconBytes,
        isNot(await (await iconStore.androidIconImage)?.readAsBytes()),
      );
    });

    test('null icons returned for incorrect project', () async {
      final iconStore = IconStore(appDirectory: incorrectProject);
      expect(await iconStore.androidIconImage, isNull);
      expect(await iconStore.iosIconImage, isNull);
    });
  });
}

Future<Uint8List> _generateSolidColorPng(Color color) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = color;

  canvas.drawRect(const Rect.fromLTWH(0, 0, 1024, 1024), paint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}

const iosContentsJson = '''
{
  "images" : [
    {
      "size" : "1024x1024",
      "idiom" : "ios-marketing",
      "filename" : "Icon-App-1024x1024@1x.png",
      "scale" : "1x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
''';