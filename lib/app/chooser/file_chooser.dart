import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/file_list_item.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

typedef OnChoosed = void Function(List<String> pathList, String currentPath);

class FileChooser extends StatefulWidget {
  String title;
  String? defaultPath;
  bool isMultiSelect;
  OnChoosed onChoosed;
  FileChooser({
    super.key,
    this.title = 'Choose File',
    required this.onChoosed,
    this.defaultPath,
    this.isMultiSelect = false,
  });

  @override
  State<FileChooser> createState() => _FileChooserState();
}

class _FileChooserState extends State<FileChooser> {
  String currentPath = '';
  List<FileSystemEntity> files = [];
  bool showHidden = false;
  List<String> choosePath = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    if (widget.defaultPath != null) {
      currentPath = widget.defaultPath!;
    } else {
      currentPath = await ThanPkg.platform.getAppExternalPath() ?? '';
    }

    if (!mounted) return;
    setState(() {});
    _scanDir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          // choose count
          choosePath.isEmpty
              ? SizedBox.shrink()
              : Text('Choose ${choosePath.length}'),
          SizedBox(width: 20),
          // unselect
          choosePath.isEmpty
              ? SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    choosePath.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear_all_rounded),
                ),
          IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert)),
          !TPlatform.isDesktop
              ? SizedBox.shrink()
              : IconButton(onPressed: _scanDir, icon: Icon(Icons.refresh)),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
            onRefresh: () async {
              _scanDir();
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  snap: true,
                  floating: true,
                  flexibleSpace: _getHeader(),
                  automaticallyImplyLeading: false,
                ),
                // list
                _getList(),
              ],
            ),
          ),
          // botton bar
          Positioned(bottom: 0, right: 0, child: _getChooseButtonBar()),
        ],
      ),
    );
  }

  Widget _getHeader() {
    return Row(
      children: [
        IconButton(onPressed: _goBackPath, icon: Icon(Icons.arrow_back)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.black),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentPath,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getList() {
    return SliverList.separated(
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final file = files[index];
        return FileListItem(
          file: file,
          choosedPath: choosePath,
          onRightClicked: _showItemMenu,
          onClicked: (file) {
            if (!file.isDirectory) {
              _chooseToggle(file.path);
              return;
            }
            currentPath = file.path;
            _scanDir();
          },
        );
      },
    );
  }

  Widget _getChooseButtonBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 15,
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
              widget.onChoosed(choosePath, currentPath);
            },
            child: Text('Choose'),
          ),
        ],
      ),
    );
  }

  void _scanDir() {
    final dir = Directory(currentPath);
    if (!dir.existsSync()) return;
    files = [];
    for (var file in dir.listSync()) {
      if (!showHidden && file.getName().startsWith('.')) {
        continue;
      }
      files.add(file);
    }
    files.sort((a, b) {
      // Folder ကို အပေါ်တင်
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;

      // တူရင် name အလိုက် A-Z
      return a.path.toLowerCase().compareTo(b.path.toLowerCase());
    });
    setState(() {});
  }

  void _goBackPath() async {
    final homePath = await ThanPkg.platform.getAppExternalPath() ?? '';
    if (currentPath == homePath) return;
    final dir = Directory(currentPath);
    currentPath = dir.parent.path;
    _scanDir();
  }

  void _chooseToggle(String path) {
    if (choosePath.contains(path)) {
      choosePath = choosePath.where((e) => e != path).toList();
    } else {
      choosePath.add(path);
    }
    setState(() {});
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        StatefulBuilder(
          builder: (context, setState) => SwitchListTile.adaptive(
            value: showHidden,
            title: Text('Show Hidden Files'),
            onChanged: (value) {
              setState(() {
                showHidden = value;
              });
              _scanDir();
            },
          ),
        ),
      ],
    );
  }

  // item menu
  void _showItemMenu(FileSystemEntity file) {
    showTMenuBottomSheet(
      context,
      title: Text(file.getName()),
      children: [
        ListTile(
          leading: Icon(Icons.info),
          title: Text('Info'),
          onTap: () {
            Navigator.pop(context);
            _showInfo(file);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever),
          title: Text('Delete'),
          onTap: () {
            Navigator.pop(context);
            _deleteConfirm(file);
          },
        ),
      ],
    );
  }

  void _showInfo(FileSystemEntity file) {
    showTAlertDialog(
      context,
      content: Text('''
Name: ${file.getName()}
Type: ${lookupMimeType(file.path)}
Size: ${file.getSizeLabel()}
Date: ${file.statSync().modified.toParseTime()}
Path: ${file.path}
'''),
      actions: [],
    );
  }

  void _deleteConfirm(FileSystemEntity file) {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာသေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () async {
        await file.delete();
        if (!mounted) return;
        final index = files.indexWhere((e) => e.path == file.path);
        if (index == -1) return;
        files.removeAt(index);
        setState(() {});
      },
    );
  }
}
