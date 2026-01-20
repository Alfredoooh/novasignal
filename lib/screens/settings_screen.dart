import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animations/animations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_strings.dart';
import '../assets/app_icons.dart';

const Color transparent = Color(0x00000000);
const Color primaryColor = Color(0xFF2C3E50);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final locale = LocaleProvider.of(context);
    final isDark = theme?.isDark ?? false;
    final currentLocale = locale?.locale ?? 'pt';

    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final appBarColor = primaryColor;
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    final dividerColor = isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0);

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: appBarColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.string(
                        AppIcons.arrowLeft,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppStrings.get('settings', currentLocale),
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: cardColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/account'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('account', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => theme?.toggleTheme(!isDark),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.dark_mode, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('dark_mode', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Container(
                                width: 50,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isDark ? primaryColor : const Color(0xFFCED0D4),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFFFFF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => _showLanguageDialog(context, currentLocale, locale, isDark),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.language, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.get('language', currentLocale),
                                      style: TextStyle(fontSize: 16, color: textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentLocale == 'pt' ? AppStrings.get('portuguese', currentLocale) : AppStrings.get('english', currentLocale),
                                      style: TextStyle(fontSize: 14, color: subtitleColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/security'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.lock, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('security', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(height: 1, color: dividerColor),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/help'),
                      child: Container(
                        color: cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.help, color: textColor, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  AppStrings.get('help', currentLocale),
                                  style: TextStyle(fontSize: 16, color: textColor),
                                ),
                              ),
                              Icon(Icons.chevron_right, color: subtitleColor, size: 20),
                            ],
                          ),
                        ),
                      ),
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

  void _showLanguageDialog(BuildContext context, String currentLocale, LocaleProvider? localeProvider, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.get('choose_language', currentLocale),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildLanguageOption(context, 'pt', AppStrings.get('portuguese', currentLocale), currentLocale == 'pt', localeProvider, isDark),
                Container(height: 1, color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                _buildLanguageOption(context, 'en', AppStrings.get('english', currentLocale), currentLocale == 'en', localeProvider, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String localeCode, String label, bool isSelected, LocaleProvider? localeProvider, bool isDark) {
    return GestureDetector(
      onTap: () {
        localeProvider?.changeLocale(localeCode);
        Navigator.of(context).pop();
      },
      child: Container(
        color: transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}