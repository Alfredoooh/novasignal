// home_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.65, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      setState(() {
        _isDrawerOpen = status == AnimationStatus.completed || _animationController.value > 0.0;
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
    if (_animationController.isCompleted || _animationController.value > 0.5) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _closeDrawerThen(VoidCallback action) {
    _animationController.reverse();
    Future.delayed(const Duration(milliseconds: 260), action);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Stack(
          children: [
            // --- Drawer (custom) ---
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
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
                          IconButton(
                            icon: const Icon(Symbols.chevron_left_rounded),
                            onPressed: _toggleDrawer,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _buildDrawerItem(
                        icon: Symbols.settings_rounded,
                        title: 'Configurações',
                        onTap: () {
                          _closeDrawerThen(() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ConfiguracoesPage(),
                              ),
                            );
                          });
                        },
                      ),
                      _buildDrawerItem(
                        icon: Symbols.info_rounded,
                        title: 'Sobre',
                        onTap: () {
                          _closeDrawerThen(() {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Football Live',
                              applicationVersion: '1.0.0',
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildDrawerItem(
                        icon: Symbols.home_rounded,
                        title: 'Home',
                        onTap: () {
                          _closeDrawerThen(() {
                            appState.mudarTab('home');
                          });
                        },
                      ),
                      _buildDrawerItem(
                        icon: Symbols.sports_soccer_rounded,
                        title: 'Jogos',
                        onTap: () {
                          _closeDrawerThen(() {
                            appState.mudarTab('jogos');
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Conteúdo principal com animação ---
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _isDrawerOpen ? _toggleDrawer : null,
              onHorizontalDragUpdate: (details) {
                final width = MediaQuery.of(context).size.width;
                final delta = details.delta.dx / width;
                _animationController.value += delta;
              },
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (_animationController.value >= 0.5 || v > 250) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              child: Transform.translate(
                offset: Offset(_slideAnimation.value.dx * MediaQuery.of(context).size.width, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_animationController.value * 20),
                    child: IgnorePointer(
                      ignoring: _isDrawerOpen,
                      child: Scaffold(
                        extendBody: true,
                        extendBodyBehindAppBar: true,
                        appBar: _buildAppBar(context, appState),
                        body: _buildBody(appState),
                        bottomNavigationBar: _buildBottomNav(appState),
                        drawer: null,
                        drawerEnableOpenDragGesture: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, AppState appState) {
    if (appState.paginaAtual == 'search') {
      return null;
    }

    String title = '';
    Widget? leading;
    List<Widget>? actions;

    final menuButton = IconButton(
      icon: Icon(_isDrawerOpen ? Symbols.chevron_left_rounded : Symbols.menu_rounded),
      onPressed: _toggleDrawer,
    );

    switch (appState.paginaAtual) {
      case 'home':
        leading = menuButton;
        title = 'Football Live';
        actions = [
          IconButton(
            icon: const Icon(Symbols.search_rounded),
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
        actions = [
          IconButton(
            icon: const Icon(Symbols.calendar_month_rounded),
            onPressed: () async {
              final data = await showDatePicker(
                context: context,
                initialDate: appState.dataSelecionada,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (data != null) {
                appState.setDataSelecionada(data);
              }
            },
          ),
        ];
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

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              leading: leading,
              title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              actions: actions,
              centerTitle: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppState appState) {
    return SafeArea(
      top: true,
      bottom: false,
      child: PageView(
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
      ),
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
    );
  }
}