import 'dart:convert';
import 'dart:io';

import 'package:than_pkg/services/t_map.dart';

import 'core/theme_services.dart';
import 'setting.dart';

class AppConfig {
  final String customPath;
  final String forwardProxyUrl;
  final String browserForwardProxyUrl;
  final String proxyUrl;
  final String hostUrl;
  final bool isUseCustomPath;
  final bool isUseForwardProxy;
  final bool isUseProxy;
  final bool isDarkTheme;
  final ThemeModes themeMode;
  const AppConfig({
    required this.customPath,
    required this.forwardProxyUrl,
    required this.browserForwardProxyUrl,
    required this.proxyUrl,
    required this.hostUrl,
    required this.isUseCustomPath,
    required this.isUseForwardProxy,
    required this.isUseProxy,
    required this.isDarkTheme,
    required this.themeMode,
  });

  factory AppConfig.create({
    String customPath = '',
    String forwardProxyUrl = '',
    String browserForwardProxyUrl = '',
    String proxyUrl = '',
    String hostUrl = '',
    bool isUseCustomPath = false,
    bool isUseForwardProxy = false,
    bool isUseProxy = false,
    bool isDarkTheme = false,
    ThemeModes themeMode = ThemeModes.system,
  }) {
    return AppConfig(
      customPath: customPath,
      forwardProxyUrl: forwardProxyUrl,
      browserForwardProxyUrl: browserForwardProxyUrl,
      proxyUrl: proxyUrl,
      hostUrl: hostUrl,
      isUseCustomPath: isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy,
      isUseProxy: isUseProxy,
      isDarkTheme: isDarkTheme,
      themeMode: themeMode,
    );
  }

  AppConfig copyWith({
    String? customPath,
    String? forwardProxyUrl,
    String? browserForwardProxyUrl,
    String? proxyUrl,
    String? hostUrl,
    bool? isUseCustomPath,
    bool? isUseForwardProxy,
    bool? isUseProxy,
    bool? isDarkTheme,
    ThemeModes? themeMode,
  }) {
    return AppConfig(
      customPath: customPath ?? this.customPath,
      forwardProxyUrl: forwardProxyUrl ?? this.forwardProxyUrl,
      browserForwardProxyUrl:
          browserForwardProxyUrl ?? this.browserForwardProxyUrl,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      hostUrl: hostUrl ?? this.hostUrl,
      isUseCustomPath: isUseCustomPath ?? this.isUseCustomPath,
      isUseForwardProxy: isUseForwardProxy ?? this.isUseForwardProxy,
      isUseProxy: isUseProxy ?? this.isUseProxy,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  // map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customPath': customPath,
      'forwardProxyUrl': forwardProxyUrl,
      'browserForwardProxyUrl': browserForwardProxyUrl,
      'proxyUrl': proxyUrl,
      'hostUrl': hostUrl,
      'isUseCustomPath': isUseCustomPath,
      'isUseForwardProxy': isUseForwardProxy,
      'isUseProxy': isUseProxy,
      'isDarkTheme': isDarkTheme,
      'themeMode': themeMode.name,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    final themeModeStr = map.getString(['themeMode']);
    return AppConfig(
      customPath: map['customPath'] as String,
      forwardProxyUrl: map['forwardProxyUrl'] as String,
      browserForwardProxyUrl: map['browserForwardProxyUrl'] as String,
      proxyUrl: map['proxyUrl'] as String,
      hostUrl: map['hostUrl'] as String,
      isUseCustomPath: map['isUseCustomPath'] as bool,
      isUseForwardProxy: map['isUseForwardProxy'] as bool,
      isUseProxy: map['isUseProxy'] as bool,
      isDarkTheme: map['isDarkTheme'] as bool,
      themeMode: ThemeModes.getName(themeModeStr),
    );
  }

  // void
  Future<void> save() async {
    try {
      final file = File('${Setting.appConfigPath}/$configName');
      final contents = JsonEncoder.withIndent(' ').convert(toMap());
      await file.writeAsString(contents);
      // appConfigNotifier.value = this;
      Setting.instance.initSetConfigFile();
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppConfig:save');
    }
  }

  // get config
  static Future<AppConfig> getConfig() async {
    final file = File('${Setting.appConfigPath}/$configName');
    if (file.existsSync()) {
      final source = await file.readAsString();
      return AppConfig.fromMap(jsonDecode(source));
    }
    return AppConfig.create();
  }

  static String configName = 'main.config.json';
}
