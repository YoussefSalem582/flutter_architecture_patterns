import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String content;
  final DateTime timestamp;

  const Note({
    required this.id,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object> get props => [id, content, timestamp];
}
