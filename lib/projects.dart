import 'dart:async';

import 'package:crosslaunch/fs/access.dart';
import 'package:crosslaunch/fs/icons.dart';
import 'package:crosslaunch/platform.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as pathlib;

final class AvailableProjects {
  final _current = <Project>[];
  final FileSystem fileSystem;

  AvailableProjects([this.fileSystem = const LocalFileSystem()]);

  List<Project> get current => _current;
  final _streamController = StreamController<List<Project>>.broadcast();
  Stream<List<Project>> get stream => _streamController.stream;

  Future<int> add(String path) async {
    final project = await Project.fromDir(fileSystem.directory(path));
    _current.add(project);
    _streamController.add(List.of(_current));
    return _current.length;
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
      case AppIconEdit edit:
        final updatedProject = project._withReplacementIconPath(
          edit.newIconPath,
        );
        _replaceProject(current: project, updated: updatedProject);
      case PubspecEdit edit:
        final updatedProject = project._withNewPubspecValues(
          versionName: edit.versionName ?? project.pubspecYaml?.versionName,
          versionCode: edit.versionCode ?? project.pubspecYaml?.versionCode,
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
      await configStore.savePubspecYaml(project.pubspecYaml!);
      if (project.replacementIconPath != null) {
        // I think this eviction is necessary but not sufficient to force
        // the images visible in the app to reload.
        await project.androidIconImage?.evict();
        await project.iosIconImage?.evict();
        final iconStore = IconStore(appDirectory: project.directory);
        await iconStore.replaceIcon(project.replacementIconPath!);
      }
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

sealed class ProjectEdit {}

sealed class PlatformSpecificEdit extends ProjectEdit {
  EditTarget get target;
}

final class AppNameEdit extends PlatformSpecificEdit {
  final String newName;
  @override
  final EditTarget target;

  AppNameEdit.newName(this.newName, {required this.target});
}

final class ApplicationIdEdit extends PlatformSpecificEdit {
  final String newApplicationId;
  @override
  final EditTarget target;

  ApplicationIdEdit.newApplicationId(
    this.newApplicationId, {
    required this.target,
  });
}

final class AppIconEdit extends PlatformSpecificEdit {
  final String newIconPath;
  @override
  final EditTarget target = EditTarget.both;

  AppIconEdit(this.newIconPath);
}

final class PubspecEdit extends ProjectEdit {
  final String? versionName;
  final String? versionCode;

  PubspecEdit({this.versionName, this.versionCode});
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
  final PubspecYaml? pubspecYaml;
  final ImageProvider? iosIconImage;
  final ImageProvider? androidIconImage;
  final String? replacementIconPath;

  ImageProvider? get replacementPreviewImage {
    if (replacementIconPath == null) return null;
    return FileImage(directory.fileSystem.file(replacementIconPath!));
  }

  ValidProject(
    this.directory, {
    required this.supportedPlatforms,
    required this.androidManifest,
    required this.iosInfoPlist,
    required this.appBuildGradle,
    required this.iosXcodeProject,
    required this.pubspecYaml,
    required this.iosIconImage,
    required this.androidIconImage,
    required this.replacementIconPath,
  }) : name = pathlib.split(directory.path).last;

  static Future<ValidProject> _fromDir(Directory directory) async {
    final supportedPlatforms = await _resolveSupportedPlatforms(directory);
    if (supportedPlatforms.isEmpty) throw Exception('No supported platforms');
    final configStore = ConfigStore(
      appDirectory: directory,
      fileSystem: directory.fileSystem,
    );
    final iconStore = IconStore(appDirectory: directory);
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
      pubspecYaml: await configStore.loadPubspecYaml(),
      iosIconImage: (await iconStore.iosIconImage)?.imageProvider,
      androidIconImage: (await iconStore.androidIconImage)?.imageProvider,
      replacementIconPath: null,
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

  bool get isVisibleVersionFromPubspec => (appBuildGradle?.isVersionNameFromPubspec ?? false) && (iosInfoPlist?.isVersionNameFromPubspec ?? false);
  bool get isInternalVersionFromPubspec => (appBuildGradle?.isVersionCodeFromPubspec ?? false) && (iosInfoPlist?.isVersionNumberFromPubspec ?? false);

  bool get hasEdits =>
      (androidManifest?.isModified ?? false) ||
      (iosInfoPlist?.isModified ?? false) ||
      (appBuildGradle?.isModified ?? false) ||
      (iosXcodeProject?.isModified ?? false) ||
      (replacementIconPath != null) ||
      (pubspecYaml?.isModified ?? false);

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
      pubspecYaml: pubspecYaml,
      iosIconImage: iosIconImage,
      androidIconImage: androidIconImage,
      replacementIconPath: replacementIconPath,
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
      pubspecYaml: pubspecYaml,
      iosIconImage: iosIconImage,
      androidIconImage: androidIconImage,
      replacementIconPath: replacementIconPath,
    );
  }

  ValidProject _withReplacementIconPath(String newIconPath) {
    return ValidProject(
      directory,
      appBuildGradle: appBuildGradle,
      pubspecYaml: pubspecYaml,
      iosXcodeProject: iosXcodeProject,
      supportedPlatforms: supportedPlatforms,
      androidManifest: androidManifest,
      iosInfoPlist: iosInfoPlist,
      iosIconImage: iosIconImage,
      androidIconImage: androidIconImage,
      replacementIconPath: newIconPath,
    );
  }

  ValidProject _withNewPubspecValues({
    String? versionName,
    String? versionCode,
  }) {
    return ValidProject(
      directory,
      supportedPlatforms: supportedPlatforms,
      androidManifest: androidManifest,
      iosInfoPlist: iosInfoPlist,
      appBuildGradle: appBuildGradle,
      iosXcodeProject: iosXcodeProject,
      pubspecYaml: pubspecYaml?.edit(
        versionName: versionName,
        versionCode: versionCode,
      ),
      iosIconImage: iosIconImage,
      androidIconImage: androidIconImage,
      replacementIconPath: replacementIconPath,
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

extension on File {
  ImageProvider get imageProvider {
    return FileImage(this);
  }
}
