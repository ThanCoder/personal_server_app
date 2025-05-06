import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:real_path_file_selector/real_path_file_selector.dart';

import '../utils/index.dart';

Future<List<String>> platformVideoPathChooser(BuildContext context) async {
  List<String> pathList = [];

  if (Platform.isLinux) {
    final files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(
            extensions: ['.mp4', '.mkv'],
            mimeTypes: ['video/mp4', 'video/mkv']),
      ],
    );

    if (files.isEmpty) return pathList;
    pathList = files
        .where((f) => File(f.path).statSync().type == FileSystemEntityType.file)
        .map((f) => f.path)
        .toList();
  } else if (Platform.isAndroid) {
    pathList = await RealPathFileSelector.openFileScanner.open(
      context,
      mimeType: 'video',
      title: 'Choose Movie',
      thumbnailDirPath: PathUtil.getCachePath(),
    );
  }
  return pathList;
}

Future<List<String>> platformImagePathChooser() async {
  List<String> pathList = [];

  final files = await openFiles(
    acceptedTypeGroups: [
      XTypeGroup(
          mimeTypes: ['image/png', 'image/jpg', 'image/webp', 'image/jpeg']),
    ],
  );

  if (files.isEmpty) return pathList;
  pathList = files
      .where((f) => File(f.path).statSync().type == FileSystemEntityType.file)
      .map((f) => f.path)
      .toList();
  return pathList;
}

Future<List<String>> platformFilePathChooser(BuildContext context) async {
  List<String> pathList = [];

  if (Platform.isLinux) {
    final files = await openFiles(
      acceptedTypeGroups: [],
    );

    if (files.isEmpty) return pathList;
    pathList = files
        .where((f) => File(f.path).statSync().type == FileSystemEntityType.file)
        .map((f) => f.path)
        .toList();
  } else if (Platform.isAndroid) {
    pathList = await RealPathFileSelector.openFileExplorer.open(
      context,
      title: 'Choose Share Files',
      thumbnailDirPath: PathUtil.getCachePath(),
    );
  }
  return pathList;
}
