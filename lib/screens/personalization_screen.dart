// lib/screens/personalization_screen.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({Key? key}) : super(key: key);

  final List<Color> _availableColors = const [
    Color(0xFF212529),
    Color(0xFF0D6EFD),
    Color(0xFF198754),
    Color(0xFFDC3545),
    Color(0xFFFFC107),
    Color(0xFF6610F2),
    Color(0xFFD63384),
    Color(0xFF20C997),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Ionicons.chevron_back,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personalização',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Cor Primária',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  themeProvider.setPrimaryColor(color);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeProvider.primaryColor == color
                          ? (themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529))
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: themeProvider.primaryColor == color
                      ? const Icon(
                          Ionicons.checkmark,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Cor de Destaque',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  themeProvider.setAccentColor(color);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeProvider.accentColor == color
                          ? (themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529))
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: themeProvider.accentColor == color
                      ? const Icon(
                          Ionicons.checkmark,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pré-visualização',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Ionicons.color_palette,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cor Primária',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: themeProvider.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Destaque',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}