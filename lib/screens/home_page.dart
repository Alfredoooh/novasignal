import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_state.dart';
import 'home_tab.dart';
import 'search_page.dart';
import 'jogos_page.dart';
import 'opcoes_page.dart';
import 'comunidade_page.dart';
import 'jogo_detalhes_page.dart';
import 'configuracoes_page.dart';
import 'cupon_page.dart';

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

  void _navigateAndCloseDrawer(VoidCallback action) {
    _animationController.reverse().then((_) {
      if (mounted) {
        action();
      }
    });
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
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final canSwipeDrawer = appState.tabAtual == 'home';

          return Material(
            color: brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                // Drawer background
                Container(
                  color: brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
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
                            icon: Ionicons.logo_whatsapp,
                            title: 'WhatsApp',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                _launchWhatsApp();
                              }
                            },
                          ),
                          _buildDrawerItem(
                            icon: Ionicons.mail_outline,
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
                // Main content
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
                                color: brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
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
                        // Overlay escuro quando drawer está aberto
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
          _AnimatedSearchButton(
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
          ),
          const SizedBox(width: 8),
          _AnimatedUserButton(
            onPressed: () {
              // Funcionalidade futura
            },
          ),
          const SizedBox(width: 12),
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
      color: Theme.of(context).brightness == Brightness.light 
          ? Colors.white 
          : Theme.of(context).colorScheme.surface,
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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AnimatedNavItem(
                    icon: Symbols.home_rounded,
                    label: 'Populaire',
                    isSelected: currentIndex == 0,
                    onTap: () => appState.mudarTab('home'),
                  ),
                  _AnimatedNavItem(
                    icon: Symbols.star_rounded,
                    label: 'Favoris',
                    isSelected: currentIndex == 1,
                    onTap: () => appState.mudarTab('jogos'),
                  ),
                  // Botão central do cupom
                  _CentralCouponButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CuponPage(),
                        ),
                      );
                    },
                  ),
                  _AnimatedNavItem(
                    icon: Symbols.schedule_rounded,
                    label: 'Historique',
                    isSelected: currentIndex == 2,
                    onTap: () => appState.mudarTab('opcoes'),
                  ),
                  _AnimatedNavItem(
                    icon: Symbols.grid_view_rounded,
                    label: 'Menu',
                    isSelected: currentIndex == 3,
                    onTap: () => appState.mudarTab('comunidade'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== BOTÃO CENTRAL DO CUPOM ====================
class _CentralCouponButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CentralCouponButton({required this.onPressed});

  @override
  State<_CentralCouponButton> createState() => _CentralCouponButtonState();
}

class _CentralCouponButtonState extends State<_CentralCouponButton>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
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
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Ionicons.ticket,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED NAV ITEM ====================
class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
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
    final brightness = Theme.of(context).brightness;
    
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
                Icon(
                  widget.icon,
                  size: 26,
                  fill: widget.isSelected ? 1 : 0,
                  color: widget.isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : (brightness == Brightness.light 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: widget.isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : (brightness == Brightness.light 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400),
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

// ==================== ANIMATED MENU BUTTON ====================
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
          Ionicons.menu_outline,
          size: 24,
        ),
        iconSize: 24,
        onPressed: _handleTap,
      ),
    );
  }
}

// ==================== ANIMATED SEARCH BUTTON ====================
class _AnimatedSearchButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedSearchButton({required this.onPressed});

  @override
  State<_AnimatedSearchButton> createState() => _AnimatedSearchButtonState();
}

class _AnimatedSearchButtonState extends State<_AnimatedSearchButton>
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
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: const Center(
            child: Icon(
              Ionicons.search,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED USER BUTTON ====================
class _AnimatedUserButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedUserButton({required this.onPressed});

  @override
  State<_AnimatedUserButton> createState() => _AnimatedUserButtonState();
}

class _AnimatedUserButtonState extends State<_AnimatedUserButton>
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Center(
            child: Icon(
              Ionicons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}