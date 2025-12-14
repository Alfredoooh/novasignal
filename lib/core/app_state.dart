import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  String tabAtual = 'home';
  String paginaAtual = 'home';
  List<String> historicoPaginas = [];
  String filtroJogos = 'hoje';
  DateTime dataSelecionada = DateTime.now();
  bool temaEscuro = false;
  bool notificacoesAtivas = true;

  Map<String, dynamic> cache = {};
  String jogoDetalhesId = '';
  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = '';
  List<dynamic> todasLigas = [];

  // Multiple API keys for fallback
  static const List<String> apiKeys = [
    '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d',
    '5fbf446f332cdcb25ae37e36e1d7edeb55f7a47c7b30f34a8fe23da37f8d6ac0',
  ];
  int _currentApiKeyIndex = 0;
  static const String apiBase = 'https://apiv3.apifootball.com';

  // Top clubs for featured matches
  final List<String> topClubs = [
    'Manchester United', 'Manchester City', 'Liverpool', 'Chelsea', 'Arsenal',
    'Real Madrid', 'Barcelona', 'Atletico Madrid',
    'Bayern Munich', 'Borussia Dortmund',
    'Juventus', 'Inter', 'AC Milan',
    'PSG', 'Lyon', 'Marseille',
  ];

  AppState() {
    _carregarConfiguracoes();
  }

  String get _currentApiKey => apiKeys[_currentApiKeyIndex];

  void _rotateApiKey() {
    _currentApiKeyIndex = (_currentApiKeyIndex + 1) % apiKeys.length;
    debugPrint('Rotating to API key index: $_currentApiKeyIndex');
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

  Future<void> _carregarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      temaEscuro = prefs.getBool('temaEscuro') ?? false;
      notificacoesAtivas = prefs.getBool('notificacoesAtivas') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }

  Future<void> _salvarConfiguracoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('temaEscuro', temaEscuro);
      await prefs.setBool('notificacoesAtivas', notificacoesAtivas);
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
    }
  }

  Future<dynamic> _makeRequest(String url, {int retryCount = 0}) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 429 || response.statusCode == 403) {
        // Rate limit or forbidden, try next API key
        if (retryCount < apiKeys.length - 1) {
          _rotateApiKey();
          return await _makeRequest(url.replaceAll(apiKeys[retryCount], _currentApiKey), retryCount: retryCount + 1);
        }
      }
      throw Exception('Erro ${response.statusCode}');
    } catch (e) {
      if (retryCount < apiKeys.length - 1) {
        _rotateApiKey();
        return await _makeRequest(url.replaceAll(apiKeys[retryCount], _currentApiKey), retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para $cacheKey');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/?action=get_events&from=$dataStr&to=$dataStr&APIkey=$_currentApiKey';
      debugPrint('Buscando jogos: $url');

      final dados = await _makeRequest(url);

      if (dados is Map && dados.containsKey('error')) {
        throw Exception(dados['error']);
      }

      if (dados is List) {
        debugPrint('Encontrados ${dados.length} jogos');
        cache[cacheKey] = dados;
        return dados;
      }

      return [];
    } catch (e) {
      debugPrint('Erro ao carregar jogos: $e');
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

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para destaques');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$_currentApiKey';
      debugPrint('Buscando destaques: $url');

      final dados = await _makeRequest(url);

      if (dados is List) {
        final jogosFiltrados = dados.where((jogo) {
          final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
          final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
          return topClubs.any((team) => 
            home.contains(team.toLowerCase()) || 
            away.contains(team.toLowerCase())
          );
        }).toList();

        // Sort by status priority (live > scheduled > finished)
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
        debugPrint('Encontrados ${limitedJogos.length} jogos em destaque');
        cache[cacheKey] = limitedJogos;
        return limitedJogos;
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar destaques: $e');
      return [];
    }
  }

  Future<List<dynamic>> pesquisarJogos(String termo) async {
    final termoLower = termo.toLowerCase();
    
    try {
      final hoje = DateTime.now();
      final seteDiasAtras = hoje.subtract(const Duration(days: 7));
      final seteDiasFrente = hoje.add(const Duration(days: 7));
      final from = DateFormat('yyyy-MM-dd').format(seteDiasAtras);
      final to = DateFormat('yyyy-MM-dd').format(seteDiasFrente);

      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$_currentApiKey';
      debugPrint('Pesquisando: $url');

      final dados = await _makeRequest(url);

      if (dados is List) {
        final resultados = dados.where((jogo) {
          final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
          final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
          final league = (jogo['league_name'] ?? '').toString().toLowerCase();
          return home.contains(termoLower) || away.contains(termoLower) || league.contains(termoLower);
        }).toList();

        debugPrint('Encontrados ${resultados.length} resultados');
        return resultados;
      }
      return [];
    } catch (e) {
      debugPrint('Erro na pesquisa: $e');
      return [];
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final cacheKey = 'detalhes_$jogoId';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para detalhes');
      return cache[cacheKey];
    }

    try {
      final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$_currentApiKey';
      debugPrint('Buscando detalhes: $url');

      final dados = await _makeRequest(url);

      if (dados is List && dados.isNotEmpty) {
        cache[cacheKey] = dados[0];
        return dados[0];
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao carregar detalhes: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> carregarLigas() async {
    const cacheKey = 'ligas_todas';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para ligas');
      todasLigas = cache[cacheKey] as List<dynamic>;
      return todasLigas;
    }

    try {
      final url = '$apiBase/?action=get_leagues&APIkey=$_currentApiKey';
      final dados = await _makeRequest(url);

      if (dados is List) {
        todasLigas = dados;
        cache[cacheKey] = todasLigas;
        return todasLigas;
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar ligas: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';

    if (cache.containsKey(cacheKey)) {
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/?action=get_standings&league_id=$ligaId&APIkey=$_currentApiKey';
      final dados = await _makeRequest(url);

      if (dados is List) {
        cache[cacheKey] = dados;
        return dados;
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar classificação: $e');
      return [];
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    final cacheKey = 'jogos_liga_$ligaId';

    if (cache.containsKey(cacheKey)) {
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final hoje = DateTime.now();
      final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
      final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
      final to = DateFormat('yyyy-MM-dd').format(hoje);
      
      final url = '$apiBase/?action=get_events&league_id=$ligaId&from=$from&to=$to&APIkey=$_currentApiKey';
      final dados = await _makeRequest(url);

      if (dados is List) {
        final jogos = dados.take(15).toList();
        cache[cacheKey] = jogos;
        return jogos;
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar jogos da liga: $e');
      return [];
    }
  }
}