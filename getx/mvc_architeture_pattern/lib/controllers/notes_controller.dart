import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/note_model.dart';

/// Controller for Notes functionality
/// Manages notes list and business logic using GetX
/// Uses GetStorage for data persistence across app restarts
class NotesController extends GetxController {
  // GetStorage instance for persistence
  final _storage = GetStorage();

  // Storage key for notes list
  static const String _notesKey = 'notes_list';

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
    // Load saved notes from storage
    _loadNotes();
  }

  /// Load notes from storage
  void _loadNotes() {
    final savedNotes = _storage.read<List>(_notesKey);
    if (savedNotes != null && savedNotes.isNotEmpty) {
      _notes.value = savedNotes
          .map((json) => NoteModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } else {
      // Add sample notes only if no saved notes exist
      _addSampleNotesQuietly();
    }
  }

  /// Save notes to storage
  Future<void> _saveNotes() async {
    final notesJson = _notes.map((note) => note.toJson()).toList();
    await _storage.write(_notesKey, notesJson);
  }

  /// Add sample notes without notifications (only on first run)
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
    _saveNotes(); // Save sample notes
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
    _saveNotes(); // Persist to storage
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
    _saveNotes(); // Persist to storage
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
        _saveNotes(); // Persist to storage
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
