import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/dialogs/index.dart';
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
    final res = await platformFilePathChooser(context);
    pathList.addAll(res);
    _share();
  }

  void _addVideos() async {
    final res = await platformVideoPathChooser(context);
    pathList.addAll(res);
    _share();
  }

  void _addImages() async {
    final res = await platformImagePathChooser();
    pathList.addAll(res);
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
          final res = dir
              .listSync()
              .where((e) => e.statSync().type == FileSystemEntityType.file)
              .map((e) => e.path)
              .toList();
          pathList.addAll(res);
          _share();
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
      list = ShareServices.getList(pathList);

      if (isServerRunning) {
        setState(() {});
        return;
      }
      setState(() {
        isLoading = true;
        isServerRunning = false;
      });
      await _startServer();

      // await Future.delayed(const Duration(seconds: 1));

      await ShareServices.share(list);

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
    return DropTarget(
      onDragDone: (details) {
        final res = details.files
            .map(
              (e) => e.path,
            )
            .where((path) => File(path).isFile())
            .toList();
        pathList.addAll(res);
        _share();
      },
      child: MyScaffold(
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
                        GestureDetector(
                          onTap: () {
                            ThanPkg.platform.launch(serverStatusText);
                          },
                          child: Text(
                            isServerRunning
                                ? 'Running On: $serverStatusText'
                                : 'Sever Stop',
                            style: TextStyle(
                              color:
                                  isServerRunning ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            list.isEmpty ? SizedBox.shrink() : Text('ရှင်းမယ်'),
                            list.isEmpty
                                ? SizedBox.shrink()
                                : IconButton(
                                    onPressed: () async {
                                      pathList.clear();
                                      list.clear();
                                      await TServer.instance
                                          .stopServer(force: true);
                                      setState(() {
                                        isServerRunning = false;
                                      });
                                    },
                                    icon: Icon(Icons.clear_all_rounded),
                                  ),
                            const SizedBox(width: 40),
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
                  SliverToBoxAdapter(child: hostAddress.isEmpty ? SizedBox.shrink(): Center(child: Text('address တစ်ခုခုနဲ့ စမ်းကြည့်ပါ'))),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),

                  // ရနိုင်သော wifi list
                  SliverList.separated(
                    itemCount: hostAddress.length,
                    itemBuilder: (context, index) {
                      final ip = hostAddress[index];
                      return ListTile(
                        tileColor: 'http://$ip:$serverPort' == serverStatusText ? Colors.teal:null,
                        title: Text(ip),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
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
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(share.date)
                                    .toParseTime(),
                              ),
                              IconButton(
                                color: Colors.red,
                                onPressed: () {
                                  pathList.removeAt(index);
                                  _share();
                                },
                                icon: Icon(Icons.delete_forever),
                              ),
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
      ),
    );
  }
}
