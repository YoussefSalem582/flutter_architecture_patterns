import 'package:get/get.dart';
import '../viewmodels/notes_viewmodel.dart';

/// Notes Binding
/// Initializes and injects NotesViewModel when navigating to Notes screen
class NotesBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization - ViewModel is created only when needed
    Get.lazyPut<NotesViewModel>(() => NotesViewModel());
  }
}
