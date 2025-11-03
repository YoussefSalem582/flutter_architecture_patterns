import 'package:get/get.dart';
import '../models/note_model.dart';

/// Controller for Notes functionality
/// Manages notes list and business logic using GetX
class NotesController extends GetxController {
  // Reactive list of notes
  final _notes = <NoteModel>[].obs;

  // Getter for notes list
  List<NoteModel> get notes => _notes;

  // Check if notes list is empty
  bool get isEmpty => _notes.isEmpty;

  // Get notes count
  int get notesCount => _notes.length;

  @override
  void onInit() {
    super.onInit();
    // Add some sample notes for demonstration
    _addSampleNotesQuietly();
  }

  /// Add sample notes without notifications
  void _addSampleNotesQuietly() {
    final note1 = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Welcome to Counter Notes App!',
    );
    final note2 = NoteModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: 'This app demonstrates MVC pattern with GetX',
    );
    _notes.addAll([note1, note2]);
  }

  /// Add a new note
  void addNote(String content) {
    if (content.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Note content cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
    );

    _notes.add(note);
    Get.snackbar(
      'Success',
      'Note added successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Delete a note by id
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    Get.snackbar(
      'Deleted',
      'Note deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  /// Clear all notes
  void clearAllNotes() {
    if (_notes.isEmpty) {
      Get.snackbar(
        'Info',
        'No notes to clear',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Clear All Notes',
      middleText: 'Are you sure you want to delete all notes?',
      textCancel: 'Cancel',
      textConfirm: 'Clear',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () {
        _notes.clear();
        Get.back();
        Get.snackbar(
          'Cleared',
          'All notes have been deleted',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
