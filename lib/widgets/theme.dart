import 'package:flutter/material.dart';

class AppColors {
  // ── Light ──────────────────────────────────────────────
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
  // ── Search bar light ───────────────────────────────────
  static const searchBg     = Color(0xFFF5F5F5);
  static const searchBorder = Color(0xFFE0E0E0);

  // ── Dark ───────────────────────────────────────────────
  static const darkBackground    = Color(0xFF0D0D0D);
  static const darkSurface       = Color(0xFF272727);
  static const darkTextPrimary   = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E8E8E);
  static const darkDivider       = Color(0xFF2C2C2C);
  static const darkNavBg         = Color(0xFF0D0D0D);
  static const darkNavUnselected = Color(0xFF8E8E8E);
  static const darkNavSelected   = Color(0xFFFFFFFF);
  static const darkDrawerBg      = Color(0xFF262626);
  static const pillDark          = Color(0xFFE0E0E0);
  static const pillDarkIcon      = Color(0xFF0D0D0D);
  // ── Search bar dark ────────────────────────────────────
  static const darkSearchBg     = Color(0xFF222222);
  static const darkSearchBorder = Color(0xFF2C2C2C);

  // ── Accent ─────────────────────────────────────────────
  static const acc     = Color(0xFF000000);
  static const accDark = Color(0xFFFFFFFF);
  static const danger  = Color(0xFFE53935);
  static const darkPaper = Color(0xFF272727);
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
  void setDark(bool v) { if (_isDark != v) { _isDark = v; notifyListeners(); } }
}

final themeNotifier = ThemeNotifier();

Color accColor(bool isDark)      => isDark ? AppColors.accDark : AppColors.acc;
Color bgColor(bool isDark)       => isDark ? AppColors.darkBackground : AppColors.background;
Color textPrimaryC(bool isDark)  => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
Color textSecondaryC(bool isDark)=> isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
Color dividerC(bool isDark)      => isDark ? AppColors.darkDivider : AppColors.divider;

Color searchBgC(bool isDark)     => isDark ? AppColors.darkSearchBg : AppColors.searchBg;
Color searchBorderC(bool isDark) => isDark ? AppColors.darkSearchBorder : AppColors.searchBorder;

InputDecoration searchDecoration({
  required bool isDark,
  String hint = 'Pesquisar…',
  Widget? prefix,
  Widget? suffix,
}) {
  final bg  = searchBgC(isDark);
  final brd = searchBorderC(isDark);
  final hc  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  final side= BorderSide(color: brd, width: 1.0);
  final r   = BorderRadius.circular(12);
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: hc, fontSize: 14),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: bg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    border:        OutlineInputBorder(borderRadius: r, borderSide: side),
    enabledBorder: OutlineInputBorder(borderRadius: r, borderSide: side),
    focusedBorder: OutlineInputBorder(borderRadius: r, borderSide: BorderSide(color: brd, width: 1.5)),
  );
}

class PaperWhiteNotifier extends ChangeNotifier {
  bool _isWhite = false;
  bool get isWhite => _isWhite;
  void toggle() { _isWhite = !_isWhite; notifyListeners(); }
  void set(bool v) { if (_isWhite != v) { _isWhite = v; notifyListeners(); } }
}

final paperWhiteNotifier = PaperWhiteNotifier();

const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF000000), Color(0xFF3A3A3A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
