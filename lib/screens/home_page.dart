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

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          key: _scaffoldKey,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, appState),
          body: _buildBody(appState),
          bottomNavigationBar: _buildBottomNav(appState),
          drawer: _buildDrawer(context, appState),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, AppState appState) {
    if (appState.paginaAtual == 'search') {
      return null;
    }

    String title = '';
    Widget? leading;
    List<Widget>? actions;

    switch (appState.paginaAtual) {
      case 'home':
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
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
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
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
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
        title = 'Atividades';
        break;
      case 'inbox':
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
        title = 'Caixa de Entrada';
        break;
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            leading: leading,
            title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            actions: actions,
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.65),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
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

  Widget _buildDrawer(BuildContext context, AppState appState) {
    return Drawer(
      child: Column(
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Football Live',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe seu futebol favorito',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Symbols.settings_rounded, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Configurações'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ConfiguracoesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Symbols.info_rounded, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Sobre'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'Football Live',
                      applicationVersion: '1.0.0',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}