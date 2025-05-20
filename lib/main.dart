import 'dart:io';

import 'package:crosslaunch/projects.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
                SidebarItem(
                  label: Text(project.name),
                  leading: MacosIcon(CupertinoIcons.folder),
                ),
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
                            final result =
                                await FilePicker.platform.getDirectoryPath();
                            if (result != null) {
                              setState(() {
                                final projectKey = ProjectKey(result);
                                context.read<AvailableProjects>().add(
                                  projectKey,
                                );
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(project.name),
                          if (project.supportedPlatforms.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (project.supportedPlatforms.contains(
                                  SupportedPlatform.ios,
                                ))
                                  const Icon(Icons.apple),
                                if (project.supportedPlatforms.contains(
                                  SupportedPlatform.android,
                                ))
                                  const Icon(Icons.android),
                              ],
                            ),
                        ],
                      ),
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
