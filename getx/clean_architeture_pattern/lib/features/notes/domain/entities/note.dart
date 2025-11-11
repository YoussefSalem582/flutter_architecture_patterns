import 'package:equatable/equatable.dart';

/// Note Entity - Domain layer
/// Pure business object without any framework dependencies
class Note extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Create a copy with modified values
  Note copyWith({String? id, String? content, DateTime? createdAt}) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, content, createdAt];

  @override
  String toString() =>
      'Note(id: $id, content: $content, createdAt: $createdAt)';
}
