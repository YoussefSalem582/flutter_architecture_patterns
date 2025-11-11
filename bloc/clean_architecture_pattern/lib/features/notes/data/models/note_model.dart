import '../../domain/entities/note.dart';

/// Note Model - Data layer
/// Extends Note entity and adds JSON serialization
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.content,
    required super.createdAt,
  });

  /// Convert entity to model
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

  @override
  NoteModel copyWith({String? id, String? content, DateTime? createdAt}) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
