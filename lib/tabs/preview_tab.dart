// lib/tabs/preview_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Text(
              'Preview',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              ),
            ),
          ),
        ),
        // Content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Ionicons.document_text_outline,
                  size: 64,
                  color: themeProvider.isDarkMode 
                      ? Colors.grey.shade700 
                      : Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum documento',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? Colors.grey.shade600 
                        : Colors.grey.shade400,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gere um documento para visualizar',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? Colors.grey.shade600 
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}