import 'dart:async';
import 'dart:io';

final class AvailableProjects {
  final _current = <Directory>[];

  List<Directory> get current => _current;
  final _streamController = StreamController<List<Directory>>.broadcast();
  Stream<List<Directory>> get stream => _streamController.stream;

  void add(Directory project) {
    _current.add(project);
    _streamController.add(_current);
  }

  void dispose() {
    _streamController.close();
  }
}
