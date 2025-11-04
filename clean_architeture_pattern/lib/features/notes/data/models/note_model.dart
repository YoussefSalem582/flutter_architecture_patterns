import '../../domain/entities/note.dart';

/// Note Model - Data layer
/// Extends Note entity with JSON serialization
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.content,
    required super.createdAt,
  });

  /// Create from JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      content: note.content,
      createdAt: note.createdAt,
    );
  }

  /// Convert to entity
  Note toEntity() {
    return Note(id: id, content: content, createdAt: createdAt);
  }
}
