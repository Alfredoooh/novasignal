import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────
// CORES — compatível com todos os ecrãs sem alterações
// ─────────────────────────────────────────────────────────
class AppColors {
  // ── Light ──────────────────────────────────────────────
  static const background    = Color(0xFFF1F0F0); // fundo claro
  static const surface       = Color(0xFFFFFFFF); // papel / cards
  static const textPrimary   = Color(0xFF000000);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider       = Color(0xFFE0E0E0);
  static const navBg         = Color(0xFFFFFFFF);
  static const navUnselected = Color(0xFF8E8E8E);
  static const navSelected   = Color(0xFF000000);
  static const pillLight     = Colors.transparent;
  static const pillLightIcon = Color(0xFF000000);

  // ── Dark ───────────────────────────────────────────────
  static const darkBackground    = Color(0xFF1B1B1B); // fundo escuro
  static const darkSurface       = Color(0xFF343434); // papel escuro — nunca mais escuro que darkBackground
  static const darkTextPrimary   = Color(0xFFFFE8E3); // texto principal escuro
  static const darkTextSecondary = Color(0xFF9E8E8A);
  static const darkDivider       = Color(0xFF3D3030);
  static const darkNavBg         = Color(0xFF1B1B1B);
  static const darkNavUnselected = Color(0xFF7A6A68);
  static const darkNavSelected   = Color(0xFFFFE8E3);
  static const pillDark          = Colors.transparent;
  static const pillDarkIcon      = Color(0xFFFFE8E3);

  // ── Accent / Primary ───────────────────────────────────
  // F13223 = vermelho forte (destaque, danger)
  // FA6559 = coral suave (primária, botões)
  static const acc     = Color(0xFFF13223); // light mode accent
  static const accDark = Color(0xFFFA6559); // dark mode accent (mais suave)
  static const primary = Color(0xFFFA6559); // cor primária global
  static const danger  = Color(0xFFF13223); // erros

  // Mantidos por retrocompatibilidade com outros ecrãs
  static const darkPaper = Color(0xFF343434);
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

// ─────────────────────────────────────────────────────────
// HELPER — cor accent consoante tema
// ─────────────────────────────────────────────────────────
Color accColor(bool isDark) => isDark ? AppColors.accDark : AppColors.acc;

// Gradiente primário — usado no FAB, botões principais, balões
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
