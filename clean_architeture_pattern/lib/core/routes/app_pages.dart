import 'package:get/get.dart';
import '../../features/counter/presentation/bindings/counter_binding.dart';
import '../../features/counter/presentation/views/counter_view.dart';
import '../../features/notes/presentation/bindings/notes_binding.dart';
import '../../features/notes/presentation/views/notes_view.dart';
import '../presentation/views/home_view.dart';
import 'app_routes.dart';

/// App Pages - Route configuration
class AppPages {
  static final pages = [
    // Home Page
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Counter Page
    GetPage(
      name: AppRoutes.counter,
      page: () => const CounterView(),
      binding: CounterBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Notes Page
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesView(),
      binding: NotesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
