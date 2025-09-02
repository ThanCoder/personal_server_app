import 'package:than_pkg/types/index.dart';

extension InstallAppExtension on List<InstalledApp> {
  void sortName({bool isAtoZ = true}) {
    sort((a, b) {
      if (isAtoZ) {
        return a.appName.compareTo(b.appName);
      } else {
        return b.appName.compareTo(a.appName);
      }
    });
  }
}
