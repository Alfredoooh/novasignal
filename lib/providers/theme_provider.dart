import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    primaryColor: const Color(0xFF111111),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF111111),
      secondary: Color(0xFF5b5b5b),
      surface: Color(0xFFFFFFFF),
      surfaceContainerHighest: Color(0xFFEEEEEE),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF5b5b5b),
      onSurface: Color(0xFF111111),
      outline: Color(0xFFDDDDDD),
      outlineVariant: Color(0xFFEEEEEE),
    ),
    cardColor: const Color(0xFFFFFFFF),
    dividerColor: const Color(0xFFEEEEEE),
    shadowColor: Colors.black.withOpacity(0.08),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF111111),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF111111), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFAFAFA),
      foregroundColor: Color(0xFF111111),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
        fontFamily: 'Inter',
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111111),
        height: 1.3,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF111111),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF5b5b5b),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF757575),
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111111),
        height: 1.4,
        letterSpacing: 0.1,
      ),
    ),
    fontFamily: 'Inter',
  );

  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    primaryColor: const Color(0xFFFFFFFF),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF),
      secondary: Color(0xFFa0a0a0),
      surface: Color(0xFF1C1C1C),
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFFa0a0a0),
      onSurface: Color(0xFFFFFFFF),
      outline: Color(0xFF3A3A3A),
      outlineVariant: Color(0xFF2A2A2A),
    ),
    cardColor: const Color(0xFF1C1C1C),
    dividerColor: const Color(0xFF2A2A2A),
    shadowColor: Colors.black.withOpacity(0.3),
    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C1C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0F0F),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black38,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        fontFamily: 'Inter',
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFFFFFF),
        height: 1.3,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFFFFFFFF),
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFFa0a0a0),
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF757575),
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFFFFFF),
        height: 1.4,
        letterSpacing: 0.1,
      ),
    ),
    fontFamily: 'Inter',
  );

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  String get themeModeName => _isDarkMode ? 'dark' : 'light';
}