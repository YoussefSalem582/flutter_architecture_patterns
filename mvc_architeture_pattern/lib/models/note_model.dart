/// Model class for Note
/// Holds the note data structure
class NoteModel {
  final String id;
  final String content;
  final DateTime createdAt;

  NoteModel({required this.id, required this.content, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

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
}
