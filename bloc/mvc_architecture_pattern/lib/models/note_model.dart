import 'package:equatable/equatable.dart';

/// Model class for Note
/// Holds the note data structure
class NoteModel extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Factory constructor with default createdAt
  factory NoteModel.create({
    required String id,
    required String content,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Create a copy of the note with optional new values
  NoteModel copyWith({String? id, String? content, DateTime? createdAt}) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert note to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create note from JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [id, content, createdAt];
}
