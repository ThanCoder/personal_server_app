import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/chooser_services.dart';
import 'package:person_server/app/chooser/file_list_item.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

typedef OnChoosed = void Function(List<String> pathList);

class FileScanner extends StatefulWidget {
  String title;
  String mimeType;
  OnChoosed onChoosed;
  FileScanner({
    super.key,
    required this.title,
    required this.mimeType,
    required this.onChoosed,
  });

  @override
  State<FileScanner> createState() => _FileScannerState();
}

class _FileScannerState extends State<FileScanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  String currentPath = '';
  List<FileSystemEntity> files = [];
  bool isLoading = false;
  List<String> choosePath = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      files = await ChooserServices.scanList(mimeType: widget.mimeType);
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
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

          !TPlatform.isDesktop
              ? SizedBox.shrink()
              : IconButton(onPressed: init, icon: Icon(Icons.refresh)),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: TLoader.random())
              : RefreshIndicator.adaptive(
                  onRefresh: init,
                  child: CustomScrollView(
                    slivers: [
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

  Widget _getList() {
    return SliverList.separated(
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _getListItem(files[index]),
    );
  }

  Widget _getListItem(FileSystemEntity file) {
    return FileListItem(
      file: file,
      choosedPath: choosePath,
      onClicked: (file) {
        if (!file.isDirectory) {
          _chooseToggle(file.path);
          return;
        }
      },
      onRightClicked: _showItemMenu,
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
              widget.onChoosed(choosePath);
            },
            child: Text('Choose'),
          ),
        ],
      ),
    );
  }

  void _chooseToggle(String path) {
    if (choosePath.contains(path)) {
      choosePath = choosePath.where((e) => e != path).toList();
    } else {
      choosePath.add(path);
    }
    setState(() {});
  }

  // menu
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
