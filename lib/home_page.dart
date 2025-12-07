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

class _DocuGenHomePageState extends State<DocuGenHomePage> {
  int _selectedIndex = 0;
  String _selectedLanguage = 'Português';
  String? _generatedHtmlContent;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDocumentGenerated(String htmlContent) {
    setState(() {
      _generatedHtmlContent = htmlContent;
      _selectedIndex = 1;
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _SettingsModal(
        selectedLanguage: _selectedLanguage,
        onLanguageChanged: (language) {
          setState(() {
            _selectedLanguage = language;
          });
        },
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _showLanguageScreen(String currentLanguage) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LanguageScreen(
          selectedLanguage: currentLanguage,
          onLanguageSelected: (language) {
            setState(() {
              _selectedLanguage = language;
            });
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  void _showPersonalizationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalizationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0A0E14) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            ChatTab(onDocumentGenerated: _onDocumentGenerated),
            PreviewTab(htmlContent: _generatedHtmlContent),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
          // <-- removida a boxShadow aqui para eliminar a "sombra no topo" do bottom bar
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFF1F3F5),
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
                    color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: _selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          width: (MediaQuery.of(context).size.width - 136) / 2,
                          height: 40,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
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
                  color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFF1F3F5),
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

class _SettingsModal extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const _SettingsModal({
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<_SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<_SettingsModal> with SingleTickerProviderStateMixin {
  bool _isThemeExpanded = false;
  late String _selectedLanguage;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _showLanguageScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LanguageScreen(
          selectedLanguage: _selectedLanguage,
          onLanguageSelected: (language) {
            setState(() {
              _selectedLanguage = language;
            });
            widget.onLanguageChanged(language);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  void _showPersonalizationScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PersonalizationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF0A0E14) : const Color(0xFFF8F9FA),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildExpandableSettingItem(
                      icon: Ionicons.contrast_outline,
                      title: 'Tema',
                      subtitle: themeProvider.isDarkMode ? 'Escuro' : 'Claro',
                      isFirst: true,
                      isLast: false,
                      themeProvider: themeProvider,
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
                      themeProvider: themeProvider,
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
                      themeProvider: themeProvider,
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

  Widget _buildExpandableSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required ThemeProvider themeProvider,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : const Radius.circular(2),
          bottom: isLast && !_isThemeExpanded ? const Radius.circular(12) : const Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(
              icon,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              size: 22,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF868E96),
                ),
              ),
            ),
            trailing: AnimatedRotation(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              turns: _isThemeExpanded ? 0.5 : 0,
              child: Icon(
                Ionicons.chevron_down,
                color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFFADB5BD),
                size: 18,
              ),
            ),
            onTap: () {
              setState(() {
                _isThemeExpanded = !_isThemeExpanded;
                if (_isThemeExpanded) {
                  _expandController.forward();
                } else {
                  _expandController.reverse();
                }
              });
            },
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFE9ECEF),
                ),
                _buildThemeOption('Claro', !themeProvider.isDarkMode, themeProvider),
                Divider(
                  height: 1,
                  color: themeProvider.isDarkMode ? const Color(0xFF2D333B) : const Color(0xFFE9ECEF),
                ),
                _buildThemeOption('Escuro', themeProvider.isDarkMode, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, bool isSelected, ThemeProvider themeProvider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Ionicons.checkmark_circle,
              color: Color(0xFF4CAF50),
              size: 22,
            )
          : null,
      onTap: () {
        if ((title == 'Escuro' && !themeProvider.isDarkMode) ||
            (title == 'Claro' && themeProvider.isDarkMode)) {
          themeProvider.toggleTheme();
          setState(() {});
        }
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : const Radius.circular(2),
          bottom: isLast ? const Radius.circular(12) : const Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF868E96),
            ),
          ),
        ),
        trailing: Icon(
          Ionicons.chevron_forward,
          color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFFADB5BD),
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}