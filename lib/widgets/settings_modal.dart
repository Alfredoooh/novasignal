import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class SettingsModal extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const SettingsModal({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  'assets/icons/close.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    colorScheme.secondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildMainPage(context, theme, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPage(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          languageProvider.translate('settings'),
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: languageProvider.translate('appearance'),
          theme: theme,
        ),
        const SizedBox(height: 12),
        _OptionsList(
          options: [
            _OptionData(
              label: languageProvider.translate('theme'),
              value: languageProvider.translate(
                themeProvider.isDarkMode ? 'dark' : 'light',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _ThemePage(
                      themeProvider: themeProvider,
                      languageProvider: languageProvider,
                    ),
                  ),
                );
              },
            ),
            _OptionData(
              label: languageProvider.translate('language'),
              value: languageProvider.languageName,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _LanguagePage(
                      languageProvider: languageProvider,
                    ),
                  ),
                );
              },
            ),
          ],
          theme: theme,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LanguagePage extends StatelessWidget {
  final LanguageProvider languageProvider;

  const _LanguagePage({
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              colorScheme.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          languageProvider.translate('language'),
          style: theme.textTheme.displayMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _OptionsList(
          options: languages.map((lang) {
            final isSelected = languageProvider.currentLanguage == lang['code'];
            return _OptionData(
              label: lang['name']!,
              trailing: isSelected
                  ? SvgPicture.asset(
                      'assets/icons/check.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4CAF50),
                        BlendMode.srcIn,
                      ),
                    )
                  : const SizedBox.shrink(),
              onTap: () {
                // Implementar mudança de idioma
                Navigator.pop(context);
              },
            );
          }).toList(),
          theme: theme,
        ),
      ),
    );
  }
}

class _ThemePage extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const _ThemePage({
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    final themes = [
      {'code': 'light', 'name': languageProvider.translate('light')},
      {'code': 'dark', 'name': languageProvider.translate('dark')},
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              colorScheme.secondary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          languageProvider.translate('theme'),
          style: theme.textTheme.displayMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _OptionsList(
          options: themes.map((themeOption) {
            final isSelected = (themeOption['code'] == 'dark') == themeProvider.isDarkMode;
            return _OptionData(
              label: themeOption['name']!,
              trailing: isSelected
                  ? SvgPicture.asset(
                      'assets/icons/check.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4CAF50),
                        BlendMode.srcIn,
                      ),
                    )
                  : const SizedBox.shrink(),
              onTap: () {
                if (!isSelected) {
                  themeProvider.toggleTheme();
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
          theme: theme,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle({
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.secondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _OptionData {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  _OptionData({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });
}

class _OptionsList extends StatelessWidget {
  final List<_OptionData> options;
  final ThemeData theme;

  const _OptionsList({
    required this.options,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isFirst = index == 0;
          final isLast = index == options.length - 1;

          return _OptionTile(
            label: option.label,
            value: option.value,
            trailing: option.trailing,
            onTap: option.onTap,
            theme: theme,
            isFirst: isFirst,
            isLast: isLast,
            showDivider: !isLast,
          );
        }),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ThemeData theme;
  final bool isFirst;
  final bool isLast;
  final bool showDivider;

  const _OptionTile({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    required this.theme,
    required this.isFirst,
    required this.isLast,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.6),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
              Row(
                children: [
                  if (value != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  if (value == null && trailing == null)
                    SvgPicture.asset(
                      'assets/icons/chevron_right.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.secondary.withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                    ),
                  if (trailing != null && trailing is! SizedBox) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}