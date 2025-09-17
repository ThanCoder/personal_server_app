import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:person_server/more_libs/desktop_exe_1.0.1/desktop_exe.dart';
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
  await DesktopExe.instance.exportNotExists(
    name: 'Personal Server App',
    assetsIconPath: 'assets/logo.png',
  );

  if (TPlatform.isDesktop) {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(514, 414), // စတင်ဖွင့်တဲ့အချိန် window size

      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      center: false,
      title: "Movie Fetcher App",
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}
