import 'package:flutter/material.dart';
import 'package:person_server/app/extensions/index.dart';
import 'package:person_server/app/models/share_file.dart';
import 'package:person_server/app/widgets/index.dart';

class ShareReceiveListItem extends StatelessWidget {
  String url;
  ShareFile share;
  void Function(ShareFile share) onClicked;
  void Function(ShareFile share) onDownloadClicked;
  bool Function(ShareFile share) isExistsFile;
  ShareReceiveListItem({
    super.key,
    required this.url,
    required this.share,
    required this.isExistsFile,
    required this.onClicked,
    required this.onDownloadClicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClicked(share),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 5,
            children: [
              share.mime.startsWith('image')
                  ? SizedBox(
                      width: 130,
                      height: 130,
                      child: MyImageUrl(url: '$url/image?path=${share.path}'),
                    )
                  : SizedBox.shrink(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    Text(share.name),
                    Text(share.size.toDouble().toFileSizeLabel()),
                    Text(share.mime),
                    Text(DateTime.fromMillisecondsSinceEpoch(share.date)
                        .toParseTime()),
                    IconButton(
                      onPressed: () => onDownloadClicked(share),
                      icon: Icon(isExistsFile(share)
                          ? Icons.download_done_rounded
                          : Icons.download),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
