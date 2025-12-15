import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'home_tab.dart';
import 'search_page.dart';
import 'jogos_page.dart';
import 'jogo_detalhes_page.dart';
import 'configuracoes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return PopScope(
          canPop: appState.historicoPaginas.isEmpty,
          onPopInvoked: (didPop) {
            if (!didPop && appState.historicoPaginas.isNotEmpty) {
              appState.voltarPagina();
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: _buildAppBar(context, appState),
            body: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: _buildPage(appState.paginaAtual, appState),
            ),
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
        title = 'Destaques';
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
      case 'jogo-detalhes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        );
        title = 'Detalhes';
        break;
None
    }

    return AppBar(
      leading: leading,
      title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      actions: actions,
      centerTitle: false,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPage(String pagina, AppState appState) {
    switch (pagina) {
      case 'home':
        return const HomeTab(key: ValueKey('home'));
      case 'search':
        return const SearchPage(key: ValueKey('search'));
      case 'jogos':
        return const JogosPage(key: ValueKey('jogos'));
      case 'jogo-detalhes':
        return JogoDetalhesPage(key: const ValueKey('jogo-detalhes'), jogoId: appState.jogoDetalhesId);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(AppState appState) {
    if (['jogo-detalhes'].contains(appState.paginaAtual)) {
      return const SizedBox.shrink();
    }

    int currentIndex = ['home', 'search', 'jogos'].indexOf(appState.tabAtual);
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                appState.mudarTab(['home', 'search', 'jogos'][index]);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Symbols.home_rounded),
                  selectedIcon: Icon(Symbols.home_rounded, fill: 1),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Symbols.search_rounded),
                  selectedIcon: Icon(Symbols.search_rounded, fill: 1),
                  label: 'Pesquisar',
                ),
                NavigationDestination(
                  icon: Icon(Symbols.sports_soccer_rounded),
                  selectedIcon: Icon(Symbols.sports_soccer_rounded, fill: 1),
                  label: 'Jogos',
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
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            alignment: Alignment.bottomLeft,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Football Live',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Acompanhe seu futebol favorito',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
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
                      MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
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

// Transição FadeThrough nativa do Material Design
class FadeThroughTransition extends StatelessWidget {
  const FadeThroughTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (context, animation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      reverseBuilder: (context, animation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

class PageTransitionSwitcher extends StatelessWidget {
  const PageTransitionSwitcher({
    super.key,
    required this.child,
    required this.duration,
    required this.transitionBuilder,
  });

  final Widget child;
  final Duration duration;
  final Widget Function(Widget, Animation<double>, Animation<double>) transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return transitionBuilder(child, animation, const AlwaysStoppedAnimation(0));
      },
      child: child,
    );
  }
}