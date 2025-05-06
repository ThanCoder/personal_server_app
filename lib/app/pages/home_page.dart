import 'dart:io';

import 'package:flutter/material.dart';
import 'package:person_server/app/components/index.dart';
import 'package:person_server/app/dialogs/share_receive_url_form_dialog.dart';
import 'package:person_server/app/screens/share_screen.dart';
import 'package:person_server/app/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

import '../constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
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
                    MaterialPageRoute(
                      builder: (context) => ShareScreen(),
                    ),
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
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => ShareReceiveUrlFormDialog(),
                    );
                  } catch (e) {
                    showDialogMessage(context, e.toString());
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
