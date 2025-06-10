import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:than_pkg/than_pkg.dart';

import 'app/my_app.dart';
import 'app/services/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThanPkg.instance.init();

  //media player
  MediaKit.ensureInitialized();

  //init config
  await initAppConfigService();

  runApp(const MyApp());
}
