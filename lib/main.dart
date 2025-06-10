import 'dart:io';

import 'package:crosslaunch/linked_text_field.dart';
import 'package:crosslaunch/platform.dart';
import 'package:crosslaunch/platform_label.dart';
import 'package:crosslaunch/projects.dart';
import 'package:crosslaunch/tri_source_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

Future<void> main() async {
  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await _configureMacosWindowUtils();
    }
  }
  final projects = AvailableProjects();
  final providers = MultiProvider(
    providers: [
      Provider.value(value: projects),
      StreamProvider.value(
        value: projects.stream,
        initialData: projects.current,
      ),
    ],
    child: const MyApp(),
  );

  runApp(providers);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      debugShowCheckedModeBanner: false,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<List<Project>>();
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: _pageIndex,
            onChanged: (index) {
              setState(() => _pageIndex = index);
            },
            items: [
              SidebarItem(
                label: Text('Home'),
                leading: MacosIcon(CupertinoIcons.home),
              ),
              for (final project in projects)
                switch (project) {
                  ValidProject project => SidebarItem(
                    label: Text(project.name),
                    leading: MacosIcon(CupertinoIcons.folder),
                  ),
                  InvalidProject project => SidebarItem(
                    label: Text(project.name),
                    leading: MacosIcon(CupertinoIcons.xmark_octagon),
                  ),
                },
            ],
          );
        },
      ),
      child: IndexedStack(
        index: _pageIndex,
        children: [
          MacosScaffold(
            children: [
              ContentArea(
                builder: ((context, scrollController) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PushButton(
                          controlSize: ControlSize.regular,
                          onPressed: () async {
                            final availableProjects =
                                context.read<AvailableProjects>();
                            final path =
                                await FilePicker.platform.getDirectoryPath();
                            if (path != null) {
                              final numProjects = await availableProjects.add(
                                path,
                              );
                              setState(() {
                                // Using the new project length as the index works because
                                // the first item in the list is the Home page.
                                _pageIndex = numProjects;
                              });
                            }
                          },
                          child: const Text('Open Project'),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          for (final project in projects)
            MacosScaffold(
              children: [
                ContentArea(
                  builder: ((context, scrollController) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: switch (project) {
                        ValidProject project => ProjectSettingsWidget(
                          project: project,
                        ),
                        InvalidProject project => Center(
                          child: Text('Error loading ${project.path}'),
                        ),
                      },
                    );
                  }),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

final class ProjectSettingsWidget extends StatelessWidget {
  final ValidProject project;

  const ProjectSettingsWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            Text('Project Settings', style: typography.title3),
            Spacer(),
            PushButton(
              controlSize: ControlSize.regular,
              onPressed:
                  project.hasEdits
                      ? () => context.read<AvailableProjects>().save(project)
                      : null,
              child: Text('Apply'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _Separator(),
        const SizedBox(height: 8),
        ...[
          LinkedTextField(
            label: 'App Name',
            dataDescriptor1: PlatformDataDescriptor.android(
              'android:label',
              value: project.androidManifest?.androidLabel ?? '',
            ),
            dataDescriptor2: PlatformDataDescriptor.ios(
              'Display Name',
              value: project.iosInfoPlist?.displayName ?? '',
            ),
            onChanged: (value, isCollapsed, descriptor) {
              context.read<AvailableProjects>().edit(
                project,
                AppNameEdit.newName(
                  value,
                  target:
                      isCollapsed
                          ? EditTarget.both
                          : descriptor.platform.editTarget,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          LinkedTextField(
            label: 'App ID',
            dataDescriptor1: PlatformDataDescriptor.android(
              'applicationId',
              value: project.appBuildGradle?.applicationId ?? '',
            ),
            dataDescriptor2: PlatformDataDescriptor.ios(
              'Bundle ID',
              value: project.iosXcodeProject?.bundleId ?? '',
            ),
            onChanged: (value, isCollapsed, descriptor) {
              context.read<AvailableProjects>().edit(
                project,
                ApplicationIdEdit.newApplicationId(
                  value,
                  target:
                      isCollapsed
                          ? EditTarget.both
                          : descriptor.platform.editTarget,
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 8),
        const _Separator(),
        const SizedBox(height: 8),
        _AppIconsWidget(
          iosAppIcon: project.iosIconImage,
          androidAppIcon: project.androidIconImage,
          previewReplacementIcon: project.replacementPreviewImage,
          onReplacementImagePath: (path) {
            context.read<AvailableProjects>().edit(project, AppIconEdit(path));
          },
        ),
        const SizedBox(height: 8),
        const _Separator(),
        TriSourceTextField(
          isExpanded: !project.isVisibleVersionFromPubspec,
          mainFieldLabel: 'Visible version',
          androidLabel: 'versionName',
          iosLabel: 'CFBundleShortVersionString',
          mainFieldValue: project.pubspecYaml?.versionName,
          androidValue: project.appBuildGradle?.versionName,
          iosValue: project.iosInfoPlist?.versionName,
          onMainFieldChanged:
              (value) => context.read<AvailableProjects>().edit(
                project,
                PubspecEdit(versionName: value),
              ),
          onAndroidChanged:
              (value) => context.read<AvailableProjects>().edit(
                project,
                AppBuildGradleEdit(versionName: value),
              ),
          onIosChanged:
              (value) => context.read<AvailableProjects>().edit(
                project,
                IosInfoPlistEdit(versionName: value),
              ),
        ),
        const SizedBox(height: 8),
        TriSourceTextField(
          isExpanded: !project.isInternalVersionFromPubspec,
          mainFieldLabel: 'Internal version',
          androidLabel: 'versionCode',
          iosLabel: 'CFBundleVersion',
          mainFieldValue: project.pubspecYaml?.versionCode,
          androidValue: project.appBuildGradle?.versionCode,
          iosValue: project.iosInfoPlist?.versionNumber,
          onMainFieldChanged: (value) => context.read<AvailableProjects>().edit(
            project,
            PubspecEdit(versionCode: value),
          ),
          onAndroidChanged: (value) => context.read<AvailableProjects>().edit(
            project,
            AppBuildGradleEdit(versionCode: value),
          ),
          onIosChanged: (value) => context.read<AvailableProjects>().edit(
            project,
            IosInfoPlistEdit(versionNumber: value),
          ),
        ),
      ],
    );
  }
}

final class PlatformDataDescriptor implements DataDescriptor {
  @override
  final Widget label;
  @override
  final String value;
  final SupportedPlatform platform;

  PlatformDataDescriptor.android(String text, {required this.value})
    : label = PlatformLabel.android(label: text),
      platform = SupportedPlatform.android;
  PlatformDataDescriptor.ios(String text, {required this.value})
    : label = PlatformLabel.ios(label: text),
      platform = SupportedPlatform.ios;
}

extension on SupportedPlatform {
  EditTarget get editTarget {
    switch (this) {
      case SupportedPlatform.android:
        return EditTarget.android;
      case SupportedPlatform.ios:
        return EditTarget.ios;
    }
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: MacosColors.separatorColor);
  }
}

class _AppIconsWidget extends StatelessWidget {
  final ImageProvider? androidAppIcon;
  final ImageProvider? iosAppIcon;
  final ImageProvider? previewReplacementIcon;
  final ValueChanged<String> onReplacementImagePath;

  const _AppIconsWidget({
    required this.androidAppIcon,
    required this.iosAppIcon,
    this.previewReplacementIcon,
    required this.onReplacementImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text('Icons', style: typography.subheadline)],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      MacosIcon(
                        Icons.apple,
                        color: MacosColors.secondaryLabelColor.darkColor,
                      ),
                      SizedBox(width: 16),
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: MacosColors.secondaryLabelColor.darkColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child:
                            iosAppIcon != null
                                ? Image(
                                  // TODO: figure out something nicer than this hack to force images to reload
                                  key: ValueKey(
                                    DateTime.now().millisecondsSinceEpoch,
                                  ),
                                  image: iosAppIcon!,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      MacosIcon(
                        Icons.android,
                        color: MacosColors.secondaryLabelColor.darkColor,
                      ),
                      SizedBox(width: 16),
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: MacosColors.secondaryLabelColor.darkColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child:
                            androidAppIcon != null
                                ? Image(
                                  key: ValueKey(
                                    // TODO: figure out something nicer than this hack to force images to reload
                                    DateTime.now().millisecondsSinceEpoch,
                                  ),
                                  image: androidAppIcon!,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null) {
                          onReplacementImagePath(result.files.first.path!);
                        }
                      },
                      child: const Text('Choose'),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                Text('Preview', style: typography.subheadline),
                SizedBox(width: 8),
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MacosColors.secondaryLabelColor.darkColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child:
                      previewReplacementIcon != null
                          ? Image(image: previewReplacementIcon!)
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
