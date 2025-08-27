import 'dart:io';

import 'package:person_server/app/models/share_file.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareServices {
  static Future<void> share(List<ShareFile> list) async {
    // TServer.instance.get('/', (req) {
    //   // File('res.html').writeAsStringSync(html);
    //   TServer.sendHtml(req, body: ShareServices.getHtml(list));
    // });
    // // send client
    // TServer.instance.get('/api', (req) {
    //   final mapList = list.map((e) => e.toMap).toList();
    //   final json = JsonEncoder.withIndent(' ').convert(mapList);
    //   TServer.sendJson(req, body: json);
    // });
    // TServer.instance.get('/download', (req) {
    //   final path = req.uri.queryParameters['path'] ?? '';
    //   TServer.sendFile(req, path);
    // });
    // TServer.instance.get('/image', (req) {
    //   final path = req.uri.queryParameters['path'] ?? '';
    //   TServer.sendImage(req, path);
    // });
    // TServer.instance.get('/cover', (req) async {
    //   final path = req.uri.queryParameters['path'] ?? '';
    //   var assetName = 'file.png';

    //   final mime = lookupMimeType(path) ?? '';
    //   if (mime.startsWith('image')) {
    //     return TServer.sendImage(req, path);
    //   }
    //   if (mime.startsWith('video')) {
    //     assetName = 'video.png';
    //   }
    //   if (mime.startsWith('application/pdf')) {
    //     assetName = 'pdf.png';
    //   }
    //   final res = await rootBundle.load('assets/$assetName');
    //   final img = File('${PathUtil.getCachePath()}/$assetName');
    //   if (!img.existsSync()) {
    //     img.writeAsBytesSync(res.buffer.asUint8List());
    //   }

    //   TServer.sendImage(req, img.path);
    // });
    // TServer.instance.get('/stream', (req) {
    //   final path = req.uri.queryParameters['path'] ?? '';
    //   TServer.sendStreamVideo(req, path);
    // });
  }

  static List<ShareFile> getList(List<String> pathList) {
    List<ShareFile> list = [];
    for (var path in pathList) {
      final mime = lookupMimeType(path) ?? '';
      final file = File(path);
      list.add(
        ShareFile(
          name: file.getName(),
          path: path,
          mime: mime,
          size: file.statSync().size,
          date: file.statSync().modified.millisecondsSinceEpoch,
        ),
      );
    }
    return list;
  }

  static String getHtml(List<ShareFile> list) {
    final html =
        '''
          <!DOCTYPE html>
          <html>
          <head><title>Share Data</title></head>
         ${_getStyleTag()}
          <body>
            <h1>Share Data List</h1>
            <ul>
              ${list.map((e) {
          return '''
            <li>
              <img src="/cover?path=${e.path}" alt="img"  width="190px" height="210px"/>
              <div class="column">
                <a href="/${e.mime.startsWith('video') ? 'stream' : 'download'}?path=${e.path}" title="${e.name}" >${e.name}</a>
                <div>Mime: ${e.mime}</div>
                <div>Size: ${e.size.toDouble().toFileSizeLabel()}</div>
                <div>Date: ${DateTime.fromMillisecondsSinceEpoch(e.date).toParseTime()}</div>
              <a href="/download?path=${e.path}" title="${e.name}" download="${e.name}" >Download</a>
              </div>
            </li>
            ''';
        }).join('<br/>')}
            </ul>
          </body>
          </html>
          ''';
    return html;
  }

  static String _getStyleTag() {
    return '''
<style>
    * {
      padding: 0;
      margin: 0;
      box-sizing: border-box;
    }
    body {
      max-width: 400%;
      padding: 2em;
      background-color: #292929;
      color: rgb(240, 240, 240);
    }
    h1 {
      margin-bottom: 1em;
    }
    ul a {
      display: block;
      text-overflow: ellipsis;
      font-size: 14px;
      text-decoration: none;
    }
    ul li {
      list-style: none;
      display: flex;
      /* justify-items: start; */
      background-color: rgba(129, 129, 129, 0.664);
      padding: 1em;
      border-radius: 1em;
      gap: 1em;
    }
    .ul li a {
      display: block;
      font-size: 14px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .column {
      display: grid;
    }
  </style>
  ''';
  }
}
