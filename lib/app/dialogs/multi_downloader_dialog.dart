import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class MultiDownloaderDialog extends StatefulWidget {
  List<String> downloadUrlList;
  void Function(String errorMsg) onClosed;

  MultiDownloaderDialog({
    super.key,
    required this.downloadUrlList,
    required this.onClosed,
  });

  @override
  State<MultiDownloaderDialog> createState() => _MultiDownloaderDialogState();
}

class _MultiDownloaderDialogState extends State<MultiDownloaderDialog> {
  @override
  void initState() {
    downloadLength = widget.downloadUrlList.length;
    super.initState();
    init();
  }

  final dio = Dio();
  final CancelToken cancelToken = CancelToken();
  double fileSize = 0;
  double downloadedSize = 0;
  String progressMsg = 'ပြင်ဆင်နေပါတယ်...';
  String errorMsg = '';
  int downloadIndex = 0;
  int downloadLength = 0;

  void init() async {
    final dir = Directory(PathUtil.getOutPath());
    await ThanPkg.platform.toggleKeepScreen(isKeep: true);

    for (var url in widget.downloadUrlList) {
      progressMsg = 'Downloading : ${url.getName()}';
      downloadIndex++;
      final savedPath = '${dir.path}/${url.getName()}';
      final file = File(savedPath);
      if (await file.exists()) continue;
      if (!mounted) return;
      setState(() {});
      // await Future.delayed(const Duration(milliseconds: 400));
      await _download(url, savedPath);
    }
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    Navigator.pop(context);
    widget.onClosed(errorMsg);
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('All Download'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text('$downloadIndex/$downloadLength'),
            Text(progressMsg),
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

  Future<void> _download(String url, String savedPath) async {
    try {
      // download file
      await dio.download(
        Uri.encodeFull(url),
        savedPath,
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          setState(() {
            fileSize = total.toDouble();
            downloadedSize = count.toDouble();
          });
        },
      );
    } catch (e) {
      errorMsg += '${e.toString()}\n';
    }
  }

  void _downloadCancel() {
    Navigator.pop(context);
    try {
      cancelToken.cancel();
    } catch (e) {
      errorMsg += '${e.toString()}\n';
    }
  }
}
