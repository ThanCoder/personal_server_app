import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:person_server/app/chooser/file_chooser.dart';
import 'package:person_server/app/chooser/file_scanner.dart';
import 'package:person_server/app/models/share_file.dart';
import 'package:person_server/app/routes_helper.dart';
import 'package:person_server/app/services/share_services.dart';
import 'package:person_server/more_libs/setting_v2.2.0/core/index.dart';
import 'package:person_server/more_libs/t_server_v1.0.0/core/http_extensions.dart';
import 'package:person_server/more_libs/t_server_v1.0.0/t_server.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  List<String> hostAddress = [];
  static List<ShareFile> list = [];
  String? defaultChooserPath;

  void init() async {
    try {
      await ThanPkg.platform.toggleKeepScreen(isKeep: true);
      TServer.instance.get('/', (req) {
        req.sendHtml(ShareServices.getHtml(list));
      });
      TServer.instance.get('/api', (req) {
        final mapList = list.map((e) => e.toMap).toList();
        final json = JsonEncoder.withIndent(' ').convert(mapList);
        req.sendJson(json);
      });

      TServer.instance.get('/cover', (req) async {
        final path = req.getQueryParameters()['path'] ?? '';
        final coverPath = await _getCoverPath(path);
        req.sendFile(coverPath);
      });
      _checkWifiAddress();
      // TServer.instance.startListen(port: 9000);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        final res = details.files
            .map((e) => e.path)
            .where((path) => File(path).isFile)
            .toList();
        _share(res);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Share'),
              snap: true,
              floating: true,
              actions: [_getListClearBtn()],
            ),
            //server status
            SliverToBoxAdapter(child: _getHeader()),

            SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: hostAddress.isEmpty
                  ? null
                  : Center(child: Text('Address တစ်ခုခုနဲ့ စမ်းကြည့်ပါ')),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ရနိုင်သော wifi list
            _getAddressList(),
            SliverToBoxAdapter(child: hostAddress.isEmpty ? null : Divider()),

            // list
            _getList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showMenu,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _getListClearBtn() {
    if (list.isEmpty) return SizedBox.shrink();
    return IconButton(
      onPressed: () {
        list.clear();
        setState(() {});
      },
      icon: Icon(Icons.clear_all),
    );
  }

  Widget _getHeader() {
    return Column(
      spacing: 5,
      children: [
        GestureDetector(
          onTap: () {
            ThanPkg.platform.launch(_getCurrentHostAddress());
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              'Server Running On: ${_getCurrentHostAddress()}',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getAddressList() {
    return SliverList.separated(
      itemCount: hostAddress.length,
      itemBuilder: (context, index) {
        final address = hostAddress[index];
        return ListTile(
          title: Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => _showQr(address),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget _getList() {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _getListItem(list[index]),
    );
  }

  Widget _getListItem(ShareFile share) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _getCoverWiget(share),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text(share.name),
                Text(share.size.toDouble().toFileSizeLabel()),
                Text(share.mime),
                Text(
                  DateTime.fromMillisecondsSinceEpoch(share.date).toParseTime(),
                ),
                IconButton(
                  color: Colors.red,
                  onPressed: () {
                    final index = list.indexWhere((e) => e.name == share.name);
                    if (index == -1) return;
                    list.removeAt(index);
                    setState(() {});
                  },
                  icon: Icon(Icons.delete_forever),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCoverWiget(ShareFile share) {
    return SizedBox(
      width: 140,
      height: 160,
      child: FutureBuilder(
        future: _getCoverPath(share.path),
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

  Future<String> _getCoverPath(String filePath) async {
    final mime = lookupMimeType(filePath) ?? '';
    if (mime.startsWith('image')) {
      return filePath;
    }
    var assetName = 'file.png';
    if (mime.startsWith('audio')) {
      final cachePath = '${PathUtil.getCachePath()}/mp3.png';
      await PathUtil.getAssetRealPathPath('mp3.png');
      return cachePath;
    }

    if (mime.startsWith('video')) {
      final cachePath =
          '${PathUtil.getCachePath()}/${filePath.getName(withExt: false)}.png';
      await ThanPkg.platform.genVideoThumbnail(
        pathList: [SrcDestType(src: filePath, dest: cachePath)],
      );
      return cachePath;
    }
    if (mime.endsWith('/pdf')) {
      final cachePath =
          '${PathUtil.getCachePath()}/${filePath.getName(withExt: false)}.png';
      await ThanPkg.platform.genPdfThumbnail(
        pathList: [SrcDestType(src: filePath, dest: cachePath)],
      );
      return cachePath;
    }
    final coverPath = await PathUtil.getAssetRealPathPath(assetName);
    return coverPath;
  }

  String _getCurrentHostAddress() {
    return 'http://${hostAddress.isNotEmpty ? hostAddress.first : 'localhost'}:${TServer.instance.getPort}';
  }

  void _share(List<String> pathList) async {
    try {
      if (pathList.isEmpty) {
        _showMenu();
        return;
      }
      final res = ShareServices.getList(pathList);
      list.addAll(res);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('_share:error ${e.toString()}');
    }
  }

  void _checkWifiAddress() async {
    hostAddress = await ThanPkg.platform.getWifiAddressList();
    setState(() {});
  }

  void _showQr(String data) {
    showTAlertDialog(
      context,
      content: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          spacing: 5,
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: QrImageView(data: data),
              ),
            ),
            Text('အခြားတစ်ဖက်ကနေ Scan လုပ်ပါ'),
          ],
        ),
      ),
      actions: [],
    );
  }

  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          title: Text('Add Files'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addFiles();
          },
        ),
        ListTile(
          title: Text('Add Videos'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addVideos();
          },
        ),
        ListTile(
          title: Text('Add Images'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addImages();
          },
        ),
        ListTile(
          title: Text('Add Mp3 (Audio)'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addAudios();
          },
        ),
        ListTile(
          title: Text('Add Folder Path'),
          leading: Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addFolderPath();
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
          _share(pathList);
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
          _share(pathList);
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
          _share(pathList);
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
          _share(pathList);
        },
      ),
    );
  }

  void _addFolderPath() async {
    showDialog(
      context: context,
      builder: (context) => TRenameDialog(
        text: '',
        onSubmit: (text) {
          final dir = Directory(text);
          if (!dir.existsSync()) return;
          final res = dir
              .listSync()
              .where((e) => e.statSync().type == FileSystemEntityType.file)
              .map((e) => e.path)
              .toList();
          _share(res);
        },
      ),
    );
  }
}
