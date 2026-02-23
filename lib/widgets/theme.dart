import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// CORES — padrão exacto da referência
// ─────────────────────────────────────────────
class AppColors {
  // Light
  static const background    = Color(0xFFFFFFFF);
  static const surface       = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider       = Color(0xFFE0E0E0);
  static const navBg         = Color(0xFFFFFFFF);
  static const navUnselected = Color(0xFF8E8E8E);
  static const navSelected   = Color(0xFF000000);
  static const pillLight     = Color(0xFF3A3A3A);
  static const pillLightIcon = Color(0xFFFFFFFF);

  // Dark
  static const darkBackground    = Color(0xFF0D0D0D);
  static const darkSurface       = Color(0xFF272727);
  static const darkTextPrimary   = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider       = Color(0xFF2C2C2C);
  static const darkNavBg         = Color(0xFF0D0D0D);
  static const darkNavUnselected = Color(0xFF8E8E8E);
  static const darkNavSelected   = Color(0xFFFFFFFF);
  static const pillDark          = Color(0xFFE0E0E0);
  static const pillDarkIcon      = Color(0xFF0D0D0D);

  // Accent Aria
  static const acc     = Color(0xFFE0185E);
  static const accDark = Color(0xFFFF6B9D);
  static const danger  = Color(0xFFFF3B30);
}

// ─────────────────────────────────────────────
// THEME NOTIFIER
// ─────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
}

final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────
// HELPER — cor accent consoante tema
// ─────────────────────────────────────────────
Color accColor(bool isDark) => isDark ? AppColors.accDark : AppColors.acc;