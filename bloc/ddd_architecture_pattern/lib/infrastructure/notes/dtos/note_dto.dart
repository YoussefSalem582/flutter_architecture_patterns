import 'dart:convert';

import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/value_objects/note_id.dart';
import '../../../domain/notes/value_objects/note_content.dart';
import '../../../domain/notes/value_objects/note_timestamp.dart';

/// NoteDTO - Data Transfer Object
///
/// Handles serialization/deserialization between domain entities
/// and infrastructure (storage, APIs, etc.).
///
/// Separates domain model from persistence format.
class NoteDTO {
  final String id;
  final String content;
  final String createdAt;

  NoteDTO({required this.id, required this.content, required this.createdAt});

  /// Convert from domain entity to DTO
  factory NoteDTO.fromEntity(NoteEntity entity) {
    return NoteDTO(
      id: entity.id.value,
      content: entity.content.text,
      createdAt: entity.createdAt.toIso8601(),
    );
  }

  /// Convert from DTO to domain entity
  NoteEntity toEntity() {
    return NoteEntity(
      id: NoteId(id),
      content: NoteContent(content),
      createdAt: NoteTimestamp.fromIso8601(createdAt),
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'createdAt': createdAt};
  }

  /// Deserialize from JSON
  factory NoteDTO.fromJson(Map<String, dynamic> json) {
    return NoteDTO(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Encode to JSON string
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string
  factory NoteDTO.decode(String source) =>
      NoteDTO.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
