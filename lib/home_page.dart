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
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoSave = true;

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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsModal(),
    );
  }

  Widget _buildSettingsModal() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
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
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212529),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
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
              
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Appearance Section
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF868E96),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingTile(
                      icon: Ionicons.moon_outline,
                      title: 'Dark Mode',
                      subtitle: 'Switch to dark theme',
                      trailing: _buildCustomSwitch(
                        value: _isDarkMode,
                        onChanged: (value) {
                          setModalState(() => _isDarkMode = value);
                          setState(() => _isDarkMode = value);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Notifications Section
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF868E96),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingTile(
                      icon: Ionicons.notifications_outline,
                      title: 'Push Notifications',
                      subtitle: 'Receive notifications',
                      trailing: _buildCustomSwitch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setModalState(() => _notificationsEnabled = value);
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingTile(
                      icon: Ionicons.volume_high_outline,
                      title: 'Sound',
                      subtitle: 'Enable notification sounds',
                      trailing: _buildCustomSwitch(
                        value: _soundEnabled,
                        onChanged: (value) {
                          setModalState(() => _soundEnabled = value);
                          setState(() => _soundEnabled = value);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // General Section
                    const Text(
                      'General',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF868E96),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingTile(
                      icon: Ionicons.save_outline,
                      title: 'Auto-save',
                      subtitle: 'Automatically save your work',
                      trailing: _buildCustomSwitch(
                        value: _autoSave,
                        onChanged: (value) {
                          setModalState(() => _autoSave = value);
                          setState(() => _autoSave = value);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingTile(
                      icon: Ionicons.language_outline,
                      title: 'Language',
                      subtitle: 'English',
                      trailing: const Icon(
                        Ionicons.chevron_forward,
                        color: Color(0xFFADB5BD),
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingTile(
                      icon: Ionicons.trash_outline,
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      trailing: const Icon(
                        Ionicons.chevron_forward,
                        color: Color(0xFFADB5BD),
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // About Section
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF868E96),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildSettingTile(
                      icon: Ionicons.information_circle_outline,
                      title: 'About App',
                      subtitle: 'Version 1.0.0',
                      trailing: const Icon(
                        Ionicons.chevron_forward,
                        color: Color(0xFFADB5BD),
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingTile(
                      icon: Ionicons.shield_checkmark_outline,
                      title: 'Privacy Policy',
                      subtitle: 'View our privacy policy',
                      trailing: const Icon(
                        Ionicons.chevron_forward,
                        color: Color(0xFFADB5BD),
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 8),
                    
                    _buildSettingTile(
                      icon: Ionicons.document_text_outline,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      trailing: const Icon(
                        Ionicons.chevron_forward,
                        color: Color(0xFFADB5BD),
                        size: 20,
                      ),
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF212529),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF868E96),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCustomSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? const Color(0xFF212529) : const Color(0xFFDEE2E6),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
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

              // Tabs (Chat e Preview) - Mais arredondados
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
                  icon: const Icon(Ionicons.settings_outline),
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