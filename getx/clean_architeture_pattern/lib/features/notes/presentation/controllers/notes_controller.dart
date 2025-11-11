import 'package:get/get.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_all_notes.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';

/// Notes Controller - Presentation layer
/// Manages notes state and business logic using GetX
class NotesController extends GetxController {
  final GetAllNotes getAllNotesUseCase;
  final AddNote addNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final DeleteAllNotes deleteAllNotesUseCase;

  NotesController({
    required this.getAllNotesUseCase,
    required this.addNoteUseCase,
    required this.deleteNoteUseCase,
    required this.deleteAllNotesUseCase,
  });

  // Reactive state
  final _notes = <Note>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  // Getters
  List<Note> get notes => _notes;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get hasNotes => _notes.isNotEmpty;
  int get notesCount => _notes.length;

  @override
  void onInit() {
    super.onInit();
    Logger.info('NotesController initialized', tag: 'NotesController');
    loadNotes();
  }

  /// Load all notes from storage
  Future<void> loadNotes() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await getAllNotesUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Logger.error(
          'Failed to load notes: ${failure.message}',
          tag: 'NotesController',
        );
      },
      (notes) {
        _notes.assignAll(notes);
        Logger.info('Loaded ${notes.length} notes', tag: 'NotesController');
      },
    );

    _isLoading.value = false;
  }

  /// Add a new note
  Future<void> addNote(String content) async {
    if (content.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Note content cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await addNoteUseCase(AddNoteParams(content: content));

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (note) {
        _notes.insert(0, note); // Add to beginning
        Get.snackbar(
          'Success',
          'Note added successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await deleteNoteUseCase(DeleteNoteParams(id: id));

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) {
        _notes.removeWhere((note) => note.id == id);
        Get.snackbar(
          'Success',
          'Note deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  /// Delete all notes with confirmation
  Future<void> deleteAllNotes() async {
    if (!hasNotes) {
      Get.snackbar(
        'Info',
        'No notes to delete',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.defaultDialog(
      title: 'Delete All Notes',
      middleText:
          'Are you sure you want to delete all notes? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        Get.back(); // Close dialog
        await _performDeleteAll();
      },
    );
  }

  /// Actually perform the delete all operation
  Future<void> _performDeleteAll() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    final result = await deleteAllNotesUseCase(const NoParams());

    result.fold(
      (failure) {
        _errorMessage.value = failure.message;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) {
        _notes.clear();
        Get.snackbar(
          'Success',
          'All notes deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      },
    );

    _isLoading.value = false;
  }

  @override
  void onClose() {
    Logger.info('NotesController disposed', tag: 'NotesController');
    super.onClose();
  }
}
