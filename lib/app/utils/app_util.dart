import 'package:intl/intl.dart';

String getParseMinutes(int minutes) {
  String res = '';
  try {
    final dur = Duration(minutes: minutes);
    res = '${_getTwoZero(dur.inHours)}:${_getTwoZero(dur.inMinutes)}';
  } catch (e) {}
  return res;
}

String _getTwoZero(int num) {
  return num < 10 ? '0$num' : '$num';
}

String getParseDate(int date) {
  String res = '';
  try {
    final lastModifiedDateTime = DateTime.fromMillisecondsSinceEpoch(date);

    // Format DateTime
    res = DateFormat('yyyy-MM-dd HH:mm:ss').format(lastModifiedDateTime);
  } catch (e) {}
  return res;
}

String getParseFileSize(double size) {
  String res = '';
  int pow = 1024;
  final labels = ['byte', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  while (size > pow) {
    size /= pow;
    i++;
  }

  res = '${size.toStringAsFixed(2)} ${labels[i]}';

  return res;
}
