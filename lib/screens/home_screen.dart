import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/settings_modal.dart';

class HomeScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const HomeScreen({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
  }) : super(key: key);

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(
        themeProvider: themeProvider,
        languageProvider: languageProvider,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    languageProvider.translate('home'),
                    style: theme.textTheme.displayLarge,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettingsModal(context),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/settings.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                child: Column(
                  children: [
                    _InfoCard(
                      title: languageProvider.translate('welcome'),
                      description: languageProvider.translate('welcomeDesc'),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: languageProvider.translate('recent'),
                      description: languageProvider.translate('recentDesc'),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: languageProvider.translate('favorites'),
                      description: languageProvider.translate('favoritesDesc'),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final ThemeData theme;

  const _InfoCard({
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}