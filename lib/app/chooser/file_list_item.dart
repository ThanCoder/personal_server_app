import 'dart:io';
import 'package:flutter/material.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';

class FileListItem extends StatefulWidget {
  final FileSystemEntity file;
  final List<String> choosedPath;
  final void Function(FileSystemEntity file)? onClicked;
  final void Function(FileSystemEntity file)? onRightClicked;
  const FileListItem({
    super.key,
    required this.file,
    required this.choosedPath,
    this.onClicked,
    this.onRightClicked,
  });

  @override
  State<FileListItem> createState() => _FileListItemState();
}

class _FileListItemState extends State<FileListItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked?.call(widget.file),
      onSecondaryTap: () => widget.onRightClicked?.call(widget.file),
      onLongPress: () => widget.onRightClicked?.call(widget.file),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: widget.choosedPath.contains(widget.file.path)
                ? const Color.fromARGB(96, 0, 150, 135)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: _getCoverWiget(widget.file),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(
                      widget.file.getName(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Type: ${widget.file.isDirectory ? 'Folder' : _getMime(widget.file)}',
                    ),
                    widget.file.isFile
                        ? Text(
                            widget.file
                                .statSync()
                                .size
                                .toDouble()
                                .toFileSizeLabel(),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Map<String, String> _cacheCoverPath = {};

  Widget _getCoverWiget(FileSystemEntity file) {
    final key = file.path.replaceAll('/', '-');
    final cache = _cacheCoverPath[key];
    if (cache != null) {
      return TImage(source: cache);
    }
    return FutureBuilder(
      future: _getCoverPath(file),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader.random();
        }
        var path = '';
        if (snapshot.hasData) {
          path = snapshot.data ?? '';
          _cacheCoverPath[key] = path;
        }
        return TImage(source: path);
      },
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
      if (!File(cachePath).existsSync()) {
        await ThanPkg.platform.genVideoThumbnail(
          pathList: [SrcDestType(src: file.path, dest: cachePath)],
        );
      }
      return cachePath;
    }
    if (mime.endsWith('/pdf')) {
      final cachePath =
          '${PathUtil.getCachePath()}/${file.path.getName(withExt: false)}.png';
      if (!File(cachePath).existsSync()) {
        await ThanPkg.platform.genPdfThumbnail(
          pathList: [SrcDestType(src: file.path, dest: cachePath)],
        );
      }
      return cachePath;
    }
    return '';
  }

  String _getMime(FileSystemEntity file) {
    return lookupMimeType(file.path) ?? '';
  }
}
