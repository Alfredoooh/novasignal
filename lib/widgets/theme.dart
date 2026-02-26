import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// CORES
// Dark mode +20% mais claro (base: 0x24→0x57, surface: 0x36→0x69)
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
  static const pillLight     = Colors.transparent;
  static const pillLightIcon = Color(0xFF000000);

  // Dark — +20% mais claro: background 0x24→0x57, surface 0x36→0x69
  static const darkBackground    = Color(0xFF575757);
  static const darkSurface       = Color(0xFF696969);
  static const darkTextPrimary   = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider       = Color(0xFF737373);
  static const darkNavBg         = Color(0xFF575757);
  static const darkNavUnselected = Color(0xFF6E6E6E);
  static const darkNavSelected   = Color(0xFFFFFFFF);
  static const pillDark          = Colors.transparent;
  static const pillDarkIcon      = Color(0xFFFFFFFF);

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
  void setDark(bool v) { if (_isDark != v) { _isDark = v; notifyListeners(); } }
}

final themeNotifier = ThemeNotifier();

// ─────────────────────────────────────────────
// HELPER — cor accent consoante tema
// ─────────────────────────────────────────────
Color accColor(bool isDark) => isDark ? AppColors.accDark : AppColors.acc;

// ─────────────────────────────────────────────
// PAPER WHITE NOTIFIER (dark mode paper color)
// ─────────────────────────────────────────────
class PaperWhiteNotifier extends ChangeNotifier {
  bool _isWhite = false;
  bool get isWhite => _isWhite;
  void toggle() { _isWhite = !_isWhite; notifyListeners(); }
  void set(bool v) { if (_isWhite != v) { _isWhite = v; notifyListeners(); } }
}

final paperWhiteNotifier = PaperWhiteNotifier();
