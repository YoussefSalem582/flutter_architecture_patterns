import 'package:equatable/equatable.dart';

/// Note Model
/// Represents the data structure for a note
class NoteModel extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  /// Creates a copy of the NoteModel with updated values
  NoteModel copyWith({String? id, String? content, DateTime? createdAt}) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a NoteModel from a JSON map
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, content, createdAt];

  @override
  String toString() =>
      'NoteModel(id: $id, content: $content, createdAt: $createdAt)';
}
