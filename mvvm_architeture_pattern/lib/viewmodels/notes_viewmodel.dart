import 'package:get/get.dart';
import '../models/note_model.dart';

/// Notes ViewModel
/// Contains reactive data and business logic for the notes feature
/// Uses GetX observables to enable reactive UI updates
class NotesViewModel extends GetxController {
  // Reactive list of notes - UI automatically updates when list changes
  final _notes = <NoteModel>[].obs;

  // Getter to access the notes list
  List<NoteModel> get notes => _notes;

  // Getter to check if notes list is empty
  bool get hasNotes => _notes.isNotEmpty;

  // Getter for notes count
  int get notesCount => _notes.length;

  /// Add a new note to the list
  void addNote(String content) {
    if (content.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Note content cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    _notes.add(note);

    Get.snackbar(
      'Success',
      'Note added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Delete a note by its ID
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);

    Get.snackbar(
      'Deleted',
      'Note deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Delete all notes
  void deleteAllNotes() {
    if (_notes.isEmpty) {
      Get.snackbar(
        'Info',
        'No notes to delete',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.defaultDialog(
      title: 'Delete All Notes',
      middleText: 'Are you sure you want to delete all notes?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () {
        _notes.clear();
        Get.back();
        Get.snackbar(
          'Deleted',
          'All notes deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );
  }

  /// Update a note's content
  void updateNote(String id, String newContent) {
    if (newContent.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Note content cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(content: newContent.trim());
      Get.snackbar(
        'Updated',
        'Note updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    print('NotesViewModel initialized');
    // Add some sample notes for demonstration
    _loadSampleNotes();
  }

  void _loadSampleNotes() {
    _notes.addAll([
      NoteModel(
        id: '1',
        content: 'Welcome to Counter Notes App!',
        createdAt: DateTime.now(),
      ),
      NoteModel(
        id: '2',
        content: 'This is a sample note using MVVM with GetX',
        createdAt: DateTime.now(),
      ),
    ]);
  }

  @override
  void onClose() {
    print('NotesViewModel disposed');
    super.onClose();
  }
}
