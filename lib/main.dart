import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:person_server/more_libs/setting_v2.2.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThanPkg.instance.init();

  //media player
  MediaKit.ensureInitialized();

  //init config
  await Setting.instance.initSetting(
    appName: 'personal_server',
    appVersionLabel: 'Personal Server App',
    onShowMessage: (context, message) {
      showTSnackBar(context, message);
    },
  );

  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/logo.png',
    getDarkMode: () => Setting.getAppConfig.isDarkTheme,
  );

  runApp(const MyApp());
}
