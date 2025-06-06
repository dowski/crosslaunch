import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as pathlib;

enum ConfigFile {
  androidManifest(
    projectRelativePath: 'android/app/src/main/AndroidManifest.xml',
  ),
  iosInfoPlist(projectRelativePath: 'ios/Runner/Info.plist'),
  appBuildGradle(projectRelativePath: 'android/app/build.gradle.kts'),
  iosXcodeProject(projectRelativePath: 'ios/Runner.xcodeproj/project.pbxproj'),
  pubspecYaml(projectRelativePath: 'pubspec.yaml');

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
  static final _versionNamePattern = RegExp(
    r'(\s*versionName\s*=\s*)([^,\n\r/]+)(\s*(?:[,/\n\r].*)??)',
  );
  static final _versionCodePattern = RegExp(
    r'(\s*versionCode\s*=\s*)([^,\n\r/]+)(\s*(?:[,/\n\r].*)??)',
  );

  final String _originalAppId;
  final String? _newAppId;
  final String _originalVersionName;
  final String? _newVersionName;
  final String _originalVersionCode;
  final String? _newVersionCode;
  final String _sourceKts;

  AppBuildGradle._({
    required String appId,
    required String versionName,
    required String versionCode,
    required String kts,
    String? newAppId,
    String? newVersionName,
    String? newVersionCode,
  }) : _sourceKts = kts,
       _originalAppId = appId,
       _newAppId = newAppId,
       _originalVersionName = versionName,
       _newVersionName = newVersionName,
       _originalVersionCode = versionCode,
       _newVersionCode = newVersionCode;
  factory AppBuildGradle.fromKts({required String kts}) {
    final appId = SingleLineMatch(_appIdPattern);
    final versionName = SingleLineMatch(_versionNamePattern);
    final versionCode = SingleLineMatch(_versionCodePattern);
    for (final line in kts.split('\n')) {
      for (final matcher in [
        appId,
        versionName,
        versionCode,
      ].where((m) => m.isNotSatisfied)) {
        if (matcher.tryLine(line)) {
          break;
        }
      }
    }
    return AppBuildGradle._(
      appId: appId.value!,
      versionName: versionName.value!,
      versionCode: versionCode.value!,
      kts: kts,
    );
  }

  String get applicationId => _newAppId ?? _originalAppId;
  String get versionName => _newVersionName ?? _originalVersionName;
  String get versionCode => _newVersionCode ?? _originalVersionCode;
  bool get isModified =>
      (_newAppId != null && _newAppId != _originalAppId) ||
      (_newVersionName != null && _newVersionName != _originalVersionName) ||
      (_newVersionCode != null && _newVersionCode != _originalVersionCode);

  AppBuildGradle edit({
    String? appId,
    String? versionName,
    String? versionCode,
  }) {
    if ((appId == null || appId == applicationId) &&
        (versionName == null || versionName == this.versionName) &&
        (versionCode == null || versionCode == this.versionCode)) {
      return this;
    }
    return AppBuildGradle._(
      appId: _originalAppId,
      versionName: _originalVersionName,
      versionCode: _originalVersionCode,
      kts: _sourceKts,
      newAppId: appId,
      newVersionName: versionName,
      newVersionCode: versionCode,
    );
  }
}

class IosInfoPlist {
  static final _valuePattern = RegExp(r'(<string>)([^<]+)(</string>.*)');
  static final _displayNameKeyPattern = RegExp(
    r'<key>CFBundleDisplayName</key>',
  );
  static final _versionStringKeyPattern = RegExp(
    r'<key>CFBundleShortVersionString</key>',
  );
  static final _versionNumberKeyPattern = RegExp(r'<key>CFBundleVersion</key>');

  final String _originalDisplayName;
  final String? _newDisplayName;
  final String _originalVersionString;
  final String? _newVersionString;
  final String _originalVersionNumber;
  final String? _newVersionNumber;
  final String _sourceXml;

  IosInfoPlist._({
    required String displayName,
    required String versionString,
    required String versionNumber,
    required String xml,
    String? newDisplayName,
    String? newVersionString,
    String? newVersionNumber,
  }) : _sourceXml = xml,
       _newDisplayName = newDisplayName,
       _originalDisplayName = displayName,
       _newVersionString = newVersionString,
       _originalVersionString = versionString,
       _newVersionNumber = newVersionNumber,
       _originalVersionNumber = versionNumber;
  factory IosInfoPlist.fromXml({required String xml}) {
    var lookingForDisplayName = false;
    var lookingForVersionString = false;
    var lookingForVersionNumber = false;
    String? displayName;
    String? versionString;
    String? versionNumber;
    for (final line in xml.split('\n')) {
      if (lookingForDisplayName && displayName == null) {
        final match = _valuePattern.firstMatch(line);
        if (match != null) {
          displayName = match.group(2);
        }
      } else if (displayName == null && _displayNameKeyPattern.hasMatch(line)) {
        lookingForDisplayName = true;
        continue;
      }
      if (lookingForVersionString && versionString == null) {
        final match = _valuePattern.firstMatch(line);
        if (match != null) {
          versionString = match.group(2);
        }
      } else if (versionString == null &&
          _versionStringKeyPattern.hasMatch(line)) {
        lookingForVersionString = true;
      }
      if (lookingForVersionNumber && versionNumber == null) {
        final match = _valuePattern.firstMatch(line);
        if (match != null) {
          versionNumber = match.group(2);
        }
      } else if (versionNumber == null &&
          _versionNumberKeyPattern.hasMatch(line)) {
        lookingForVersionNumber = true;
      }
    }
    if (displayName != null && versionString != null && versionNumber != null) {
      return IosInfoPlist._(
        displayName: displayName,
        versionString: versionString,
        versionNumber: versionNumber,
        xml: xml,
      );
    }
    throw StateError('values missing in xml');
  }

  IosInfoPlist edit({
    String? displayName,
    String? versionName,
    String? versionNumber,
  }) {
    if ((displayName == null || displayName == this.displayName) &&
        (versionName == null || versionName == this.versionName) &&
        (versionNumber == null || versionNumber == this.versionNumber)) {
      return this;
    }
    return IosInfoPlist._(
      displayName: _originalDisplayName,
      versionString: _originalVersionString,
      versionNumber: _originalVersionNumber,
      xml: _sourceXml,
      newDisplayName: displayName,
      newVersionString: versionName,
      newVersionNumber: versionNumber,
    );
  }

  bool get isModified =>
      (_newDisplayName != null && _newDisplayName != _originalDisplayName) ||
      (_newVersionString != null &&
          _newVersionString != _originalVersionString) ||
      (_newVersionNumber != null &&
          _newVersionNumber != _originalVersionNumber);
  String get displayName => _newDisplayName ?? _originalDisplayName;
  String get versionName => _newVersionString ?? _originalVersionString;
  String get versionNumber => _newVersionNumber ?? _originalVersionNumber;
}

class IosXcodeProject {
  static final _bundleIdPattern = RegExp(
    r'(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*)(\w+(?:\.(?!RunnerTests)\w+)*)(\.RunnerTests;|;)',
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

  bool get isModified =>
      _newBundleId != null && _newBundleId != _originalBundleId;
  String get bundleId => _newBundleId ?? _originalBundleId;
}

class PubspecYaml {
  static final _versionPattern = RegExp(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)');

  final String _originalVersionName;
  final String _originalVersionCode;
  final String? _newVersionName;
  final String? _newVersionCode;
  final String _sourceYaml;

  PubspecYaml._({
    required String versionName,
    required String versionCode,
    required String yaml,
    String? newVersionName,
    String? newVersionCode,
  }) : _sourceYaml = yaml,
       _originalVersionName = versionName,
       _originalVersionCode = versionCode,
       _newVersionName = newVersionName,
       _newVersionCode = newVersionCode;

  factory PubspecYaml.fromYaml({required String yaml}) {
    for (final line in yaml.split('\n')) {
      final match = _versionPattern.firstMatch(line);
      if (match != null) {
        return PubspecYaml._(
          versionName: match.group(1)!,
          versionCode: match.group(2)!,
          yaml: yaml,
        );
      }
    }
    throw StateError('version not found in pubspec.yaml');
  }

  String get versionName => _newVersionName ?? _originalVersionName;
  String get versionCode => _newVersionCode ?? _originalVersionCode;

  bool get isModified =>
      (_newVersionName != null && _newVersionName != _originalVersionName) ||
      (_newVersionCode != null && _newVersionCode != _originalVersionCode);

  PubspecYaml edit({String? versionName, String? versionCode}) {
    if ((versionName == null || versionName == this.versionName) &&
        (versionCode == null || versionCode == this.versionCode)) {
      return this;
    }
    return PubspecYaml._(
      versionName: _originalVersionName,
      versionCode: _originalVersionCode,
      yaml: _sourceYaml,
      newVersionName: versionName,
      newVersionCode: versionCode,
    );
  }
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
    final fieldUpdates = [
      PlistFieldUpdate(
        keyPattern: IosInfoPlist._displayNameKeyPattern,
        valuePattern: IosInfoPlist._valuePattern,
        newValue: infoPlist.displayName,
      ),
      PlistFieldUpdate(
        keyPattern: IosInfoPlist._versionStringKeyPattern,
        valuePattern: IosInfoPlist._valuePattern,
        newValue: infoPlist.versionName,
      ),
      PlistFieldUpdate(
        keyPattern: IosInfoPlist._versionNumberKeyPattern,
        valuePattern: IosInfoPlist._valuePattern,
        newValue: infoPlist.versionNumber,
      ),
    ];
    final modifiedXml = infoPlist._sourceXml
        .split('\n')
        .map((line) {
          for (final update in fieldUpdates) {
            if (!update.isApplied) {
              final updatedLine = update.updateLine(line);
              if (updatedLine != null) {
                return updatedLine;
              }
            }
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

    final updates = [
      SingleLineUpdate(AppBuildGradle._appIdPattern, buildGradle.applicationId),
      SingleLineUpdate(
        AppBuildGradle._versionNamePattern,
        buildGradle.versionName,
      ),
      SingleLineUpdate(
        AppBuildGradle._versionCodePattern,
        buildGradle.versionCode,
      ),
    ];
    final modifiedKts = buildGradle._sourceKts
        .split('\n')
        .map((line) {
          for (final update in updates.where(
            (update) => update.isNotSatisfied,
          )) {
            final updatedLine = update.tryReplace(line);
            if (updatedLine != null) {
              return updatedLine;
            }
          }
          return line;
        })
        .join('\n');
    final file = _fileSystem.file(
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
      ),
    );
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

class PlistFieldUpdate {
  final RegExp keyPattern;
  final RegExp valuePattern;
  final String newValue;
  var isKeyMatched = false;
  var isApplied = false;

  PlistFieldUpdate({
    required this.keyPattern,
    required this.valuePattern,
    required this.newValue,
  });

  String? updateLine(String line) {
    if (isKeyMatched && valuePattern.hasMatch(line)) {
      isApplied = true;
      return line.replaceFirstMapped(IosInfoPlist._valuePattern, (match) {
        return '${match.group(1)}$newValue${match.group(3)}';
      });
    } else if (keyPattern.hasMatch(line)) {
      isKeyMatched = true;
    }
    return null;
  }
}

abstract interface class LineMatch {
  bool get isNotSatisfied;
  String? get value;
  bool tryLine(String line);
}

class SingleLineMatch implements LineMatch {
  final RegExp _pattern;

  @override
  bool get isNotSatisfied => !_isSatisfied;
  @override
  String? value;
  bool _isSatisfied = false;

  SingleLineMatch(this._pattern);

  @override
  bool tryLine(String line) {
    if (_isSatisfied) throw StateError('called tryLine when satisfied');
    final match = _pattern.firstMatch(line);
    if (match != null) {
      _isSatisfied = true;
      value = match.group(2);
      return true;
    }
    return false;
  }
}

class SingleLineUpdate {
  final RegExp _pattern;
  final String newValue;

  bool get isNotSatisfied => !_isSatisfied;
  bool _isSatisfied = false;

  SingleLineUpdate(this._pattern, this.newValue);

  String? tryReplace(String line) {
    if (_pattern.hasMatch(line)) {
      _isSatisfied = true;

      return line.replaceFirstMapped(_pattern, (match) {
        return '${match.group(1)}$newValue${match.group(3)}';
      });
    }
    return null;
  }
}
