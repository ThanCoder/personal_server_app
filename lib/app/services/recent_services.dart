import 'dart:convert';
import 'dart:io';

import 'package:person_server/more_libs/setting_v2.2.0/core/index.dart';
import 'package:than_pkg/than_pkg.dart';

class RecentServices {
  static Future<T> get<T>(String key, {required T defaultValue}) async {
    final map = await getAll();
    return TMap.get<T>(map, [key], defaultValue: defaultValue);
  }

  static Future<Map<String, dynamic>> getAll() async {
    final file = File(_getDBPath);
    if (!file.existsSync()) return {};
    final json = jsonDecode(await file.readAsString());
    return json as Map<String, dynamic>;
  }

  static Future<void> set(String key, String value) async {
    final file = File(_getDBPath);
    final map = await getAll();
    map[key] = value;
    final contents = JsonEncoder.withIndent(' ').convert(map);
    await file.writeAsString(contents);
  }

  static String get _getDBPath {
    return '${PathUtil.getDatabasePath()}/recent.db.json';
  }
}
