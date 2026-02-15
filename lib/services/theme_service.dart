import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app theme mode (light/dark/system) and language
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  
  ThemeMode _themeMode = ThemeMode.system;
  String _languageCode = 'en';
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isInitialized => _isInitialized;

  ThemeService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
      
      // Load language
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        _languageCode = savedLanguage;
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }

  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    
    _languageCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, code);
    } catch (e) {
      debugPrint('Failed to save language: $e');
    }
  }

  /// Returns the display name for the current theme mode
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  /// Returns the display name for the current language
  String get languageDisplayName {
    const languageNames = {
      'en': 'English',
      'fr': 'Français',
      'es': 'Español',
      'de': 'Deutsch',
      'pt': 'Português',
      'it': 'Italiano',
      'nl': 'Nederlands',
      'pl': 'Polski',
      'ro': 'Română',
      'el': 'Ελληνικά',
      'cs': 'Čeština',
      'hu': 'Magyar',
      'sv': 'Svenska',
      'bg': 'Български',
      'hr': 'Hrvatski',
      'sk': 'Slovenčina',
      'da': 'Dansk',
      'fi': 'Suomi',
      'no': 'Norsk',
      'uk': 'Українська',
      'sr': 'Српски',
      'sl': 'Slovenščina',
      'lt': 'Lietuvių',
      'lv': 'Latviešu',
      'et': 'Eesti',
      'sq': 'Shqip',
      'tr': 'Türkçe',
      'ru': 'Русский',
    };
    return languageNames[_languageCode] ?? 'English';
  }
}
