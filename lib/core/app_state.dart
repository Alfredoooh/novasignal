import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AppState with ChangeNotifier {
  // ========== CONFIGURAÇÕES DE TEMA ==========
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

  // ========== GETTERS ==========
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get temaEscuroProfundo => _temaEscuroProfundo;
  bool get corDinamica => _corDinamica;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // ========== CONFIGURAÇÃO DA API ==========
  static const List<String> _apiKeys = [
    'b44c67ad584a39726891c32421edec77847c068cb036edf6a41c4c40d8855f97',
    '5fbf446f332cdcb25ae37e36e1d7edeb55f7a47c7b30f34a8fe23da37f8d6ac0',
    '20e63224b98d436a5cacca064bd40c204f7179171b08212b9cdf6d770cfef3ff'
  ];

  static const String _apiBase = 'https://apiv3.apifootball.com';
  int _currentApiKeyIndex = 0;

  // Controle de requisições por API key
  final Map<int, int> _apiKeyRequestCount = {};
  final Map<int, DateTime> _apiKeyResetTime = {};
  static const int _maxRequestsPerHour = 150;

  static const String newsApiKey = 'b2e4d59068e545abbdffaf947c371bcd';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // Cache e intervalos otimizados
  static const int _cacheStaleTime = 60;
  static const int _cacheDurationNews = 1800;

  // Intervalos de atualização
  static const int _updateIntervalJogosAoVivo = 30;
  static const int _updateIntervalJogosNormais = 60;
  static const int _updateIntervalDetalhes = 15;

  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  final Map<String, Completer<dynamic>> _pendingRequests = {};

  AppState() {
    _carregarPreferencias();
    _startCacheCleanup();
    _initializeApiKeyTracking();
  }

  void _initializeApiKeyTracking() {
    for (int i = 0; i < _apiKeys.length; i++) {
      _apiKeyRequestCount[i] = 0;
      _apiKeyResetTime[i] = DateTime.now().add(const Duration(hours: 1));
    }

    Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndResetApiKeys();
    });
  }

  void _checkAndResetApiKeys() {
    final now = DateTime.now();
    for (int i = 0; i < _apiKeys.length; i++) {
      if (now.isAfter(_apiKeyResetTime[i]!)) {
        _apiKeyRequestCount[i] = 0;
        _apiKeyResetTime[i] = now.add(const Duration(hours: 1));
        debugPrint('🔄 API Key $i resetada. Contagem: 0/$_maxRequestsPerHour');
      }
    }
  }

  void _incrementApiKeyCount() {
    _apiKeyRequestCount[_currentApiKeyIndex] = 
        (_apiKeyRequestCount[_currentApiKeyIndex] ?? 0) + 1;

    final count = _apiKeyRequestCount[_currentApiKeyIndex]!;
    final remaining = _maxRequestsPerHour - count;

    debugPrint('📊 API Key $_currentApiKeyIndex: $count/$_maxRequestsPerHour requisições (restam: $remaining)');

    if (count >= _maxRequestsPerHour) {
      debugPrint('⚠️ API Key $_currentApiKeyIndex atingiu o limite! Rotacionando...');
      _rotateToNextAvailableKey();
    }
  }

  void _rotateToNextAvailableKey() {
    final startIndex = _currentApiKeyIndex;
    int attempts = 0;

    do {
      _currentApiKeyIndex = (_currentApiKeyIndex + 1) % _apiKeys.length;
      attempts++;

      final count = _apiKeyRequestCount[_currentApiKeyIndex] ?? 0;

      if (count < _maxRequestsPerHour) {
        final remaining = _maxRequestsPerHour - count;
        debugPrint('✅ Rotacionado para API Key $_currentApiKeyIndex (uso: $count/$_maxRequestsPerHour, restam: $remaining)');
        return;
      }

      debugPrint('⏭️ API Key $_currentApiKeyIndex também no limite ($count/$_maxRequestsPerHour), tentando próxima...');

    } while (_currentApiKeyIndex != startIndex && attempts < _apiKeys.length);

    if (attempts >= _apiKeys.length) {
      debugPrint('❌ TODAS as API Keys atingiram o limite! Aguardando reset...');
      final nextReset = _apiKeyResetTime.values
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final waitTime = nextReset.difference(DateTime.now());
      debugPrint('⏰ Próximo reset em: ${waitTime.inMinutes} minutos');
    }
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

  String _getCurrentApiKey() {
    return _apiKeys[_currentApiKeyIndex];
  }

  void _rotateApiKey() {
    _rotateToNextAvailableKey();
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

      if (key.contains('noticias')) {
        if (age < _cacheDurationNews) {
          debugPrint('✅ Cache FRESH (notícias): $key (${age}s)');
          return entry.data;
        } else {
          debugPrint('⚠️ Cache STALE (notícias): $key (${age}s)');
          return null;
        }
      }

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

    if (key.contains('noticias')) {
      return age >= _cacheDurationNews;
    }

    return age >= _cacheStaleTime;
  }

  // ========== REQUISIÇÕES API FOOTBALL ==========

  Future<dynamic> _makeApiRequest(String action, Map<String, String> params) async {
    final queryParams = {
      'action': action,
      'APIkey': _getCurrentApiKey(),
      ...params,
    };

    final uri = Uri.parse(_apiBase).replace(queryParameters: queryParams);
    final cacheKey = uri.toString();

    if (_pendingRequests.containsKey(cacheKey)) {
      debugPrint('⏳ Aguardando requisição: $action');
      return await _pendingRequests[cacheKey]!.future;
    }

    final completer = Completer<dynamic>();
    _pendingRequests[cacheKey] = completer;

    try {
      final result = await _executeApiRequest(uri);
      _saveToCache(cacheKey, result);
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  Future<dynamic> _executeApiRequest(Uri uri) async {
    int retries = 0;
    const maxRetries = 3;

    while (retries < maxRetries) {
      try {
        debugPrint('🚀 API Request: ${uri.queryParameters['action']}');

        _incrementApiKeyCount();

        final response = await _httpClient.get(uri).timeout(
          const Duration(seconds: 15),
        );

        debugPrint('📡 Status Code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is Map && data.containsKey('error')) {
            final errorMsg = data['error'].toString().toLowerCase();

            if (errorMsg.contains('requests') || 
                errorMsg.contains('limit') || 
                errorMsg.contains('quota') ||
                errorMsg.contains('exceeded')) {
              debugPrint('⚠️ Limite de requisições atingido pela resposta da API, rotacionando chave...');
              _rotateApiKey();
              retries++;
              await Future.delayed(Duration(seconds: retries));
              continue;
            }
            throw Exception(data['error']);
          }

          debugPrint('✅ Response OK');
          return data;
        } else if (response.statusCode == 429 || response.statusCode == 401) {
          debugPrint('⚠️ Erro ${response.statusCode}, rotacionando chave...');
          _rotateApiKey();
          retries++;
          await Future.delayed(Duration(seconds: retries));
          continue;
        } else {
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        if (retries >= maxRetries - 1) {
          debugPrint('❌ Erro após $maxRetries tentativas: $e');
          rethrow;
        }
        retries++;
        await Future.delayed(Duration(seconds: retries));
      }
    }

    throw Exception('Falha após $maxRetries tentativas');
  }

  // ========== NEWS API ==========

  Future<List<Map<String, dynamic>>> carregarNoticias() async {
    const cacheKey = 'noticias_sports';
    final cached = _getFromCache(cacheKey);

    if (cached != null) {
      debugPrint('📰 Retornando ${(cached as List).length} notícias do cache');

      if (_isCacheStale(cacheKey)) {
        _fetchNoticiasBackground(cacheKey);
      }

      return List<Map<String, dynamic>>.from(cached);
    }

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
          }
        } catch (e) {
          debugPrint('⚠️ Erro com query "$query": $e');
          continue;
        }
      }

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

  // CONTINUA NA PARTE 2...

  // ========== JOGOS - API DIRETA ==========

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

      final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await _makeApiRequest('get_events', {'from': hoje, 'to': hoje});

      List<dynamic> jogos = [];

      if (response is List) {
        jogos = response;
        debugPrint('✅ ${jogos.length} jogos carregados');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar todos jogos: $e');
    }
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      if (_isCacheStale(cacheKey)) {
        _fetchJogosDoDiaBackground(dataStr, cacheKey);
      }
      return cached;
    }

    await _fetchJogosDoDiaBackground(dataStr, cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchJogosDoDiaBackground(String dataStr, String cacheKey) async {
    try {
      debugPrint('📅 Carregando jogos para: $dataStr');

      final response = await _makeApiRequest('get_events', {
        'from': dataStr,
        'to': dataStr,
      });

      List<dynamic> jogos = [];

      if (response is List) {
        jogos = response;
        debugPrint('✅ ${jogos.length} jogos carregados');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao buscar jogos do dia: $e');
    }
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
          _fetchJogosDoDiaBackground(dataStr, cacheKey);
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
      final response = await _makeApiRequest('get_events', {'match_id': jogoId});

      if (response != null && response is List && response.isNotEmpty) {
        _saveToCache(cacheKey, response[0]);
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

  // ========== LIGAS ==========

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
      final response = await _makeApiRequest('get_leagues', {});

      if (response is List) {
        todasLigas = response;
        _saveToCache(cacheKey, todasLigas);
        debugPrint('✅ ${todasLigas.length} ligas carregadas');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ligas: $e');
    }
  }

  Future<List<dynamic>> carregarJogosPorLiga(String ligaId) async {
    final cacheKey = 'jogos_liga_$ligaId';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      debugPrint('📋 Retornando ${cached.length} jogos da liga do cache');
      if (_isCacheStale(cacheKey)) {
        _fetchJogosPorLigaBackground(ligaId, cacheKey);
      }
      return cached;
    }

    await _fetchJogosPorLigaBackground(ligaId, cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchJogosPorLigaBackground(String ligaId, String cacheKey) async {
    try {
      debugPrint('🔄 Carregando jogos da liga: $ligaId');

      final hoje = DateTime.now();
      final inicioTemporada = hoje.subtract(const Duration(days: 180));

      final dataInicio = DateFormat('yyyy-MM-dd').format(inicioTemporada);
      final dataFim = DateFormat('yyyy-MM-dd').format(hoje);

      debugPrint('📅 Buscando jogos de $dataInicio até $dataFim');

      final response = await _makeApiRequest('get_events', {
        'league_id': ligaId,
        'from': dataInicio,
        'to': dataFim,
      });

      List<dynamic> jogos = [];

      if (response is List) {
        jogos = response;
        debugPrint('✅ ${jogos.length} jogos da liga carregados (total)');

        final finalizados = jogos.where((j) {
          final status = j['match_status']?.toString() ?? '';
          return status.contains('Finished') || status == 'FT' || status == 'AET';
        }).length;

        debugPrint('   📊 $finalizados jogos finalizados');
        debugPrint('   ⏳ ${jogos.length - finalizados} jogos futuros/ao vivo');
      } else {
        debugPrint('⚠️ Resposta não é uma lista: ${response.runtimeType}');
      }

      _saveToCache(cacheKey, jogos);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos da liga $ligaId: $e');
      _saveToCache(cacheKey, []);
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';
    final cached = _getFromCache(cacheKey);

    if (cached != null && cached is List) {
      if (_isCacheStale(cacheKey)) {
        _fetchClassificacaoBackground(ligaId, cacheKey);
      }
      return cached;
    }

    await _fetchClassificacaoBackground(ligaId, cacheKey);
    final result = _getFromCache(cacheKey);
    return result is List ? result : [];
  }

  Future<void> _fetchClassificacaoBackground(String ligaId, String cacheKey) async {
    try {
      debugPrint('🔄 Carregando classificação da liga: $ligaId');
      final response = await _makeApiRequest('get_standings', {'league_id': ligaId});

      List<dynamic> standings = [];

      if (response is List) {
        standings = response;
        debugPrint('✅ ${standings.length} times na classificação');
      }

      _saveToCache(cacheKey, standings);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar classificação: $e');
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    return carregarJogosPorLiga(ligaId);
  }

  // ========== UTILIDADES ==========

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