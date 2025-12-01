import 'package:flutter/material.dart';  
import 'package:ionicons/ionicons.dart';  
import 'tabs/chat_tab.dart';  
import 'tabs/preview_tab.dart';  
  
class DocuGenHomePage extends StatefulWidget {  
  const DocuGenHomePage({Key? key}) : super(key: key);  
  
  @override  
  State<DocuGenHomePage> createState() => _DocuGenHomePageState();  
}  
  
class _DocuGenHomePageState extends State<DocuGenHomePage> with SingleTickerProviderStateMixin {  
  late PageController _pageController;  
  int _selectedIndex = 0;  
  bool _isDarkMode = false;  
  String _selectedLanguage = 'Português';  
  
  @override  
  void initState() {  
    super.initState();  
    _pageController = PageController();  
  }  
  
  @override  
  void dispose() {  
    _pageController.dispose();  
    super.dispose();  
  }  
  
  void _onPageChanged(int index) {  
    setState(() {  
      _selectedIndex = index;  
    });  
  }  
  
  void _onTabTapped(int index) {  
    _pageController.animateToPage(  
      index,  
      duration: const Duration(milliseconds: 400),  
      curve: Curves.easeInOutCubic,  
    );  
  }  
  
  void _showSettingsModal() {  
    showModalBottomSheet(  
      context: context,  
      isScrollControlled: true,  
      backgroundColor: Colors.transparent,  
      transitionAnimationController: AnimationController(  
        duration: const Duration(milliseconds: 500),  
        vsync: this,  
      ),  
      builder: (context) => _buildSettingsModal(),  
    );  
  }  
  
  void _showLanguageDialog() {  
    showDialog(  
      context: context,  
      builder: (context) => AlertDialog(  
        title: const Text('Selecionar Idioma'),  
        content: Column(  
          mainAxisSize: MainAxisSize.min,  
          children: [  
            _buildLanguageOption('Português'),  
            _buildLanguageOption('English'),  
            _buildLanguageOption('Español'),  
            _buildLanguageOption('Français'),  
          ],  
        ),  
        actions: [  
          TextButton(  
            onPressed: () => Navigator.pop(context),  
            child: const Text('Cancelar'),  
          ),  
        ],  
      ),  
    );  
  }  
  
  Widget _buildLanguageOption(String language) {  
    return ListTile(  
      title: Text(language),  
      trailing: _selectedLanguage == language  
          ? const Icon(Ionicons.checkmark_circle, color: Color(0xFF212529))  
          : null,  
      onTap: () {  
        setState(() {  
          _selectedLanguage = language;  
        });  
        Navigator.pop(context);  
      },  
    );  
  }  
  
  Widget _buildSettingsModal() {  
    return StatefulBuilder(  
      builder: (context, setModalState) {  
        return AnimatedContainer(  
          duration: const Duration(milliseconds: 500),  
          curve: Curves.easeOutCubic,  
          height: MediaQuery.of(context).size.height * 0.6,  
          decoration: const BoxDecoration(  
            color: Color(0xFFF8F9FA),  
            borderRadius: BorderRadius.only(  
              topLeft: Radius.circular(24),  
              topRight: Radius.circular(24),  
            ),  
          ),  
          child: Column(  
            children: [  
              // Handle bar  
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
  
              // Header  
              Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 24),  
                child: Row(  
                  children: [  
                    const Text(  
                      'Definições',  
                      style: TextStyle(  
                        fontSize: 28,  
                        fontWeight: FontWeight.bold,  
                        color: Color(0xFF212529),  
                      ),  
                    ),  
                    const Spacer(),  
                    Container(  
                      decoration: const BoxDecoration(  
                        color: Color(0xFFFFFFFF),  
                        shape: BoxShape.circle,  
                      ),  
                      child: IconButton(  
                        icon: const Icon(Ionicons.close),  
                        color: const Color(0xFF495057),  
                        onPressed: () => Navigator.pop(context),  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
  
              const SizedBox(height: 24),  
  
              // Content - Lista sem scroll  
              Padding(  
                padding: const EdgeInsets.symmetric(horizontal: 24),  
                child: Column(  
                  children: [  
                    _buildSettingItem(  
                      icon: Ionicons.contrast_outline,  
                      title: 'Tema',  
                      subtitle: _isDarkMode ? 'Escuro' : 'Claro',  
                      onTap: () {  
                        setModalState(() => _isDarkMode = !_isDarkMode);  
                        setState(() => _isDarkMode = !_isDarkMode);  
                      },  
                    ),  
  
                    _buildSettingItem(  
                      icon: Ionicons.language_outline,  
                      title: 'Linguagem',  
                      subtitle: _selectedLanguage,  
                      onTap: () {  
                        Navigator.pop(context);  
                        _showLanguageDialog();  
                      },  
                    ),  
  
                    _buildSettingItem(  
                      icon: Ionicons.color_palette_outline,  
                      title: 'Personalização',  
                      subtitle: 'Cores e aparência',  
                      onTap: () {},  
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
  
  Widget _buildSettingItem({  
    required IconData icon,  
    required String title,  
    required String subtitle,  
    required VoidCallback onTap,  
  }) {  
    return Container(  
      margin: const EdgeInsets.only(bottom: 12),  
      decoration: BoxDecoration(  
        color: Colors.white,  
        borderRadius: BorderRadius.circular(16),  
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
        leading: Container(  
          width: 56,  
          height: 56,  
          decoration: BoxDecoration(  
            color: const Color(0xFFF8F9FA),  
            borderRadius: BorderRadius.circular(14),  
          ),  
          child: Icon(  
            icon,  
            color: const Color(0xFF212529),  
            size: 26,  
          ),  
        ),  
        title: Text(  
          title,  
          style: const TextStyle(  
            fontSize: 17,  
            fontWeight: FontWeight.w600,  
            color: Color(0xFF212529),  
            letterSpacing: -0.3,  
          ),  
        ),  
        subtitle: Padding(  
          padding: const EdgeInsets.only(top: 4),  
          child: Text(  
            subtitle,  
            style: const TextStyle(  
              fontSize: 15,  
              color: Color(0xFF868E96),  
              letterSpacing: -0.2,  
            ),  
          ),  
        ),  
        trailing: const Icon(  
          Ionicons.chevron_forward,  
          color: Color(0xFFADB5BD),  
          size: 20,  
        ),  
        onTap: onTap,  
      ),  
    );  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: const Color(0xFFF8F9FA),  
      body: Column(  
        children: [  
          const SizedBox(height: 50),  
          Expanded(  
            child: PageView(  
              controller: _pageController,  
              onPageChanged: _onPageChanged,  
              physics: const BouncingScrollPhysics(),  
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
        decoration: const BoxDecoration(  
          color: Colors.white,  
        ),  
        child: SafeArea(  
          child: Row(  
            children: [  
              // Botão Esquerda (Redondo)  
              Container(  
                width: 48,  
                height: 48,  
                decoration: BoxDecoration(  
                  color: const Color(0xFFF1F3F5),  
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
                  color: const Color(0xFF495057),  
                  iconSize: 24,  
                  onPressed: () {},  
                ),  
              ),  
  
              const SizedBox(width: 16),  
  
              // Tabs (Chat e Preview)  
              Expanded(  
                child: Container(  
                  height: 48,  
                  decoration: BoxDecoration(  
                    color: const Color(0xFFF1F3F5),  
                    borderRadius: BorderRadius.circular(24),  
                  ),  
                  child: Row(  
                    children: [  
                      Expanded(  
                        child: GestureDetector(  
                          onTap: () => _onTabTapped(0),  
                          child: AnimatedContainer(  
                            duration: const Duration(milliseconds: 300),  
                            curve: Curves.easeInOut,  
                            margin: const EdgeInsets.all(4),  
                            decoration: BoxDecoration(  
                              color: _selectedIndex == 0  
                                  ? Colors.white  
                                  : Colors.transparent,  
                              borderRadius: BorderRadius.circular(20),  
                              boxShadow: _selectedIndex == 0  
                                  ? [  
                                      BoxShadow(  
                                        color: Colors.black.withOpacity(0.1),  
                                        blurRadius: 8,  
                                        offset: const Offset(0, 2),  
                                      ),  
                                    ]  
                                  : [],  
                            ),  
                            child: Center(  
                              child: Text(  
                                'Chat',  
                                style: TextStyle(  
                                  fontSize: 15,  
                                  fontWeight: FontWeight.w600,  
                                  color: _selectedIndex == 0  
                                      ? const Color(0xFF212529)  
                                      : const Color(0xFF868E96),  
                                ),  
                              ),  
                            ),  
                          ),  
                        ),  
                      ),  
                      Expanded(  
                        child: GestureDetector(  
                          onTap: () => _onTabTapped(1),  
                          child: AnimatedContainer(  
                            duration: const Duration(milliseconds: 300),  
                            curve: Curves.easeInOut,  
                            margin: const EdgeInsets.all(4),  
                            decoration: BoxDecoration(  
                              color: _selectedIndex == 1  
                                  ? Colors.white  
                                  : Colors.transparent,  
                              borderRadius: BorderRadius.circular(20),  
                              boxShadow: _selectedIndex == 1  
                                  ? [  
                                      BoxShadow(  
                                        color: Colors.black.withOpacity(0.1),  
                                        blurRadius: 8,  
                                        offset: const Offset(0, 2),  
                                      ),  
                                    ]  
                                  : [],  
                            ),  
                            child: Center(  
                              child: Text(  
                                'Preview',  
                                style: TextStyle(  
                                  fontSize: 15,  
                                  fontWeight: FontWeight.w600,  
                                  color: _selectedIndex == 1  
                                      ? const Color(0xFF212529)  
                                      : const Color(0xFF868E96),  
                                ),  
                              ),  
                            ),  
                          ),  
                        ),  
                      ),  
                    ],  
                  ),  
                ),  
              ),  
  
              const SizedBox(width: 16),  
  
              // Botão Direita (Redondo - Settings)  
              Container(  
                width: 48,  
                height: 48,  
                decoration: BoxDecoration(  
                  color: const Color(0xFFF1F3F5),  
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
                  icon: const Icon(Ionicons.pending_outline),  
                  color: const Color(0xFF495057),  
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