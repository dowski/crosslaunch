import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as pathlib;



enum ConfigFile {
  androidManifest(projectRelativePath: 'android/app/src/main/AndroidManifest.xml'),
  iosInfoPlist(projectRelativePath: 'ios/Runner/Info.plist');

  final String projectRelativePath;

  const ConfigFile({required this.projectRelativePath});
}

class AndroidManifest {
  static final _labelPattern = RegExp(r'(android:label\s*=\s*")([^"]+)(")');

  final bool isModified;
  final String androidLabel;
  final String _originalXml;

  AndroidManifest._({required this.isModified, required this.androidLabel, required String xml}) : _originalXml = xml;
  factory AndroidManifest.fromXml({required String xml}) {
    for (final line in xml.split('\n')) {
      final match = _labelPattern.firstMatch(line);
      if (match != null) {
        return AndroidManifest._(androidLabel: match.group(2)!, isModified: false, xml: xml);
      }
    }
    throw StateError('android:label not found in xml');
  }


  AndroidManifest edit({String? androidLabel}) {
    if (androidLabel == null || androidLabel == this.androidLabel) {
      return this;
    }
    return AndroidManifest._(isModified: true, androidLabel: androidLabel, xml: _originalXml);
  }
}

class IosInfoPlist {
  static final _valuePattern = RegExp(r'(<string>)([^<]+)(</string>.*)');
  static final _displayNameKeyPattern = RegExp(r'<key>CFBundleDisplayName</key>');

  final bool isModified;
  final String displayName;
  final String _originalXml;

  IosInfoPlist._({required this.isModified, required this.displayName, required String xml}) : _originalXml = xml;
  factory IosInfoPlist.fromXml({required String xml}) {
    var lookingForValue = false;
    for (final line in xml.split('\n')) {
      if (lookingForValue) {
        final match = _valuePattern.firstMatch(line);
        if (match != null) {
          return IosInfoPlist._(displayName: match.group(2)!, isModified: false, xml: xml);
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
    return IosInfoPlist._(isModified: true, displayName: displayName, xml: _originalXml);
  }
}

class ConfigStore {
  final FileSystem _fileSystem;
  final Directory _appDirectory;


  ConfigStore({required Directory appDirectory, FileSystem fileSystem = const LocalFileSystem()}) : _fileSystem = fileSystem, _appDirectory = appDirectory;

  Future<AndroidManifest> loadAndroidManifest() async {
    final file = _fileSystem.file(pathlib.join(_appDirectory.path, ConfigFile.androidManifest.projectRelativePath));
    final contents = await file.readAsString();
    return AndroidManifest.fromXml(xml: contents);
  }

  Future<void> saveAndroidManifest(AndroidManifest manifest) async {
    if (!manifest.isModified) {
      return;
    }
    final modifiedXml = manifest._originalXml.split('\n').map((line) {
      if (AndroidManifest._labelPattern.hasMatch(line)) {
        return line.replaceFirstMapped(AndroidManifest._labelPattern, (match) {
          return '${match.group(1)}${manifest.androidLabel}${match.group(3)}';
        });
      }
      return line;
    }).join('\n');
    final file = _fileSystem.file(pathlib.join(_appDirectory.path, ConfigFile.androidManifest.projectRelativePath));
    await file.writeAsString(modifiedXml);
  }

  Future<IosInfoPlist> loadIosInfoPlist() async {
    final file = _fileSystem.file(pathlib.join(_appDirectory.path, ConfigFile.iosInfoPlist.projectRelativePath));
    final contents = await file.readAsString();
    return IosInfoPlist.fromXml(xml: contents);
  }

  Future<void> saveIosInfoPlist(IosInfoPlist infoPlist) async {
    if (!infoPlist.isModified) {
      return;
    }
    var shouldWriteValue = false;
    final modifiedXml = infoPlist._originalXml.split('\n').map((line) {
      if (shouldWriteValue && IosInfoPlist._valuePattern.hasMatch(line)) {
        shouldWriteValue = false;
        return line.replaceFirstMapped(IosInfoPlist._valuePattern, (match) {
          return '${match.group(1)}${infoPlist.displayName}${match.group(3)}';
        });
      } else if (IosInfoPlist._displayNameKeyPattern.hasMatch(line)) {
        shouldWriteValue = true;
      }
      return line;
    }).join('\n');
    final file = _fileSystem.file(pathlib.join(_appDirectory.path, ConfigFile.iosInfoPlist.projectRelativePath));
    await file.writeAsString(modifiedXml);
  }
}