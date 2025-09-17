import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';
import 'theme_services.dart';

class ThemeModesChooser extends StatefulWidget {
  const ThemeModesChooser({super.key});

  @override
  State<ThemeModesChooser> createState() => _ThemeModesChooserState();
}

class _ThemeModesChooserState extends State<ThemeModesChooser> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ValueListenableBuilder(
              valueListenable: Setting.getAppConfigNotifier,
              builder: (context, config, child) {
                return DropdownButton<ThemeModes>(
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  value: config.themeMode,
                  items: ThemeModes.values
                      .map(
                        (e) => DropdownMenuItem<ThemeModes>(
                          value: e,
                          child: Text(e.name.toCaptalize()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final newConfig = config.copyWith(
                      themeMode: value,
                      isDarkTheme: value!.isDarkMode,
                    );
                    Setting.getAppConfigNotifier.value = newConfig;
                    newConfig.save();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
