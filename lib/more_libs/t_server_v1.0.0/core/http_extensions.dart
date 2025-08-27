import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';

import 't_encoder.dart';

extension HttpExtensions on HttpRequest {
  void sendText(String text) {
    response
      ..headers.contentType = ContentType.text
      ..write(text)
      ..close();
  }

  void sendHtml(String html) {
    response
      ..headers.contentType = ContentType.html
      ..write(html)
      ..close();
  }

  void sendJson(String jsonStr) {
    response
      ..headers.contentType = ContentType.json
      ..write(jsonStr)
      ..close();
  }

  Map<String, dynamic> getQueryParameters() {
    return uri.queryParameters;
  }

  Map<String, dynamic> getParams() {
    // final path = uri.queryParameters;
    return {};
  }

  Future<String> getBody() async {
    final content = await utf8.decoder.bind(this).join();
    return content;
  }

  Future<void> sendFile(String filePath) async {
    try {
      final file = File(filePath);
      final name = file.path.split('/').last;

      if (file.existsSync()) {
        response.headers.set('Content-Type', 'text/plain; charset=utf-8');
        response.headers.set(
          'Content-Disposition',
          'attachment; filename="${TEncoder.encodeRFC5987(name)}"',
        );
        response.headers.set('Content-Length', file.statSync().size);

        // UTF-8 stream နဲ့ pipe လုပ်
        await file.openRead().pipe(response);
      } else {
        response
          ..statusCode = HttpStatus.notFound
          ..write('File not found')
          ..close();
      }
    } catch (e) {
      debugPrint(e.toString());
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error')
        ..close();
    }
  }

  Future<void> sendVideoStream(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        response
          ..statusCode = HttpStatus.notFound
          ..write('File not found')
          ..close();
        return;
      }

      final total = await file.length();
      int start = 0;
      int end = total - 1;

      final rangeHeader = headers.value(HttpHeaders.rangeHeader);
      if (rangeHeader != null) {
        final match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(rangeHeader);
        if (match != null) {
          start = int.parse(match.group(1)!);
          if (match.group(2) != null && match.group(2)!.isNotEmpty) {
            end = int.parse(match.group(2)!);
          }
        }
        response.statusCode = HttpStatus.partialContent;
      }

      final length = end - start + 1;

      response.headers
        ..set(HttpHeaders.contentTypeHeader, 'video/mp4')
        ..set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..set(HttpHeaders.contentLengthHeader, length.toString())
        ..set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$total');

      final stream = file.openRead(start, end + 1);
      await stream.pipe(response);
    } catch (e) {
      debugPrint(e.toString());
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error')
        ..close();
    }
  }
}
