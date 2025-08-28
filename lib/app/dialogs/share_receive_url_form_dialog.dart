import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:person_server/app/constants.dart';
import 'package:person_server/app/services/recent_services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareReceiveUrlFormDialog extends StatefulWidget {
  void Function(String url) onSuccess;
  ShareReceiveUrlFormDialog({super.key, required this.onSuccess});

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

  bool isLoading = false;
  bool isAliveUrl = false;
  List<String> hostAddress = [];
  String? errorText;
  Dio dio = Dio(
    BaseOptions(
      sendTimeout: Duration(seconds: 3),
      connectTimeout: Duration(seconds: 3),
      receiveTimeout: Duration(seconds: 3),
    ),
  );

  void init() async {
    try {
      hostAddress = await ThanPkg.platform.getWifiAddressList();
      final oldUrl = await RecentServices.get<String>('url', defaultValue: '');
      urlController.text = oldUrl.isEmpty ? hostAddress.first : oldUrl;
      // _checkHost();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
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
          _getHostAddressList(),
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

  Widget _getHostAddressList() {
    return Column(
      children: List.generate(hostAddress.length, (index) {
        final address = hostAddress[index];
        return ListTile(
          title: Text(address),
          onTap: () {
            urlController.text = address;
            _checkHost();
          },
        );
      }),
    );
  }

  void _checkHost() async {
    try {
      setState(() {
        isLoading = true;
        isAliveUrl = false;
      });
      final url = 'http://${urlController.text}:$serverPort';

      await dio.get(url);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isAliveUrl = true;
        errorText = null;
      });
      // await RecentServices.instance
      //     .setValue<String>('share-host-address', urlController.text);
      await RecentServices.set('url', urlController.text);

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess(url);
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
}
