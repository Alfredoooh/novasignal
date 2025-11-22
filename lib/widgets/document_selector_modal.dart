import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/theme_provider.dart';

class DocumentSelectorModal extends StatelessWidget {
  final Function(String) onDocumentSelected;

  const DocumentSelectorModal({
    Key? key,
    required this.onDocumentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Backdrop blur effect - empurra a tela anterior
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: CupertinoColors.black.withOpacity(0.3),
            ),
          ),
        ),
        // Modal com handle bar
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: screenHeight * 0.6,
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
                        themeProvider.translate('select_document'),
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha o tipo de conversa',
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
                            _buildDocumentTile(
                              context,
                              'Documento Geral',
                              'Use para conversas gerais',
                              CupertinoIcons.doc_text,
                              themeProvider,
                              const Color(0xFF0A84FF),
                            ),
                            _buildDocumentTile(
                              context,
                              'Documento Técnico',
                              'Para questões técnicas',
                              CupertinoIcons.gear_alt,
                              themeProvider,
                              const Color(0xFF5856D6),
                            ),
                            _buildDocumentTile(
                              context,
                              'Documento Criativo',
                              'Para ideias criativas',
                              CupertinoIcons.lightbulb,
                              themeProvider,
                              const Color(0xFFFF9500),
                            ),
                            _buildDocumentTile(
                              context,
                              'Documento Pessoal',
                              'Para uso pessoal',
                              CupertinoIcons.person,
                              themeProvider,
                              const Color(0xFF30D158),
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

  Widget _buildDocumentTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeProvider theme,
    Color iconColor,
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
        onPressed: () {
          // Animação de feedback
          onDocumentSelected(title);
        },
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
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