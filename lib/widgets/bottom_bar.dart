import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/language_provider.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final LanguageProvider languageProvider;
  final bool isDarkMode;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onScrollUp;
  final VoidCallback? onScrollDown;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.languageProvider,
    required this.isDarkMode,
    this.onSettingsTap,
    this.onScrollUp,
    this.onScrollDown,
  }) : super(key: key);

  bool _isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return width >= 900 || (width > height && width >= 768);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDesktop(context)) {
      return _buildSideBar(context);
    }
    return _buildBottomBar(context);
  }

  Widget _buildSideBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Botão Settings (circular, no topo)
          if (onSettingsTap != null)
            _SideBarCircularButton(
              child: SvgPicture.asset(
                'assets/icons/settings.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              onTap: onSettingsTap!,
              colorScheme: colorScheme,
              backgroundColor: colorScheme.primary,
            ),
          
          const SizedBox(height: 32),
          
          // Botão Home (circular)
          _SideBarCircularButton(
            child: SvgPicture.asset(
              'assets/icons/home.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                currentIndex == 0 ? colorScheme.primary : colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => onTabChanged(0),
            colorScheme: colorScheme,
            isActive: currentIndex == 0,
          ),
          
          const SizedBox(height: 16),
          
          // Botão Center/New (circular)
          _SideBarCircularButton(
            child: SvgPicture.asset(
              'assets/icons/plus.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onPrimary,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => onTabChanged(2),
            colorScheme: colorScheme,
            backgroundColor: colorScheme.primary,
          ),
          
          const SizedBox(height: 16),
          
          // Botão Sparkle (circular)
          _SideBarCircularButton(
            child: SvgPicture.asset(
              'assets/icons/sparkle.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                currentIndex == 1 ? colorScheme.primary : colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            onTap: () => onTabChanged(1),
            colorScheme: colorScheme,
            isActive: currentIndex == 1,
          ),
          
          const SizedBox(height: 40),
          
          // Divisor
          Container(
            height: 1,
            width: 48,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          
          const SizedBox(height: 24),
          
          // Botão Scroll Up
          if (onScrollUp != null)
            _ScrollButton(
              icon: Icons.keyboard_arrow_up,
              onTap: onScrollUp!,
              colorScheme: colorScheme,
            ),
          
          if (onScrollUp != null && onScrollDown != null)
            const SizedBox(height: 12),
          
          // Botão Scroll Down
          if (onScrollDown != null)
            _ScrollButton(
              icon: Icons.keyboard_arrow_down,
              onTap: onScrollDown!,
              colorScheme: colorScheme,
            ),
          
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 16,
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

// Botão circular para o sidebar desktop
class _SideBarCircularButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final Color? backgroundColor;
  final bool isActive;

  const _SideBarCircularButton({
    required this.child,
    required this.onTap,
    required this.colorScheme,
    this.backgroundColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? 
        (isActive 
            ? colorScheme.primary.withOpacity(0.08) 
            : Colors.transparent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: backgroundColor == null && !isActive
                ? Border.all(
                    color: colorScheme.secondary.withOpacity(0.2),
                    width: 1,
                  )
                : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// Botão de scroll (setas up/down)
class _ScrollButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ScrollButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: colorScheme.secondary,
          ),
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
                ? colorScheme.primary.withOpacity(0.08)
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
                color: Colors.black.withOpacity(0.15),
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
                  colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimary,
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