import 'package:flutter/material.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/index.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/theme_switcher.dart';
import 'package:t_server/t_server.dart';
import 'package:t_widgets/functions/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'screens/index.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    try {
      TServer.instance.get('/download', (req) {
        final path = req.getQueryParameters['path'] ?? '';
        req.sendFile(path);
      });
      TServer.instance.get('/stream', (req) {
        final path = req.getQueryParameters['path'] ?? '';
        req.sendVideoStream(path);
      });
      TServer.instance.post('/upload', (req) {
        req.uploadFile(PathUtil.getOutPath());
      });
      TServer.instance.startListen(port: 9000);
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
      }
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  void dispose() {
    TServer.instance.stop(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      builder: (config) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: config.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
