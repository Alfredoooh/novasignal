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

  // Cache com exibição imediata e atualização em background
  final Map<String, _CacheEntry> _cache = {};
  String jogoDetalhesId = '';
  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = '';
  List<dynamic> todasLigas = [];

  // HTTP Client reutilizável com pool de conexões
  final http.Client _httpClient = http.Client();

  // Timers de auto-atualização
  final Map<String, Timer> _autoUpdateTimers = {};

  // Getters para configurações
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get temaEscuroProfundo => _temaEscuroProfundo;
  bool get corDinamica => _corDinamica;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // ========== CLOUDFLARE API CONFIGURATION ==========
  static const String cloudflareBase = 'https://dawn-sun-590a.alfredopjonas.workers.dev';

  // NOVA ESTRATÉGIA: Cache serve apenas para exibição imediata
  // Dados são SEMPRE atualizados em background
  static const int _cacheStaleTime = 30; // segundos - quando considerar "antigo"
  
  // Intervalos de atualização automática (em segundos)
  static const int _updateIntervalJogosAoVivo = 10; // 10s para jogos ao vivo
  static const int _updateIntervalJogosNormais = 30; // 30s para jogos normais
  static const int _updateIntervalDetalhes = 5; // 5s para detalhes de jogo

  // Top clubs para jogos em destaque
  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  // Map para controlar requisições em andamento (evita duplicação)
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  AppState() {
    _carregarPreferencias();
    _startCacheCleanup();
  }

  // Timer para limpar cache muito antigo
  void _startCacheCleanup() {
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _cleanOldCache();
    });
  }

  void _cleanOldCache() {
    final now = DateTime.now();
    // Remove apenas itens com mais de 1 hora
    _cache.removeWhere((key, entry) => 
      now.difference(entry.timestamp).inHours > 1
    );
    debugPrint('🧹 Cache antigo limpo. Itens restantes: ${_cache.length}');
  }

  // ========== MÉTODOS DE PREFERÊNCIAS ==========

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

  // ========== MÉTODOS DE NAVEGAÇÃO ==========

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

  // ========== MÉTODOS DE FILTROS ==========

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

  // ========== NOVO SISTEMA DE CACHE COM STALE-WHILE-REVALIDATE ==========

  dynamic _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null) {
      final age = DateTime.now().difference(entry.timestamp).inSeconds;
      if (age < _cacheStaleTime) {
        debugPrint('✅ Cache FRESH: $key (${age}s)');
        return entry.data;
      } else {
        debugPrint('⚠️ Cache STALE: $key (${age}s) - retornando mas atualizando...');
        return entry.data; // Retorna mesmo se antigo
      }
    }
    debugPrint('❌ Cache MISS: $key');
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

  // ========== SISTEMA DE REQUISIÇÕES COM DEDUPLICAÇÃO ==========

  Future<dynamic> _makeRequest(String endpoint, String cacheKey) async {
    // Se já existe uma requisição em andamento, aguarda ela
    if (_pendingRequests.containsKey(endpoint)) {
      debugPrint('⏳ Aguardando requisição em andamento: $endpoint');
      return await _pendingRequests[endpoint]!.future;
    }

    // Cria um novo Completer para esta requisição
    final completer = Completer<dynamic>();
    _pendingRequests[endpoint] = completer;

    try {
      final result = await _executeRequest(endpoint);
      
      // Salva no cache
      _saveToCache(cacheKey, result);
      
      // Completa a requisição
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
      debugPrint('🚀 API Request: $url');

      final response = await _httpClient.get(Uri.parse(url)).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }

        debugPrint('✅ API Response OK: $endpoint');
        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erro na requisição: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS PRINCIPAIS COM STALE-WHILE-REVALIDATE ==========

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';

    // 1. Retorna cache imediatamente se existir
    final cached = _getFromCache(cacheKey);
    
    // 2. Se cache está antigo OU não existe, busca novos dados
    if (_isCacheStale(cacheKey)) {
      _fetchJogosDoDiaBackground(data, cacheKey);
    }

    // 3. Retorna cache (mesmo que antigo) ou lista vazia
    return cached as List<dynamic>? ?? [];
  }

  Future<void> _fetchJogosDoDiaBackground(DateTime data, String cacheKey) async {
    try {
      final dataStr = DateFormat('yyyy-MM-dd').format(data);
      final response = await _makeRequest('/api/matches', cacheKey);

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        final jogosDoDia = todosJogos.where((jogo) {
          final matchDate = jogo['match_date'] ?? '';
          return matchDate == dataStr;
        }).toList();

        debugPrint('✅ ${jogosDoDia.length} jogos para $dataStr');
        _saveToCache(cacheKey, jogosDoDia);
        notifyListeners(); // Atualiza UI
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar jogos: $e');
    }
  }

  // Auto-atualização contínua para jogos ao vivo
  void iniciarAutoAtualizacaoJogos(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final timerId = 'jogos_$dataStr';
    
    // Cancela timer anterior se existir
    _autoUpdateTimers[timerId]?.cancel();
    
    // Cria novo timer
    _autoUpdateTimers[timerId] = Timer.periodic(
      Duration(seconds: _updateIntervalJogosAoVivo),
      (timer) {
        final cacheKey = 'jogos_$dataStr';
        _fetchJogosDoDiaBackground(data, cacheKey);
      },
    );
    
    debugPrint('🔄 Auto-atualização iniciada para $dataStr');
  }

  void pararAutoAtualizacaoJogos(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final timerId = 'jogos_$dataStr';
    _autoUpdateTimers[timerId]?.cancel();
    _autoUpdateTimers.remove(timerId);
    debugPrint('⏸️ Auto-atualização pausada para $dataStr');
  }

  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    const cacheKey = 'destaque_jogos';

    final cached = _getFromCache(cacheKey);
    
    if (_isCacheStale(cacheKey)) {
      _fetchJogosDestaqueBackground(cacheKey);
    }

    return cached as List<dynamic>? ?? [];
  }

  Future<void> _fetchJogosDestaqueBackground(String cacheKey) async {
    try {
      final response = await _makeRequest('/api/matches', cacheKey);

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

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

        // Ordenar: jogos ao vivo primeiro
        jogosFiltrados.sort((a, b) {
          final aIsLive = _isJogoAoVivo(a);
          final bIsLive = _isJogoAoVivo(b);

          if (aIsLive && !bIsLive) return -1;
          if (!aIsLive && bIsLive) return 1;
          return 0;
        });

        final limitedJogos = jogosFiltrados.take(10).toList();
        debugPrint('✅ ${limitedJogos.length} jogos em destaque');
        _saveToCache(cacheKey, limitedJogos);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar destaques: $e');
    }
  }

  bool _isJogoAoVivo(dynamic jogo) {
    final status = jogo['match_status'] ?? '';
    
    // Verifica se é um número (minutos do jogo)
    if (int.tryParse(status.toString()) != null) {
      return true;
    }
    
    return status.contains("'") || 
           status == 'HT' || 
           status == 'LIVE' ||
           status == '1H' ||
           status == '2H';
  }

  Future<List<dynamic>> pesquisarJogos(String termo) async {
    final termoLower = termo.toLowerCase();
    final cacheKey = 'pesquisa_$termoLower';

    final cached = _getFromCache(cacheKey);
    
    if (_isCacheStale(cacheKey)) {
      _fetchPesquisaBackground(termo, cacheKey);
    }

    return cached as List<dynamic>? ?? [];
  }

  Future<void> _fetchPesquisaBackground(String termo, String cacheKey) async {
    try {
      final termoLower = termo.toLowerCase();
      final response = await _makeRequest('/api/matches', cacheKey);

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        final resultados = todosJogos.where((jogo) {
          final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
          final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
          final league = (jogo['league_name'] ?? '').toString().toLowerCase();
          return home.contains(termoLower) || 
                 away.contains(termoLower) || 
                 league.contains(termoLower);
        }).toList();

        debugPrint('✅ ${resultados.length} resultados para "$termo"');
        _saveToCache(cacheKey, resultados);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro na pesquisa: $e');
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final cacheKey = 'detalhes_$jogoId';

    final cached = _getFromCache(cacheKey);
    
    // Sempre atualiza detalhes (dados mais críticos)
    _fetchJogoDetalhesBackground(jogoId, cacheKey);

    return cached;
  }

  Future<void> _fetchJogoDetalhesBackground(String jogoId, String cacheKey) async {
    try {
      final response = await _makeRequest('/api/matches/$jogoId', cacheKey);

      if (response != null) {
        _saveToCache(cacheKey, response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar detalhes: $e');
    }
  }

  // Auto-atualização para detalhes de jogo
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
    
    debugPrint('🔄 Auto-atualização de detalhes iniciada para jogo $jogoId');
  }

  void pararAutoAtualizacaoDetalhes(String jogoId) {
    final timerId = 'detalhes_$jogoId';
    _autoUpdateTimers[timerId]?.cancel();
    _autoUpdateTimers.remove(timerId);
    debugPrint('⏸️ Auto-atualização de detalhes pausada');
  }

  Future<List<dynamic>> carregarLigas() async {
    const cacheKey = 'ligas_todas';

    final cached = _getFromCache(cacheKey);
    if (cached != null) {
      todasLigas = cached as List<dynamic>;
    }
    
    if (_isCacheStale(cacheKey)) {
      _fetchLigasBackground(cacheKey);
    }

    return todasLigas;
  }

  Future<void> _fetchLigasBackground(String cacheKey) async {
    try {
      final response = await _makeRequest('/api/matches', cacheKey);

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        final ligasMap = <String, Map<String, dynamic>>{};

        for (var jogo in todosJogos) {
          final ligaId = jogo['league_id']?.toString();
          final ligaNome = jogo['league_name'];

          if (ligaId != null && ligaNome != null && !ligasMap.containsKey(ligaId)) {
            ligasMap[ligaId] = {
              'league_id': ligaId,
              'league_name': ligaNome,
              'country_name': jogo['country_name'] ?? '',
              'league_logo': jogo['league_logo'] ?? '',
            };
          }
        }

        todasLigas = ligasMap.values.toList();
        _saveToCache(cacheKey, todasLigas);
        debugPrint('✅ ${todasLigas.length} ligas carregadas');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar ligas: $e');
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';

    final cached = _getFromCache(cacheKey);
    
    if (_isCacheStale(cacheKey)) {
      _fetchClassificacaoBackground(ligaId, cacheKey);
    }

    return cached as List<dynamic>? ?? [];
  }

  Future<void> _fetchClassificacaoBackground(String ligaId, String cacheKey) async {
    try {
      await carregarJogosPorLiga(ligaId);
      _saveToCache(cacheKey, []);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar classificação: $e');
    }
  }

  Future<List<dynamic>> carregarJogosPorLiga(String ligaId) async {
    final cacheKey = 'jogos_liga_$ligaId';

    final cached = _getFromCache(cacheKey);
    
    if (_isCacheStale(cacheKey)) {
      _fetchJogosPorLigaBackground(ligaId, cacheKey);
    }

    return cached as List<dynamic>? ?? [];
  }

  Future<void> _fetchJogosPorLigaBackground(String ligaId, String cacheKey) async {
    try {
      final response = await _makeRequest(
        '/api/matches/league?league_id=$ligaId',
        cacheKey,
      );

      if (response is Map && response.containsKey('matches')) {
        final jogos = response['matches'] as List<dynamic>;
        debugPrint('✅ ${jogos.length} jogos da liga $ligaId');
        _saveToCache(cacheKey, jogos);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar jogos da liga: $e');
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    return carregarJogosPorLiga(ligaId);
  }

  Future<void> precarregarDadosHome() async {
    debugPrint('🔥 Pré-carregando dados da Home...');
    
    // Inicia carregamento em paralelo
    await Future.wait([
      carregarJogosDoDia(DateTime.now()),
      carregarJogosDestaque(topClubs),
    ]);
    
    // Inicia auto-atualização
    iniciarAutoAtualizacaoJogos(DateTime.now());
    
    debugPrint('✅ Dados da Home pré-carregados e auto-atualização iniciada');
  }

  void limparCache() {
    _cache.clear();
    debugPrint('🗑️ Cache limpo manualmente');
    notifyListeners();
  }

  void pararTodasAutoAtualizacoes() {
    for (var timer in _autoUpdateTimers.values) {
      timer.cancel();
    }
    _autoUpdateTimers.clear();
    debugPrint('⏸️ Todas auto-atualizações pausadas');
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