// ignore_for_file: public_member_api_docs, sort_constructors_first
class ShareFile {
  String name;
  String path;
  String mime;
  int size;
  int date;
  ShareFile({
    required this.name,
    required this.path,
    required this.mime,
    required this.size,
    required this.date,
  });

  factory ShareFile.fromMap(Map<String, dynamic> map) {
    return ShareFile(
      name: map['name'],
      path: map['path'],
      mime: map['mime'],
      size: map['size'],
      date: map['date'],
    );
  }

  Map<String, dynamic> get toMap => {
        'name': name,
        'path': path,
        'mime': mime,
        'size': size,
        'date': date,
      };
  @override
  String toString() {
    return name;
  }
}
