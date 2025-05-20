import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:propertylistserialization/propertylistserialization.dart';

final class AvailableProjects {
  final _current = <Project>[];
  final FileSystem fileSystem;

  AvailableProjects([this.fileSystem = const LocalFileSystem()]);

  List<Project> get current => _current;
  final _streamController = StreamController<List<Project>>.broadcast();
  Stream<List<Project>> get stream => _streamController.stream;

  Future<void> add(String path) async {
    final project = await Project.fromDir(fileSystem.directory(path));
    _current.add(project);
    _streamController.add(_current);
  }

  void dispose() {
    _streamController.close();
  }
}

enum SupportedPlatform { ios, android }

final class Project {
  final Directory directory;
  final String name;
  final Set<SupportedPlatform> supportedPlatforms;
  final String? iosAppName;

  Project(this.directory, {required this.supportedPlatforms, this.iosAppName})
    : name = path.split(directory.path).last;

  static Future<Project> fromDir(Directory directory) async {
    final supportedPlatforms = await _resolveSupportedPlatforms(directory);
    String? iosAppName;
    if (supportedPlatforms.contains(SupportedPlatform.ios)) {
      try {
        final plistFile = directory
            .childDirectory('ios')
            .childDirectory('Runner')
            .childFile('Info.plist');
        if (await plistFile.exists()) {
          final result = await plistFile.readAsString();
          final dict =
              PropertyListSerialization.propertyListWithString(result)
                  as Map<String, Object>;
          iosAppName = dict['CFBundleDisplayName'] as String;
        }
      } on PropertyListReadStreamException catch (e) {
        // handle error.
      }
    }
    return Project(
      directory,
      supportedPlatforms: supportedPlatforms,
      iosAppName: iosAppName,
    );
  }

  static Future<Set<SupportedPlatform>> _resolveSupportedPlatforms(
    Directory directory,
  ) async {
    final supportedPlatforms = <SupportedPlatform>{};
    await for (final item in directory.list()) {
      if (item is Directory && path.split(item.path).last == 'ios') {
        supportedPlatforms.add(SupportedPlatform.ios);
      }
      if (item is Directory && path.split(item.path).last == 'android') {
        supportedPlatforms.add(SupportedPlatform.android);
      }
    }
    return supportedPlatforms;
  }
}
