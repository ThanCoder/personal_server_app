import 'package:flutter/material.dart';
import 'package:person_server/more_libs/setting_v2.2.0/setting.dart';

class AppMorePage extends StatelessWidget {
  const AppMorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('More')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Setting.getThemeSwitcherWidget,
            Setting.getCurrentVersionWidget,
            Setting.getSettingListTileWidget,

            Setting.getCacheManagerWidget,
          ],
        ),
      ),
    );
  }
}
