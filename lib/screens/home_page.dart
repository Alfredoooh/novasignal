import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'home_tab.dart';
import 'search_page.dart';
import 'jogos_page.dart';
import 'atividades_page.dart';
import 'inbox_page.dart';
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
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.7, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final canSwipeDrawer = appState.tabAtual == 'home';

          return Material(
            color: brightness == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surface,
            child: Stack(
              children: [
                // --- Drawer (custom) ---
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
                                      'Football Live',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Acompanhe seu futebol favorito',
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
                            icon: Symbols.info_rounded,
                            title: 'Sobre',
                            onTap: () async {
                              await _animationController.reverse();
                              if (mounted) {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Football Live',
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

                // --- Conteúdo principal com animação ---
                Transform.translate(
                  offset: Offset(_slideAnimation.value.dx * MediaQuery.of(context).size.width, 0),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
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

    final menuButton = IconButton(
      icon: const Icon(Symbols.menu_rounded),
      iconSize: 24,
      onPressed: _toggleDrawer,
    );

    switch (appState.paginaAtual) {
      case 'home':
        leading = menuButton;
        title = 'Football Live';
        actions = [
          IconButton(
            icon: const Icon(Symbols.search_rounded),
            iconSize: 24,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SearchPage(),
              ),
            ),
          ),
        ];
        break;
      case 'jogos':
        leading = menuButton;
        title = 'Jogos';
        break;
      case 'atividades':
        leading = menuButton;
        title = 'Atividades';
        break;
      case 'inbox':
        leading = menuButton;
        title = 'Caixa de Entrada';
        break;
      default:
        leading = menuButton;
        title = 'Football Live';
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
        final tabs = ['home', 'jogos', 'atividades', 'inbox'];
        if (index < tabs.length) {
          appState.mudarTab(tabs[index]);
        }
      },
      children: const [
        HomeTab(),
        JogosPage(),
        AtividadesPage(),
        InboxPage(),
      ],
    );
  }

  Widget _buildBottomNav(AppState appState) {
    int currentIndex = ['home', 'jogos', 'atividades', 'inbox'].indexOf(appState.tabAtual);
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
            color: Theme.of(context).colorScheme.surface.withOpacity(0.65),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 80,
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) {
                  final tabs = ['home', 'jogos', 'atividades', 'inbox'];
                  appState.mudarTab(tabs[index]);
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Symbols.home_rounded),
                    selectedIcon: Icon(Symbols.home_rounded, fill: 1),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.sports_soccer_rounded),
                    selectedIcon: Icon(Symbols.sports_soccer_rounded, fill: 1),
                    label: 'Jogos',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.notifications_rounded),
                    selectedIcon: Icon(Symbols.notifications_rounded, fill: 1),
                    label: 'Atividades',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.inbox_rounded),
                    selectedIcon: Icon(Symbols.inbox_rounded, fill: 1),
                    label: 'Inbox',
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