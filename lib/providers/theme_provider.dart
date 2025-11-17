// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  // Azul do Facebook
  static const Color facebookBlue = Color(0xFF1877F2);
  
  // Branco puro
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // Carvão profundo (não cinza)
  static const Color deepCharcoal = Color(0xFF0D0D0D);
  static const Color charcoalSurface = Color(0xFF1A1A1A);

  // Tema Claro - BRANCO PURO
  ThemeData get lightTheme => ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: pureWhite,
    colorScheme: ColorScheme.light(
      primary: facebookBlue,
      secondary: facebookBlue,
      surface: pureWhite,
      background: pureWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: pureWhite,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // Tema Escuro - CARVÃO PROFUNDO
  ThemeData get darkTheme => ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: facebookBlue,
    scaffoldBackgroundColor: deepCharcoal,
    colorScheme: ColorScheme.dark(
      primary: facebookBlue,
      secondary: facebookBlue,
      surface: charcoalSurface,
      background: deepCharcoal,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: deepCharcoal,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: charcoalSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  Future<void> _loadThemeMode() async {
    final themeModeString = _prefs.getString('theme_mode') ?? 'system';
    _themeMode = _getThemeModeFromString(themeModeString);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('theme_mode', _getStringFromThemeMode(mode));
    notifyListeners();
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}