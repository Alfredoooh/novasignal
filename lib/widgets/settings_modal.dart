import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class SettingsModal extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const SettingsModal({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
  }) : super(key: key);

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool _notificationsEnabled = false;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = widget.themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.languageProvider.translate('settings'),
                      style: theme.textTheme.displayMedium,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 24),
                      color: colorScheme.secondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: widget.languageProvider.translate('appearance'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  label: widget.languageProvider.translate('theme'),
                  value: widget.languageProvider.translate(
                    widget.themeProvider.isDarkMode ? 'dark' : 'light',
                  ),
                  onTap: () {
                    widget.themeProvider.toggleTheme();
                  },
                  theme: theme,
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: widget.languageProvider.translate('language'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  label: widget.languageProvider.translate('language'),
                  value: widget.languageProvider.languageName,
                  onTap: () {
                    widget.languageProvider.toggleLanguage();
                  },
                  theme: theme,
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: widget.languageProvider.translate('notifications'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  label: widget.languageProvider.translate('notifications'),
                  trailing: _CustomToggle(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    colorScheme: colorScheme,
                  ),
                  theme: theme,
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: widget.languageProvider.translate('privacy'),
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _OptionTile(
                  label: widget.languageProvider.translate('analytics'),
                  trailing: _CustomToggle(
                    value: _analyticsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _analyticsEnabled = value;
                      });
                    },
                    colorScheme: colorScheme,
                  ),
                  theme: theme,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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

class _OptionTile extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _OptionTile({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
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
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme colorScheme;

  const _CustomToggle({
    required this.value,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? colorScheme.primary : colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}