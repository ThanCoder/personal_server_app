import 'package:flutter/material.dart';
import 'package:person_server/app/components/index.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/screens/receive_screen.dart';
import 'package:person_server/app/services/index.dart';
import 'package:person_server/app/services/recent_services.dart';
import 'package:person_server/app/widgets/core/t_text_field.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareReceiveUrlFormDialog extends StatefulWidget {
  const ShareReceiveUrlFormDialog({super.key});

  @override
  State<ShareReceiveUrlFormDialog> createState() =>
      _ShareReceiveUrlFormDialogState();
}

class _ShareReceiveUrlFormDialogState extends State<ShareReceiveUrlFormDialog> {
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool isAliveUrl = false;
  String? errorText;

  void init() async {
    try {
      final hostList = await ThanPkg.platform.getWifiAddressList();
      final res = await RecentServices.instance.getValue<String>(
          'share-host-address',
          defaultValue: hostList.isNotEmpty ? hostList.first : '');
      urlController.text = res;
      _checkHost();
    } catch (e) {
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  void _checkHost() async {
    try {
      setState(() {
        isLoading = true;
        isAliveUrl = false;
      });
      final url = 'http://${urlController.text}:$serverPort';

      await DioServices.instance.getDio.get(url);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isAliveUrl = true;
        errorText = null;
      });
      await RecentServices.instance
          .setValue<String>('share-host-address', urlController.text);

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiveScreen(url: url),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isAliveUrl = false;
        errorText = 'ချိတ်ဆက် မရပါ';
      });
    }
  }

  bool get _isGoButtonEnable {
    if (isLoading) {
      return false;
    }
    if (errorText == null) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        children: [
          TTextField(
            label: Text('Connect Url'),
            controller: urlController,
            errorText: errorText,
            onSubmitted: (value) {
              _checkHost();
            },
          ),
          isLoading ? LinearProgressIndicator() : SizedBox.shrink(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
        TextButton(
          onPressed: _isGoButtonEnable ? _checkHost : null,
          child: Text('စမ်းသပ်'),
        ),
      ],
    );
  }
}
