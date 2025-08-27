import 'dart:convert';

class TEncoder {
  static String encodeRFC5987(String text) {
    final bytes = utf8.encode(text);
    final encoded = bytes.map((b) {
      if ((b >= 0x30 && b <= 0x39) || // 0-9
          (b >= 0x41 && b <= 0x5A) || // A-Z
          (b >= 0x61 && b <= 0x7A) || // a-z
          b == 0x2D ||
          b == 0x2E ||
          b == 0x5F ||
          b == 0x7E) {
        // - . _ ~
        return String.fromCharCode(b);
      }
      return '%${b.toRadixString(16).toUpperCase().padLeft(2, '0')}';
    }).join();
    return encoded;
  }
}
