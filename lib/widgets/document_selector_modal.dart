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

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey3,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            themeProvider.translate('select_document'),
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 17,
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(12),
        onPressed: () => onDocumentSelected(title),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey2,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}