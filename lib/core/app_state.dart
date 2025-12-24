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

  // HTTP Client reutilizável
  final http.Client _httpClient = http.Client();

  // Getters para configurações
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get notificacoesAtivas => _notificacoesAtivas;

  // ========== CLOUDFLARE API CONFIGURATION ==========
  static const String cloudflareBase = 'https://dawn-sun-590a.alfredopjonas.workers.dev';

  // ========== NEWS API CONFIGURATION ==========
  static const String newsApiKey = 'b2e4d59068e545abbdffaf947c371bcd';
  static const String newsApiBase = 'https://newsapi.org/v2';

  // Cache de duração por tipo de requisição (em minutos)
  static const int _cacheDurationJogos = 2;
  static const int _cacheDurationDetalhes = 1;
  static const int _cacheDurationLigas = 60;
  static const int _cacheDurationClassificacao = 30;
  static const int _cacheDurationNews = 30;

  // Top clubs para jogos em destaque
  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  // Map para controlar requisições em andamento
  final Map<String, Future<dynamic>> _pendingRequests = {};

  AppState() {
    _carregarPreferencias();
    _startCacheCleanup();
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

  // ========== MÉTODOS DE CACHE ==========

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

  // ========== MÉTODOS DE API CLOUDFLARE ==========

  Future<dynamic> _makeCloudflareRequest(String endpoint) async {
    // Verifica se já existe uma requisição em andamento
    if (_pendingRequests.containsKey(endpoint)) {
      debugPrint('⏳ Requisição já em andamento, aguardando...');
      return await _pendingRequests[endpoint]!;
    }

    // Cria a requisição e armazena como pendente
    final requestFuture = _executeCloudflareRequest(endpoint);
    _pendingRequests[endpoint] = requestFuture;

    try {
      final result = await requestFuture;
      return result;
    } finally {
      _pendingRequests.remove(endpoint);
    }
  }

  Future<dynamic> _executeCloudflareRequest(String endpoint) async {
    try {
      final url = '$cloudflareBase$endpoint';
      debugPrint('🚀 Cloudflare Request: $url');

      final response = await _httpClient.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se há erro na resposta
        if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }

        return data;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('✗ Erro na requisição Cloudflare: $e');
      rethrow;
    }
  }

  // ========== MÉTODOS DE NEWS API ==========

  Future<List<Map<String, dynamic>>> carregarNoticias() async {
    const cacheKey = 'noticias_sports';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return List<Map<String, dynamic>>.from(cached);

    try {
      final url = '$newsApiBase/top-headlines?category=sports&language=pt&apiKey=$newsApiKey';
      debugPrint('🚀 News API Request: $url');

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

          _saveToCache(cacheKey, noticias, _cacheDurationNews);
          debugPrint('✓ ${noticias.length} notícias carregadas');
          return noticias;
        }
      }

      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar notícias: $e');
      return [];
    }
  }

  String _formatNewsDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'Há ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Há ${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return 'Há ${difference.inDays}d';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  // ========== MÉTODOS PRINCIPAIS ==========

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      // Busca todos os jogos do Cloudflare
      final response = await _makeCloudflareRequest('/api/matches');

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        // Filtra por data
        final jogosDoDia = todosJogos.where((jogo) {
          final matchDate = jogo['match_date'] ?? '';
          return matchDate == dataStr;
        }).toList();

        debugPrint('✓ ${jogosDoDia.length} jogos encontrados para $dataStr');
        _saveToCache(cacheKey, jogosDoDia, _cacheDurationJogos);
        return jogosDoDia;
      }

      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar jogos: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    final cacheKey = 'destaque_jogos';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final response = await _makeCloudflareRequest('/api/matches');

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        // Filtra jogos com times populares
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
      final response = await _makeCloudflareRequest('/api/matches');

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

        debugPrint('✓ ${resultados.length} resultados para "$termo"');
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
      final response = await _makeCloudflareRequest('/api/matches/$jogoId');

      if (response != null && response is! Map) {
        _saveToCache(cacheKey, response, _cacheDurationDetalhes);
        return response;
      } else if (response is Map && !response.containsKey('error')) {
        _saveToCache(cacheKey, response, _cacheDurationDetalhes);
        return response;
      }

      return null;
    } catch (e) {
      debugPrint('✗ Erro ao carregar detalhes: $e');
      return null;
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
      final response = await _makeCloudflareRequest('/api/matches');

      if (response is Map && response.containsKey('matches')) {
        final todosJogos = response['matches'] as List<dynamic>;

        // Extrai ligas únicas dos jogos
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
      // Busca jogos da liga e calcula classificação manualmente
      final jogosLiga = await carregarJogosPorLiga(ligaId);

      // Aqui você pode implementar lógica para calcular classificação
      // baseado nos resultados dos jogos, ou retornar vazio se não tiver
      // essa funcionalidade no Cloudflare

      _saveToCache(cacheKey, [], _cacheDurationClassificacao);
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar classificação: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarJogosPorLiga(String ligaId) async {
    final cacheKey = 'jogos_liga_$ligaId';

    final cached = _getFromCache(cacheKey);
    if (cached != null) return cached as List<dynamic>;

    try {
      final response = await _makeCloudflareRequest('/api/matches/league?league_id=$ligaId');

      if (response is Map && response.containsKey('matches')) {
        final jogos = response['matches'] as List<dynamic>;
        debugPrint('✓ ${jogos.length} jogos da liga $ligaId');
        _saveToCache(cacheKey, jogos, _cacheDurationJogos);
        return jogos;
      }
      return [];
    } catch (e) {
      debugPrint('✗ Erro ao carregar jogos da liga: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    return carregarJogosPorLiga(ligaId);
  }

  // Pré-carregar dados em paralelo
  Future<void> precarregarDadosHome() async {
    debugPrint('🔥 Pré-carregando dados da Home...');
    await Future.wait([
      carregarJogosDoDia(DateTime.now()),
      carregarJogosDestaque(topClubs),
      carregarNoticias(),
    ]);
    debugPrint('✓ Dados da Home pré-carregados');
  }

  // Limpar cache manualmente
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