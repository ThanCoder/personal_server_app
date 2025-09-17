// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';

import 'package:person_server/more_libs/setting_v2.2.0/core/index.dart';

class ClientDownloader extends TDownloadManager {
  final bool isFileExistsOverride;
  ClientDownloader({this.isFileExistsOverride = false});

  final String saveDir = PathUtil.getOutPath();
  final TClientToken token = TClientToken(
    isCancelFileDelete: false,
    onCancelMessage: 'Download Cancel',
  );
  final client = TClient();

  @override
  void cancel() {
    token.cancel();
  }

  @override
  Stream<TProgress> actions(List<String> urls) {
    final controller = StreamController<TProgress>();
    (() async {
      try {
        int index = 0;
        // preparing
        controller.add(TProgress.preparing(indexLength: urls.length));
        for (var url in urls) {
          index++;
          final name = url.getName();
          final savePath = '$saveDir/$name';
          // override false == skip download
          if (!isFileExistsOverride && File(savePath).existsSync()) continue;

          await client.download(
            url,
            savePath: savePath,
            token: token,
            onError: controller.addError,
            onCancelCallback: controller.addError,
            onReceiveProgressSpeed: (received, total, speed, eta) {
              controller.add(
                TProgress.progress(
                  index: index,
                  indexLength: urls.length,
                  loaded: received,
                  total: total,
                  message:
                      'Downloading...\n$name\nSpeed: ${speed.toFileSizeLabel()} - ${eta?.toAutoTimeLabel()} Left',
                ),
              );
            },
          );
        }

        controller.add(TProgress.done(message: 'Downloaded'));
      } catch (e) {
        controller.addError(e);
      } finally {
        await controller.close();
      }
    })();

    return controller.stream;
  }
}
