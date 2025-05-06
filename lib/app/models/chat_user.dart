// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

class ChatUser {
  String id;
  String name;
  WebSocket socket;
  DateTime date;
  ChatUser({
    required this.id,
    required this.name,
    required this.socket,
    required this.date,
  });

  Map<String, dynamic> get toMap => {
        'id': id,
        'name': name,
        'date': date.toLocal().toIso8601String(),
      };
}
