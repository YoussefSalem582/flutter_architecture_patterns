import '../../domain/notes/note.dart';

class NoteDto {
  final String id;
  final String title;
  final String content;

  const NoteDto({required this.id, required this.title, required this.content});

  factory NoteDto.fromDomain(Note note) {
    return NoteDto(id: note.id, title: note.title, content: note.content);
  }

  Note toDomain() {
    return Note(id: id, title: title, content: content);
  }

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content};
  }
}
