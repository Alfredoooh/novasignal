import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/language_provider.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final LanguageProvider languageProvider;
  final bool isDarkMode;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.languageProvider,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TabButton(
              iconPath: 'assets/icons/home.svg',
              isActive: currentIndex == 0,
              onTap: () => onTabChanged(0),
              colorScheme: colorScheme,
            ),
            _CenterButton(
              label: languageProvider.translate('new'),
              onTap: () => onTabChanged(2),
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
            ),
            _TabButton(
              iconPath: 'assets/icons/sparkle.svg',
              isActive: currentIndex == 1,
              onTap: () => onTabChanged(1),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String iconPath;
  final bool isActive;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _TabButton({
    required this.iconPath,
    required this.isActive,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.secondary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? colorScheme.primary : colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDarkMode;

  const _CenterButton({
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/plus.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isDarkMode ? Colors.black : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}