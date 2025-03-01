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

  Widget _getCoverImage() {
    if (serverFile.isFolder) {
      return MyImageFile(
        path: '',
        defaultAssetsPath: 'assets/folder1.png',
        fit: BoxFit.fill,
        borderRadius: 5,
      );
    } else {
      return MyImageFile(
        path: serverFile.coverPath,
        defaultAssetsPath: 'assets/file.png',
        fit: BoxFit.fill,
        borderRadius: 5,
      );
    }
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
              width: 110,
              height: 120,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
