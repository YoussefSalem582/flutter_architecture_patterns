import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;

  const Note({required this.id, required this.title, required this.content});

  factory Note.empty() => const Note(id: '', title: '', content: '');

  Note copyWith({String? id, String? title, String? content}) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [id, title, content];
}
