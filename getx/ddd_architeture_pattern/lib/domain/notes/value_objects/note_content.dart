import 'package:equatable/equatable.dart';

/// NoteContent - Value Object for Note Content
///
/// In DDD, value objects encapsulate business rules and validation.
/// This ensures:
/// - Content cannot be null
/// - Content has reasonable length limits
/// - Content validation is centralized
class NoteContent extends Equatable {
  final String text;

  const NoteContent._(this.text);

  /// Factory with validation
  factory NoteContent(String content) {
    if (content.isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }
    if (content.length > 500) {
      throw ArgumentError('Note content cannot exceed 500 characters');
    }
    return NoteContent._(content.trim());
  }

  /// Check if content is empty
  bool get isEmpty => text.isEmpty;

  /// Check if content is valid
  bool get isValid => text.isNotEmpty && text.length <= 500;

  /// Get character count
  int get length => text.length;

  @override
  List<Object?> get props => [text];

  @override
  String toString() => 'NoteContent($text)';
}
