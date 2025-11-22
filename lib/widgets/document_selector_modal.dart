import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
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

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: CupertinoColors.black.withOpacity(0.4),
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
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    themeProvider.translate('select_document'),
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildDocumentTile(
                          context,
                          'Documento Geral',
                          'Use para conversas gerais',
                          CupertinoIcons.doc_text,
                          themeProvider,
                        ),
                        _buildDocumentTile(
                          context,
                          'Documento Técnico',
                          'Para questões técnicas',
                          CupertinoIcons.gear_alt,
                          themeProvider,
                        ),
                        _buildDocumentTile(
                          context,
                          'Documento Criativo',
                          'Para ideias criativas',
                          CupertinoIcons.lightbulb,
                          themeProvider,
                        ),
                        _buildDocumentTile(
                          context,
                          'Documento Pessoal',
                          'Para uso pessoal',
                          CupertinoIcons.person,
                          themeProvider,
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
    );
  }

  Widget _buildDocumentTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    ThemeProvider theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => onDocumentSelected(title),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
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