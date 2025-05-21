import 'dart:io';

import 'package:crosslaunch/linked_text_field.dart';
import 'package:crosslaunch/projects.dart';
import 'package:crosslaunch/values.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path_provider/path_provider.dart';
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
  Directory? _docsDirectory;

  @override
  void initState() {
    super.initState();
    _loadDocsDirectory();
  }

  void _loadDocsDirectory() async {
    final result = await getApplicationDocumentsDirectory();
    setState(() {
      _docsDirectory = result;
    });
  }

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
                        Text('Home'),
                        if (_docsDirectory != null) Text(_docsDirectory!.path),
                        MacosIconButton(
                          icon: MacosIcon(CupertinoIcons.add),
                          onPressed: () async {
                            final path =
                                await FilePicker.platform.getDirectoryPath();
                            if (path != null) {
                              setState(() {
                                context.read<AvailableProjects>().add(path);
                              });
                            }
                          },
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
            Text('Project Settings', style: typography.title1),
            if (project.supportedPlatforms.contains(SupportedPlatform.ios)) ...[
              SizedBox(width: 4),
              MacosIcon(
                Icons.apple,
                color: MacosColors.secondaryLabelColor.darkColor,
              ),
            ],
            if (project.supportedPlatforms.contains(
              SupportedPlatform.android,
            )) ...[
              SizedBox(width: 4),
              MacosIcon(
                Icons.android,
                color: MacosColors.secondaryLabelColor.darkColor,
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        Container(height: 1, color: MacosColors.separatorColor),
        SizedBox(height: 8),
        for (final (property, value) in project.attributes)
        LinkedTextField(
          label: property.name,
          dataDescriptor1: DataDescriptor.android(
            property.androidProperty.name,
            dataSource: value!.androidValue!,
          ),
          dataDescriptor2: DataDescriptor.ios(
            property.iosProperty.name,
            dataSource: value.iosValue!,
          ),
        ),
      ],
    );
  }
}
