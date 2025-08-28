import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/index.dart';

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
        final item = files[index];
        return GestureDetector(
          onTap: () {
            if (!item.isDirectory) {
              _chooseToggle(item.path);
              return;
            }
            currentPath = item.path;
            _scanDir();
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: choosePath.contains(item.path)
                      ? const Color.fromARGB(96, 0, 150, 135)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    _getCoverWiget(item),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(
                            item.getName(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('Type: ${item.isDirectory ? 'Folder' : 'File'}'),
                          item.isFile
                              ? Text(
                                  item
                                      .statSync()
                                      .size
                                      .toDouble()
                                      .toFileSizeLabel(),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getCoverWiget(FileSystemEntity file) {
    return SizedBox(
      width: 100,
      height: 100,
      child: FutureBuilder(
        future: _getCoverPath(file),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TLoader.random();
          }
          var path = '';
          if (snapshot.hasData) {
            path = snapshot.data ?? '';
          }
          return TImage(source: path);
        },
      ),
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

  Future<String> _getCoverPath(FileSystemEntity file) async {
    if (file.isDirectory) {
      final cachePath = '${PathUtil.getCachePath()}/folder.png';
      await PathUtil.getAssetRealPathPath('folder.png');
      return cachePath;
    }
    final mime = lookupMimeType(file.path) ?? '';
    if (mime.startsWith('image')) {
      return file.path;
    }
    if (mime.startsWith('audio')) {
      final cachePath = '${PathUtil.getCachePath()}/mp3.png';
      await PathUtil.getAssetRealPathPath('mp3.png');
      return cachePath;
    }
    if (mime.startsWith('video')) {
      final cachePath =
          '${PathUtil.getCachePath()}/${file.path.getName(withExt: false)}.png';
      await ThanPkg.platform.genVideoThumbnail(
        pathList: [SrcDestType(src: file.path, dest: cachePath)],
      );
      return cachePath;
      // assetName = 'video.png';
    } else if (mime.endsWith('/pdf')) {
      // assetName = 'pdf.png';
      final cachePath =
          '${PathUtil.getCachePath()}/${file.path.getName(withExt: false)}.png';
      await ThanPkg.platform.genPdfThumbnail(
        pathList: [SrcDestType(src: file.path, dest: cachePath)],
      );
      return cachePath;
    }
    return '';
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
}
