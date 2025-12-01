// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFF212529);
  Color _accentColor = const Color(0xFF495057);

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? const Color(0xFF343A40) : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : const Color(0xFF212529),
        elevation: 0,
      ),
      cardColor: _isDarkMode ? const Color(0xFF343A40) : Colors.white,
      iconTheme: IconThemeData(
        color: _isDarkMode ? Colors.white : const Color(0xFF495057),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: _isDarkMode ? Colors.white : const Color(0xFF212529),
        ),
        bodyMedium: TextStyle(
          color: _isDarkMode ? Colors.white70 : const Color(0xFF495057),
        ),
      ),
    );
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }
}