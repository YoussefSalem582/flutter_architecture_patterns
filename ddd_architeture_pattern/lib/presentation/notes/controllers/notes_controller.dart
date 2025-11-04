import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/notes/usecases/get_all_notes_usecase.dart';
import '../../../application/notes/usecases/add_note_usecase.dart';
import '../../../application/notes/usecases/delete_note_usecase.dart';
import '../../../application/notes/usecases/delete_all_notes_usecase.dart';
import '../../../domain/notes/entities/note_entity.dart';

/// Notes Controller - Presentation Layer
///
/// In DDD:
/// - Controllers coordinate between UI and application layer
/// - They call use cases (application services)
/// - They manage UI state reactively
/// - They handle UI-specific concerns (dialogs, snackbars)
class NotesController extends GetxController {
  // Use cases (injected)
  final GetAllNotesUseCase getAllNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final DeleteAllNotesUseCase deleteAllNotesUseCase;

  NotesController({
    required this.getAllNotesUseCase,
    required this.addNoteUseCase,
    required this.deleteNoteUseCase,
    required this.deleteAllNotesUseCase,
  });

  // Reactive state
  final RxList<NoteEntity> notes = <NoteEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  /// Load all notes
  Future<void> loadNotes() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await getAllNotesUseCase.execute();

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (loadedNotes) {
        notes.value = loadedNotes;
      },
    );

    isLoading.value = false;
  }

  /// Show add note dialog
  Future<void> showAddNoteDialog() async {
    final textController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add New Note'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter note content...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.isNotEmpty) {
      await addNote(textController.text);
    }

    textController.dispose();
  }

  /// Add a new note
  Future<void> addNote(String content) async {
    if (content.trim().isEmpty) {
      Get.snackbar('Error', 'Note content cannot be empty');
      return;
    }

    final result = await addNoteUseCase.execute(content);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
      },
      (note) {
        notes.add(note);
        Get.snackbar('Success', 'Note added successfully');
      },
    );
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    final result = await deleteNoteUseCase.execute(noteId);

    result.fold(
      (failure) {
        Get.snackbar('Error', failure.message);
      },
      (_) {
        notes.removeWhere((note) => note.id.value == noteId);
        Get.snackbar('Success', 'Note deleted');
      },
    );
  }

  /// Delete all notes with confirmation
  Future<void> deleteAllNotes() async {
    if (notes.isEmpty) {
      Get.snackbar('Info', 'No notes to delete');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete All Notes?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await deleteAllNotesUseCase.execute();

      result.fold(
        (failure) {
          Get.snackbar('Error', failure.message);
        },
        (_) {
          notes.clear();
          Get.snackbar('Success', 'All notes deleted');
        },
      );
    }
  }
}
