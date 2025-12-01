// lib/screens/language_screen.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class LanguageScreen extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LanguageScreen({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'name': 'Português', 'code': 'pt'},
    {'name': 'English', 'code': 'en'},
    {'name': 'Español', 'code': 'es'},
    {'name': 'Français', 'code': 'fr'},
    {'name': 'Deutsch', 'code': 'de'},
    {'name': 'Italiano', 'code': 'it'},
    {'name': '日本語', 'code': 'ja'},
    {'name': '中文', 'code': 'zh'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
  }

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
          'Linguagem',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isFirst = index == 0;
          final isLast = index == _languages.length - 1;
          
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: isFirst ? const Radius.circular(16) : const Radius.circular(2),
                    bottom: isLast ? const Radius.circular(16) : const Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Text(
                    language['name']!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      letterSpacing: -0.3,
                    ),
                  ),
                  trailing: _selectedLanguage == language['name']
                      ? Icon(
                          Ionicons.checkmark_circle,
                          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language['name']!;
                    });
                    widget.onLanguageSelected(language['name']!);
                    Navigator.pop(context);
                  },
                ),
              ),
              if (!isLast) const SizedBox(height: 2),
            ],
          );
        },
      ),
    );
  }
}