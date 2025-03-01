import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/components/index.dart';
import 'package:person_server/app/dialogs/index.dart';
import 'package:person_server/app/models/server_file_model.dart';
import 'package:person_server/app/notifiers/server_notifier.dart';
import 'package:person_server/app/services/index.dart';
import 'package:t_server/t_server.dart';
import 'package:than_pkg/than_pkg.dart';

import '../constants.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> hostList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initHostList();
    init();
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  void initHostList() async {
    final res = await ThanPkg.platform.getWifiAddressList();
    setState(() {
      hostList = res;
    });
    ThanPkg.platform.toggleKeepScreen(isKeep: true);
  }

  void init() async {
    if (isServerRunningNotifier.value) return;

    final recentPath = getRecentDB<String>('recent_dir_path') ?? '';
    if (recentPath.isEmpty) return;
    isServerRunningNotifier.value = false;
    setState(() {
      isLoading = true;
    });
    //start server
    await TServer.instance.stopServer(force: true);
    await TServer.instance.startServer(port: serverPort);
    isServerRunningNotifier.value = true;
    _serverListener();
    //set
    serverHostAddressNotifier.value = 'http://localhost:$serverPort';
    serverSendFolderPathNotifier.value = recentPath;

    serverSendListNotifier.value =
        await ServerFileService.instance.getList(dirPath: recentPath);
    setState(() {
      isLoading = false;
    });
    TServer.instance.get('/', (req) async {
      tServerSend(
        req,
        body: JsonEncoder.withIndent(' ')
            .convert(serverSendListNotifier.value.toMapList()),
        contentType: ContentType.json,
      );
    });
  }

  void _sendDirList() {
    final recentPath = getRecentDB<String>('recent_dir_path') ?? '';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        title: 'folder path ထည့်ပေးပါ',
        renameText: recentPath,
        onCancel: () {},
        onSubmit: (path) async {
          await TServer.instance.stopServer(force: true);
          await TServer.instance.startServer(port: serverPort);
          isServerRunningNotifier.value = true;
          _serverListener();
          //set
          serverHostAddressNotifier.value = 'http://localhost:$serverPort';
          serverSendFolderPathNotifier.value = path;
          //set recent
          setRecentDB<String>('recent_dir_path', path);
          serverSendListNotifier.value =
              await ServerFileService.instance.getList(dirPath: path);
          setState(() {
            isLoading = false;
          });
          TServer.instance.get('/', (req) async {
            tServerSend(
              req,
              body: JsonEncoder.withIndent(' ')
                  .convert(serverSendListNotifier.value.toMapList()),
              contentType: ContentType.json,
            );
          });
        },
      ),
    );
  }

  void _checkStoragePermisssion() async {
    if (!await ThanPkg.platform.isStoragePermissionGranted()) {
      await ThanPkg.platform.requestStoragePermission();
      return;
    }
    _sendDirList();
  }

  Widget _getHeaderInfo() {
    return ValueListenableBuilder(
      valueListenable: isServerRunningNotifier,
      builder: (context, isServerRunning, child) {
        return Column(
          children: [
            //info
            Card(
              child: Row(
                spacing: 10,
                children: [
                  IconButton(
                    color: isServerRunning ? Colors.red : Colors.green,
                    iconSize: 30,
                    onPressed: _toggleStartServer,
                    icon:
                        Icon(isServerRunning ? Icons.stop : Icons.play_circle),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: serverHostAddressNotifier,
                          builder: (context, value, child) {
                            if (value.isEmpty) return SizedBox();
                            return Text(
                              'Server ${isServerRunning ? 'Running On' : 'is Stopped'}: $value',
                              style: TextStyle(
                                color:
                                    isServerRunning ? Colors.green : Colors.red,
                                fontSize: 15,
                              ),
                            );
                          },
                        ),
                        //send dir
                        ValueListenableBuilder(
                          valueListenable: serverSendFolderPathNotifier,
                          builder: (context, value, child) {
                            if (value.isEmpty) return SizedBox();
                            return Text(
                              'Send Folder Path: $value',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 189, 101, 34),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //wifi list
            isServerRunning
                ? Center(
                    child: Column(
                      spacing: 5,
                      children: [
                        Text('Wifi List'),
                        SelectableText(
                          hostList.join('\n'),
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: serverSendListNotifier,
      builder: (context, list, child) {
        return MyScaffold(
          contentPadding: 0,
          body: isLoading
              ? TLoader()
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Text(appTitle),
                      floating: false,
                      pinned: true,
                    ),

                    SliverToBoxAdapter(
                      child: _getHeaderInfo(),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),

                    //list
                    SliverList.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return ServerFileListItem(
                          serverFile: list[index],
                          onClicked: (serverFile) {
                            if (!serverFile.mime.startsWith('video')) {
                              showDialogMessage(
                                  context, 'Viewer Not Suppored!');
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPlayerScreen(
                                  resoure: serverFile.path,
                                  title: serverFile.name,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _checkStoragePermisssion,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _toggleStartServer() async {
    if (isServerRunningNotifier.value) {
      await TServer.instance.stopServer(force: true);
    } else {
      //start server
      await TServer.instance.stopServer(force: true);
      await TServer.instance.startServer(port: serverPort);
    }
    isServerRunningNotifier.value = !isServerRunningNotifier.value;
  }

  void _serverListener() {
    TServer.instance.get('/custom', (req) async {
      //default
      final defaultPath = await ThanPkg.platform.getAppExternalPath() ?? '';
      var dirPath = req.uri.queryParameters['path'] ?? defaultPath;
      bool isShowHidden = true;
      final isShowHiddenQuery = req.uri.queryParameters['hidden_file'];
      if (isShowHiddenQuery != null) {
        if (isShowHiddenQuery.toUpperCase() == 'TRUE') {
          isShowHidden = true;
        }
        if (isShowHiddenQuery.toUpperCase() == 'FALSE') {
          isShowHidden = false;
        }
      }
      final list = await ServerFileService.instance.getList(
        dirPath: dirPath,
        isShowHidden: isShowHidden,
      );
      final json = JsonEncoder.withIndent(
        ' ',
      ).convert(list.map((sf) => sf.toMap()).toList());
      tServerSend(req, body: json, contentType: ContentType.json);
    });

    TServer.instance.get('/download', (req) async {
      final path = req.uri.queryParameters['path'] ?? '';
      //path မရှိရင်
      if (path.isEmpty) {
        tServerSend(req,
            body: '`path` မရှိပါ', httpStatus: HttpStatus.notFound);
        return;
      }
      //send stream
      try {
        await tServerSendFile(req, path);
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    //stream video
    TServer.instance.get('/stream', (req) async {
      final path = req.uri.queryParameters['path'] ?? '';
      //path မရှိရင်
      if (path.isEmpty) {
        tServerSend(req,
            body: '`path` မရှိပါ', httpStatus: HttpStatus.notFound);
        return;
      }
      //send stream
      await tServerStreamVideo(req, path);
    });
  }
}
