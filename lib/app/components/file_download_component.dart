import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:person_server/app/components/core/app_components.dart';
import 'package:person_server/app/dialogs/index.dart';
import 'package:person_server/app/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

class FileDownloadComponent extends StatefulWidget {
  String filename;
  String fileUrl;
  String savePath;
  FileDownloadComponent({
    super.key,
    required this.filename,
    required this.fileUrl,
    required this.savePath,
  });

  @override
  State<FileDownloadComponent> createState() => _FileDownloadComponentState();
}

class _FileDownloadComponentState extends State<FileDownloadComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  bool isDownloading = false;
  bool isFileExists = false;
  String? erroMsg;
  final dio = Dio();
  final max = ValueNotifier<int>(0);
  final progress = ValueNotifier<int>(0);

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      _checkFile();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      erroMsg = e.toString();
      debugPrint(e.toString());
    }
  }

  void _checkFile() {
    final saveFile = File(widget.savePath);

    if (saveFile.existsSync()) {
      setState(() {
        isFileExists = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isFileExists = false;
        isLoading = false;
      });
    }
  }

  void _downloadConfirm() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText:
            'file downloaded ပြီးပါပြီ။ထပ်ပြီး download လုပ်ချင်ပါသလား?',
        onCancel: _checkFile,
        onSubmit: _download,
      ),
    );
  }

  void _download() async {
    //download
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        title: widget.filename,
        url: widget.fileUrl,
        saveFullPath: widget.savePath,
        message: '',
        onError: (msg) {},
        onSuccess: (savedPath) {
          _checkFile();
          showMessage(context, 'Downloaded');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader(size: 30);
    }
    if (max.value > 0) {
      return ValueListenableBuilder(
        valueListenable: progress,
        builder: (context, value, child) => LinearProgressIndicator(
          value: progress.value / max.value,
        ),
      );
    }
    return IconButton(
      onPressed: () async {
        if (!await ThanPkg.platform.isStoragePermissionGranted()) {
          await ThanPkg.platform.requestStoragePermission();
          return;
        }
        //check save path
        if (isFileExists) {
          _downloadConfirm();
          return;
        }
        _download();
      },
      icon: Icon(isFileExists ? Icons.download_done : Icons.download),
    );
  }
}
