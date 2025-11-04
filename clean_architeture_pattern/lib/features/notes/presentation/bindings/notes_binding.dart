import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/delete_all_notes.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_all_notes.dart';
import '../controllers/notes_controller.dart';

/// Notes Binding - Presentation layer
/// Handles dependency injection for Notes feature
class NotesBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.lazyPut<NotesLocalDataSource>(
      () => NotesLocalDataSourceImpl(GetStorage()),
    );

    Get.lazyPut(() => NotesRepositoryImpl(Get.find<NotesLocalDataSource>()));

    // Domain layer - Use cases
    Get.lazyPut(() => GetAllNotes(Get.find<NotesRepositoryImpl>()));
    Get.lazyPut(() => AddNote(Get.find<NotesRepositoryImpl>()));
    Get.lazyPut(() => DeleteNote(Get.find<NotesRepositoryImpl>()));
    Get.lazyPut(() => DeleteAllNotes(Get.find<NotesRepositoryImpl>()));

    // Presentation layer - Controller
    Get.lazyPut(
      () => NotesController(
        getAllNotesUseCase: Get.find<GetAllNotes>(),
        addNoteUseCase: Get.find<AddNote>(),
        deleteNoteUseCase: Get.find<DeleteNote>(),
        deleteAllNotesUseCase: Get.find<DeleteAllNotes>(),
      ),
    );
  }
}
