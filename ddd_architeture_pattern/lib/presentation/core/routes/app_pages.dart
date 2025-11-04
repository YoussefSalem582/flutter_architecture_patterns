import 'package:get/get.dart';

import '../../counter/bindings/counter_binding.dart';
import '../../counter/views/counter_view.dart';
import '../../notes/bindings/notes_binding.dart';
import '../../notes/views/notes_view.dart';
import '../views/home_view.dart';
import 'app_routes.dart';

/// App Pages - GetX Route Configuration
///
/// In DDD:
/// - Routing configuration is part of presentation layer
/// - Each route has its own binding (dependency injection)
class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(
      name: AppRoutes.counter,
      page: () => const CounterView(),
      binding: CounterBinding(),
    ),
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesView(),
      binding: NotesBinding(),
    ),
  ];
}
