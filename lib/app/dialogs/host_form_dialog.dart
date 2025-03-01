import 'package:flutter/material.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/services/core/index.dart';
import 'package:person_server/app/widgets/core/index.dart';
import 'package:than_pkg/than_pkg.dart';

class HostFormDialog extends StatefulWidget {
  void Function(String hostUrl) onSubmit;
  HostFormDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<HostFormDialog> createState() => _HostFormDialogState();
}

class _HostFormDialogState extends State<HostFormDialog> {
  final TextEditingController hostController = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  List<String> hostList = [];

  void init() async {
    final res = await ThanPkg.platform.getWifiAddressList();
    setState(() {
      hostList = res;
    });

    final host = getRecentDB<String>('client_recent_host') ?? '';
    if (host.isNotEmpty) {
      hostController.text =
          host.replaceAll('http://', '').replaceAll(':$serverPort', '');
    } else {
      hostController.text = '192.168.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Host Address'),
      content: SingleChildScrollView(
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //host list
            SelectableText(hostList.join('\n')),
            //form
            TTextField(
              label: Text('Host Address'),
              hintText: '192.168.xxx.xxx',
              controller: hostController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSubmit('http://${hostController.text}:$serverPort');
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
