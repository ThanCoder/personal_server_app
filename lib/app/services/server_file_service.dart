import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mime/mime.dart';
import 'package:person_server/app/extensions/string_extension.dart';
import 'package:person_server/app/models/index.dart';
import 'package:person_server/app/utils/index.dart';
import 'package:than_pkg/than_pkg.dart';

class ServerFileService {
  //singleton pattern
  static final ServerFileService instance = ServerFileService._();
  ServerFileService._();
  factory ServerFileService() => instance;

  Future<List<ServerFileModel>> getList({
    required String dirPath,
    bool isShowHidden = true,
  }) async {
    final cachePath = getCachePath();

    List<ServerFileModel> list =
        await Isolate.run<List<ServerFileModel>>(() async {
      List<ServerFileModel> list = [];
      try {
        Directory dir = Directory(dirPath);
        if (!await dir.exists()) return list;

        await for (var file in dir.list()) {
          final name = file.path.split('/').last;
          //hidden ကိုင်တွယ်မယ်
          if (!isShowHidden && name.startsWith('.')) {
            continue;
          }
          final mime = lookupMimeType(file.path) ?? '';
          var fileCache = '$cachePath/${name.getName(withExt: false)}.png';
          if (mime.startsWith('image')) {
            fileCache = file.path;
          }
          final serverFile = ServerFileModel(
              name: name,
              path: file.path,
              mime: mime,
              isFolder: file.statSync().type == FileSystemEntityType.directory,
              size: file.statSync().size,
              date: file.statSync().modified.millisecondsSinceEpoch,
              coverPath: fileCache);
          // print(serverFile.mime);
          list.add(serverFile);
        }
        //sort
        // list.sort((a, b) => a.name.compareTo(b.name));
        //sort folder to top
        list.sort((a, b) {
          if (a.isFolder && !b.isFolder) {
            return -1; // a သည် folder, b သည် file ဆိုရင် a ကို အရင်တင်
          }
          if (!a.isFolder && b.isFolder) {
            return 1; // a သည် file, b သည် folder ဆိုရင် b ကို အရင်တင်
          }
          return 0; // နှစ်ခုစလုံး folder (သို့) file ဆိုရင် မပြောင်းဘူး
        });
      } catch (e) {
        debugPrint('ServerFileService->getList: ${e.toString()}');
      }
      return list;
    });

    final genVCoverList = list
        .where((sf) => sf.mime.startsWith('video'))
        .map((sf) => sf.path)
        .toList();
    final genPdfCoverList = list
        .where((sf) => sf.mime.startsWith('application/pdf'))
        .map((sf) => sf.path)
        .toList();

    await ThanPkg.platform
        .genVideoCover(outDirPath: cachePath, videoPathList: genVCoverList);
    await ThanPkg.platform
        .genPdfCover(outDirPath: cachePath, pdfPathList: genPdfCoverList);

    return list;
  }
}
