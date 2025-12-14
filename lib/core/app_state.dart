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

  // API football-data.org
  static const String apiKey = '81e164bfa4364ff783bc397c30f39627';
  static const String apiBase = 'https://api.football-data.org/v4';

  AppState() {
    _carregarConfiguracoes();
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

  Map<String, String> get _headers => {
    'X-Auth-Token': apiKey,
  };

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para $cacheKey');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/matches?date=$dataStr';
      debugPrint('Buscando jogos: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Timeout ao buscar jogos'),
      );

      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);

        if (dados['matches'] != null && dados['matches'] is List) {
          final jogos = (dados['matches'] as List).map((item) => _converterJogo(item)).toList();
          debugPrint('Encontrados ${jogos.length} jogos');
          cache[cacheKey] = jogos;
          return jogos;
        }

        debugPrint('Formato inesperado de resposta');
        return [];
      } else {
        debugPrint('Erro HTTP: ${response.statusCode}');
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar jogos: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    final hoje = DateTime.now();
    final dataStr = DateFormat('yyyy-MM-dd').format(hoje);
    final cacheKey = 'destaque_$dataStr';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para destaques');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      // Buscar jogos das principais ligas
      final ligas = ['PL', 'PD', 'BL1', 'SA', 'FL1', 'CL']; // Premier League, La Liga, Bundesliga, Serie A, Ligue 1, Champions
      List<dynamic> todosJogos = [];

      for (var ligaCode in ligas) {
        final url = '$apiBase/competitions/$ligaCode/matches?status=SCHEDULED,LIVE,IN_PLAY,PAUSED,FINISHED';
        try {
          final response = await http.get(Uri.parse(url), headers: _headers).timeout(
            const Duration(seconds: 10),
          );

          if (response.statusCode == 200) {
            final dados = json.decode(response.body);
            if (dados['matches'] != null && dados['matches'] is List) {
              final matches = dados['matches'] as List;
              // Pegar apenas jogos de hoje ou próximos 2 dias
              final jogosRecentes = matches.where((match) {
                final utcDate = DateTime.parse(match['utcDate']);
                final diff = utcDate.difference(hoje).inDays;
                return diff >= -1 && diff <= 2;
              }).take(3);
              todosJogos.addAll(jogosRecentes.map((item) => _converterJogo(item)));
            }
          }
        } catch (e) {
          debugPrint('Erro ao buscar liga $ligaCode: $e');
          continue;
        }
      }

      debugPrint('Encontrados ${todosJogos.length} jogos em destaque');
      cache[cacheKey] = todosJogos;
      return todosJogos;
    } catch (e) {
      debugPrint('Erro ao carregar destaques: $e');
      return [];
    }
  }

  Future<List<dynamic>> pesquisarJogos(String termo) async {
    final termoLower = termo.toLowerCase();
    final cacheKey = 'search_$termoLower';

    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para pesquisa');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final hoje = DateTime.now();
      final dataInicio = DateFormat('yyyy-MM-dd').format(hoje.subtract(const Duration(days: 3)));
      final dataFim = DateFormat('yyyy-MM-dd').format(hoje.add(const Duration(days: 7)));
      final url = '$apiBase/matches?dateFrom=$dataInicio&dateTo=$dataFim';
      
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);

        if (dados['matches'] != null && dados['matches'] is List) {
          final jogos = (dados['matches'] as List).map((item) => _converterJogo(item)).toList();
          final resultados = jogos.where((jogo) {
            final home = (jogo['match_hometeam_name'] ?? '').toString().toLowerCase();
            final away = (jogo['match_awayteam_name'] ?? '').toString().toLowerCase();
            final league = (jogo['league_name'] ?? '').toString().toLowerCase();
            return home.contains(termoLower) || away.contains(termoLower) || league.contains(termoLower);
          }).toList();

          debugPrint('Encontrados ${resultados.length} resultados');
          cache[cacheKey] = resultados;
          return resultados;
        }
        return [];
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
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
      final url = '$apiBase/matches/$jogoId';
      debugPrint('Buscando detalhes: $url');

      final response = await http.get(Uri.parse(url), headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        final jogo = _converterJogoDetalhado(dados);
        cache[cacheKey] = jogo;
        return jogo;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
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
      final url = '$apiBase/competitions';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados['competitions'] != null && dados['competitions'] is List) {
          todasLigas = (dados['competitions'] as List).map((item) => {
            'league_id': item['id'].toString(),
            'league_name': item['name'],
            'league_logo': item['emblem'] ?? '',
            'country_name': item['area']['name'],
            'league_code': item['code'],
          }).toList();
          cache[cacheKey] = todasLigas;
          return todasLigas;
        }
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
      final url = '$apiBase/competitions/$ligaId/standings';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados['standings'] != null && dados['standings'] is List && dados['standings'].isNotEmpty) {
          final standings = dados['standings'][0]['table'] as List;
          final classificacao = standings.map((item) => {
            'overall_league_position': item['position'].toString(),
            'team_name': item['team']['name'],
            'team_badge': item['team']['crest'] ?? '',
            'overall_league_payed': item['playedGames'],
            'overall_league_PTS': item['points'],
          }).toList();
          cache[cacheKey] = classificacao;
          return classificacao;
        }
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
      final url = '$apiBase/competitions/$ligaId/matches?status=FINISHED';
      final response = await http.get(Uri.parse(url), headers: _headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados['matches'] != null && dados['matches'] is List) {
          final jogos = (dados['matches'] as List).take(15).map((item) => _converterJogo(item)).toList();
          cache[cacheKey] = jogos;
          return jogos;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao carregar jogos da liga: $e');
      return [];
    }
  }

  Map<String, dynamic> _converterJogo(dynamic item) {
    final homeTeam = item['homeTeam'];
    final awayTeam = item['awayTeam'];
    final score = item['score'];
    final competition = item['competition'];
    final utcDate = DateTime.parse(item['utcDate']);
    final localDate = utcDate.toLocal();

    return {
      'match_id': item['id'].toString(),
      'match_date': DateFormat('dd/MM/yyyy').format(localDate),
      'match_time': DateFormat('HH:mm').format(localDate),
      'match_status': _converterStatus(item['status']),
      'match_hometeam_name': homeTeam['name'],
      'match_awayteam_name': awayTeam['name'],
      'match_hometeam_score': score['fullTime']['home']?.toString() ?? '-',
      'match_awayteam_score': score['fullTime']['away']?.toString() ?? '-',
      'team_home_badge': homeTeam['crest'] ?? '',
      'team_away_badge': awayTeam['crest'] ?? '',
      'league_name': competition['name'],
      'league_id': competition['id'].toString(),
      'goalscorer': [],
      'cards': [],
      'statistics': [],
    };
  }

  Map<String, dynamic> _converterJogoDetalhado(dynamic item) {
    final jogo = _converterJogo(item);
    
    // Adicionar gols se disponível
    if (item['goals'] != null && item['goals'] is List) {
      jogo['goalscorer'] = (item['goals'] as List).map((goal) => {
        'time': goal['minute']?.toString() ?? '?',
        'home_scorer': goal['team']['id'] == item['homeTeam']['id'] ? goal['scorer']['name'] : null,
        'away_scorer': goal['team']['id'] == item['awayTeam']['id'] ? goal['scorer']['name'] : null,
      }).toList();
    }

    // Adicionar cartões se disponível
    if (item['bookings'] != null && item['bookings'] is List) {
      jogo['cards'] = (item['bookings'] as List).map((card) => {
        'time': card['minute']?.toString() ?? '?',
        'card': card['card'] == 'YELLOW_CARD' ? 'yellow card' : 'red card',
        'home_fault': card['team']['id'] == item['homeTeam']['id'] ? card['player']['name'] : null,
        'away_fault': card['team']['id'] == item['awayTeam']['id'] ? card['player']['name'] : null,
      }).toList();
    }

    return jogo;
  }

  String _converterStatus(String status) {
    switch (status) {
      case 'SCHEDULED': return 'Agendado';
      case 'TIMED': return 'Agendado';
      case 'IN_PLAY': return 'LIVE';
      case 'PAUSED': return 'HT';
      case 'FINISHED': return 'Terminado';
      case 'POSTPONED': return 'Adiado';
      case 'CANCELLED': return 'Cancelado';
      case 'SUSPENDED': return 'Suspenso';
      case 'AWARDED': return 'Decidido';
      default: return status;
    }
  }
}