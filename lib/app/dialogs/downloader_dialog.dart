import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

class DownloaderDialog extends StatefulWidget {
  String title;
  String url;
  String message;
  String saveFullPath;
  void Function() onSuccess;
  void Function(String msg) onError;
  DownloaderDialog({
    super.key,
    this.title = '',
    required this.url,
    required this.saveFullPath,
    required this.message,
    required this.onError,
    required this.onSuccess,
  });

  @override
  State<DownloaderDialog> createState() => _DownloaderDialogState();
}

class _DownloaderDialogState extends State<DownloaderDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    super.dispose();
  }

  final dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double fileSize = 0;
  double downloadedSize = 0;

  void init() async {
    try {
      await ThanPkg.platform.toggleFullScreen(isFullScreen: true);
      //download file
      await dio.download(
        Uri.encodeFull(widget.url),
        widget.saveFullPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          setState(() {
            fileSize = total.toDouble();
            downloadedSize = count.toDouble();
          });
        },
      );
      widget.onSuccess();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      widget.onError(e.toString());
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _downloadCancel() {
    try {
      cancelToken.cancel();
      final file = File(widget.saveFullPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title.isEmpty ? null : Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(widget.message),
            LinearProgressIndicator(
              value: fileSize == 0 ? null : downloadedSize / fileSize,
            ),
            //label
            fileSize == 0
                ? const SizedBox.shrink()
                : Text(
                    '${downloadedSize.toDouble().toFileSizeLabel()} / ${fileSize.toDouble().toFileSizeLabel()}',
                  ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _downloadCancel();
          },
          child: const Text('Cancel'),
        ),
        // TextButton(
        //   onPressed:() {
        //           Navigator.pop(context);
        //         },
        //   child: const Text('Upgrade'),
        // ),
      ],
    );
  }
}
