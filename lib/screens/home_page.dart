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
        return PopScope(
          canPop: appState.historicoPaginas.isEmpty,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && appState.historicoPaginas.isNotEmpty) {
              appState.voltarPagina();
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: _buildAppBar(context, appState),
            body: _buildBody(appState),
            bottomNavigationBar: _buildBottomNav(appState),
            drawer: _buildDrawer(context, appState),
          ),
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
      case 'jogo-detalhes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => appState.voltarPagina(),
        );
        title = 'Detalhes';
        break;
      case 'configuracoes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        );
        title = 'Configurações';
        break;
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            leading: leading,
            title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            actions: actions,
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppState appState) {
    // Para páginas especiais, usa navegação direta
    if (['jogo-detalhes', 'configuracoes'].contains(appState.paginaAtual)) {
      return _buildPage(appState.paginaAtual, appState);
    }

    // Para tabs principais, usa PageView com navegação nativa horizontal
    return PageView(
      controller: _pageController,
      physics: const PageScrollPhysics(), // Scroll nativo iOS/Android
      onPageChanged: (index) {
        appState.mudarTab(['home', 'jogos', 'atividades', 'inbox'][index]);
      },
      children: const [
        HomeTab(),
        JogosPage(),
        AtividadesPage(),
        InboxPage(),
      ],
    );
  }

  Widget _buildPage(String pagina, AppState appState) {
    switch (pagina) {
      case 'jogo-detalhes':
        return JogoDetalhesPage(jogoId: appState.jogoDetalhesId);
      case 'configuracoes':
        return const ConfiguracoesPage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(AppState appState) {
    if (['jogo-detalhes', 'configuracoes', 'search'].contains(appState.paginaAtual)) {
      return const SizedBox.shrink();
    }

    int currentIndex = ['home', 'jogos', 'atividades', 'inbox'].indexOf(appState.tabAtual);

    // Sincronizar PageView com NavigationBar
    if (_pageController.hasClients && _pageController.page?.round() != currentIndex) {
      _pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                appState.mudarTab(['home', 'jogos', 'atividades', 'inbox'][index]);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
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