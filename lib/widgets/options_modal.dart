import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';

class OptionsModal extends StatelessWidget {
  final VoidCallback onClose;

  const OptionsModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Backdrop blur effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: CupertinoColors.black.withOpacity(0.3),
            ),
          ),
        ),
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.55,
                  decoration: BoxDecoration(
                    color: themeProvider.navigationBarColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Opções',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerencie suas conversas',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildOptionTile(
                              'Nova Conversa',
                              'Iniciar uma nova sessão',
                              CupertinoIcons.chat_bubble_2,
                              themeProvider,
                              const Color(0xFF0A84FF),
                              () {
                                onClose();
                              },
                            ),
                            _buildOptionTile(
                              'Histórico',
                              'Ver conversas anteriores',
                              CupertinoIcons.clock,
                              themeProvider,
                              const Color(0xFF5856D6),
                              () {
                                onClose();
                              },
                            ),
                            _buildOptionTile(
                              'Favoritos',
                              'Mensagens salvas',
                              CupertinoIcons.star_fill,
                              themeProvider,
                              const Color(0xFFFF9500),
                              () {
                                onClose();
                              },
                            ),
                            _buildOptionTile(
                              'Compartilhar',
                              'Exportar conversa',
                              CupertinoIcons.share,
                              themeProvider,
                              const Color(0xFF30D158),
                              () {
                                onClose();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    String title,
    String subtitle,
    IconData icon,
    ThemeProvider theme,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(18),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
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
                      color: theme.textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}