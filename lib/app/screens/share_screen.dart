import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/dialogs/index.dart';
import 'package:person_server/app/extensions/datetime_extension.dart';
import 'package:person_server/app/extensions/double_extension.dart';
import 'package:person_server/app/lib_components/path_chooser.dart';
import 'package:person_server/app/models/share_file.dart';
import 'package:person_server/app/services/share_services.dart';
import 'package:person_server/app/widgets/index.dart';
import 'package:t_server/t_server.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    TServer.instance.stopServer(force: true);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  List<String> hostAddress = [];
  List<ShareFile> list = [];
  List<String> pathList = [];
  bool isLoading = false;
  bool isServerRunning = false;
  String serverStatusText = '';

  void init() async {
    try {
      hostAddress = await ThanPkg.platform.getWifiAddressList();
      await ThanPkg.platform.toggleKeepScreen(isKeep: true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _addFiles() async {
    pathList = await platformFilePathChooser(context);
    _share();
  }

  void _addFolderPath() async {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        text: '',
        onSubmit: (text) {
          final dir = Directory(text);
          if (!dir.existsSync()) return;
          pathList = dir
              .listSync()
              .where((e) => e.statSync().type == FileSystemEntityType.file)
              .map((e) => e.path)
              .toList();
          _share();
        },
      ),
    );
  }

  Future<void> _startServer() async {
    await TServer.instance.stopServer(force: true);
    await TServer.instance.startServer(port: serverPort);
    debugPrint('start server on http://localhost:$serverPort');
  }

  void _share() async {
    try {
      if (pathList.isEmpty) {
        _showMenu();
        return;
      }
      setState(() {
        isLoading = true;
        isServerRunning = false;
      });

      await _startServer();

      list = ShareServices.getList(pathList);
      final mapList = list.map((e) => e.toMap).toList();
      final json = JsonEncoder.withIndent(' ').convert(mapList);
      // send client
      TServer.instance.get('/', (req) {
        // TServer.send(req, body: 'hello');
        TServer.sendJson(req, body: json);
      });
      TServer.instance.get('/download', (req) {
        final path = req.uri.queryParameters['path'] ?? '';
        TServer.sendFile(req, path);
      });
      TServer.instance.get('/image', (req) {
        final path = req.uri.queryParameters['path'] ?? '';
        TServer.sendImage(req, path);
      });
      TServer.instance.get('/stream', (req) {
        final path = req.uri.queryParameters['path'] ?? '';
        TServer.sendStreamVideo(req, path);
      });

      if (!mounted) return;
      setState(() {
        isLoading = false;
        isServerRunning = true;
        serverStatusText =
            'http://${hostAddress.isNotEmpty ? hostAddress.first : 'localhost'}:$serverPort';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('_share:error ${e.toString()}');
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 150),
          child: Column(
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
                title: Text('Add Folder Path'),
                leading: Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  _addFolderPath();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: isLoading
          ? TLoader()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('Share'),
                ),
                //server status
                SliverToBoxAdapter(
                  child: Column(
                    spacing: 5,
                    children: [
                      Text(
                        isServerRunning
                            ? 'Running On: $serverStatusText'
                            : 'Sever Stop',
                        style: TextStyle(
                          color: isServerRunning ? Colors.green : Colors.red,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ပြန်စတင်မယ်'),
                          IconButton(
                            onPressed: _share,
                            icon: Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(child: Divider()),

                // list
                SliverList.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final share = list[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(share.name),
                            Text(share.size.toDouble().toFileSizeLabel()),
                            Text(share.mime),
                            Text(DateTime.fromMillisecondsSinceEpoch(share.date)
                                .toParseTime()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMenu,
        child: Icon(Icons.add),
      ),
    );
  }
}
