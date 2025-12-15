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
  bool _notificacoesAtivas = true;

  // Estado de navegação
  String tabAtual = 'home';
  String paginaAtual = 'home';
  List<String> historicoPaginas = [];

  // Estado de filtros e seleções
  String filtroJogos = 'hoje';
  DateTime dataSelecionada = DateTime.now();

  // Cache com expiração
  final Map<String, _CacheEntry> _cache = {};
  String jogoDetalhesId = '';
  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = '';
  List<dynamic> todasLigas = [];

  // HTTP Client reutilizável (mais rápido que criar novo a cada request)
  final http.Client _httpClient = http.Client();

  // Getters para configurações
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // Configuração da API
  static const List<String> apiKeys = [
    '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d',
    '5fbf446f332cdcb25ae37e36e1d7edeb55f7a47c7b30f34a8fe23da37f8d6ac0',
  ];
  int _currentApiKeyIndex = 0;
  static const String apiBase = 'https://apifootball.com/api';

  // Cache de duração por tipo de requisição (em minutos)
  static const int _cacheDurationJogos = 2; // 2 minutos para jogos
  static const int _cacheDurationDetalhes = 1; // 1 minuto para detalhes
  static const int _cacheDurationLigas = 60; // 60 minutos para ligas
  static const int _cacheDurationClassificacao = 30; // 30 minutos

  // Top clubs para jogos em destaque
  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  // Map para controlar requisições em andamento (evita duplicatas)
  final Map<String, Future<dynamic>> _pendingRequests = {};

  AppState() {
    _carregarPreferencias();
    _startCacheCleanup();
  }

  String get _currentApiKey => apiKeys[_currentApiKeyIndex];

  void _rotateApiKey() {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % apiKeys.length;
    debugPrint('Rotating to API key index: $_currentApiKeyIndex');
  }

  // Timer para limpar cache expirado automaticamente
  void _startCacheCleanup() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanExpiredCache();
    });
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired(now));
    debugPrint('Cache limpo. Itens restantes: ${_cache.length}');
  }

  // ========== MÉTODOS DE PREFERÊNCIAS ==========

  Future<void> _carregarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _temaEscuro = prefs.getBool('tema_escuro') ?? false;
      _temaAmoled = prefs.getBool('tema_amoled') ?? false;
      _notificacoesAtivas = prefs.getBool('notificacoes') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar preferências: $e');
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

  // ========== MÉTODOS DE API OTIMIZADOS ==========

  // Verifica cache com expiração
  dynamic _getFromCache(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired(DateTime.now())) {
      debugPrint('✓ Cache HIT: $key');
      return entry.data;
    }
    if (entry != null) {
      debugPrint('✗ Cache EXPIRED: $key');
      _cache.remove(key);
    }
    return null;
  }

  void _saveToCache(String key, dynamic data, int durationMinutes) {
    _cache[key] = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(Duration(minutes: durationMinutes)),
    );
  }

  Future<dynamic> _makeRequest(String url, {int retryCount = 0}) async {
    // Verifica se já existe uma requisição em andamento para esta URL
    if (_pendingRequests.containsKey(url)) {
      debugPrint('⏳ Requisição já em andamento, aguardando...');
      return await _pendingRequests[url]!;
    }

    // Cria a requisição e armazena como pendente
    final requestFuture = _executeRequest(url, retryCount);
    _pendingRequests[url] = requestFuture;

    try {
      final result = await requestFuture;
      return result;
    } finally {
      // Remove da lista de pendentes quando completar
      _pendingRequests.remove(url);
    }
  }

  Future<dynamic> _executeRequest(String url, int retryCount) async {
    try {
      final response = await _httpClient.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5), // Reduzido de 10 para 5 segundos
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 429 || response.statusCode == 403) {
        if (retryCount < apiKeys.length - 1) {
          _rotateApiKey();
          return await _makeRequest(
            url.replaceAll(apiKeys[retryCount], _currentApiKey), 
            retryCount: retryCount + 1
          );
        }
      }
      throw Exception('Erro ${response.statusCode}');
    } catch (e) {
      if (retryCount < apiKeys.length - 1) {
        _rotateApiKey();
        return await _makeRequest(
          url.replaceAll(apiKeys[retryCount], _currentApiKey), 
          retryCount: retryCount + 1
        );
      }
      rethrow;
    }
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';

    // Verifica cache primeiro
    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final url = '$apiBase/?action=get_events&from=$dataStr&to=$dataStr&APIkey=$_currentApiKey';
      debugPrint('🚀 Buscando jogos: $dataStr');

      final dados = await _makeRequest(url);

      if (dados is Map && dados.containsKey('error')) {
        throw Exception(dados['error']);
      }

      if (dados is List) {
        debugPrint('✓ ${dados.length} jogos encontrados');
        _saveToCache(cacheKey, dados, _cacheDurationJogos);
        return dados;
      }

      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar jogos: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    final hoje = DateTime.now();
    final doisDiasAtras = hoje.subtract(const Duration(days: 2));
    final cincoDiasFrente = hoje.add(const Duration(days: 3));
    final from = DateFormat('yyyy-MM-dd').format(doisDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(cincoDiasFrente);

    final cacheKey = 'destaque_$from\_$to';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$_currentApiKey';
      debugPrint('🚀 Buscando destaques...');

      final dados = await _makeRequest(url);

      if (dados is List) {
        // Filtro otimizado
        final jogosFiltrados = dados.where((jogo) {
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

        // Ordena por status (ao vivo primeiro)
        jogosFiltrados.sort((a, b) {
          final aStatus = a['match_status'] ?? '';
          final bStatus = b['match_status'] ?? '';

          final aIsLive = aStatus.contains("'") || aStatus == 'HT' || aStatus == 'LIVE';
          final bIsLive = bStatus.contains("'") || bStatus == 'HT' || bStatus == 'LIVE';

          if (aIsLive && !bIsLive) return -1;
          if (!aIsLive && bIsLive) return 1;
          return 0;
        });

        final limitedJogos = jogosFiltrados.take(10).toList();
        debugPrint('✓ ${limitedJogos.length} jogos em destaque');
        _saveToCache(cacheKey, limitedJogos, _cacheDurationJogos);
        return limitedJogos;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar destaques: $e');
      return [];
    }
  }

  Future<List<dynamic>> pesquisarJogos(String termo) async {
    final termoLower = termo.toLowerCase();
    final cacheKey = 'pesquisa_$termoLower';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final hoje = DateTime.now();
      final seteDiasAtras = hoje.subtract(const Duration(days: 7));
      final seteDiasFrente = hoje.add(const Duration(days: 7));
      final from = DateFormat('yyyy-MM-dd').format(seteDiasAtras);
      final to = DateFormat('yyyy-MM-dd').format(seteDiasFrente);

      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$_currentApiKey';
      debugPrint('🔍 Pesquisando: $termo');

      final dados = await _makeRequest(url);

      if (dados is List) {
        final resultados = dados.where((jogo) {
          final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
          final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
          final league = (jogo['league_name'] ?? '').toString().toLowerCase();
          return home.contains(termoLower) || 
                 away.contains(termoLower) || 
                 league.contains(termoLower);
        }).toList();

        debugPrint('✓ ${resultados.length} resultados');
        _saveToCache(cacheKey, resultados, _cacheDurationJogos);
        return resultados;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro na pesquisa: $e');
      return [];
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final cacheKey = 'detalhes_$jogoId';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached;

    try {
      final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$_currentApiKey';
      debugPrint('🚀 Buscando detalhes: $jogoId');

      final dados = await _makeRequest(url);

      if (dados is List && dados.isNotEmpty) {
        _saveToCache(cacheKey, dados[0], _cacheDurationDetalhes);
        return dados[0];
      }
      return null;
    } catch (e) {
      debugPrint('✗ Erro ao carregar detalhes: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> carregarLigas() async {
    const cacheKey = 'ligas_todas';

    final cached = _getFromCache(cacheKey);
    if (cached != null) {
      todasLigas = cached as List<dynamic>;
      return todasLigas;
    }

    try {
      final url = '$apiBase/?action=get_leagues&APIkey=$_currentApiKey';
      debugPrint('🚀 Buscando ligas...');

      final dados = await _makeRequest(url);

      if (dados is List) {
        todasLigas = dados;
        _saveToCache(cacheKey, todasLigas, _cacheDurationLigas);
        debugPrint('✓ ${todasLigas.length} ligas carregadas');
        return todasLigas;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar ligas: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final url = '$apiBase/?action=get_standings&league_id=$ligaId&APIkey=$_currentApiKey';
      final dados = await _makeRequest(url);

      if (dados is List) {
        _saveToCache(cacheKey, dados, _cacheDurationClassificacao);
        return dados;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar classificação: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    final cacheKey = 'jogos_liga_$ligaId';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final hoje = DateTime.now();
      final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
      final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
      final to = DateFormat('yyyy-MM-dd').format(hoje);

      final url = '$apiBase/?action=get_events&league_id=$ligaId&from=$from&to=$to&APIkey=$_currentApiKey';
      final dados = await _makeRequest(url);

      if (dados is List) {
        final jogos = dados.take(15).toList();
        _saveToCache(cacheKey, jogos, _cacheDurationJogos);
        return jogos;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar jogos da liga: $e');
      return [];
    }
  }

  // Pré-carregar dados em paralelo para páginas específicas
  Future<void> precarregarDadosHome() async {
    debugPrint('🔥 Pré-carregando dados da Home...');
    await Future.wait([
      carregarJogosDoDia(DateTime.now()),
      carregarJogosDestaque(topClubs),
    ]);
    debugPrint('✓ Dados da Home pré-carregados');
  }

  // Limpar cache manualmente se necessário
  void limparCache() {
    _cache.clear();
    debugPrint('🗑️ Cache limpo manualmente');
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}

// Classe auxiliar para cache com expiração
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool isExpired(DateTime now) => now.isAfter(expiresAt);
}