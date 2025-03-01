import 'package:flutter/material.dart';
import 'package:person_server/app/models/index.dart';
import 'package:person_server/app/utils/index.dart';
import 'package:person_server/app/widgets/core/my_image_file.dart';

class ServerFileListItem extends StatelessWidget {
  ServerFileModel serverFile;
  void Function(ServerFileModel serverFile) onClicked;
  ServerFileListItem({
    super.key,
    required this.serverFile,
    required this.onClicked,
  });

  String _getCoverPath() {
    if (serverFile.mime.startsWith('image')) {
      return serverFile.path;
    }
    if (serverFile.isFolder) {
      return 'assets/folder1.png';
    }
    return 'assets/file.png';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          width: 150,
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyImageFile(
              path: _getCoverPath(),
              fit: BoxFit.fill,
              borderRadius: 5,
            ),
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
            ],
          ),
        ),
      ],
    );
  }
}
