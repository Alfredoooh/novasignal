import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AppState with ChangeNotifier {
  // Configurações de tema e notificações
  bool _temaEscuro = false;
  bool _temaEscuroProfundo = false;
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
  bool get temaEscuroProfundo => _temaEscuroProfundo;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // ========== CONFIGURAÇÃO DA API ==========
  static const String cloudflareBase = 'https://dawn-sun-590a.alfredopjonas.workers.dev';
  static const String newsApiKey = 'b2e4d59068e545abbdffaf947c371bcd';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // Cache e intervalos otimizados
  static const int _cacheStaleTime = 60; // 1 minuto
  static const int _cacheDurationNews = 1800; // 30 minutos

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
      _temaEscuroProfundo = prefs.getBool('tema_escuro_profundo') ?? false;
      _notificacoesAtivas = prefs.getBool('notificacoes') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar preferências: $e');
    }
  }

  Future<void> alternarTemaEscuro() async {
    _temaEscuro = !_temaEscuro;
    if (!_temaEscuro) {
      _temaEscuroProfundo = false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', _temaEscuro);
    await prefs.setBool('tema_escuro_profundo', _temaEscuroProfundo);
    notifyListeners();
  }

  Future<void> alternarTemaEscuroProfundo() async {
    _temaEscuroProfundo = !_temaEscuroProfundo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro_profundo', _temaEscuroProfundo);
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
      
      // Cache especial para notícias (30 minutos)
      if (key.contains('noticias')) {
        if (age < _cacheDurationNews) {
          debugPrint('✅ Cache FRESH (notícias): $key (${age}s)');
          return entry.data;
        } else {
          debugPrint('⚠️ Cache STALE (notícias): $key (${age}s)');
          return null;
        }
      }
      
      // Cache normal (1 minuto)
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
    
    // Cache especial para notícias
    if (key.contains('noticias')) {
      return age >= _cacheDurationNews;
    }
    
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

  // ========== NEWS API - CORRIGIDO ==========

  Future<List<Map<String, dynamic>>> carregarNoticias() async {
    const cacheKey = 'noticias_sports';
    final cached = _getFromCache(cacheKey);

    // Retorna cache se ainda for válido (30 minutos)
    if (cached != null) {
      debugPrint('📰 Retornando ${(cached as List).length} notícias do cache');
      
      // Atualiza em background se stale
      if (_isCacheStale(cacheKey)) {
        _fetchNoticiasBackground(cacheKey);
      }
      
      return List<Map<String, dynamic>>.from(cached);
    }

    // Busca pela primeira vez
    debugPrint('📰 Buscando notícias pela primeira vez...');
    try {
      await _fetchNoticiasSync(cacheKey);
      final result = _getFromCache(cacheKey);
      return result != null ? List<Map<String, dynamic>>.from(result) : [];
    } catch (e) {
      debugPrint('❌ Erro ao buscar notícias: $e');
      return [];
    }
  }

  Future<void> _fetchNoticiasSync(String cacheKey) async {
    try {
      // Tenta múltiplas categorias e idiomas para melhorar resultados
      final queries = [
        'category=sports&language=pt&country=br',
        'q=futebol&language=pt',
        'q=football OR soccer&language=en',
      ];

      for (var query in queries) {
        try {
          final url = '$newsApiBase/top-headlines?$query&pageSize=20&apiKey=$newsApiKey';
          debugPrint('🚀 News Request: $query');

          final response = await _httpClient.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

          debugPrint('📡 News Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['status'] == 'ok' && data['articles'] != null) {
              final articles = data['articles'] as List;
              
              if (articles.isEmpty) {
                debugPrint('⚠️ Nenhuma notícia encontrada com: $query');
                continue;
              }

              final noticias = articles
                  .where((article) => 
                      article['title'] != null && 
                      article['title'].toString().isNotEmpty &&
                      article['title'] != '[Removed]')
                  .map((article) {
                return {
                  'title': article['title'] ?? 'Sem título',
                  'subtitle': article['source']?['name'] ?? 'Fonte desconhecida',
                  'description': article['description'] ?? '',
                  'date': _formatNewsDate(article['publishedAt']),
                  'url': article['url'] ?? '',
                  'imageUrl': article['urlToImage'] ?? '',
                };
              }).toList();

              if (noticias.isNotEmpty) {
                _saveToCache(cacheKey, noticias);
                debugPrint('✅ ${noticias.length} notícias salvas no cache');
                notifyListeners();
                return;
              }
            }
          } else if (response.statusCode == 426) {
            debugPrint('⚠️ API Key inválida ou limite excedido');
            throw Exception('API Key issue');
          } else if (response.statusCode == 429) {
            debugPrint('⚠️ Limite de requisições excedido');
            throw Exception('Rate limit exceeded');
          }
        } catch (e) {
          debugPrint('⚠️ Erro com query "$query": $e');
          continue;
        }
      }

      // Se chegou aqui, nenhuma query funcionou
      debugPrint('❌ Nenhuma notícia pôde ser carregada');
      
      // Salva lista vazia no cache para evitar múltiplas tentativas
      _saveToCache(cacheKey, []);
      
    } catch (e) {
      debugPrint('❌ Erro fatal ao buscar notícias: $e');
      rethrow;
    }
  }

  Future<void> _fetchNoticiasBackground(String cacheKey) async {
    try {
      await _fetchNoticiasSync(cacheKey);
    } catch (e) {
      debugPrint('❌ Erro ao atualizar notícias em background: $e');
    }
  }

  String _formatNewsDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Agora';
      if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Há ${diff.inHours}h';
      if (diff.inDays == 1) return 'Ontem';
      if (diff.inDays < 7) return 'Há ${diff.inDays}d';
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      debugPrint('❌ Erro ao formatar data: $dateStr');
      return '';
    }
  }

  // ========== JOGOS - INTEGRADO COM WORKER ==========

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

      final response = await _executeRequest('/api/matches');

      List<dynamic> jogos = [];

      if (response is Map && response.containsKey('matches')) {
        jogos = response['matches'] as List<dynamic>;
        debugPrint('✅ ${jogos.length} jogos carregados via /api/matches');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar todos jogos: $e');
    }
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final amanha = DateFormat('yyyy-MM-dd').format(
      DateTime.now().add(const Duration(days: 1))
    );

    debugPrint('📅 Carregando jogos para: $dataStr');

    String endpoint;
    if (dataStr == hoje) {
      endpoint = '/api/matches/today';
    } else if (dataStr == amanha) {
      endpoint = '/api/matches/tomorrow';
    } else {
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
      final response = await _executeRequest(endpoint);

      List<dynamic> jogos = [];

      if (response is Map && response.containsKey('matches')) {
        jogos = response['matches'] as List<dynamic>;
        debugPrint('✅ ${jogos.length} jogos carregados');
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
    return [];
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    return carregarJogosPorLiga(ligaId);
  }

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