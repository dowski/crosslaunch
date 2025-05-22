import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as pathlib;

enum ConfigFile {
  androidManifest(
    projectRelativePath: 'android/app/src/main/AndroidManifest.xml',
  ),
  iosInfoPlist(projectRelativePath: 'ios/Runner/Info.plist'),
  appBuildGradle(projectRelativePath: 'android/app/build.gradle.kts'),
  iosXcodeProject(projectRelativePath: 'ios/Runner.xcodeproj/project.pbxproj');

  final String projectRelativePath;

  const ConfigFile({required this.projectRelativePath});
}

class AndroidManifest {
  static final _labelPattern = RegExp(r'(android:label\s*=\s*")([^"]+)(")');

  final String _originalAndroidLabel;
  final String? _newAndroidLabel;
  final String _sourceXml;

  AndroidManifest._({
    required String androidLabel,
    required String xml,
    String? newAndroidLabel,
  }) : _sourceXml = xml,
       _originalAndroidLabel = androidLabel,
       _newAndroidLabel = newAndroidLabel;
  factory AndroidManifest.fromXml({required String xml}) {
    for (final line in xml.split('\n')) {
      final match = _labelPattern.firstMatch(line);
      if (match != null) {
        return AndroidManifest._(androidLabel: match.group(2)!, xml: xml);
      }
    }
    throw StateError('android:label not found in xml');
  }

  AndroidManifest edit({String? androidLabel}) {
    if (androidLabel == null || this.androidLabel == androidLabel) {
      return this;
    }
    return AndroidManifest._(
      androidLabel: _originalAndroidLabel,
      xml: _sourceXml,
      newAndroidLabel: androidLabel,
    );
  }

  bool get isModified =>
      _newAndroidLabel != null && _newAndroidLabel != _originalAndroidLabel;

  String get androidLabel => _newAndroidLabel ?? _originalAndroidLabel;
}

class AppBuildGradle {
  static final _appIdPattern = RegExp(r'(applicationId\s*=\s*")([^"]+)(")');

  final String _originalAppId;
  final String? _newAppId;
  final String _sourceKts;

  AppBuildGradle._({
    required String appId,
    required String kts,
    String? newAppId,
  }) : _sourceKts = kts,
       _originalAppId = appId,
       _newAppId = newAppId;
  factory AppBuildGradle.fromKts({required String kts}) {
    for (final line in kts.split('\n')) {
      final match = _appIdPattern.firstMatch(line);
      if (match != null) {
        return AppBuildGradle._(appId: match.group(2)!, kts: kts);
      }
    }
    throw StateError('applicationId not found in kts');
  }

  String get applicationId => _newAppId ?? _originalAppId;
  bool get isModified => _newAppId != null && _newAppId != _originalAppId;

  AppBuildGradle edit({String? appId}) {
    if (appId == null || appId == applicationId) {
      return this;
    }
    return AppBuildGradle._(
      appId: _originalAppId,
      kts: _sourceKts,
      newAppId: appId,
    );
  }
}

class IosInfoPlist {
  static final _valuePattern = RegExp(r'(<string>)([^<]+)(</string>.*)');
  static final _displayNameKeyPattern = RegExp(
    r'<key>CFBundleDisplayName</key>',
  );

  final String _originalDisplayName;
  final String? _newDisplayName;
  final String _sourceXml;

  IosInfoPlist._({
    required String displayName,
    required String xml,
    String? newDisplayName,
  }) : _sourceXml = xml,
       _newDisplayName = newDisplayName,
       _originalDisplayName = displayName;
  factory IosInfoPlist.fromXml({required String xml}) {
    var lookingForValue = false;
    for (final line in xml.split('\n')) {
      if (lookingForValue) {
        final match = _valuePattern.firstMatch(line);
        if (match != null) {
          return IosInfoPlist._(displayName: match.group(2)!, xml: xml);
        }
      } else if (_displayNameKeyPattern.hasMatch(line)) {
        lookingForValue = true;
      }
    }
    throw StateError('CFBundleDisplayName not found in xml');
  }

  IosInfoPlist edit({String? displayName}) {
    if (displayName == null || displayName == this.displayName) {
      return this;
    }
    return IosInfoPlist._(
      displayName: _originalDisplayName,
      xml: _sourceXml,
      newDisplayName: displayName,
    );
  }

  bool get isModified =>
      _newDisplayName != null && _newDisplayName != _originalDisplayName;
  String get displayName => _newDisplayName ?? _originalDisplayName;
}

class IosXcodeProject {
  static final _bundleIdPattern = RegExp(
    r'(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*)([^;]+)(;)',
  );

  final String _originalBundleId;
  final String? _newBundleId;
  final String _sourcePbxproj;

  IosXcodeProject._({
    required String bundleId,
    required String pbxproj,
    String? newBundleId,
  }) : _sourcePbxproj = pbxproj,
       _newBundleId = newBundleId,
       _originalBundleId = bundleId;
  factory IosXcodeProject.fromPbxproj({required String pbxproj}) {
    for (final line in pbxproj.split('\n')) {
      final match = _bundleIdPattern.firstMatch(line);
      if (match != null) {
        return IosXcodeProject._(bundleId: match.group(2)!, pbxproj: pbxproj);
      }
    }
    throw StateError('PRODUCT_BUNDLE_IDENTIFIER not found in pbxproj');
  }

  IosXcodeProject edit({String? bundleId}) {
    if (bundleId == null || bundleId == this.bundleId) {
      return this;
    }
    return IosXcodeProject._(
      bundleId: _originalBundleId,
      pbxproj: _sourcePbxproj,
      newBundleId: bundleId,
    );
  }

  bool get isModified => _newBundleId != null && _newBundleId != _originalBundleId;
  String get bundleId => _newBundleId ?? _originalBundleId;
}

class ConfigStore {
  final FileSystem _fileSystem;
  final Directory _appDirectory;

  ConfigStore({
    required Directory appDirectory,
    FileSystem fileSystem = const LocalFileSystem(),
  }) : _fileSystem = fileSystem,
       _appDirectory = appDirectory;

  Future<AndroidManifest> loadAndroidManifest() async {
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.androidManifest.projectRelativePath,
      ),
    );
    final contents = await file.readAsString();
    return AndroidManifest.fromXml(xml: contents);
  }

  Future<void> saveAndroidManifest(AndroidManifest manifest) async {
    if (!manifest.isModified) {
      return;
    }
    final modifiedXml = manifest._sourceXml
        .split('\n')
        .map((line) {
          if (AndroidManifest._labelPattern.hasMatch(line)) {
            return line.replaceFirstMapped(AndroidManifest._labelPattern, (
              match,
            ) {
              return '${match.group(1)}${manifest.androidLabel}${match.group(3)}';
            });
          }
          return line;
        })
        .join('\n');
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.androidManifest.projectRelativePath,
      ),
    );
    await file.writeAsString(modifiedXml);
  }

  Future<IosInfoPlist> loadIosInfoPlist() async {
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.iosInfoPlist.projectRelativePath,
      ),
    );
    final contents = await file.readAsString();
    return IosInfoPlist.fromXml(xml: contents);
  }

  Future<void> saveIosInfoPlist(IosInfoPlist infoPlist) async {
    if (!infoPlist.isModified) {
      return;
    }
    var shouldWriteValue = false;
    final modifiedXml = infoPlist._sourceXml
        .split('\n')
        .map((line) {
          if (shouldWriteValue && IosInfoPlist._valuePattern.hasMatch(line)) {
            shouldWriteValue = false;
            return line.replaceFirstMapped(IosInfoPlist._valuePattern, (match) {
              return '${match.group(1)}${infoPlist.displayName}${match.group(3)}';
            });
          } else if (IosInfoPlist._displayNameKeyPattern.hasMatch(line)) {
            shouldWriteValue = true;
          }
          return line;
        })
        .join('\n');
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.iosInfoPlist.projectRelativePath,
      ),
    );
    await file.writeAsString(modifiedXml);
  }

  Future<AppBuildGradle> loadAppBuildGradle() async {
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.appBuildGradle.projectRelativePath,
      ),
    );
    final contents = await file.readAsString();
    return AppBuildGradle.fromKts(kts: contents);
  }

  Future<void> saveAppBuildGradle(AppBuildGradle buildGradle) async {
    if (!buildGradle.isModified) {
      return;
    }
    final modifiedKts = buildGradle._sourceKts
        .split('\n')
        .map((line) {
          if (AppBuildGradle._appIdPattern.hasMatch(line)) {
            return line.replaceFirstMapped(AppBuildGradle._appIdPattern, (
              match,
            ) {
              return '${match.group(1)}${buildGradle.applicationId}${match.group(3)}';
            });
          }
          return line;
        })
        .join('\n');
    final file = await _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.appBuildGradle.projectRelativePath,
      ),
    );
    await file.writeAsString(modifiedKts);
  }

  Future<IosXcodeProject> loadIosXcodeProject() async {
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.iosXcodeProject.projectRelativePath,
      ));
    final contents = await file.readAsString();
    return IosXcodeProject.fromPbxproj(pbxproj: contents);
  }

  Future<void> saveIosXcodeProject(IosXcodeProject project) async {
    if (!project.isModified) {
      return;
    }
    final modifiedPbxproj = project._sourcePbxproj
        .split('\n')
        .map((line) {
          if (IosXcodeProject._bundleIdPattern.hasMatch(line)) {
            return line.replaceFirstMapped(IosXcodeProject._bundleIdPattern, (
              match,
            ) {
              return '${match.group(1)}${project.bundleId}${match.group(3)}';
            });
          }
          return line;
        })
        .join('\n');
    final file = _fileSystem.file(
      pathlib.join(
        _appDirectory.path,
        ConfigFile.iosXcodeProject.projectRelativePath,
      ),
    );
    await file.writeAsString(modifiedPbxproj);
  }
}
