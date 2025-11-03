import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../models/note_model.dart';

/// Notes View
/// Displays a list of notes with add and delete functionality
/// Uses Obx widget to reactively update UI when ViewModel data changes
class NotesView extends GetView<NotesViewModel> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        actions: [
          // Delete all notes button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: controller.deleteAllNotes,
            tooltip: 'Delete All Notes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Note Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Get.theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note_add),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.addNote(value);
                        textController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      controller.addNote(textController.text);
                      textController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Notes Count
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => Row(
                children: [
                  const Icon(Icons.list, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Total Notes: ${controller.notesCount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notes List - Observes notes list changes
          Expanded(
            child: Obx(() {
              if (!controller.hasNotes) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first note above',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.notes.length,
                itemBuilder: (context, index) {
                  final note = controller.notes[index];
                  return _NoteCard(
                    note: note,
                    onDelete: () => controller.deleteNote(note.id),
                  );
                },
              );
            }),
          ),

          // Info Footer
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Using GetX reactive list observables',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Note Card Widget
class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.onDelete});

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.2),
          child: const Icon(Icons.note, color: Colors.green),
        ),
        title: Text(note.content, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _formatDateTime(note.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Delete Note',
        ),
      ),
    );
  }
}
