import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
  String getName({bool withExt = true}) {
    final name = path.split('/').last;
    if (withExt) {
      return name;
    }
    return name.split('.').first;
  }

  String getExt() {
    return path.split('/').last.split('.').last;
  }

  bool isDirectory() {
    return statSync().type == FileSystemEntityType.directory;
  }

  bool isFile() {
    return statSync().type == FileSystemEntityType.file;
  }
}
