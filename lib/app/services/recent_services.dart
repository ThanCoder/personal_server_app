import 'dart:convert';
import 'dart:io';

import 'package:person_server/app/utils/path_util.dart';

class RecentServices {
  static final RecentServices instance = RecentServices._();
  RecentServices._();
  factory RecentServices() => instance;

  Future<T> getValue<T>(String key, {required T defaultValue}) async {
    final file = File(getPath);
    if (!await file.exists()) return defaultValue;
    Map<String, dynamic> map = jsonDecode(await file.readAsString());
    return map[key] ?? defaultValue;
  }

  Future<void> setValue<T>(String key, T value) async {
    final file = File(getPath);
    Map<String, dynamic> map = {};
    if (await file.exists()) {
      map = jsonDecode(await file.readAsString());
    }
    map[key] = value;
    //save
    await file.writeAsString(jsonEncode(map));
  }

  String get getPath => '${PathUtil.getCachePath()}/recent.db.json';
}
