import 'package:flutter/material.dart';

class AriaTheme {
  static const acc = Color(0xFFE0185E);
  static const bg  = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFF0F0F0);
  static const textPrimary = Color(0xFF111111);
  static const textSub = Color(0xFF8E8E93);
  static const danger = Color(0xFFFF3B30);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: acc,
      surface: bg,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: bg,
    fontFamily: 'Syne',
    appBarTheme: const AppBarTheme(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: textPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: acc,
      unselectedItemColor: textSub,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Syne', fontWeight: FontWeight.w800,
        fontSize: 10, letterSpacing: 0.5,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Syne', fontWeight: FontWeight.w800,
        fontSize: 10, letterSpacing: 0.5,
      ),
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: border,
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
  );
}
