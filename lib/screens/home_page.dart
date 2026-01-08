import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_state.dart';
import 'home_tab.dart';
import 'search_page.dart';
import 'jogos_page.dart';
import 'opcoes_page.dart';
import 'comunidade_page.dart';
import 'cupom_page.dart';
import 'jogo_detalhes_page.dart';
import 'configuracoes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.7, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      setState(() {
        _isDrawerOpen = status == AnimationStatus.completed;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _closeDrawer() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/258843902649');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendFeedback() async {
    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: 'support@elephantbetclub.com',
      query: 'subject=Feedback do App&body=Olá, gostaria de enviar um feedback sobre o app:',
    );
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final canSwipeDrawer = appState.tabAtual == 'home';

          return Material(
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Elephantbet Club',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Powered by Nexa Group',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          _buildDrawerItem(
                            icon: Symbols.settings_rounded,
                            title: 'Configurações',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ConfiguracoesPage(),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildDrawerItem(
                            icon: Symbols.logo_dev_rounded,
                            title: 'WhatsApp',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                _launchWhatsApp();
                              }
                            },
                          ),
                          _buildDrawerItem(
                            icon: Symbols.mail_outline_rounded,
                            title: 'Enviar Feedback',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                _sendFeedback();
                              }
                            },
                          ),
                          _buildDrawerItem(
                            icon: Symbols.info_rounded,
                            title: 'Sobre',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Elephantbet Club',
                                  applicationVersion: '1.0.0',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_slideAnimation.value.dx * MediaQuery.of(context).size.width, 0),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: _isDrawerOpen ? _closeDrawer : null,
                          onHorizontalDragUpdate: canSwipeDrawer ? (details) {
                            final width = MediaQuery.of(context).size.width;
                            final delta = details.delta.dx / width;
                            _animationController.value = (_animationController.value + delta).clamp(0.0, 1.0);
                          } : null,
                          onHorizontalDragEnd: canSwipeDrawer ? (details) {
                            final velocity = details.primaryVelocity ?? 0;
                            if (velocity > 700 || _animationController.value > 0.5) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          } : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_animationController.value * 16),
                            child: IgnorePointer(
                              ignoring: _isDrawerOpen,
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    if (appState.paginaAtual != 'search')
                                      _buildAppBar(context, appState),
                                    Expanded(child: _buildBody(appState)),
                                    _buildBottomNav(appState),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_animationController.value > 0)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _closeDrawer,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(_animationController.value * 16),
                                child: Container(
                                  color: Colors.black.withOpacity(_animationController.value * 0.5),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppState appState) {
    String title = '';
    Widget? leading;
    List<Widget>? actions;

    final menuButton = _AnimatedMenuButton(
      onPressed: _toggleDrawer,
      isOpen: _isDrawerOpen,
    );

    switch (appState.paginaAtual) {
      case 'home':
        leading = menuButton;
        title = 'Elephantbet Club';
        actions = [
          _AnimatedIconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SearchPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeScaleTransition(
                      animation: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            svgPath: 'assets/icons/search.svg',
          ),
          const SizedBox(width: 8),
          _AnimatedIconButton(
            onPressed: () {},
            svgPath: 'assets/icons/user.svg',
          ),
          const SizedBox(width: 16),
        ];
        break;
      case 'jogos':
        leading = menuButton;
        title = 'Jogos';
        break;
      case 'opcoes':
        leading = menuButton;
        title = 'Opções';
        break;
      case 'comunidade':
        leading = menuButton;
        title = 'Comunidade';
        break;
      default:
        leading = menuButton;
        title = 'Elephantbet Club';
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              if (leading != null) leading,
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppState appState) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        final tabs = ['home', 'jogos', 'opcoes', 'comunidade'];
        if (index < tabs.length) {
          appState.mudarTab(tabs[index]);
        }
      },
      children: const [
        HomeTab(),
        JogosPage(),
        OpcoesPage(),
        ComunidadePage(),
      ],
    );
  }

  Widget _buildBottomNav(AppState appState) {
    int currentIndex = ['home', 'jogos', 'opcoes', 'comunidade'].indexOf(appState.tabAtual);
    if (currentIndex == -1) currentIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page != null &&
          _pageController.page!.round() != currentIndex) {
        _pageController.jumpToPage(currentIndex);
      }
    });

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AnimatedNavItem(
                    svgPath: 'assets/icons/home.svg',
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => appState.mudarTab('home'),
                  ),
                  _AnimatedNavItem(
                    svgPath: 'assets/icons/soccer.svg',
                    label: 'Jogos',
                    isSelected: currentIndex == 1,
                    onTap: () => appState.mudarTab('jogos'),
                  ),
                  _AnimatedNavItem(
                    svgPath: 'assets/icons/category.svg',
                    label: 'Categorias',
                    isSelected: currentIndex == 2,
                    onTap: () => appState.mudarTab('opcoes'),
                  ),
                  _AnimatedNavItem(
                    svgPath: 'assets/icons/community.svg',
                    label: 'Comunidade',
                    isSelected: currentIndex == 3,
                    onTap: () => appState.mudarTab('comunidade'),
                  ),
                ],
              ),
            ),
          ),
        ),
        // FAB Cupom
        Positioned(
          right: 16,
          bottom: 80,
          child: _CupomFAB(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CupomPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// CONTINUAÇÃO DA HOME PAGE - WIDGETS

class _CupomFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _CupomFAB({required this.onPressed});

  @override
  State<_CupomFAB> createState() => _CupomFABState();
}

class _CupomFABState extends State<_CupomFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF007AFF),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Symbols.confirmation_number_rounded,
            color: Colors.white,
            size: 26,
            fill: 1,
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatefulWidget {
  final String svgPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.svgPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar qual ícone usar baseado no estado
    final iconPath = widget.isSelected 
        ? widget.svgPath.replaceAll('.svg', '_filled.svg')
        : widget.svgPath;
    
    return Expanded(
      child: GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 26,
                  height: 26,
                  colorFilter: ColorFilter.mode(
                    widget.isSelected 
                        ? const Color(0xFF007AFF)
                        : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected 
                        ? const Color(0xFF007AFF)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedMenuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isOpen;

  const _AnimatedMenuButton({
    required this.onPressed,
    required this.isOpen,
  });

  @override
  State<_AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<_AnimatedMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: const Icon(
          Symbols.menu_rounded,
          size: 24,
        ),
        iconSize: 24,
        padding: const EdgeInsets.all(16),
        onPressed: _handleTap,
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String svgPath;

  const _AnimatedIconButton({
    required this.onPressed,
    required this.svgPath,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFD5E1F5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              widget.svgPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF007AFF),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}