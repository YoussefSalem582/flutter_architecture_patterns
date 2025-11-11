import '../../../domain/notes/entities/note_entity.dart';
import '../../../domain/notes/value_objects/note_id.dart';
import '../../../domain/notes/value_objects/note_content.dart';
import '../../../domain/notes/value_objects/note_timestamp.dart';

/// Note DTO - Infrastructure Layer
///
/// In DDD, DTOs handle the translation between:
/// - Domain entities (rich business objects)
/// - Storage format (simple data structures)
class NoteDto {
  final String id;
  final String content;
  final String createdAt; // ISO8601 format

  const NoteDto({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Convert from domain entity
  factory NoteDto.fromEntity(NoteEntity entity) {
    return NoteDto(
      id: entity.id.value,
      content: entity.content.text,
      createdAt: entity.createdAt.dateTime.toIso8601String(),
    );
  }

  /// Convert to domain entity
  NoteEntity toEntity() {
    return NoteEntity(
      id: NoteId(id),
      content: NoteContent(content),
      createdAt: NoteTimestamp.from(DateTime.parse(createdAt)),
    );
  }

  /// From JSON
  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'createdAt': createdAt};
  }
}
