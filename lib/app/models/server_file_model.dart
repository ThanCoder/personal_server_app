// ignore_for_file: public_member_api_docs, sort_constructors_first
class ServerFileModel {
  String name;
  String path;
  String mime;
  bool isFolder;
  int size;
  int date;
  ServerFileModel({
    required this.name,
    required this.path,
    required this.mime,
    required this.isFolder,
    required this.size,
    required this.date,
  });

  factory ServerFileModel.fromMap(Map<String, dynamic> map) {
    return ServerFileModel(
      name: map['name'],
      path: map['path'],
      mime: map['mime'],
      isFolder: map['is_folder'],
      size: map['size'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'path': path,
        'mime': mime,
        'is_folder': isFolder,
        'size': size,
        'date': date,
      };
}

extension ServerFileModelExtension on List<ServerFileModel> {
  List<Map<String, dynamic>> toMapList() {
    return map((sf) => sf.toMap()).toList();
  }
}
