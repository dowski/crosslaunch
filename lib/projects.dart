import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

typedef ProjectKey = Directory;

final class AvailableProjects {
  final _current = <Project>[];

  List<Project> get current => _current;
  final _streamController = StreamController<List<Project>>.broadcast();
  Stream<List<Project>> get stream => _streamController.stream;

  Future<void> add(ProjectKey key) async {
    final project = await Project.fromKey(key);
    _current.add(project);
    _streamController.add(_current);
  }

  void dispose() {
    _streamController.close();
  }
}

enum SupportedPlatform { ios, android }

final class Project {
  final ProjectKey directory;
  final String name;
  final Set<SupportedPlatform> supportedPlatforms;

  Project(this.directory, {required this.supportedPlatforms})
    : name = path.split(directory.path).last;

  static Future<Project> fromKey(ProjectKey directory) async {
    return Project(
      directory,
      supportedPlatforms: await _resolveSupportedPlatforms(directory),
    );
  }

  static Future<Set<SupportedPlatform>> _resolveSupportedPlatforms(
    ProjectKey directory,
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
