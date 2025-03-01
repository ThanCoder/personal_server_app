import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:person_server/app/components/core/index.dart';
import 'package:person_server/app/components/server_file_online_list_item.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/dialogs/host_form_dialog.dart';
import 'package:person_server/app/models/index.dart';
import 'package:person_server/app/notifiers/server_notifier.dart';
import 'package:person_server/app/services/index.dart';
import 'package:person_server/app/widgets/core/index.dart';

class OtherClientPage extends StatefulWidget {
  const OtherClientPage({super.key});

  @override
  State<OtherClientPage> createState() => _OtherClientPageState();
}

class _OtherClientPageState extends State<OtherClientPage> {
  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
    // sendTimeout: Duration(seconds: 5),
  ));

  @override
  void initState() {
    super.initState();
    init();
  }

  List<ServerFileModel> list = [];
  bool isLoading = false;

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await dio.get(_getHost());
      //set current host
      clientHostAddressNotifier.value = _getHost();

      List<dynamic> resList = jsonDecode(res.data);

      if (!mounted) return;
      setState(() {
        isLoading = false;
        list = resList.map((map) => ServerFileModel.fromMap(map)).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _hostDialog();
      debugPrint(e.toString());
    }
  }

  String _getHost() {
    final host = getRecentDB<String>('client_recent_host') ?? '';
    if (host.isNotEmpty) {
      return host;
    }
    return 'http://localhost:$serverPort';
  }

  void _hostDialog() {
    showDialog(
      context: context,
      builder: (context) => HostFormDialog(
        onSubmit: (hostUrl) {
          setRecentDB<String>('client_recent_host', hostUrl);
          clientHostAddressNotifier.value = hostUrl;
          init();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(clientHostAddressNotifier.value);
    return MyScaffold(
      body: isLoading
          ? TLoader()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(appTitle),
                ),
                //show info
                SliverToBoxAdapter(
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: clientHostAddressNotifier,
                          builder: (context, value, child) {
                            if (value.isEmpty) return SizedBox();
                            return Text(
                              'Connnect Server Address: $value',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                //list
                SliverList.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ServerFileOnlineListItem(
                      serverFile: list[index],
                      onClicked: (serverFile) {
                        if (!serverFile.mime.startsWith('video')) {
                          showDialogMessage(context, 'Viewer Not Suppored!');
                          return;
                        }
                        final url =
                            '${clientHostAddressNotifier.value}/stream?path=${serverFile.path}';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              resoure: url,
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
        onPressed: init,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
