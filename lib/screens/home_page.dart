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
import 'scanner_page.dart';
import 'acerca_page.dart';

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
        bool showBottomNav = !['liga-detalhes', 'jogo-detalhes', 'configuracoes', 'scanner', 'acerca'].contains(appState.paginaAtual);

        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildTopBar(context, appState),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation);
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _buildPage(appState.paginaAtual, appState),
          ),
          bottomNavigationBar: AnimatedSlide(
            offset: showBottomNav ? Offset.zero : const Offset(0, 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showBottomNav ? _buildBottomNav(appState) : const SizedBox(),
          ),
          drawer: _buildDrawer(context, appState),
        );
      },
    );
  }

  PreferredSizeWidget? _buildTopBar(BuildContext context, AppState appState) {
    Widget? leading;
    String title = '';
    List<Widget>? actions;

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
                firstDate: DateTime(2000),
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
        leading = IconButton(
          icon: const Icon(Symbols.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
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
        title = appState.jogoDetalhesTitulo;
        break;
      case 'configuracoes':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: appState.voltarPagina,
        );
        title = 'Configurações';
        break;
      case 'scanner':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: appState.voltarPagina,
        );
        title = 'Scanner';
        break;
      case 'acerca':
        leading = IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: appState.voltarPagina,
        );
        title = 'Acerca';
        break;
    }

    return AppBar(
      leading: leading,
      title: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      actions: actions,
      centerTitle: false,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
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
      case 'scanner':
        return const ScannerPage(key: ValueKey('scanner'));
      case 'acerca':
        return const AcercaPage(key: ValueKey('acerca'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomNav(AppState appState) {
    int currentIndex = ['jogos', 'pesquisar', 'ligas'].indexOf(appState.tabAtual);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        appState.mudarTab(['jogos', 'pesquisar', 'ligas'][index]);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Symbols.sports_soccer_rounded),
          label: 'Jogos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.search_rounded),
          label: 'Pesquisar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Symbols.emoji_events_rounded),
          label: 'Ligas',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildDrawer(BuildContext context, AppState appState) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Football Live', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                Text('Acompanhe seu futebol favorito', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Symbols.settings_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Configurações'),
            subtitle: const Text('Tema, idioma e preferências'),
            onTap: () {
              Navigator.pop(context);
              appState.navegarPara('configuracoes');
            },
          ),
          ListTile(
            leading: Icon(Symbols.qr_code_scanner_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Scanner'),
            subtitle: const Text('Escanear códigos QR'),
            onTap: () {
              Navigator.pop(context);
              appState.navegarPara('scanner');
            },
          ),
          ListTile(
            leading: Icon(Symbols.info_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Acerca'),
            subtitle: const Text('Informações do aplicativo'),
            onTap: () {
              Navigator.pop(context);
              appState.navegarPara('acerca');
            },
          ),
        ],
      ),
    );
  }
}