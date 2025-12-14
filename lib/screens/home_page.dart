import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'jogos_page.dart';
import 'pesquisar_page.dart';
import 'ligas_page.dart';
import 'liga_detalhes_page.dart';
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
            appBar: _buildTopBar(context, appState),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
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

  PreferredSizeWidget? _buildTopBar(BuildContext context, AppState appState) {
    Widget? leading;
    String title = '';
    List<Widget>? actions;
    bool showLeading = true;

    switch (appState.paginaAtual) {
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
      case 'pesquisar':
        showLeading = false;
        title = 'Pesquisar';
        break;
      case 'ligas':
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
        title = 'Ligas';
        break;
      case 'liga-detalhes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: appState.voltarPagina,
        );
        title = appState.ligaDetalhesTitulo;
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
      leading: showLeading ? leading : null,
      automaticallyImplyLeading: showLeading,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      actions: actions,
      centerTitle: false,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          height: 0.5,
        ),
      ),
    );
  }

  Widget _buildPage(String pagina, AppState appState) {
    switch (pagina) {
      case 'jogos':
        return const JogosPage(key: ValueKey('jogos'));
      case 'pesquisar':
        return const PesquisarPage(key: ValueKey('pesquisar'));
      case 'ligas':
        return const LigasPage(key: ValueKey('ligas'));
      case 'liga-detalhes':
        return LigaDetalhesPage(key: const ValueKey('liga-detalhes'), ligaId: appState.ligaDetalhesId);
      case 'jogo-detalhes':
        return JogoDetalhesPage(key: const ValueKey('jogo-detalhes'), jogoId: appState.jogoDetalhesId);
      case 'configuracoes':
        return const ConfiguracoesPage(key: ValueKey('configuracoes'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(AppState appState) {
    if (['liga-detalhes', 'jogo-detalhes', 'configuracoes'].contains(appState.paginaAtual)) {
      return const SizedBox.shrink();
    }

    int currentIndex = ['jogos', 'pesquisar', 'ligas'].indexOf(appState.tabAtual);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Symbols.sports_soccer_rounded,
                label: 'Jogos',
                isSelected: currentIndex == 0,
                onTap: () => appState.mudarTab('jogos'),
              ),
              _buildNavItem(
                icon: Symbols.search_rounded,
                label: 'Pesquisar',
                isSelected: currentIndex == 1,
                onTap: () => appState.mudarTab('pesquisar'),
              ),
              _buildNavItem(
                icon: Symbols.emoji_events_rounded,
                label: 'Ligas',
                isSelected: currentIndex == 2,
                onTap: () => appState.mudarTab('ligas'),
              ),
            ],
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
            title: const Text('Sobre o App'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Football Live',
                applicationVersion: '1.2.0',
                applicationIcon: const Icon(Symbols.sports_soccer_rounded, size: 48),
              );
            },
          ),
        ],
      ),
    );
  }
}