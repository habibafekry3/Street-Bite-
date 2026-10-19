import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../preferences/app_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeMode.system);

  void loadTheme() {
    final saved = _prefs.getThemeMode();
    switch (saved) {
      case 'light':
        emit(ThemeMode.light);
        break;
      case 'dark':
        emit(ThemeMode.dark);
        break;
      default:
        emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.saveThemeMode(mode.name);
    emit(mode);
  }
}
