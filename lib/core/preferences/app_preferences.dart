import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _keyThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  const AppPreferences(this._prefs);

  String? getThemeMode() => _prefs.getString(_keyThemeMode);
  Future<void> saveThemeMode(String value) =>
      _prefs.setString(_keyThemeMode, value);
}
