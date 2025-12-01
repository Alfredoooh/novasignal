import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showSettingsModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => _buildIOSSettingsModal(),
    );
  }

  void _showLanguageDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Selecionar Idioma',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8E8E93),
          ),
        ),
        actions: [
          _buildLanguageAction('Português'),
          _buildLanguageAction('English'),
          _buildLanguageAction('Español'),
          _buildLanguageAction('Français'),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  Widget _buildLanguageAction(String language) {
    return CupertinoActionSheetAction(
      onPressed: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (_selectedLanguage == language) ...[
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.checkmark_alt,
              color: CupertinoColors.activeBlue,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIOSSettingsModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: Column(
        children: [
          // Handle bar (iOS style)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  'Definições',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                    letterSpacing: -0.41,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Color(0xFF636366),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de opções (iOS grouped style)
          Expanded(
            child: CupertinoScrollbar(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Grupo 1: Aparência
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildIOSSettingItem(
                          icon: CupertinoIcons.circle_lefthalf_fill,
                          title: 'Tema',
                          subtitle: _isDarkMode ? 'Escuro' : 'Claro',
                          onTap: () {
                            setState(() => _isDarkMode = !_isDarkMode);
                          },
                          isFirst: true,
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildIOSSettingItem(
                          icon: CupertinoIcons.globe,
                          title: 'Linguagem',
                          subtitle: _selectedLanguage,
                          onTap: () {
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 300), () {
                              _showLanguageDialog();
                            });
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grupo 2: Personalização
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildIOSSettingItem(
                      icon: CupertinoIcons.paintbrush_fill,
                      title: 'Personalização',
                      subtitle: 'Cores e aparência',
                      onTap: () {},
                      isFirst: true,
                      isLast: true,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grupo 3: Outras opções
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildIOSSettingItem(
                          icon: CupertinoIcons.bell_fill,
                          title: 'Notificações',
                          subtitle: 'Gerenciar alertas',
                          onTap: () {},
                          isFirst: true,
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildIOSSettingItem(
                          icon: CupertinoIcons.lock_fill,
                          title: 'Privacidade',
                          subtitle: 'Configurações de segurança',
                          onTap: () {},
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIOSSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(10) : Radius.zero,
            bottom: isLast ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                      letterSpacing: -0.41,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E8E93),
                      letterSpacing: -0.08,
                    ),
                  ),
                ],
              ),
            ),
            // Seta
            const Icon(
              CupertinoIcons.chevron_forward,
              color: Color(0xFFC7C7CC),
              size: 20,
            ),
          ],
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

              // Tabs (Chat e Preview) com animação de deslize
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Indicador deslizante
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: _selectedIndex == 0 ? 4 : null,
                        right: _selectedIndex == 1 ? 4 : null,
                        top: 4,
                        bottom: 4,
                        width: (MediaQuery.of(context).size.width - 136) / 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                      // Botões
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
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedIndex == 0
                                          ? const Color(0xFF212529)
                                          : const Color(0xFF868E96),
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
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedIndex == 1
                                          ? const Color(0xFF212529)
                                          : const Color(0xFF868E96),
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

              // Botão Direita (Redondo - Settings) - Ícone correto
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
                  icon: const Icon(Ionicons.ellipsis_horizontal_circle_outline),
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