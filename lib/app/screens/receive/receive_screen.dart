import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/file_chooser.dart';
import 'package:person_server/app/chooser/file_scanner.dart';
import 'package:person_server/app/components/share_receive_list_item.dart';
import 'package:person_server/app/dialogs/downloader_dialog.dart';
import 'package:person_server/app/dialogs/multi_downloader_dialog.dart';
import 'package:person_server/app/dialogs/multi_uploader_dialog.dart';
import 'package:person_server/app/models/share_file.dart';
import 'package:person_server/app/routes_helper.dart';
import 'package:person_server/app/screens/index.dart';
import 'package:person_server/app/services/dio_services.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ReceiveScreen extends StatefulWidget {
  String url;
  ReceiveScreen({super.key, required this.url});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  List<ShareFile> list = [];
  String? defaultChooserPath;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await DioServices.getDio.get('${widget.url}/api');
      List<dynamic> resList = res.data;
      list = resList.map((map) => ShareFile.fromMap(map)).toList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receive'),
        actions: [
          TPlatform.isDesktop
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: init,
        child: CustomScrollView(
          slivers: [
            //header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('All Download'),
                    IconButton(
                      onPressed: _downloadMultiple,
                      icon: Icon(Icons.download),
                    ),
                  ],
                ),
              ),
            ),

            // list
            _getListWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: Icon(Icons.upload_file),
      ),
    );
  }

  Widget _getListWidget() {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final share = list[index];
        return ShareReceiveListItem(
          url: widget.url,
          share: share,
          isExistsFile: (ShareFile share) {
            final file = File('${PathUtil.getOutPath()}/${share.name}');
            return file.existsSync();
          },
          onClicked: (share) {
            if (!share.mime.startsWith('video')) {
              // showDialogMessage(context, 'Video ပဲဖွင့်လို့ရပါတယ်');
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  resoure: '${widget.url}/stream?path=${share.path}',
                  title: share.name,
                ),
              ),
            );
          },
          onDownloadClicked: _downloadConfirm,
        );
      },
    );
  }

  void _download(ShareFile share, String savePath) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloaderDialog(
        url: '${widget.url}/download?path=${share.path}',
        saveFullPath: savePath,
        message: '`${share.name}` Downloading...',
        onError: (msg) {
          showTMessageDialogError(context, msg);
          setState(() {});
        },
        onSuccess: () {
          setState(() {});
        },
      ),
    );
  }

  void _downloadConfirm(ShareFile share) {
    final savePath = '${PathUtil.getOutPath()}/${share.name}';
    final file = File(savePath);
    if (file.existsSync()) {
      showDialog(
        context: context,
        builder: (context) => TConfirmDialog(
          contentText: 'ပြန်ပြီး download ပြုုလုပ်ချင်ပါသလား?',
          submitText: 'Download',
          onSubmit: () {
            _download(share, savePath);
          },
        ),
      );
      return;
    }
    _download(share, savePath);
  }

  void _downloadMultiple() {
    final downloadUrlList = list
        .map((e) => '${widget.url}/download?path=${e.path}')
        .toList();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiDownloaderDialog(
        downloadUrlList: downloadUrlList,
        onClosed: (errorMsg) {
          setState(() {});
          if (errorMsg.isNotEmpty) {
            // showDialogMessage(context, errorMsg);
            return;
          }
          setState(() {});
        },
      ),
    );
  }

  // menu
  void _showAddMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          title: Text('Upload Files'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addFiles();
          },
        ),
        ListTile(
          title: Text('Upload Videos'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addVideos();
          },
        ),
        ListTile(
          title: Text('Upload Images'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addImages();
          },
        ),
        ListTile(
          title: Text('Upload Mp3 (Audio)'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addAudios();
          },
        ),
      ],
    );
  }

  void _addFiles() async {
    goRoute(
      context,
      builder: (context) => FileChooser(
        defaultPath: defaultChooserPath,
        onChoosed: (pathList, currentPath) {
          defaultChooserPath = currentPath;
          _uploadFiles(pathList);
        },
      ),
    );
  }

  void _addVideos() async {
    goRoute(
      context,
      builder: (context) => FileScanner(
        title: 'Choose Videos',
        mimeType: 'video',
        onChoosed: (pathList) {
          _uploadFiles(pathList);
        },
      ),
    );
  }

  void _addImages() async {
    goRoute(
      context,
      builder: (context) => FileScanner(
        title: 'Choose Images',
        mimeType: 'image',
        onChoosed: (pathList) {
          _uploadFiles(pathList);
        },
      ),
    );
  }

  void _addAudios() async {
    goRoute(
      context,
      builder: (context) => FileScanner(
        title: 'Choose Audio',
        mimeType: 'audio',
        onChoosed: (pathList) {
          _uploadFiles(pathList);
        },
      ),
    );
  }

  void _uploadFiles(List<String> pathList) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MultiUploaderDialog(
        hostUrl: widget.url,
        pathList: pathList,
        onSuccess: () {
          showTMessageDialog(context, 'Upload လုပ်ပြီးပါပြီ');
        },
      ),
    );
  }
}
