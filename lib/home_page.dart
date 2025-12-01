// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'tabs/chat_tab.dart';
import 'tabs/preview_tab.dart';
import 'screens/language_screen.dart';
import 'screens/personalization_screen.dart';

class DocuGenHomePage extends StatefulWidget {
  const DocuGenHomePage({Key? key}) : super(key: key);

  @override
  State<DocuGenHomePage> createState() => _DocuGenHomePageState();
}

class _DocuGenHomePageState extends State<DocuGenHomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedLanguage = 'Português';
  bool _isThemeExpanded = false;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsModal(),
    );
  }

  void _showLanguageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageScreen(
          selectedLanguage: _selectedLanguage,
          onLanguageSelected: (language) {
            setState(() {
              _selectedLanguage = language;
            });
          },
        ),
      ),
    );
  }

  void _showPersonalizationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
    );
  }

  Widget _buildSettingsModal() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Definições',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF343A40) : const Color(0xFFFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Ionicons.close),
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF495057),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildExpandableSettingItem(
                      icon: Ionicons.contrast_outline,
                      title: 'Tema',
                      subtitle: themeProvider.isDarkMode ? 'Escuro' : 'Claro',
                      isFirst: true,
                      isLast: false,
                      isExpanded: _isThemeExpanded,
                      onTap: () {
                        setModalState(() {
                          _isThemeExpanded = !_isThemeExpanded;
                        });
                      },
                      expandedContent: Column(
                        children: [
                          const Divider(height: 1, color: Color(0xFFE9ECEF)),
                          _buildThemeOption(
                            'Claro',
                            !themeProvider.isDarkMode,
                            () {
                              themeProvider.toggleTheme(false);
                            },
                            setModalState,
                          ),
                          const Divider(height: 1, color: Color(0xFFE9ECEF)),
                          _buildThemeOption(
                            'Escuro',
                            themeProvider.isDarkMode,
                            () {
                              themeProvider.toggleTheme(true);
                            },
                            setModalState,
                          ),
                        ],
                      ),
                      setModalState: setModalState,
                    ),
                    const SizedBox(height: 2),
                    _buildSettingItem(
                      icon: Ionicons.language_outline,
                      title: 'Linguagem',
                      subtitle: _selectedLanguage,
                      isFirst: false,
                      isLast: false,
                      onTap: () {
                        Navigator.pop(context);
                        _showLanguageScreen();
                      },
                    ),
                    const SizedBox(height: 2),
                    _buildSettingItem(
                      icon: Ionicons.color_palette_outline,
                      title: 'Personalização',
                      subtitle: 'Cores e aparência',
                      isFirst: false,
                      isLast: true,
                      onTap: () {
                        Navigator.pop(context);
                        _showPersonalizationScreen();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String title, bool isSelected, VoidCallback onTap, StateSetter setModalState) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
        ),
      ),
      trailing: Switch(
        value: isSelected,
        onChanged: (value) => onTap(),
        activeColor: const Color(0xFF212529),
      ),
      onTap: onTap,
    );
  }

  Widget _buildExpandableSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget expandedContent,
    required StateSetter setModalState,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            leading: Icon(
              icon,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              size: 26,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                letterSpacing: -0.3,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF868E96),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: isExpanded ? 0.5 : 0,
              child: Icon(
                Ionicons.chevron_down,
                color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFFADB5BD),
                size: 20,
              ),
            ),
            onTap: onTap,
          ),
          if (isExpanded) expandedContent,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
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
        leading: Icon(
          icon,
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            letterSpacing: -0.3,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF868E96),
              letterSpacing: -0.2,
            ),
          ),
        ),
        trailing: Icon(
          Ionicons.chevron_forward,
          color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFFADB5BD),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF212529) : const Color(0xFFF8F9FA),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                ChatTab(),
                PreviewTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Ionicons.cube_outline),
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF495057),
                  iconSize: 24,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: _selectedIndex == 0 
                            ? Alignment.centerLeft 
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: (MediaQuery.of(context).size.width - 136) / 2,
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabTapped(0),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedIndex == 0
                                          ? (themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529))
                                          : (themeProvider.isDarkMode ? Colors.white60 : const Color(0xFF868E96)),
                                    ),
                                    child: const Text('Chat'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onTabTapped(1),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedIndex == 1
                                          ? (themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529))
                                          : (themeProvider.isDarkMode ? Colors.white60 : const Color(0xFF868E96)),
                                    ),
                                    child: const Text('Preview'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF495057) : const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Ionicons.ellipsis_horizontal_circle_outline),
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF495057),
                  iconSize: 24,
                  onPressed: _showSettingsModal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}