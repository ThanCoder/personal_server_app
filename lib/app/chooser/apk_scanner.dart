import 'dart:async';

import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/install_app_extension.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/installed_app.dart';

typedef OnChoosedCallback = void Function(List<InstalledApp> list);

class ApkScanner extends StatefulWidget {
  final Widget? title;
  final OnChoosedCallback? onChoosed;
  const ApkScanner({
    super.key,
    this.onChoosed,
    this.title = const Text('Apk Scanner'),
  });

  @override
  State<ApkScanner> createState() => _ApkScannerState();
}

class _ApkScannerState extends State<ApkScanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = true;
  List<InstalledApp> allList = [];
  List<InstalledApp> list = [];
  List<InstalledApp> selectedList = [];
  late PackageInfo info;
  Timer? _timer;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      info = await ThanPkg.platform.getPackageInfo();
      allList = await ThanPkg.android.app.getInstalledAppsList();
      list = allList;
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _onSort();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Count: ${selectedList.length}'),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _getList(),
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onChoosed?.call(selectedList);
                  },
                  child: Text('Choose'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      floating: true,
      snap: true,
      flexibleSpace: TSearchField(
        autofocus: false,
        onChanged: (text) {
          if (text.isEmpty) return;
          if (_timer?.isActive ?? false) {
            _timer!.cancel();
          }
          _timer = Timer(Duration(milliseconds: 1200), () => _onSearch(text));
        },
        onCleared: () {
          list = allList;
          setState(() {});
        },
      ),
    );
  }

  Widget _getList() {
    if (isLoading) {
      return Center(child: TLoader.random());
    }
    return RefreshIndicator.adaptive(
      onRefresh: init,
      child: CustomScrollView(
        slivers: [
          // search
          _getSearchBar(),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          // list
          SliverList.separated(
            itemCount: list.length,
            itemBuilder: (context, index) => _getListItem(list[index]),
            separatorBuilder: (context, index) => Divider(),
          ),
        ],
      ),
    );
  }

  Widget _getListItem(InstalledApp app) {
    final isExists = _isSelected(app);
    return GestureDetector(
      onTap: () => _toggleSelectApp(app, isExists: isExists),
      child: Row(
        spacing: 5,
        children: [
          app.coverData == null
              ? SizedBox.shrink()
              : SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.memory(app.coverData!),
                ),
          Expanded(
            child: Card(
              color: isExists ? Colors.teal : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text('T: ${app.appName}'),
                    Text('Package: ${app.packageName}'),
                    Text('VersionName: ${app.versionName}'),
                    Text('VersionCode: ${app.versionCode}'),
                    app.size == null
                        ? SizedBox.shrink()
                        : Text('Size: ${app.size!.getSizeLabel()}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSelected(InstalledApp app) {
    final isExists = selectedList.map((e) => e.appName).contains(app.appName);
    return isExists;
  }

  void _onSort() async {
    list.sortName();
    // sort current package name
    final index = list.indexWhere((e) => e.packageName == info.packageName);
    if (index != -1) {
      list.sort((a, b) {
        if (a.packageName == info.packageName &&
            b.packageName != info.packageName) {
          return -1;
        }
        return 0;
      });
    }

    setState(() {});
  }

  void _toggleSelectApp(InstalledApp app, {bool isExists = false}) {
    if (isExists) {
      final index = selectedList.indexWhere(
        (e) => e.packageName == app.packageName,
      );
      if (index == -1) return;
      selectedList.removeAt(index);
    } else {
      selectedList.add(app);
    }
    setState(() {});
  }

  void _onSearch(String text) {
    list = allList
        .where((e) => e.appName.toUpperCase().contains(text.toUpperCase()))
        .toList();
    setState(() {});
  }
}
