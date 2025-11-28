import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/theme_provider.dart';

class HomeDrawer extends StatelessWidget {
  final ThemeData theme;
  final ThemeProvider themeProvider;
  final VoidCallback onNavigateToFavorites;
  final VoidCallback onShowSettings;
  final String userName;
  final String userInitial;

  const HomeDrawer({
    Key? key,
    required this.theme,
    required this.themeProvider,
    required this.onNavigateToFavorites,
    required this.onShowSettings,
    this.userName = 'Usuário',
    this.userInitial = 'U',
  }) : super(key: key);

  static const Color _activeBlue = Color(0xFF1877F2);
  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF242526) : Colors.white;
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF050505);
    final secondaryColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF65676B);

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bgColor,
      child: Column(
        children: [
          // Cabeçalho com Avatar
          Container(
            height: 120,
            padding: const EdgeInsets.only(left: 16, top: 50, bottom: 16),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF3E4042) : const Color(0xFFDADADA),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _activeBlue,
                  child: Text(
                    userInitial.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ver perfil',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de itens
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  'assets/icons/heart.svg',
                  'Favoritos',
                  () {
                    // Fecha o drawer imediatamente
                    Navigator.of(context).pop();
                    // Pequeno delay para garantir que o drawer fechou
                    Future.delayed(const Duration(milliseconds: 250), () {
                      onNavigateToFavorites();
                    });
                  },
                  isDark,
                ),
                _buildDrawerItem(
                  context,
                  'assets/icons/settings.svg',
                  'Configurações',
                  () {
                    // Fecha o drawer imediatamente
                    Navigator.of(context).pop();
                    // Pequeno delay para garantir que o drawer fechou
                    Future.delayed(const Duration(milliseconds: 250), () {
                      onShowSettings();
                    });
                  },
                  isDark,
                ),
              ],
            ),
          ),

          // Versão do app no rodapé
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'V$_appVersion',
              style: TextStyle(
                fontSize: 13,
                color: secondaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String iconPath,
    String title,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFFA383E)
        : (isDark ? const Color(0xFFE4E6EB) : const Color(0xFF050505));

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFA383E).withOpacity(0.1)
                    : (isDark ? const Color(0xFF3A3B3C) : const Color(0xFFF0F2F5)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}