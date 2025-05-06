import 'dart:io';

import 'package:mime/mime.dart';
import 'package:person_server/app/models/share_file.dart';
import 'package:real_path_file_selector/ui/extensions/index.dart';

class ShareServices {
  static List<ShareFile> getList(List<String> pathList) {
    List<ShareFile> list = [];
    for (var path in pathList) {
      final mime = lookupMimeType(path) ?? '';
      final file = File(path);
      list.add(ShareFile(
        name: file.getName(),
        path: path,
        mime: mime,
        size: file.statSync().size,
        date: file.statSync().modified.millisecondsSinceEpoch,
      ));
    }
    return list;
  }
}
