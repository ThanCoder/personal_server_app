import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../dialogs/core/index.dart';
import '../../services/core/app_services.dart';
import '../../widgets/index.dart';
import '../index.dart';

class CoverComponents extends StatefulWidget {
  String coverPath;
  CoverComponents({super.key, required this.coverPath});

  @override
  State<CoverComponents> createState() => _CoverComponentsState();
}

class _CoverComponentsState extends State<CoverComponents> {
  bool isLoading = false;

  void _downloadUrl() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        renameLabelText: Text('Download From Url'),
        submitText: 'Download',
        renameText: '',
        onCancel: () {},
        onSubmit: (url) async {
          try {
            setState(() {
              isLoading = true;
            });
            await Dio().download(url, widget.coverPath);

            setState(() {
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              isLoading = false;
            });
            _showMsg(e.toString());
          }
        },
      ),
    );
  }

  void _showMsg(String msg) {
    showDialogMessage(context, msg);
  }

  void _addFromPath() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await FilePicker.platform.pickFiles(
        dialogTitle: 'Fick Cover',
        type: FileType.image,
      );
      if (res != null && res.files.isNotEmpty) {
        final path = res.files.first.path!;
        final file = File(path);
        await file.copy(widget.coverPath);
        //clear image cache
        clearAndRefreshImage();
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _addFromPath();
            },
            leading: const Icon(Icons.add),
            title: const Text('Add From Path'),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _downloadUrl();
            },
            leading: const Icon(Icons.add),
            title: const Text('Add From Url'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _showMenu,
        child: SizedBox(
          width: 150,
          height: 150,
          child: isLoading
              ? TLoader()
              : MyImageFile(
                  path: widget.coverPath,
                ),
        ),
      ),
    );
  }
}
