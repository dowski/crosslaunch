import 'dart:io' as io;
import 'dart:isolate';

import 'package:file/file.dart';
import 'package:flutter_launcher_icons/config/config.dart' as icon_config;
import 'package:flutter_launcher_icons/logger.dart';
import 'package:flutter_launcher_icons/main.dart';

/// A source for iOS and Android app icons.
///
/// Can load representative icons to render in the UI and
/// supports replacing all sized icons generated from a new
/// replacement icon.
class IconStore {
  final Directory _appDirectory;
  static final _androidLauncherPattern = RegExp(
    'android:icon="@mipmap/([a-zA-Z0-9_]+)"',
    multiLine: true,
  );

  /// A new [IconStore] rooted at [appDirectory].
  ///
  /// [appDirectory] must be the root of a Flutter application (and contain 'ios/' and 'android/' sub directories).
  IconStore({required Directory appDirectory}) : _appDirectory = appDirectory;

  Future<File?> get iosIconImage {
    return _imageFileAtPath(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset',
      'Icon-App-1024x1024@1x.png',
    );
  }

  Future<File?> get androidIconImage async {
    final androidManifest = _appDirectory.childFile(
      'android/app/src/main/AndroidManifest.xml',
    );
    if (!(await androidManifest.exists())) return null;
    final xmlManifest = await androidManifest.readAsString();
    final launcherMatch = _androidLauncherPattern.firstMatch(xmlManifest);
    if (launcherMatch == null) return null;
    return _imageFileAtPath(
      'android/app/src/main/res/mipmap-xxxhdpi',
      '${launcherMatch.group(1)}.png',
    );
  }

  Future<File?> _imageFileAtPath(String path, String fileName) async {
    final iconDir = _appDirectory.childDirectory(path);
    final iconFile = iconDir.childFile(fileName);
    if (await iconFile.exists()) {
      return iconFile;
    }
    return null;
  }

  Future<void> replaceIcon(String newIconPath) async {
    await Isolate.run(() async {
      io.Directory.current = _appDirectory.absolute.path;
      final config = icon_config.Config(
        android: true,
        ios: true,
        imagePath: newIconPath,
        minSdkAndroid: 21,
        removeAlphaIOS: true,
      );
      await createIconsFromConfig(config, FLILogger(false), '.');
    });
  }
}
