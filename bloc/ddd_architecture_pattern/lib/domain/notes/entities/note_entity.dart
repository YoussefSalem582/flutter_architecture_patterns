import 'package:equatable/equatable.dart';

import '../value_objects/note_id.dart';
import '../value_objects/note_content.dart';
import '../value_objects/note_timestamp.dart';

/// Note Entity - Domain Model
///
/// In DDD, this entity represents a Note aggregate root.
/// It contains:
/// - Identity (NoteId value object)
/// - Content (NoteContent value object)
/// - Timestamp (NoteTimestamp value object)
/// - Business rules for note operations
///
/// Framework-independent, pure domain logic
class NoteEntity extends Equatable {
  final NoteId id;
  final NoteContent content;
  final NoteTimestamp createdAt;

  const NoteEntity({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Factory: Create new note
  factory NoteEntity.create({required String id, required String content}) {
    return NoteEntity(
      id: NoteId(id),
      content: NoteContent(content),
      createdAt: NoteTimestamp.now(),
    );
  }

  /// Business rule: Update note content
  NoteEntity updateContent(String newContent) {
    return NoteEntity(
      id: id,
      content: NoteContent(newContent),
      createdAt: createdAt, // Preserve original timestamp
    );
  }

  /// Business rule: Check if note is empty
  bool get isEmpty => content.isEmpty;

  /// Business rule: Check if note is valid
  bool get isValid => content.isValid;

  @override
  List<Object?> get props => [id, content, createdAt];

  @override
  String toString() =>
      'NoteEntity(id: ${id.value}, content: "${content.text}")';
}
