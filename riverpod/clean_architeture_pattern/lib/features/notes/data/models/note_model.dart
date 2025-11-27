import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required String id,
    required String content,
    required DateTime createdAt,
  }) : super(id: id, content: content, createdAt: createdAt);

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      content: note.content,
      createdAt: note.createdAt,
    );
  }
}
