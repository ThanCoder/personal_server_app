import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/chooser_services.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';

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

  void init() async {
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
          SizedBox(width: 10),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: TLoader.random())
              : CustomScrollView(
                  slivers: [
                    // list
                    _getList(),
                  ],
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
      itemBuilder: (context, index) {
        final item = files[index];
        return GestureDetector(
          onTap: () {
            if (!item.isDirectory) {
              _chooseToggle(item.path);
              return;
            }
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
                          Text(
                            'Type: ${item.isDirectory ? 'Folder' : 'File'}',
                          ),
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
              widget.onChoosed(choosePath);
            },
            child: Text('Choose'),
          ),
        ],
      ),
    );
  }

  Future<String> _getCoverPath(FileSystemEntity file) async {
    if (file.isDirectory) {
      return 'assets/folder.png';
    }
    final mime = lookupMimeType(file.path) ?? '';
    if (mime.startsWith('image')) {
      return file.path;
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

  void _chooseToggle(String path) {
    if (choosePath.contains(path)) {
      choosePath = choosePath.where((e) => e != path).toList();
    } else {
      choosePath.add(path);
    }
    setState(() {});
  }
}
