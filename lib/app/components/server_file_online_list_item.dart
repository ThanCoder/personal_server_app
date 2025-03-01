import 'package:flutter/material.dart';
import 'package:person_server/app/components/index.dart';
import 'package:person_server/app/models/index.dart';
import 'package:person_server/app/notifiers/server_notifier.dart';
import 'package:person_server/app/utils/index.dart';
import 'package:person_server/app/widgets/core/my_image_file.dart';
import 'package:person_server/app/widgets/index.dart';

class ServerFileOnlineListItem extends StatelessWidget {
  ServerFileModel serverFile;
  void Function(ServerFileModel serverFile) onClicked;
  ServerFileOnlineListItem({
    super.key,
    required this.serverFile,
    required this.onClicked,
  });

  String _getDownloadUrl() {
    final host = clientHostAddressNotifier.value;
    return '$host/download?path=${serverFile.path}';
  }

  Widget _getCoverImage() {
    if (serverFile.mime.startsWith('image')) {
      final host = clientHostAddressNotifier.value;
      if (host.isNotEmpty) {
        final url = '$host/download?path=${serverFile.path}';
        return MyImageUrl(
          url: url,
          fit: BoxFit.fill,
          borderRadius: 5,
        );
      }
    } else if (serverFile.isFolder) {
      return MyImageFile(
        path: 'assets/folder1.png',
        fit: BoxFit.fill,
        borderRadius: 5,
      );
    }
    return MyImageFile(
      path: '',
      fit: BoxFit.fill,
      borderRadius: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(serverFile),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
              width: 120,
              height: 130,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getCoverImage(),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    serverFile.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(serverFile.mime),
                  Text('Folder: ${serverFile.isFolder.toString()}'),
                  Text(getParseFileSize(serverFile.size.toDouble())),
                  Text(getParseDate(serverFile.date)),
                  serverFile.isFolder
                      ? SizedBox()
                      : FileDownloadComponent(
                          filename: serverFile.name,
                          fileUrl: _getDownloadUrl(),
                          savePath: '${getOutPath()}/${serverFile.name}',
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
