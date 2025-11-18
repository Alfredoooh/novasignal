// screens/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header com arrow back
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/arrow_back_icon.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onBackground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Opções
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Tema
                  _SettingCard(
                    icon: 'assets/theme_icon.svg',
                    title: 'Tema',
                    subtitle: _getThemeModeName(themeProvider.themeMode),
                    onTap: () => _showThemeDialog(context),
                  ),
                  const SizedBox(height: 12),

                  // Idioma
                  _SettingCard(
                    icon: 'assets/language_icon.svg',
                    title: 'Idioma',
                    subtitle: _getLanguageName(localeProvider.locale),
                    onTap: () => _showLanguageDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      default:
        return 'Automático';
    }
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return 'Português';
    }
  }

  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar Tema',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              _ThemeOption(
                title: 'Claro',
                icon: 'assets/light_theme_icon.svg',
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              
              _ThemeOption(
                title: 'Escuro',
                icon: 'assets/dark_theme_icon.svg',
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              
              _ThemeOption(
                title: 'Automático',
                icon: 'assets/auto_theme_icon.svg',
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar Idioma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              _LanguageOption(
                title: 'Português',
                subtitle: 'Portuguese',
                isSelected: localeProvider.locale.languageCode == 'pt',
                onTap: () {
                  localeProvider.setLocale(const Locale('pt', 'PT'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              
              _LanguageOption(
                title: 'English',
                subtitle: 'English',
                isSelected: localeProvider.locale.languageCode == 'en',
                onTap: () {
                  localeProvider.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              
              _LanguageOption(
                title: 'Español',
                subtitle: 'Spanish',
                isSelected: localeProvider.locale.languageCode == 'es',
                onTap: () {
                  localeProvider.setLocale(const Locale('es', 'ES'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              
              _LanguageOption(
                title: 'Français',
                subtitle: 'French',
                isSelected: localeProvider.locale.languageCode == 'fr',
                onTap: () {
                  localeProvider.setLocale(const Locale('fr', 'FR'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card de configuração
class _SettingCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onBackground,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/arrow_right_icon.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Opção de tema
class _ThemeOption extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.onBackground,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

// Opção de idioma
class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}