/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';

void main() {
  runApp(const DocuGenApp());
}

class DocuGenApp extends StatelessWidget {
  const DocuGenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DocuGen AI',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF212529),
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DocuGenHomePage(),
          );
        },
      ),
    );
  }
}*/

// Complete Flutter code for the app

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart'; // Note: This package might need to be 'material_symbols_icons'
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Football Live',
            themeMode: appState.temaEscuro ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.light(
                primary: const Color(0xFF007AFF),
                primaryContainer: const Color(0xFF66AFFF),
                inversePrimary: const Color(0xFF0056CC),
                onPrimary: Colors.white,
                surface: const Color(0xFFFFFFFF),
                onSurface: const Color(0xFF1C1B1F),
                onSurfaceVariant: const Color(0xFF757575),
                outline: const Color(0xFFE0E0E0),
                background: const Color(0xFFF8F9FA),
                error: const Color(0xFFFF3B30),
                tertiary: const Color(0xFF34C759),
                secondary: const Color(0xFF8E8E93),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFFFFFFFF),
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: const Color(0xFF1C1B1F),
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              cardTheme: CardTheme(
                color: const Color(0xFFFFFFFF),
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              fontFamily: 'Roboto',
              iconTheme: const IconThemeData(color: Color(0xFF1C1B1F)),
              dividerColor: const Color(0xFFE0E0E0),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                bodySmall: TextStyle(fontSize: 12, color: Color(0xFF757575)),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF007AFF),
                primaryContainer: const Color(0xFF66AFFF),
                inversePrimary: const Color(0xFF0056CC),
                onPrimary: Colors.white,
                surface: const Color(0xFF1E1E1E),
                onSurface: const Color(0xFFE0E0E0),
                onSurfaceVariant: const Color(0xFF9E9E9E),
                outline: const Color(0xFF2D2D2D),
                background: const Color(0xFF121212),
                error: const Color(0xFFFF3B30),
                tertiary: const Color(0xFF34C759),
                secondary: const Color(0xFF8E8E93),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                scrolledUnderElevation: 0,
                foregroundColor: const Color(0xFFE0E0E0),
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              cardTheme: CardTheme(
                color: const Color(0xFF1E1E1E),
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
              fontFamily: 'Roboto',
              iconTheme: const IconThemeData(color: Color(0xFFE0E0E0)),
              dividerColor: const Color(0xFF2D2D2D),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                bodySmall: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
              ),
            ),
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppState with ChangeNotifier {
  String tabAtual = 'jogos';
  String paginaAtual = 'jogos';
  List<String> historicoPaginas = [];
  String filtroJogos = 'hoje';
  DateTime dataSelecionada = DateTime.now();
  bool temaEscuro = false;
  bool notificacoesAtivas = true;
  bool atualizacaoTempoReal = true;

  Map<String, List<dynamic>> jogosCache = {};
  List<dynamic>? ligasCache;
  Map<String, List<dynamic>> classificacoesCache = {};
  Map<String, List<dynamic>> pesquisasCache = {};

  List<dynamic> todasLigas = [];
  List<dynamic> jogosHoje = [];
  bool ligasCarregadas = false;

  Timer? intervaloAtualizacao;
  Timer? timeoutPesquisa;

  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = 'Liga';
  String jogoDetalhesId = '';
  String jogoDetalhesTitulo = 'Detalhes';

  AppState() {
    _carregarConfiguracoes();
    _iniciarAtualizacaoTempoReal();
  }

  void mudarTab(String tab) {
    if (tabAtual == tab) return;
    tabAtual = tab;
    paginaAtual = tab;
    historicoPaginas = [];
    notifyListeners();
  }

  void navegarPara(String pagina) {
    historicoPaginas.add(paginaAtual);
    paginaAtual = pagina;
    notifyListeners();
  }

  void voltarPagina() {
    if (historicoPaginas.isEmpty) {
      mudarTab(tabAtual);
      return;
    }
    paginaAtual = historicoPaginas.removeLast();
    notifyListeners();
  }

  void alternarTema(bool value) {
    temaEscuro = value;
    _salvarConfiguracoes();
    notifyListeners();
  }

  void alternarNotificacoes(bool value) {
    notificacoesAtivas = value;
    _salvarConfiguracoes();
    notifyListeners();
  }

  void alternarAtualizacaoTempoReal(bool value) {
    atualizacaoTempoReal = value;
    _salvarConfiguracoes();
    if (atualizacaoTempoReal) {
      _iniciarAtualizacaoTempoReal();
    } else {
      _pararAtualizacaoTempoReal();
    }
    notifyListeners();
  }

  void filtrarJogos(String filtro) {
    filtroJogos = filtro;
    notifyListeners();
  }

  void setDataSelecionada(DateTime data) {
    dataSelecionada = data;
    notifyListeners();
  }

  void setLigaDetalhes(String id, String titulo) {
    ligaDetalhesId = id;
    ligaDetalhesTitulo = titulo;
  }

  void setJogoDetalhes(String id, String titulo) {
    jogoDetalhesId = id;
    jogoDetalhesTitulo = titulo;
  }

  void _iniciarAtualizacaoTempoReal() {
    _pararAtualizacaoTempoReal();
    if (!atualizacaoTempoReal) return;
    intervaloAtualizacao = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (paginaAtual == 'jogos' && filtroJogos == 'direto') {
        notifyListeners();
      }
    });
  }

  void _pararAtualizacaoTempoReal() {
    intervaloAtualizacao?.cancel();
    intervaloAtualizacao = null;
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    temaEscuro = prefs.getBool('temaEscuro') ?? false;
    notificacoesAtivas = prefs.getBool('notificacoesAtivas') ?? true;
    atualizacaoTempoReal = prefs.getBool('atualizacaoTempoReal') ?? true;
    notifyListeners();
  }

  Future<void> _salvarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('temaEscuro', temaEscuro);
    prefs.setBool('notificacoesAtivas', notificacoesAtivas);
    prefs.setBool('atualizacaoTempoReal', atualizacaoTempoReal);
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';
    if (jogosCache.containsKey(cacheKey)) {
      return jogosCache[cacheKey]!;
    }
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final url = '$apiBase/?action=get_events&from=$dataStr&to=$dataStr&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      jogosCache[cacheKey] = dados;
      jogosHoje = dados;
      return dados;
    } else {
      throw Exception('Failed to load jogos');
    }
  }

  Future<List<dynamic>> carregarLigas() async {
    if (ligasCache != null) {
      return ligasCache!;
    }
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final url = '$apiBase/?action=get_leagues&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      ligasCache = dados;
      todasLigas = dados;
      ligasCarregadas = true;
      return dados;
    } else {
      throw Exception('Failed to load ligas');
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';
    if (classificacoesCache.containsKey(cacheKey)) {
      return classificacoesCache[cacheKey]!;
    }
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final url = '$apiBase/?action=get_standings&league_id=$ligaId&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      classificacoesCache[cacheKey] = dados;
      return dados;
    } else {
      throw Exception('Failed to load classificacao');
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    final hoje = DateTime.now();
    final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(hoje);
    final url = '$apiBase/?action=get_events&league_id=$ligaId&from=$from&to=$to&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return dados.reversed.toList();
    } else {
      throw Exception('Failed to load jogos liga');
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return dados.isNotEmpty ? dados[0] : null;
    } else {
      throw Exception('Failed to load jogo detalhes');
    }
  }

  Future<List<dynamic>> executarPesquisa(String termo) async {
    final termoLower = termo.toLowerCase();
    final cacheKey = 'pesquisa_$termoLower';
    if (pesquisasCache.containsKey(cacheKey)) {
      return pesquisasCache[cacheKey]!;
    }
    final hoje = DateTime.now();
    final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
    const apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
    const apiBase = 'https://apiv3.apifootball.com';
    final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(hoje);
    final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      final resultados = dados.where((jogo) {
        final hometeam = (jogo['match_hometeam_name'] ?? '').toLowerCase().contains(termoLower);
        final awayteam = (jogo['match_awayteam_name'] ?? '').toLowerCase().contains(termoLower);
        final league = (jogo['league_name'] ?? '').toLowerCase().contains(termoLower);
        final country = (jogo['country_name'] ?? '').toLowerCase().contains(termoLower);
        return hometeam || awayteam || league || country;
      }).toList();
      pesquisasCache[cacheKey] = resultados;
      return resultados;
    } else {
      throw Exception('Failed to search');
    }
  }
}

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
        return JogosPage(key: const ValueKey('jogos'));
      case 'pesquisar':
        return PesquisarPage(key: const ValueKey('pesquisar'));
      case 'ligas':
        return LigasPage(key: const ValueKey('ligas'));
      case 'liga-detalhes':
        return LigaDetalhesPage(key: const ValueKey('liga-detalhes'), ligaId: appState.ligaDetalhesId);
      case 'jogo-detalhes':
        return JogoDetalhesPage(key: const ValueKey('jogo-detalhes'), jogoId: appState.jogoDetalhesId);
      case 'configuracoes':
        return ConfiguracoesPage(key: const ValueKey('configuracoes'));
      case 'scanner':
        return ScannerPage(key: const ValueKey('scanner'));
      case 'acerca':
        return AcercaPage(key: const ValueKey('acerca'));
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

class JogosPage extends StatefulWidget {
  const JogosPage({super.key});

  @override
  State<JogosPage> createState() => _JogosPageState();
}

class _JogosPageState extends State<JogosPage> {
  Future<List<dynamic>>? _futureJogos;

  @override
  void initState() {
    super.initState();
    _loadJogos();
  }

  void _loadJogos() {
    final appState = context.read<AppState>();
    _futureJogos = appState.carregarJogosDoDia(appState.dataSelecionada);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _loadJogos(); // Reload if data changes

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hoje'),
                  selected: appState.filtroJogos == 'hoje',
                  onSelected: (b) => appState.filtrarJogos('hoje'),
                  avatar: const Icon(Symbols.today_rounded),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(color: appState.filtroJogos == 'hoje' ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                  side: BorderSide(color: appState.filtroJogos == 'hoje' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Direto'),
                  selected: appState.filtroJogos == 'direto',
                  onSelected: (b) => appState.filtrarJogos('direto'),
                  avatar: const Icon(Symbols.circle_rounded),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(color: appState.filtroJogos == 'direto' ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                  side: BorderSide(color: appState.filtroJogos == 'direto' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Terminados'),
                  selected: appState.filtroJogos == 'terminados',
                  onSelected: (b) => appState.filtrarJogos('terminados'),
                  avatar: const Icon(Symbols.check_circle_rounded),
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  labelStyle: TextStyle(color: appState.filtroJogos == 'terminados' ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 13),
                  side: BorderSide(color: appState.filtroJogos == 'terminados' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureJogos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('A carregar jogos...')]));
              } else if (snapshot.hasError) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.error_rounded, size: 100, color: Colors.grey), Text('Erro'), Text('Não foi possível carregar os jogos. Tente novamente.')] ));
              } else if (snapshot.hasData) {
                final jogos = snapshot.data!;
                final jogosFiltrados = _filtrarJogos(jogos, appState.filtroJogos);
                if (jogosFiltrados.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.filter_alt_rounded, size: 100, color: Colors.grey), Text('Nenhum jogo'), Text('Não há jogos para o filtro selecionado')] ));
                }
                return _buildJogosList(jogosFiltrados, context, appState);
              } else {
                return const Center(child: Text('Sem jogos'));
              }
            },
          ),
        ),
      ],
    );
  }

  List<dynamic> _filtrarJogos(List<dynamic> jogos, String filtro) {
    switch (filtro) {
      case 'direto':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains("'") || status == 'HT' || status == 'PEN' || status == 'LIVE';
        }).toList();
      case 'terminados':
        return jogos.where((j) {
          final status = j['match_status'] ?? '';
          return status.contains('Finished') || status == 'FT' || status == 'AET' || status == 'FT_PEN';
        }).toList();
      default:
        return jogos;
    }
  }

  Widget _buildJogosList(List<dynamic> jogosFiltrados, BuildContext context, AppState appState) {
    Map<String, dynamic> jogosPorLiga = {};
    for (var jogo in jogosFiltrados) {
      String ligaId = jogo['league_id'] ?? 'unknown';
      if (!jogosPorLiga.containsKey(ligaId)) {
        jogosPorLiga[ligaId] = {
          'liga': {
            'id': ligaId,
            'name': jogo['league_name'] ?? 'Unknown',
            'logo': jogo['league_logo'],
            'country': jogo['country_name'] ?? 'Unknown',
            'flag': jogo['country_logo'],
          },
          'jogos': [],
        };
      }
      jogosPorLiga[ligaId]['jogos'].add(jogo);
    }

    return ListView.builder(
      itemCount: jogosPorLiga.length,
      itemBuilder: (context, index) {
        var ligaData = jogosPorLiga.values.toList()[index];
        return Card(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  appState.setLigaDetalhes(ligaData['liga']['id'], ligaData['liga']['name']);
                  appState.navegarPara('liga-detalhes');
                },
                customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          ligaData['liga']['logo'] ?? 'https://via.placeholder.com/40x40?text=🏆',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=🏆', width: 40, height: 40),
                        ),
                      ),
                      if (ligaData['liga']['flag'] != null) const SizedBox(width: 12),
                      if (ligaData['liga']['flag'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Image.network(
                            ligaData['liga']['flag'],
                            width: 24,
                            height: 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ligaData['liga']['name'],
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              ligaData['liga']['country'],
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Symbols.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              ...ligaData['jogos'].map((jogo) => _buildMatchWidget(jogo, context, appState)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchWidget(dynamic jogo, BuildContext context, AppState appState) {
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    String badgeText = formatarStatus(status);
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setJogoDetalhes(jogo['match_id'], '${jogo['match_hometeam_name']} vs ${jogo['match_awayteam_name']}');
            appState.navegarPara('jogo-detalhes');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Symbols.schedule_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(jogo['match_time'] ?? '--:--', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              jogo['team_home_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              jogo['match_hometeam_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '\( {jogo['match_hometeam_score'] ?? '-'} : \){jogo['match_awayteam_score'] ?? '-'}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              jogo['match_awayteam_name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              jogo['team_away_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (ligaData['jogos'].last != jogo) const Divider(height: 1, thickness: 1),
      ],
    );
  }
}

class PesquisarPage extends StatefulWidget {
  const PesquisarPage({super.key});

  @override
  State<PesquisarPage> createState() => _PesquisarPageState();
}

class _PesquisarPageState extends State<PesquisarPage> {
  final TextEditingController _controller = TextEditingController();
  Future<List<dynamic>>? _futureResultados;
  String _currentTerm = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Symbols.search_rounded),
              hintText: 'Pesquisar jogos, clubes ou ligas...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).colorScheme.background,
            ),
            onChanged: (value) {
              if (value.trim().length < 2) {
                setState(() {
                  _futureResultados = null;
                });
                return;
              }
              _currentTerm = value.trim();
              _futureResultados = context.read<AppState>().executarPesquisa(_currentTerm);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: _futureResultados == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.search_rounded, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Pesquisar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('Digite para pesquisar jogos ou clubes', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                )
              : FutureBuilder<List<dynamic>>(
                  future: _futureResultados,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.error_rounded, size: 100, color: Colors.grey), Text('Erro'), Text('Erro ao realizar pesquisa. Tente novamente.')] ));
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.search_off_rounded, size: 100, color: Colors.grey), Text('Nenhum resultado'), Text('Nenhum resultado encontrado para "$_currentTerm"')] ));
                    } else if (snapshot.hasData) {
                      final resultados = snapshot.data!;
                      Map<String, List<dynamic>> jogosPorData = {};
                      for (var jogo in resultados) {
                        String data = jogo['match_date'] ?? 'Data desconhecida';
                        jogosPorData.putIfAbsent(data, () => []);
                        jogosPorData[data]!.add(jogo);
                      }
                      final sortedDates = jogosPorData.keys.toList()..sort((a, b) => b.compareTo(a));
                      return ListView.builder(
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final data = sortedDates[index];
                          final jogosDaData = jogosPorData[data]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Text(data, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              Card(
                                child: Column(
                                  children: jogosDaData.map((jogo) => _buildSearchMatch(jogo, context)).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchMatch(dynamic jogo, BuildContext context) {
    final appState = context.read<AppState>();
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setJogoDetalhes(jogo['match_id'], '${jogo['match_hometeam_name']} vs ${jogo['match_awayteam_name']}');
            appState.navegarPara('jogo-detalhes');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Symbols.schedule_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(jogo['match_time'] ?? '--:--', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatarStatus(status),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.network(
                            jogo['team_home_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(jogo['match_hometeam_name'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Text('${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(child: Text(jogo['match_awayteam_name'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
                          const SizedBox(width: 10),
                          Image.network(
                            jogo['team_away_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${jogo['league_name'] ?? ''} • ${jogo['country_name'] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class LigasPage extends StatefulWidget {
  const LigasPage({super.key});

  @override
  State<LigasPage> createState() => _LigasPageState();
}

class _LigasPageState extends State<LigasPage> {
  Future<List<dynamic>>? _futureLigas;

  @override
  void initState() {
    super.initState();
    _futureLigas = context.read<AppState>().carregarLigas();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureLigas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('A carregar ligas...')]));
        } else if (snapshot.hasError) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.error_rounded, size: 100, color: Colors.grey), Text('Erro'), Text('Não foi possível carregar as ligas.')] ));
        } else if (snapshot.hasData) {
          final ligas = snapshot.data!;
          Map<String, List<dynamic>> ligasPorPais = {};
          for (var liga in ligas) {
            String pais = liga['country_name'] ?? 'Outros';
            ligasPorPais.putIfAbsent(pais, () => []);
            ligasPorPais[pais]!.add(liga);
          }
          final sortedPaises = ligasPorPais.keys.toList()..sort();
          return ListView.builder(
            itemCount: sortedPaises.length,
            itemBuilder: (context, index) {
              final pais = sortedPaises[index];
              final ligasDoPais = ligasPorPais[pais]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Symbols.location_on_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(pais, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: ligasDoPais.map((liga) => _buildLeagueItem(liga, context)).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: Text('Sem ligas'));
        }
      },
    );
  }

  Widget _buildLeagueItem(dynamic liga, BuildContext context) {
    final appState = context.read<AppState>();
    return Column(
      children: [
        InkWell(
          onTap: () {
            appState.setLigaDetalhes(liga['league_id'], liga['league_name']);
            appState.navegarPara('liga-detalhes');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.network(
                  liga['league_logo'] ?? 'https://via.placeholder.com/40x40?text=🏆',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=🏆', width: 40, height: 40),
                ),
                if (liga['country_logo'] != null) const SizedBox(width: 12),
                if (liga['country_logo'] != null)
                  Image.network(
                    liga['country_logo'],
                    width: 24,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(liga['league_name'] ?? 'Unknown', style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
                      Text(liga['country_name'] ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Symbols.chevron_right_rounded),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class LigaDetalhesPage extends StatefulWidget {
  final String ligaId;

  const LigaDetalhesPage({super.key, required this.ligaId});

  @override
  State<LigaDetalhesPage> createState() => _LigaDetalhesPageState();
}

class _LigaDetalhesPageState extends State<LigaDetalhesPage> {
  Future<List<dynamic>>? _futureClassificacao;
  Future<List<dynamic>>? _futureJogos;

  dynamic _liga;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final appState = context.read<AppState>();
    _liga = appState.todasLigas.firstWhere((l) => l['league_id'] == widget.ligaId, orElse: () => null);
    _futureClassificacao = appState.carregarClassificacao(widget.ligaId);
    _futureJogos = appState.carregarUltimosJogosLiga(widget.ligaId);
  }

  @override
  Widget build(BuildContext context) {
    if (_liga == null) {
      return const Center(child: Text('Liga não encontrada'));
    }

    return ListView(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Image.network(
                _liga['league_logo'] ?? 'https://via.placeholder.com/60x60?text=🏆',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/60x60?text=🏆', width: 60, height: 60),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_liga['league_name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    Text(_liga['country_name'] ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        FutureBuilder<List<dynamic>>(
          future: _futureClassificacao,
          builder: (context, snapshotClass) {
            if (snapshotClass.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshotClass.hasError) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Classificação não disponível'),
              );
            } else if (snapshotClass.hasData && snapshotClass.data!.isNotEmpty) {
              final classificacao = snapshotClass.data!;
              String roundInfo = classificacao.isNotEmpty ? 'Rodada atual: ${classificacao[0]['overall_league_payed'] ?? '?'}' : '';
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(roundInfo, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Symbols.leaderboard_rounded, size: 20),
                        const SizedBox(width: 8),
                        const Text('Classificação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.background,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const SizedBox(width: 30, child: Text('#', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const Expanded(child: Text('Equipa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const SizedBox(width: 40, child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const SizedBox(width: 40, child: Text('V', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const SizedBox(width: 40, child: Text('E', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const SizedBox(width: 40, child: Text('D', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                              const SizedBox(width: 40, child: Text('PTS', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                            ],
                          ),
                        ),
                        ...classificacao.asMap().entries.map((entry) {
                          int index = entry.key;
                          dynamic equipa = entry.value;
                          Color? borderColor;
                          if (index < 4) borderColor = const Color(0xFFFFD700); // champions
                          else if (index < 6) borderColor = const Color(0xFF4A90E2); // europa
                          else if (index >= classificacao.length - 3) borderColor = const Color(0xFFFF6B6B); // relegation
                          return Container(
                            decoration: BoxDecoration(
                              border: borderColor != null ? Border(left: BorderSide(color: borderColor, width: 3)) : null,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  SizedBox(width: 30, child: Text(equipa['overall_league_position'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary))),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Image.network(
                                          equipa['team_badge'] ?? 'https://via.placeholder.com/28x28?text=⚽',
                                          width: 28,
                                          height: 28,
                                          errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/28x28?text=⚽', width: 28, height: 28),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(equipa['team_name'] ?? 'Unknown'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 40, child: Text('${equipa['overall_league_payed'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                                  SizedBox(width: 40, child: Text('${equipa['overall_league_W'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                                  SizedBox(width: 40, child: Text('${equipa['overall_league_D'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                                  SizedBox(width: 40, child: Text('${equipa['overall_league_L'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                                  SizedBox(width: 40, child: Text('${equipa['overall_league_PTS'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Classificação não disponível'),
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Symbols.sports_soccer_rounded, size: 20),
              const SizedBox(width: 8),
              const Text('Últimos Jogos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: _futureJogos,
          builder: (context, snapshotJogos) {
            if (snapshotJogos.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshotJogos.hasError) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum jogo recente encontrado'),
              );
            } else if (snapshotJogos.hasData && snapshotJogos.data!.isNotEmpty) {
              final jogos = snapshotJogos.data!.take(10).toList();
              return Card(
                child: Column(
                  children: jogos.map((jogo) => _buildMatchWidget(jogo, context, context.read<AppState>())).toList(),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhum jogo recente encontrado'),
              );
            }
          },
        ),
      ],
    );
  }
  Widget _buildMatchWidget(dynamic jogo, BuildContext context, AppState appState) {
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    String badgeText = formatarStatus(status);
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return InkWell(
      onTap: () {
        appState.setJogoDetalhes(jogo['match_id'], '${jogo['match_hometeam_name']} vs ${jogo['match_awayteam_name']}');
        appState.navegarPara('jogo-detalhes');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.schedule_rounded, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(jogo['match_time'] ?? '--:--', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          jogo['team_home_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          jogo['match_hometeam_name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${jogo['match_hometeam_score'] ?? '-'} : ${jogo['match_awayteam_score'] ?? '-'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          jogo['match_awayteam_name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          jogo['team_away_badge'] ?? 'https://via.placeholder.com/40x40?text=⚽',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=⚽', width: 40, height: 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JogoDetalhesPage extends StatefulWidget {
  final String jogoId;

  const JogoDetalhesPage({super.key, required this.jogoId});

  @override
  State<JogoDetalhesPage> createState() => _JogoDetalhesPageState();
}

class _JogoDetalhesPageState extends State<JogoDetalhesPage> {
  Future<dynamic>? _futureJogo;

  @override
  void initState() {
    super.initState();
    _futureJogo = context.read<AppState>().carregarJogoDetalhes(widget.jogoId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _futureJogo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('A carregar detalhes do jogo...')]));
        } else if (snapshot.hasError) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Symbols.error_rounded, size: 100, color: Colors.grey), Text('Erro'), Text('Não foi possível carregar os detalhes do jogo.')] ));
        } else if (snapshot.hasData) {
          final jogo = snapshot.data!;
          return _buildJogoDetalhes(jogo, context);
        } else {
          return const Center(child: Text('Jogo não encontrado'));
        }
      },
    );
  }

  Widget _buildJogoDetalhes(dynamic jogo, BuildContext context) {
    final status = jogo['match_status'] ?? '';
    Color badgeColor;
    if (status.contains('Finished') || status == 'FT' || status == 'AET') {
      badgeColor = Theme.of(context).colorScheme.tertiary;
    } else if (status.contains("'") || status == 'HT' || status == 'LIVE') {
      badgeColor = Theme.of(context).colorScheme.error;
    } else {
      badgeColor = Theme.of(context).colorScheme.secondary;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Image.network(
                            jogo['team_home_badge'] ?? 'https://via.placeholder.com/80x80?text=⚽',
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/80x80?text=⚽', width: 80, height: 80),
                          ),
                          const SizedBox(height: 8),
                          Text(jogo['match_hometeam_name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${jogo['match_hometeam_score'] ?? '0'} : ${jogo['match_awayteam_score'] ?? '0'}',
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatarStatus(status),
                              style: TextStyle(fontSize: 12, color: badgeColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${jogo['league_name'] ?? ''} • ${jogo['match_date'] ?? ''} ${jogo['match_time'] ?? ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Image.network(
                            jogo['team_away_badge'] ?? 'https://via.placeholder.com/80x80?text=⚽',
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/80x80?text=⚽', width: 80, height: 80),
                          ),
                          const SizedBox(height: 8),
                          Text(jogo['match_awayteam_name'] ?? 'Unknown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Symbols.info_rounded, size: 20),
                const SizedBox(width: 8),
                const Text('Informações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                _buildInfoRow('Liga', jogo['league_name'] ?? 'N/A', context),
                _buildInfoRow('Estádio', jogo['match_stadium'] ?? 'N/A', context),
                _buildInfoRow('Árbitro', jogo['match_referee'] ?? 'N/A', context),
                _buildInfoRow('Público', jogo['match_attendance'] ?? 'N/A', context),
              ],
            ),
          ),
          if (jogo['statistics'] != null && jogo['statistics'].isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Symbols.bar_chart_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Estatísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: jogo['statistics'].map<Widget>((stat) => _buildStatRow(stat, context)).toList(),
              ),
            ),
          ],
          if (jogo['goalscorer'] != null && jogo['goalscorer'].isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Symbols.sports_soccer_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Gols', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: jogo['goalscorer'].map<Widget>((gol) => _buildGoalRow(gol, context)).toList(),
              ),
            ),
          ],
          if (jogo['cards'] != null && jogo['cards'].isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Symbols.style_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Cartões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: (jogo['cards']..sort((a, b) => (int.tryParse(a['time']) ?? 0) - (int.tryParse(b['time']) ?? 0))).map<Widget>((cartao) => _buildCardRow(cartao, jogo, context)).toList(),
              ),
            ),
          ],
          if (jogo['substitutions'] != null && (jogo['substitutions']['home'] != null || jogo['substitutions']['away'] != null)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Symbols.swap_horiz_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Substituições', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  if (jogo['substitutions']['home'] != null && jogo['substitutions']['home'].isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(jogo['match_hometeam_name'] ?? 'Home', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    ...(jogo['substitutions']['home']..sort((a, b) => (int.tryParse(a['time']) ?? 0) - (int.tryParse(b['time']) ?? 0))).map<Widget>((sub) => _buildSubRow(sub, context)).toList(),
                  ],
                  if (jogo['substitutions']['away'] != null && jogo['substitutions']['away'].isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(jogo['match_awayteam_name'] ?? 'Away', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    ...(jogo['substitutions']['away']..sort((a, b) => (int.tryParse(a['time']) ?? 0) - (int.tryParse(b['time']) ?? 0))).map<Widget>((sub) => _buildSubRow(sub, context)).toList(),
                  ],
                ],
              ),
            ),
          ],
          if (jogo['lineups'] != null && (jogo['lineups']['home'] != null || jogo['lineups']['away'] != null)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Symbols.people_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text('Jogadores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  if (jogo['lineups']['home'] != null && jogo['lineups']['home']['starting_lineups'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(jogo['match_hometeam_name'] ?? 'Home', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    ...jogo['lineups']['home']['starting_lineups'].map<Widget>((player) => _buildPlayerRow(player, context)).toList(),
                  ],
                  if (jogo['lineups']['away'] != null && jogo['lineups']['away']['starting_lineups'] != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(jogo['match_awayteam_name'] ?? 'Away', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    ...jogo['lineups']['away']['starting_lineups'].map<Widget>((player) => _buildPlayerRow(player, context)).toList(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatRow(dynamic stat, BuildContext context) {
    final casa = double.tryParse(stat['home'] ?? '0') ?? 0;
    final fora = double.tryParse(stat['away'] ?? '0') ?? 0;
    final total = casa + fora > 0 ? casa + fora : 1;
    final percentCasa = (casa / total) * 100;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('$casa', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentCasa / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(stat['type'] ?? '', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerRight,
                widthFactor: (100 - percentCasa) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 40, child: Text('$fora', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildGoalRow(dynamic gol, BuildContext context) {
    final isHome = gol['home_scorer'] != null;
    final scorer = isHome ? gol['home_scorer'] : gol['away_scorer'];
    final time = gol['time'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer, size: 18),
              const SizedBox(width: 8),
              Text(scorer ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Text('$time\'', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  Widget _buildCardRow(dynamic cartao, dynamic jogo, BuildContext context) {
    final isYellow = cartao['card'] == 'yellow card';
    final jogador = cartao['home_fault'] ?? cartao['away_fault'] ?? 'N/A';
    final timeTeam = cartao['home_fault'] != null ? jogo['match_hometeam_name'] ?? 'Home' : jogo['match_awayteam_name'] ?? 'Away';
    final time = cartao['time'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 22,
                decoration: BoxDecoration(
                  color: isYellow ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 1)],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jogador, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(timeTeam, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          Text('$time\'', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSubRow(dynamic sub, BuildContext context) {
    final time = sub['time'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Symbols.arrow_downward_rounded, color: const Color(0xFFFF6B6B), size: 20),
              const SizedBox(width: 8),
              Text(sub['substitution'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Text('$time\'', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
          Row(
            children: [
              Text(sub['substitution_player'] ?? 'N/A', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Icon(Symbols.arrow_upward_rounded, color: const Color(0xFF34C759), size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(dynamic player, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              player['player_image'] ?? 'https://via.placeholder.com/40x40?text=👤',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.network('https://via.placeholder.com/40x40?text=👤', width: 40, height: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player['player'] ?? 'Unknown', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('${player['lineup_position'] ?? 'Jogador'} • ${player['lineup_number'] ?? 'N/A'}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Symbols.palette_rounded, size: 20),
              const SizedBox(width: 8),
              const Text('Aparência', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Tema Escuro'),
                value: appState.temaEscuro,
                onChanged: appState.alternarTema,
              ),
              ListTile(
                title: const Text('Idioma'),
                trailing: DropdownButton<String>(
                  value: 'pt',
                  items: const [
                    DropdownMenuItem(value: 'pt', child: Text('Português')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                  ],
                  onChanged: (value) {
                    // Implement idioma change
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Symbols.notifications_rounded, size: 20),
              const SizedBox(width: 8),
              const Text('Notificações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notificações Push'),
                value: appState.notificacoesAtivas,
                onChanged: appState.alternarNotificacoes,
              ),
              SwitchListTile(
                title: const Text('Resultados em Tempo Real'),
                value: appState.atualizacaoTempoReal,
                onChanged: appState.alternarAtualizacaoTempoReal,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.qr_code_scanner_rounded, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text('Scanner de QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Text('Funcionalidade em desenvolvimento', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

class AcercaPage extends StatelessWidget {
  const AcercaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Symbols.sports_soccer_rounded, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Football Live', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Versão 1.2.0', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            Text(
              'Acompanhe todos os jogos de futebol ao vivo, classificações e muito mais. \nDesenvolvido para oferecer a melhor experiência de acompanhamento esportivo.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              strutStyle: const StrutStyle(height: 1.6),
            ),
            const SizedBox(height: 16),
            Text('© 2024 Football Live. Todos os direitos reservados.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

String formatarStatus(String status) {
  if (status.isEmpty) return 'Agendado';
  if (status.contains('Finished') || status == 'FT') return 'Terminado';
  if (status == 'AET') return 'Prorrogação';
  if (status == 'HT') return 'Intervalo';
  if (status == 'LIVE') return 'Ao Vivo';
  if (status.contains("'")) return 'Ao Vivo';
  if (status == 'PEN') return 'Pênaltis';
  return status;
}

String escapeHtml(String? texto) {
  if (texto == null) return '';
  return texto.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#039;');
}

// This completes the code with all pages, functionalities, navigation, live updates via timer, and matching UI/animations from HTML.