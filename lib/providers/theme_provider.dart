// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFF1a1a1a); // Cinza escuro
  Color _accentColor = const Color(0xFF2d2d2d); // Cinza médio escuro

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme({bool? isDark}) async {
    _isDarkMode = isDark ?? !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
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

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        secondary: const Color(0xFF404040), // Cinza para contraste
      ),
      scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF0a0a0a) : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? const Color(0xFF141414) : Colors.white,
        foregroundColor: _isDarkMode ? const Color(0xFFe0e0e0) : const Color(0xFF1a1a1a),
        elevation: 0,
      ),
      cardColor: _isDarkMode ? const Color(0xFF1f1f1f) : Colors.white,
      iconTheme: IconThemeData(
        color: _isDarkMode ? const Color(0xFFe0e0e0) : const Color(0xFF2d2d2d),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: _isDarkMode ? const Color(0xFFe0e0e0) : const Color(0xFF1a1a1a),
        ),
        bodyMedium: TextStyle(
          color: _isDarkMode ? const Color(0xFFa0a0a0) : const Color(0xFF2d2d2d),
        ),
      ),
    );
  }
}

/* 
 * PALETA DE CORES ESCURAS (NEUTRAS):
 * 
 * Primária: #1a1a1a (Cinza escuro)
 * Acento: #2d2d2d (Cinza médio escuro)
 * Secundário: #404040 (Cinza para contraste)
 * Background: #0a0a0a (Preto profundo)
 * Card/AppBar: #141414 / #1f1f1f (Cinzas escuros)
 * Texto principal: #e0e0e0 (Branco suave)
 * Texto secundário: #a0a0a0 (Cinza claro)
 * 
 * Cores neutras escuras sem tons azuis.
 */