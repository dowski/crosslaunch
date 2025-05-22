import 'dart:async';

import 'package:crosslaunch/values.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as pathlib;

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

sealed class Project {
  String get name;
  static Future<Project> fromDir(Directory directory) async {
    try {
      return await ValidProject._fromDir(directory);
    } catch (e) {
      return InvalidProject(directory.path);
    }
  }
}

final class ValidProject implements Project {
  final Directory directory;
  @override
  final String name;
  final Set<SupportedPlatform> supportedPlatforms;
  final List<(CommonProperty, CommonValue?)> attributes;

  ValidProject(
    this.directory, {
    required this.supportedPlatforms,
    required this.attributes,
  }) : name = pathlib.split(directory.path).last;

  static Future<ValidProject> _fromDir(Directory directory) async {
    final supportedPlatforms = await _resolveSupportedPlatforms(directory);
    if (supportedPlatforms.isEmpty) throw Exception('No supported platforms');
    final properties = [CommonProperty.appName];
    final values = await PropertyLoader(
      fileSystem: directory.fileSystem,
    ).load(properties, directory: directory, platforms: supportedPlatforms);
    // Zip the properties and values together into an attributes list.
    final attributes = List.generate(
      properties.length,
      (index) => (properties[index], values[index]),
    );

    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      attributes: attributes,
    );
  }

  static Future<Set<SupportedPlatform>> _resolveSupportedPlatforms(
    Directory directory,
  ) async {
    final supportedPlatforms = <SupportedPlatform>{};
    await for (final item in directory.list()) {
      if (item is Directory && pathlib.split(item.path).last == 'ios') {
        supportedPlatforms.add(SupportedPlatform.ios);
      }
      if (item is Directory && pathlib.split(item.path).last == 'android') {
        supportedPlatforms.add(SupportedPlatform.android);
      }
    }
    return supportedPlatforms;
  }

  bool get hasEdits => attributes.any(
    (element) =>
        (element.$2?.androidValue?.isEdited ?? false) ||
        (element.$2?.iosValue?.isEdited ?? false),
  );
}

final class InvalidProject implements Project {
  final String path;
  @override
  final String name;

  InvalidProject(this.path)
    : name = pathlib.split(path).lastWhere((e) => e.trim().isNotEmpty);
}
