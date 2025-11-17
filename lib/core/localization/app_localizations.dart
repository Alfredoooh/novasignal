// core/localization/app_localizations.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'assets/translations/${locale.languageCode}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get forgotPassword => translate('forgot_password');
  String get home => translate('home');
  String get search => translate('search');
  String get wishlist => translate('wishlist');
  String get profile => translate('profile');
  String get addToWishlist => translate('add_to_wishlist');
  String get removeFromWishlist => translate('remove_from_wishlist');
  String get createOrder => translate('create_order');
  String get orderDescriptionLabel => translate('order_description_label');
  String get orderDescriptionHint => translate('order_description_hint');
  String get orderDescriptionRequired => translate('order_description_required');
  String get deadline => translate('deadline');
  String get urgency => translate('urgency');
  String get urgencyLow => translate('urgency_low');
  String get urgencyMedium => translate('urgency_medium');
  String get urgencyHigh => translate('urgency_high');
  String get sendOrder => translate('send_order');
  String get orderSentSuccess => translate('order_sent_success');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get themeLight => translate('theme_light');
  String get themeDark => translate('theme_dark');
  String get themeAuto => translate('theme_auto');
  String get language => translate('language');
  String get save => translate('save');
  String get cancel => translate('cancel');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt', 'en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}