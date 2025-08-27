import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/dialogs/share_receive_url_form_dialog.dart';
import 'package:person_server/app/routes_helper.dart';
import 'package:person_server/app/screens/receive/receive_screen.dart';
import 'package:person_server/app/screens/share/share_screen.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: IconButton(
                iconSize: 60,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShareScreen()),
                  );
                },
                icon: Icon(Icons.share_rounded),
              ),
            ),
            Card(
              child: IconButton(
                iconSize: 60,
                onPressed: () async {
                  try {
                    if (Platform.isAndroid &&
                        !await ThanPkg.android.permission
                            .isStoragePermissionGranted()) {
                      await ThanPkg.android.permission
                          .requestStoragePermission();
                      return;
                    }
                    if (!context.mounted) return;
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ShareReceiveUrlFormDialog(
                        onSuccess: (url) {
                          goRoute(
                            context,
                            builder: (context) => ReceiveScreen(url: url),
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                  }
                },
                icon: Icon(Icons.download),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
