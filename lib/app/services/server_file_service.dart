import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mime/mime.dart';
import 'package:person_server/app/models/index.dart';

class ServerFileService {
  //singleton pattern
  static final ServerFileService instance = ServerFileService._();
  ServerFileService._();
  factory ServerFileService() => instance;

  // List<Map<String,dynamic>> toMapList()=> ;

  Future<List<ServerFileModel>> getList({
    required String dirPath,
    bool isShowHidden = true,
  }) async {
    return await Isolate.run<List<ServerFileModel>>(() async {
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
          final serverFile = ServerFileModel(
            name: name,
            path: file.path,
            mime: lookupMimeType(file.path) ?? '',
            isFolder: file.statSync().type == FileSystemEntityType.directory,
            size: file.statSync().size,
            date: file.statSync().modified.millisecondsSinceEpoch,
          );
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
  }
}
