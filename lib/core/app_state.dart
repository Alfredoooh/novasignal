import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AppState with ChangeNotifier {
  // Configurações de tema e notificações
  bool _temaEscuro = false;
  bool _temaAmoled = false;
  bool _temaEscuroProfundo = false;
  bool _corDinamica = true;
  bool _notificacoesAtivas = true;

  // Estado de navegação
  String tabAtual = 'home';
  String paginaAtual = 'home';
  List<String> historicoPaginas = [];

  // Estado de filtros e seleções
  String filtroJogos = 'hoje';
  DateTime dataSelecionada = DateTime.now();

  // Cache otimizado
  final Map<String, _CacheEntry> _cache = {};
  String jogoDetalhesId = '';
  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = '';
  List<dynamic> todasLigas = [];

  // HTTP Client reutilizável
  final http.Client _httpClient = http.Client();

  // Timers de auto-atualização
  final Map<String, Timer> _autoUpdateTimers = {};

  // Getters
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get temaEscuroProfundo => _temaEscuroProfundo;
  bool get corDinamica => _corDinamica;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // ========== CONFIGURAÇÃO DA API ==========
  static const String cloudflareBase = 'https://dawn-sun-590a.alfredopjonas.workers.dev';
  static const String newsApiKey = 'b2e4d59068e545abbdffaf947c371bcd';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // Cache e intervalos otimizados
  static const int _cacheStaleTime = 60; // 1 minuto
  static const int _cacheDurationNews = 30; // 30 minutos

  // Intervalos OTIMIZADOS
  static const int _updateIntervalJogosAoVivo = 30; // 30s
  static const int _updateIntervalJogosNormais = 60; // 1 min
  static const int _updateIntervalDetalhes = 15; // 15s

  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  // Controle de requisições em andamento
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  AppState() {
    _carregarPreferencias();
    _startCacheCleanup();
  }

  void _startCacheCleanup() {
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _cleanOldCache();
    });
  }

  void _cleanOldCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => 
      now.difference(entry.timestamp).inHours > 1
    );
    debugPrint('🧹 Cache limpo. Itens: ${_cache.length}');
  }

  // ========== PREFERÊNCIAS ==========

  Future<void> _carregarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _temaEscuro = prefs.getBool('tema_escuro') ?? false;
      _temaAmoled = prefs.getBool('tema_amoled') ?? false;
      _temaEscuroProfundo = prefs.getBool('tema_escuro_profundo') ?? false;
      _corDinamica = prefs.getBool('cor_dinamica') ?? true;
      _notificacoesAtivas = prefs.getBool('notificacoes') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências: $e');
    }
  }

  Future<void> alternarTema(bool valor) async {
    _temaEscuro = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', valor);
    notifyListeners();
  }

  Future<void> alternarTemaAmoled(bool valor) async {
    _temaAmoled = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_amoled', valor);
    notifyListeners();
  }

  Future<void> alternarTemaEscuroProfundo(bool valor) async {
    _temaEscuroProfundo = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro_profundo', valor);
    notifyListeners();
  }

  Future<void> alternarCorDinamica(bool valor) async {
    _corDinamica = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cor_dinamica', valor);
    notifyListeners();
  }

  Future<void> alternarNotificacoes(bool valor) async {
    _notificacoesAtivas = valor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacoes', valor);
    notifyListeners();
  }

  // ========== NAVEGAÇÃO ==========

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

  // ========== FILTROS ==========

  void filtrarJogos(String filtro) {
    filtroJogos = filtro;
    notifyListeners();
  }

  void setDataSelecionada(DateTime data) {
    dataSelecionada = data;
    notifyListeners();
  }

  void setJogoDetalhes(String id, String titulo) {
    jogoDetalhesId = id;
  }

  void setLigaDetalhes(String id, String titulo) {
    ligaDetalhesId = id;
    ligaDetalhesTitulo = titulo;
  }

  // ========== SISTEMA DE CACHE ==========

  dynamic _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null) {
      final age = DateTime.now().difference(entry.timestamp).inSeconds;
      if (age < _cacheStaleTime) {
        debugPrint('✅ Cache FRESH: $key (${age}s)');
        return entry.data;
      } else {
        debugPrint('⚠️ Cache STALE: $key (${age}s)');
        return entry.data;
      }
    }
    return null;
  }

  void _saveToCache(String key, dynamic data) {
    _cache[key] = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  bool _isCacheStale(String key) {
    final entry = _cache[key];
    if (entry == null) return true;
    final age = DateTime.now().difference(entry.timestamp).inSeconds;
    return age >= _cacheStaleTime;
  }

  // ========== REQUISIÇÕES ==========

  Future<dynamic> _makeRequest(String endpoint, String cacheKey) async {
    if (_pendingRequests.containsKey(endpoint)) {
      debugPrint('⏳ Aguardando requisição: $endpoint');
      return await _pendingRequests[endpoint]!.future;
    }

    final completer = Completer<dynamic>();
    _pendingRequests[endpoint] = completer;

    try {
      final result = await _executeRequest(endpoint);
      _saveToCache(cacheKey, result);
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(endpoint);
    }
  }

  Future<dynamic> _executeRequest(String endpoint) async {
    try {
      final url = '$cloudflareBase$endpoint';
      debugPrint('🚀 Request: $url');

      final response = await _httpClient.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );

      debugPrint('📡 Status Code: ${response.statusCode}');
      debugPrint('📦 Response Body (primeiros 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }

        debugPrint('✅ Response OK: $endpoint');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro em _executeRequest: $e');
      rethrow;
    }
  }

  // ========== NEWS API ==========

  Future<List<Map<String, dynamic>>> carregarNoticias() async {
    const cacheKey = 'noticias_sports';
    final cached = _getFromCache(cacheKey);

    if (cached != null) {
      if (_isCacheStale(cacheKey)) {
        _fetchNoticiasBackground(cacheKey);
      }
      return List<Map<String, dynamic>>.from(cached);
    }

    await _fetchNoticiasBackground(cacheKey);
    final result = _getFromCache(cacheKey);
    return result != null ? List<Map<String, dynamic>>.from(result) : [];
  }

  Future<void> _fetchNoticiasBackground(String cacheKey) async {
    try {
      final url = '$newsApiBase/top-headlines?category=sports&language=pt&apiKey=$newsApiKey';
      debugPrint('🚀 News Request');

      final response = await _httpClient.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok' && data['articles'] != null) {
          final articles = data['articles'] as List;
          final noticias = articles.map((article) {
            return {
              'title': article['title'] ?? '',
              'subtitle': article['source']?['name'] ?? '',
              'description': article['description'] ?? '',
              'date': _formatNewsDate(article['publishedAt']),
              'url': article['url'] ?? '',
              'imageUrl': article['urlToImage'] ?? '',
            };
          }).toList();

          _saveToCache(cacheKey, noticias);
          debugPrint('✅ ${noticias.length} notícias');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Erro notícias: $e');
    }
  }

  String _formatNewsDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Há ${diff.inHours}h';
      if (diff.inDays < 7) return 'Há ${diff.inDays}d';
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  // ========== JOGOS - INTEGRADO COM WORKER ==========

  // Carrega TODOS os jogos (live + today + tomorrow)
  Future<List<dynamic>> carregarTodosJogos() async {
    const cacheKey = 'jogos_todos';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      if (_isCacheStale(cacheKey)) {
        _fetchTodosJogosBackground(cacheKey);
      }
      return cached;
    }

    await _fetchTodosJogosBackground(cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchTodosJogosBackground(String cacheKey) async {
    try {
      debugPrint('🔄 Carregando TODOS os jogos...');

      // Usa o endpoint /api/matches que retorna tudo
      final response = await _executeRequest('/api/matches');

      debugPrint('📦 Tipo da resposta: ${response.runtimeType}');
      debugPrint('📦 Conteúdo: $response');

      List<dynamic> jogos = [];

      // O Worker retorna: { "count": X, "matches": [...] }
      if (response is Map && response.containsKey('matches')) {
        jogos = response['matches'] as List<dynamic>;
        debugPrint('✅ ${jogos.length} jogos carregados via /api/matches');
      } else {
        debugPrint('⚠️ Formato de resposta inesperado');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar todos jogos: $e');
    }
  }

  // Carrega jogos de uma data específica
  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final amanha = DateFormat('yyyy-MM-dd').format(
      DateTime.now().add(const Duration(days: 1))
    );

    debugPrint('📅 Carregando jogos para: $dataStr (hoje: $hoje, amanhã: $amanha)');

    // Determina qual endpoint usar
    String endpoint;
    if (dataStr == hoje) {
      endpoint = '/api/matches/today';
    } else if (dataStr == amanha) {
      endpoint = '/api/matches/tomorrow';
    } else {
      // Para outras datas, usa todos e filtra
      return _filtrarJogosPorData(dataStr);
    }

    final cacheKey = 'jogos_$dataStr';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      if (_isCacheStale(cacheKey)) {
        _fetchJogosDoDiaBackground(endpoint, cacheKey);
      }
      return cached;
    }

    await _fetchJogosDoDiaBackground(endpoint, cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchJogosDoDiaBackground(String endpoint, String cacheKey) async {
    try {
      debugPrint('🔄 Buscando: $endpoint');
      final response = await _executeRequest(endpoint);

      List<dynamic> jogos = [];

      if (response is Map && response.containsKey('matches')) {
        jogos = response['matches'] as List<dynamic>;
        debugPrint('✅ ${jogos.length} jogos carregados');
      } else {
        debugPrint('⚠️ Formato inesperado na resposta');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao buscar jogos do dia: $e');
    }
  }

  Future<List<dynamic>> _filtrarJogosPorData(String dataStr) async {
    final todosJogos = await carregarTodosJogos();

    return todosJogos.where((jogo) {
      final matchDate = jogo['match_date'] ?? '';
      return matchDate == dataStr;
    }).toList();
  }

  // Auto-atualização otimizada
  void iniciarAutoAtualizacaoJogos(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final timerId = 'jogos_$dataStr';

    _autoUpdateTimers[timerId]?.cancel();

    _autoUpdateTimers[timerId] = Timer.periodic(
      Duration(seconds: _updateIntervalJogosAoVivo),
      (timer) {
        final cacheKey = 'jogos_$dataStr';
        final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

        if (dataStr == hoje) {
          _fetchJogosDoDiaBackground('/api/matches/today', cacheKey);
        }
      },
    );

    debugPrint('🔄 Auto-atualização iniciada: $dataStr');
  }

  void pararAutoAtualizacaoJogos(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final timerId = 'jogos_$dataStr';
    _autoUpdateTimers[timerId]?.cancel();
    _autoUpdateTimers.remove(timerId);
    debugPrint('⏸️ Auto-atualização pausada: $dataStr');
  }

  // Jogos em destaque
  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    const cacheKey = 'destaque_jogos';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      if (_isCacheStale(cacheKey)) {
        _fetchJogosDestaqueBackground(cacheKey);
      }
      return cached;
    }

    await _fetchJogosDestaqueBackground(cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchJogosDestaqueBackground(String cacheKey) async {
    try {
      final todosJogos = await carregarTodosJogos();

      final jogosFiltrados = todosJogos.where((jogo) {
        final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
        final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();

        for (var team in topClubs) {
          final teamLower = team.toLowerCase();
          if (home.contains(teamLower) || away.contains(teamLower)) {
            return true;
          }
        }
        return false;
      }).toList();

      // Ordena: jogos ao vivo primeiro
      jogosFiltrados.sort((a, b) {
        final aIsLive = _isJogoAoVivo(a);
        final bIsLive = _isJogoAoVivo(b);
        if (aIsLive && !bIsLive) return -1;
        if (!aIsLive && bIsLive) return 1;
        return 0;
      });

      final limitados = jogosFiltrados.take(10).toList();
      debugPrint('✅ ${limitados.length} jogos destaque');
      _saveToCache(cacheKey, limitados);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro destaques: $e');
    }
  }

  bool _isJogoAoVivo(dynamic jogo) {
    final status = jogo['match_status'] ?? '';

    if (int.tryParse(status.toString()) != null) return true;

    return status.contains("'") || 
           status == 'HT' || 
           status == 'LIVE' ||
           status == '1H' ||
           status == '2H';
  }

  // Pesquisa
  Future<List<dynamic>> pesquisarJogos(String termo) async {
    final termoLower = termo.toLowerCase();
    final todosJogos = await carregarTodosJogos();

    return todosJogos.where((jogo) {
      final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
      final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
      final league = (jogo['league_name'] ?? '').toString().toLowerCase();

      return home.contains(termoLower) || 
             away.contains(termoLower) || 
             league.contains(termoLower);
    }).toList();
  }

  // Detalhes do jogo
  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final cacheKey = 'detalhes_$jogoId';
    final cached = _getFromCache(cacheKey);

    if (cached == null) {
      await _fetchJogoDetalhesBackground(jogoId, cacheKey);
      return _getFromCache(cacheKey);
    }

    _fetchJogoDetalhesBackground(jogoId, cacheKey);
    return cached;
  }

  Future<void> _fetchJogoDetalhesBackground(String jogoId, String cacheKey) async {
    try {
      final response = await _executeRequest('/api/matches/$jogoId');

      if (response != null) {
        _saveToCache(cacheKey, response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro detalhes: $e');
    }
  }

  void iniciarAutoAtualizacaoDetalhes(String jogoId) {
    final timerId = 'detalhes_$jogoId';
    _autoUpdateTimers[timerId]?.cancel();

    _autoUpdateTimers[timerId] = Timer.periodic(
      Duration(seconds: _updateIntervalDetalhes),
      (timer) {
        final cacheKey = 'detalhes_$jogoId';
        _fetchJogoDetalhesBackground(jogoId, cacheKey);
      },
    );

    debugPrint('🔄 Auto-atualização detalhes: $jogoId');
  }

  void pararAutoAtualizacaoDetalhes(String jogoId) {
    final timerId = 'detalhes_$jogoId';
    _autoUpdateTimers[timerId]?.cancel();
    _autoUpdateTimers.remove(timerId);
  }

  // Ligas
  Future<List<dynamic>> carregarLigas() async {
    const cacheKey = 'ligas_todas';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      todasLigas = cached;
      if (_isCacheStale(cacheKey)) {
        _fetchLigasBackground(cacheKey);
      }
      return todasLigas;
    }

    await _fetchLigasBackground(cacheKey);
    final result = _getFromCache(cacheKey);
    todasLigas = result is List ? result : [];
    return todasLigas;
  }

  Future<void> _fetchLigasBackground(String cacheKey) async {
    try {
      debugPrint('🔄 Carregando ligas...');
      final response = await _executeRequest('/api/leagues');

      if (response is Map && response.containsKey('leagues')) {
        final leagues = response['leagues'] as Map;

        todasLigas = leagues.entries.map((entry) {
          return {
            'league_id': entry.value,
            'league_name': entry.key,
          };
        }).toList();

        _saveToCache(cacheKey, todasLigas);
        debugPrint('✅ ${todasLigas.length} ligas carregadas');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ligas: $e');
    }
  }

  Future<List<dynamic>> carregarJogosPorLiga(String ligaId) async {
    final todosJogos = await carregarTodosJogos();

    return todosJogos.where((jogo) {
      final jogoLigaId = jogo['league_id']?.toString();
      return jogoLigaId == ligaId;
    }).toList();
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    // Classificação pode ser implementada no futuro
    return [];
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    return carregarJogosPorLiga(ligaId);
  }

  // Pré-carregamento
  Future<void> precarregarDadosHome() async {
    debugPrint('🔥 Pré-carregando Home...');

    await Future.wait([
      carregarJogosDoDia(DateTime.now()),
      carregarJogosDestaque(topClubs),
      carregarNoticias(),
    ]);

    iniciarAutoAtualizacaoJogos(DateTime.now());
    debugPrint('✅ Home pré-carregada');
  }

  void limparCache() {
    _cache.clear();
    debugPrint('🗑️ Cache limpo');
    notifyListeners();
  }

  void pararTodasAutoAtualizacoes() {
    for (var timer in _autoUpdateTimers.values) {
      timer.cancel();
    }
    _autoUpdateTimers.clear();
    debugPrint('⏸️ Auto-atualizações pausadas');
  }

  @override
  void dispose() {
    pararTodasAutoAtualizacoes();
    _httpClient.close();
    super.dispose();
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  _CacheEntry({
    required this.data,
    required this.timestamp,
  });
}