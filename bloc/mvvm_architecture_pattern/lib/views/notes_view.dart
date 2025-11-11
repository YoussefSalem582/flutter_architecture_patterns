import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/notes_viewmodel.dart';
import '../models/note_model.dart';

/// Notes View
/// Displays a list of notes with add and delete functionality
/// Uses BlocBuilder widget to reactively update UI when ViewModel state changes
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesViewModel(),
      child: Builder(
        builder: (context) {
          final viewModel = context.read<NotesViewModel>();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Notes'),
              centerTitle: true,
              actions: [
                // Delete all notes button
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showDeleteAllDialog(context, viewModel),
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
                    color: Theme.of(context).cardColor,
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
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Enter a note...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.note_add),
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              viewModel.addNote(value);
                              _textController.clear();
                              _showSuccessSnackbar(
                                context,
                                'Note added successfully',
                              );
                            } else {
                              _showErrorSnackbar(
                                context,
                                'Note content cannot be empty',
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_textController.text.trim().isNotEmpty) {
                            viewModel.addNote(_textController.text);
                            _textController.clear();
                            _showSuccessSnackbar(
                              context,
                              'Note added successfully',
                            );
                          } else {
                            _showErrorSnackbar(
                              context,
                              'Note content cannot be empty',
                            );
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
                  child: BlocBuilder<NotesViewModel, List<NoteModel>>(
                    builder: (context, notes) {
                      return Row(
                        children: [
                          const Icon(Icons.list, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Total Notes: ${notes.length}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Notes List - Observes notes list changes
                Expanded(
                  child: BlocBuilder<NotesViewModel, List<NoteModel>>(
                    builder: (context, notes) {
                      if (notes.isEmpty) {
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add your first note above',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return _NoteCard(
                            note: note,
                            onDelete: () {
                              viewModel.deleteNote(note.id);
                              _showSuccessSnackbar(
                                context,
                                'Note deleted successfully',
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
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
                              'Using BLoC reactive state management',
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
        },
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, NotesViewModel viewModel) {
    if (!viewModel.hasNotes) {
      _showInfoSnackbar(context, 'No notes to delete');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete All Notes'),
        content: const Text('Are you sure you want to delete all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              viewModel.deleteAllNotes();
              Navigator.of(dialogContext).pop();
              _showSuccessSnackbar(context, 'All notes deleted successfully');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
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
