import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────
// CORES
// ─────────────────────────────────────────────────────────
class AppColors {
  // ── Light — branco super puro ──────────────────────────
  static const background    = Color(0xFFFFFFFF);
  static const surface       = Color(0xFFFFFFFF);
  static const textPrimary   = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider       = Color(0xFFE5E5E5);
  static const navBg         = Color(0xFFFFFFFF);
  static const navUnselected = Color(0xFF8E8E8E);
  static const navSelected   = Color(0xFF000000);
  static const pillLight     = Colors.transparent;
  static const pillLightIcon = Color(0xFF000000);

  // ── Search bar light ───────────────────────────────────
  static const searchBg     = Color(0xFFFFFFFF);
  static const searchBorder = Color(0xFFD9D9D9);

  // ── Dark ───────────────────────────────────────────────
  static const darkBackground    = Color(0xFF1B1B1B);
  static const darkSurface       = Color(0xFF343434);
  static const darkTextPrimary   = Color(0xFFFFE8E3);
  static const darkTextSecondary = Color(0xFF9E8E8A);
  static const darkDivider       = Color(0xFF3D3030);
  static const darkNavBg         = Color(0xFF1B1B1B);
  static const darkNavUnselected = Color(0xFF7A6A68);
  static const darkNavSelected   = Color(0xFFFFE8E3);
  static const pillDark          = Colors.transparent;
  static const pillDarkIcon      = Color(0xFFFFE8E3);

  // ── Search bar dark ────────────────────────────────────
  static const darkSearchBg     = Color(0xFF2A2020);
  static const darkSearchBorder = Color(0xFF3D3030);

  // ── Accent ─────────────────────────────────────────────
  static const acc     = Color(0xFFF13223);
  static const accDark = Color(0xFFFA6559);
  static const primary = Color(0xFFFA6559);
  static const danger  = Color(0xFFF13223);
  static const darkPaper = Color(0xFF343434);
}

// ─────────────────────────────────────────────────────────
// HELPERS DE SEARCH BAR — reutilizáveis em qualquer ecrã
// ─────────────────────────────────────────────────────────
Color searchBg(bool isDark)     => isDark ? AppColors.darkSearchBg     : AppColors.searchBg;
Color searchBorder(bool isDark) => isDark ? AppColors.darkSearchBorder  : AppColors.searchBorder;

InputDecoration searchDecoration({
  required bool isDark,
  String hint = 'Pesquisar…',
  Widget? prefix,
  Widget? suffix,
}) {
  final bg   = searchBg(isDark);
  final brd  = searchBorder(isDark);
  final hc   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  final side = BorderSide(color: brd, width: 1.0);
  final r    = BorderRadius.circular(12);
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

// ─────────────────────────────────────────────────────────
// THEME NOTIFIER
// ─────────────────────────────────────────────────────────
class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
  void setDark(bool v) { if (_isDark != v) { _isDark = v; notifyListeners(); } }
}

final themeNotifier = ThemeNotifier();

Color accColor(bool isDark) => isDark ? AppColors.accDark : AppColors.acc;

const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFFF13223), Color(0xFFFA6559)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─────────────────────────────────────────────────────────
// PAPER WHITE NOTIFIER
// ─────────────────────────────────────────────────────────
class PaperWhiteNotifier extends ChangeNotifier {
  bool _isWhite = false;
  bool get isWhite => _isWhite;
  void toggle() { _isWhite = !_isWhite; notifyListeners(); }
  void set(bool v) { if (_isWhite != v) { _isWhite = v; notifyListeners(); } }
}

final paperWhiteNotifier = PaperWhiteNotifier();
