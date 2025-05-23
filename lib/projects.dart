import 'dart:async';

import 'package:crosslaunch/fs/access.dart';
import 'package:crosslaunch/platform.dart';
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
    _streamController.add(List.of(_current));
  }

  void edit(ValidProject project, ProjectEdit edit) {
    switch (edit) {
      case AppNameEdit edit:
        final updatedProject = project._withNewAppName(
          edit.newName,
          editTarget: edit.target,
        );
        _replaceProject(current: project, updated: updatedProject);
      case ApplicationIdEdit edit:
        final updatedProject = project._withNewApplicationId(
          edit.newApplicationId,
          editTarget: edit.target,
        );
        _replaceProject(current: project, updated: updatedProject);
    }
  }

  Future<void> save(ValidProject project) async {
    if (project.hasEdits) {
      final configStore = ConfigStore(
        appDirectory: project.directory,
        fileSystem: project.directory.fileSystem,
      );
      await configStore.saveAndroidManifest(project.androidManifest!);
      await configStore.saveIosInfoPlist(project.iosInfoPlist!);
      await configStore.saveAppBuildGradle(project.appBuildGradle!);
      await configStore.saveIosXcodeProject(project.iosXcodeProject!);
      final reloadedProject = await ValidProject._fromDir(project.directory);
      _replaceProject(current: project, updated: reloadedProject);
    }
  }

  void _replaceProject({
    required ValidProject current,
    required ValidProject updated,
  }) {
    final index = _current.indexOf(current);
    _current[index] = updated;
    _streamController.add(List.of(_current));
  }

  void dispose() {
    _streamController.close();
  }
}

enum EditTarget {
  android,
  ios,
  both;

  bool get includesAndroid =>
      this == EditTarget.android || this == EditTarget.both;

  bool get includesIos => this == EditTarget.ios || this == EditTarget.both;
}

sealed class ProjectEdit {
  EditTarget get target;
}

final class AppNameEdit implements ProjectEdit {
  final String newName;
  @override
  final EditTarget target;

  AppNameEdit.newName(this.newName, {required this.target});
}

final class ApplicationIdEdit implements ProjectEdit {
  final String newApplicationId;
  @override
  final EditTarget target;

  ApplicationIdEdit.newApplicationId(
    this.newApplicationId, {
    required this.target,
  });
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
  final AndroidManifest? androidManifest;
  final IosInfoPlist? iosInfoPlist;
  final AppBuildGradle? appBuildGradle;
  final IosXcodeProject? iosXcodeProject;

  ValidProject(
    this.directory, {
    required this.supportedPlatforms,
    required this.androidManifest,
    required this.iosInfoPlist,
    required this.appBuildGradle,
    required this.iosXcodeProject,
  }) : name = pathlib.split(directory.path).last;

  static Future<ValidProject> _fromDir(Directory directory) async {
    final supportedPlatforms = await _resolveSupportedPlatforms(directory);
    if (supportedPlatforms.isEmpty) throw Exception('No supported platforms');
    final configStore = ConfigStore(
      appDirectory: directory,
      fileSystem: directory.fileSystem,
    );

    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      androidManifest:
          supportedPlatforms.contains(SupportedPlatform.android)
              ? await configStore.loadAndroidManifest()
              : null,
      iosInfoPlist:
          supportedPlatforms.contains(SupportedPlatform.ios)
              ? await configStore.loadIosInfoPlist()
              : null,
      appBuildGradle:
          supportedPlatforms.contains(SupportedPlatform.android)
              ? await configStore.loadAppBuildGradle()
              : null,
      iosXcodeProject:
          supportedPlatforms.contains(SupportedPlatform.ios)
              ? await configStore.loadIosXcodeProject()
              : null,
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

  bool get hasEdits =>
      (androidManifest?.isModified ?? false) ||
      (iosInfoPlist?.isModified ?? false) ||
      (appBuildGradle?.isModified ?? false) ||
      (iosXcodeProject?.isModified ?? false);

  ValidProject _withNewAppName(
    String newName, {
    required EditTarget editTarget,
  }) {
    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      androidManifest:
          editTarget.includesAndroid
              ? androidManifest?.edit(androidLabel: newName)
              : androidManifest,
      iosInfoPlist:
          editTarget.includesIos
              ? iosInfoPlist?.edit(displayName: newName)
              : iosInfoPlist,
      appBuildGradle: appBuildGradle,
      iosXcodeProject: iosXcodeProject,
    );
  }

  ValidProject _withNewApplicationId(
    String newApplicationId, {
    required EditTarget editTarget,
  }) {
    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      androidManifest: androidManifest,
      iosInfoPlist: iosInfoPlist,
      appBuildGradle:
          editTarget.includesAndroid
              ? appBuildGradle?.edit(appId: newApplicationId)
              : appBuildGradle,
      iosXcodeProject:
          editTarget.includesIos
              ? iosXcodeProject?.edit(bundleId: newApplicationId)
              : iosXcodeProject,
    );
  }
}

final class InvalidProject implements Project {
  final String path;
  @override
  final String name;

  InvalidProject(this.path)
    : name = pathlib.split(path).lastWhere((e) => e.trim().isNotEmpty);
}
