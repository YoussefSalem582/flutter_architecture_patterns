import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_providers.dart';

class ThemeViewModel extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeViewModel(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = _prefs.getBool('is_dark');
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setBool('is_dark', state == ThemeMode.dark);
  }
}

final themeViewModelProvider = StateNotifierProvider<ThemeViewModel, ThemeMode>(
  (ref) {
    return ThemeViewModel(ref.watch(sharedPreferencesProvider));
  },
);
