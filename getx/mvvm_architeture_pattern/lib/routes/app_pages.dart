import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../bindings/counter_binding.dart';
import '../bindings/notes_binding.dart';
import '../views/home_view.dart';
import '../views/counter_view.dart';
import '../views/notes_view.dart';

/// App Pages
/// Defines all application pages with their routes, bindings, and transitions
class AppPages {
  static final pages = [
    // Home Page
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Counter Page with Binding
    GetPage(
      name: AppRoutes.counter,
      page: () => const CounterView(),
      binding: CounterBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Notes Page with Binding
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesView(),
      binding: NotesBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
