import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'pt';
  
  String get currentLanguage => _currentLanguage;
  
  final Map<String, Map<String, String>> _translations = {
    'pt': {
      'home': 'Home',
      'welcome': 'Bem-vindo',
      'welcomeDesc': 'Explore as funcionalidades do app',
      'recent': 'Recentes',
      'recentDesc': 'Os teus itens mais recentes aparecerão aqui',
      'favorites': 'Favoritos',
      'favoritesDesc': 'Acede rapidamente aos teus favoritos',
      'settings': 'Definições',
      'appearance': 'Aparência',
      'theme': 'Tema',
      'light': 'Claro',
      'dark': 'Escuro',
      'language': 'Idioma',
      'portuguese': 'Português',
      'english': 'Inglês',
      'notifications': 'Notificações',
      'privacy': 'Privacidade',
      'analytics': 'Análises',
      'new': 'New',
      'ai': 'IA',
      'createNew': 'Criar Novo',
      'createNewDesc': 'Crie algo incrível',
      'start': 'Começar',
      'textAssistant': 'Assistente de Texto',
      'textAssistantDesc': 'Gere e edita textos com inteligência artificial',
      'imageAnalysis': 'Análise de Imagem',
      'imageAnalysisDesc': 'Analisa e descreve imagens automaticamente',
      'smartSuggestions': 'Sugestões Inteligentes',
      'smartSuggestionsDesc': 'Recebe sugestões personalizadas baseadas no teu conteúdo',
    },
    'en': {
      'home': 'Home',
      'welcome': 'Welcome',
      'welcomeDesc': 'Explore the app features',
      'recent': 'Recent',
      'recentDesc': 'Your most recent items will appear here',
      'favorites': 'Favorites',
      'favoritesDesc': 'Quickly access your favorites',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'language': 'Language',
      'portuguese': 'Portuguese',
      'english': 'English',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'analytics': 'Analytics',
      'new': 'New',
      'ai': 'AI',
      'createNew': 'Create New',
      'createNewDesc': 'Create something amazing',
      'start': 'Get Started',
      'textAssistant': 'Text Assistant',
      'textAssistantDesc': 'Generate and edit texts with artificial intelligence',
      'imageAnalysis': 'Image Analysis',
      'imageAnalysisDesc': 'Analyze and describe images automatically',
      'smartSuggestions': 'Smart Suggestions',
      'smartSuggestionsDesc': 'Get personalized suggestions based on your content',
    },
  };

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'pt';
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'pt' ? 'en' : 'pt';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _currentLanguage);
    notifyListeners();
  }

  String get languageName => _currentLanguage == 'pt' ? 'Português' : 'English';
}