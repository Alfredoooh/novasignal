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

  // Ao clicar na tab: usa jumpToPage para evitar animação de slide
  void _onTabTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  // Exibe modal de definições com animação de FADE (showGeneralDialog)
  void _showSettingsModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Definições',
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (context, animation, secondaryAnimation) {
        // o conteúdo real é construído no transitionBuilder para aplicar fade
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, _) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.transparent,
              child: Container(
                // Altura ≈ 60% da tela (igual pedido)
                height: MediaQuery.of(context).size.height * 0.60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  // mantêm esquema claro/branco do teu design, mas com cantos menos curvos
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12), // menos curvo
                    topRight: Radius.circular(12), // menos curvo
                  ),
                ),
                child: _buildSettingsModalContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Conteúdo do modal - itens estilizados conforme a imagem fornecida
  Widget _buildSettingsModalContent() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEE2E6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
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

              const SizedBox(height: 20),

              // Lista de 3 opções - estilizadas como na imagem (cards escuros com cantos arredondados)
              // Mantive o conteúdo sem alterar semanticamente (Tema, Atualizar, E-mail)
              Column(
                children: [
                  _buildDarkListItem(
                    icon: Ionicons.briefcase_outline,
                    title: 'Área de trabalho',
                    subtitle: 'Pessoal',
                    onTap: () {
                      // ação de exemplo: fechar modal
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDarkListItem(
                    icon: Ionicons.sparkles_outline,
                    title: 'Atualizar para Go',
                    subtitle: '',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDarkListItem(
                    icon: Ionicons.mail_outline,
                    title: 'E-mail',
                    subtitle: 'albertopucutaabrao@gmail.com',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Separador e as definições clássicas (Tema, Linguagem, Personalização)
              // Estes itens usam o ícone correcto para "Tema" => Ionicons.contrast
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Ionicons.contrast, // ícone correcto pedido
                      title: 'Tema',
                      subtitle: _isDarkMode ? 'Escuro' : 'Claro',
                      onTap: () {
                        setModalState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
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

  // Item claro (usado abaixo das opções escuras)
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

  // Item escuro (semelhante à imagem que enviaste)
  Widget _buildDarkListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF3B3B3B), // card escuro como na imagem
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2F2F2F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBFC6CC),
                  ),
                ),
              )
            : null,
        trailing: const SizedBox.shrink(), // sem chevron na imagem
        onTap: onTap,
      ),
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

  // Helper caso queiras empurrar novas rotas com fade (manter consistência)
  Route<T> _fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
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
              physics: const BouncingScrollPhysics(), // swipe continua habilitado
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
                              color: _selectedIndex == 0 ? Colors.white : Colors.transparent,
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
                              color: _selectedIndex == 1 ? Colors.white : Colors.transparent,
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

              // Botão Direita (Redondo - Settings) - ícone atualizado para "pending circle"
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
                  // ícone atualizado conforme pedido
                  icon: const Icon(Ionicons.time_outline),
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