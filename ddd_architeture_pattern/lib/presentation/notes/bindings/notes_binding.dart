import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../application/notes/usecases/get_all_notes_usecase.dart';
import '../../../application/notes/usecases/add_note_usecase.dart';
import '../../../application/notes/usecases/delete_note_usecase.dart';
import '../../../application/notes/usecases/delete_all_notes_usecase.dart';
import '../../../domain/notes/repositories/notes_repository.dart';
import '../../../infrastructure/notes/datasources/notes_local_datasource.dart';
import '../../../infrastructure/notes/repositories/notes_repository_impl.dart';
import '../controllers/notes_controller.dart';

/// Notes Binding - Dependency Injection
///
/// In DDD:
/// - Bindings configure the dependency graph
/// - Follow dependency inversion principle
/// - Wire up: Infrastructure → Domain ← Application ← Presentation
class NotesBinding extends Bindings {
  @override
  void dependencies() {
    // Infrastructure layer (data source)
    Get.lazyPut<NotesLocalDataSource>(
      () => NotesLocalDataSource(Get.find<GetStorage>()),
    );

    // Infrastructure layer (repository implementation)
    Get.lazyPut<NotesRepository>(
      () => NotesRepositoryImpl(Get.find<NotesLocalDataSource>()),
    );

    // Application layer (use cases)
    Get.lazyPut(() => GetAllNotesUseCase(Get.find<NotesRepository>()));
    Get.lazyPut(() => AddNoteUseCase(Get.find<NotesRepository>()));
    Get.lazyPut(() => DeleteNoteUseCase(Get.find<NotesRepository>()));
    Get.lazyPut(() => DeleteAllNotesUseCase(Get.find<NotesRepository>()));

    // Presentation layer (controller)
    Get.lazyPut(
      () => NotesController(
        getAllNotesUseCase: Get.find(),
        addNoteUseCase: Get.find(),
        deleteNoteUseCase: Get.find(),
        deleteAllNotesUseCase: Get.find(),
      ),
    );
  }
}
