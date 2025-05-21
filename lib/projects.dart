import 'dart:async';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as pathlib;
import 'package:propertylistserialization/propertylistserialization.dart';
import 'package:xml/xml.dart';

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
  final String? iosAppName;
  final String? androidAppName;

  ValidProject(
    this.directory, {
    required this.supportedPlatforms,
    this.iosAppName,
    this.androidAppName,
  }) : name = pathlib.split(directory.path).last;

  static Future<ValidProject> _fromDir(Directory directory) async {
    final supportedPlatforms = await _resolveSupportedPlatforms(directory);
    if (supportedPlatforms.isEmpty) throw Exception('No supported platforms');
    String? iosAppName;
    String? androidAppName;
    if (supportedPlatforms.contains(SupportedPlatform.ios)) {
      final plistFile = directory
          .childDirectory('ios')
          .childDirectory('Runner')
          .childFile('Info.plist');
      final result = await plistFile.readAsString();
      final dict =
          PropertyListSerialization.propertyListWithString(result)
              as Map<String, Object>;
      iosAppName = dict['CFBundleDisplayName'] as String;
    }
    if (supportedPlatforms.contains(SupportedPlatform.android)) {
      final manifestFile = directory
          .childDirectory('android')
          .childFile('app/src/main/AndroidManifest.xml');
      final manifestXml = await manifestFile.readAsString();
      final manifest = XmlDocument.parse(manifestXml).firstElementChild;
      androidAppName = manifest?.findElements('application').first.attributes.firstWhere((attr) => attr.name.qualified == 'android:label').value;
    }
    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      iosAppName: iosAppName,
      androidAppName: androidAppName,
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
}

final class InvalidProject implements Project {
  final String path;
  @override
  final String name;

  InvalidProject(this.path) : name = pathlib.split(path).lastWhere((e) => e.trim().isNotEmpty);
}
