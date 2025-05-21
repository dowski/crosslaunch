import 'package:crosslaunch/linked_text_field.dart';
import 'package:crosslaunch/projects.dart';

final class AndroidProjectNameSource implements TextDataSource {
  final ValidProject project;

  AndroidProjectNameSource(this.project);

  @override
  String get text => project.androidAppName!;

  @override
  set text(String value) {
  }
}

final class IOSProjectNameSource implements TextDataSource {
  final ValidProject project;

  IOSProjectNameSource(this.project);

  @override
  String get text => project.iosAppName!;

  @override
  set text(String value) {
  }
}
