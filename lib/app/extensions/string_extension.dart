extension StringExtension on String {
  String toCaptalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1, length)}';
  }

  String getName({bool withExt = true}) {
    final name = split('/').last;
    if (withExt) {
      return name;
    }
    return name.split('.').first;
  }

  String getExt() {
    return split('/').last.split('.').last;
  }
}
