import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  String _language = 'pt';
  Color _primaryColor = const Color(0xFF0A84FF);

  bool get isDark => _isDark;
  String get language => _language;
  Color get primaryColor => _primaryColor;

  Color get backgroundColor => _isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color get navigationBarColor => _isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
  Color get textColor => _isDark ? CupertinoColors.white : CupertinoColors.black;
  Color get secondaryBackground => _isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
  Color get borderColor => _isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? true;
    _language = prefs.getString('language') ?? 'pt';
    final colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  String translate(String key) {
    final translations = {
      'pt': {
        'welcome': 'Bem-vindo',
        'start_conversation': 'Iniciar conversa',
        'message': 'Mensagem',
        'clear': 'Limpar',
        'settings': 'Configurações',
        'clear_chat': 'Limpar Chat',
        'clear_message': 'Deseja remover todas as mensagens?',
        'cancel': 'Cancelar',
        'ok': 'OK',
        'start': 'Começar',
        'select_document': 'Selecionar Documento',
      },
      'en': {
        'welcome': 'Welcome',
        'start_conversation': 'Start a conversation',
        'message': 'Message',
        'clear': 'Clear',
        'settings': 'Settings',
        'clear_chat': 'Clear Chat',
        'clear_message': 'Do you want to remove all messages?',
        'cancel': 'Cancel',
        'ok': 'OK',
        'start': 'Start',
        'select_document': 'Select Document',
      },
    };
    return translations[_language]?[key] ?? key;
  }
}