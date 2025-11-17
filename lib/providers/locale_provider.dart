// providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale = const Locale('pt', 'PT');

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final languageCode = _prefs.getString('language_code') ?? 'pt';
    final countryCode = _prefs.getString('country_code') ?? 'PT';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString('language_code', locale.languageCode);
    await _prefs.setString('country_code', locale.countryCode ?? '');
    notifyListeners();
  }
}