import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AriaTheme {
  static const acc       = Color(0xFFE0185E);
  static const bg        = Color(0xFFFFFFFF);
  static const card      = Color(0xFFFFFFFF);
  static const border    = Color(0xFFF0F0F0);
  static const textPrimary = Color(0xFF111111);
  static const textSub   = Color(0xFF8E8E93);
  static const danger    = Color(0xFFFF3B30);

  // Syne carregada via google_fonts — funciona na web E no nativo
  static TextStyle syne({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textPrimary,
    double? letterSpacing,
    double? height,
  }) => GoogleFonts.syne(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);
    // Aplica Syne como fonte base via google_fonts
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: acc,
        surface: bg,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.syneTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.syne(
          fontWeight: FontWeight.w800, fontSize: 18, color: textPrimary),
      ),
      dividerColor: border,
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
    );
  }
}
