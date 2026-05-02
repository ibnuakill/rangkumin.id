import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _lastNoteKey = 'last_note_id';
  static const String _themeKey = 'is_dark_theme';

  Future<void> saveLastNoteId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastNoteKey, id);
  }

  Future<int?> getLastNoteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastNoteKey);
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
