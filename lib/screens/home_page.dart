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
            extendBody: true,
            appBar: _buildAppBar(context, appState),
            body: _buildPage(appState.paginaAtual, appState),
            bottomNavigationBar: _buildBottomNav(appState),
            drawer: _buildDrawer(context, appState),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, AppState appState) {
    if (appState.paginaAtual == 'search') {
      return null; // SearchPage tem seu próprio AppBar
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
          onPressed: appState.voltarPagina,
        );
        title = 'Detalhes';
        break;
      case 'configuracoes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: appState.voltarPagina,
        );
        title = 'Configurações';
        break;
    }

    return AppBar(
      leading: leading,
      title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      actions: actions,
      centerTitle: false,
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
      case 'configuracoes':
        return const ConfiguracoesPage(key: ValueKey('configuracoes'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(AppState appState) {
    if (['jogo-detalhes', 'configuracoes'].contains(appState.paginaAtual)) {
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
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _buildNavItem(
                    icon: Symbols.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => appState.mudarTab('home'),
                  ),
                  _buildNavItem(
                    icon: Symbols.search_rounded,
                    label: 'Pesquisar',
                    isSelected: currentIndex == 1,
                    onTap: () => appState.mudarTab('search'),
                  ),
                  _buildNavItem(
                    icon: Symbols.sports_soccer_rounded,
                    label: 'Jogos',
                    isSelected: currentIndex == 2,
                    onTap: () => appState.mudarTab('jogos'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 160,
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
            padding: const EdgeInsets.all(20),
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
                    appState.navegarPara('configuracoes');
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