import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesNotifierProvider);
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => ref.read(notesNotifierProvider.notifier).clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      ref
                          .read(notesNotifierProvider.notifier)
                          .add(textController.text);
                      textController.clear();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.content),
                  subtitle: Text(note.createdAt.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => ref
                        .read(notesNotifierProvider.notifier)
                        .delete(note.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
