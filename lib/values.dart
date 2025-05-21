import 'package:file/file.dart';
import 'package:path/path.dart' as path;

enum SupportedPlatform { ios, android }

sealed class PlatformSource {
  SupportedPlatform get platform;
  String get path;
}

enum AndroidPropertySource implements PlatformSource {
  manifest(path: 'android/app/src/main/AndroidManifest.xml'),
  buildGradleKts(path: 'android/app/build.gradle.kts');

  @override
  final String path;
  @override
  final SupportedPlatform platform = SupportedPlatform.android;

  const AndroidPropertySource({required this.path});
}

enum IosPropertySource implements PlatformSource {
  infoPlist(path: 'ios/Runner/Info.plist'),
  projectPbxproj(path: 'ios/Runner.xcodeproj/project.pbxproj');

  @override
  final String path;
  @override
  final SupportedPlatform platform = SupportedPlatform.ios;

  const IosPropertySource({required this.path});
}

sealed class PlatformProperty {
  final String name;
  final PlatformSource source;
  final String pattern;
  final String? valuePattern;

  const PlatformProperty({
    required this.name,
    required this.source,
    required this.pattern,
    this.valuePattern,
  });

  /// Call this method for every [sourceLine] until it returns true.
  ///
  /// After that, start calling [valueFromSource] until it returns a non-null value.
  bool shouldLookForValue(String sourceLine) =>
      RegExp(pattern).hasMatch(sourceLine);

  PlatformValue? valueFromSource(String sourceLine) {
    final matcher = RegExp(valuePattern ?? pattern);
    final rawValue = matcher.firstMatch(sourceLine)?.group(1);
    if (rawValue == null) return null;
    return PlatformValue(initialValue: rawValue, platformProperty: this);
  }
}

class AndroidStringProperty extends PlatformProperty {
  static const label = AndroidStringProperty(
    name: 'android:label',
    source: AndroidPropertySource.manifest,
    pattern: r'android:label\s*=\s*"([^"]+)"',
  );
  static const packageId = AndroidStringProperty(
    name: 'Application ID',
    source: AndroidPropertySource.buildGradleKts,
    pattern: r'applicationId\s*=\s*"([^"]+)"',
  );

  const AndroidStringProperty({required super.name, required super.source, required super.pattern});
}

class IosStringProperty extends PlatformProperty {
  static const displayName = IosStringProperty(
    name: 'Display Name',
    source: IosPropertySource.infoPlist,
    pattern: r'<key>CFBundleDisplayName</key>',
    valuePattern: r'<string>([^<]+)</string>',
  );
  static const bundleId = IosStringProperty(
    name: 'Bundle ID',
    source: IosPropertySource.projectPbxproj,
    pattern: r'PRODUCT_BUNDLE_IDENTIFIER\s*=\s*([^;]+)',
  );

  const IosStringProperty({
    required super.name,
    required super.source,
    required super.pattern,
    super.valuePattern,
  });
}

enum CommonProperty {
  appName(
    androidProperty: AndroidStringProperty.label,
    iosProperty: IosStringProperty.displayName,
  ),
  appId(
    androidProperty: AndroidStringProperty.packageId,
    iosProperty: IosStringProperty.bundleId,
  );

  final AndroidStringProperty androidProperty;
  final IosStringProperty iosProperty;

  const CommonProperty({
    required this.androidProperty,
    required this.iosProperty,
  });
}

class CommonValue {
  final PlatformValue? androidValue;
  final PlatformValue? iosValue;

  CommonValue({this.androidValue, this.iosValue});
}

class PlatformValue {
  final PlatformProperty platformProperty;
  final String initialValue;
  String newValue;

  PlatformValue({required this.platformProperty, required this.initialValue})
    : newValue = initialValue;

  bool get isEdited => newValue != initialValue;
  String get value => isEdited ? newValue : initialValue;
}

class PropertyLoader {
  final FileSystem fileSystem;

  PropertyLoader({required this.fileSystem});

  Future<List<CommonValue?>> load(
    List<CommonProperty> properties, {
    required Directory directory,
    required Set<SupportedPlatform> platforms,
  }) async {
    final result = List<CommonValue?>.filled(properties.length, null);
    final sourceToProperties = <PlatformSource, List<PlatformProperty>>{};
    final propertiesToValues = <PlatformProperty, PlatformValue?>{};
    for (final property in properties) {
      if (platforms.contains(SupportedPlatform.android)) {
        sourceToProperties
            .putIfAbsent(property.androidProperty.source, () => [])
            .add(property.androidProperty);
      }
      if (platforms.contains(SupportedPlatform.ios)) {
        sourceToProperties
            .putIfAbsent(property.iosProperty.source, () => [])
            .add(property.iosProperty);
      }
    }

    final propertiesLookingForValues = <PlatformProperty>{};
    for (final source in sourceToProperties.keys) {
      final file = fileSystem.file(path.join(directory.path, source.path));
      for (final line in await file.readAsLines()) {
        if (sourceToProperties[source]!.isEmpty) break;
        for (final property in sourceToProperties[source]!) {
          if (propertiesToValues.containsKey(property) ||
              (!propertiesLookingForValues.contains(property) &&
                  !property.shouldLookForValue(line))) {
            continue;
          }
          propertiesLookingForValues.add(property);
          final value = property.valueFromSource(line);
          if (value != null) {
            propertiesToValues[property] = value;
          }
        }
      }
    }

    // loop over original properties and their indexes and update the result values.
    for (var i = 0; i < properties.length; i++) {
      final property = properties[i];
      result[i] = CommonValue(
        androidValue: propertiesToValues[property.androidProperty],
        iosValue: propertiesToValues[property.iosProperty],
      );
    }
    return result;
  }
}
