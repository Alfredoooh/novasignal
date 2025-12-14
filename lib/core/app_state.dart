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

  static const String apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
  static const String apiBase = 'https://apiv3.apifootball.com';

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

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';
    
    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para $cacheKey');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/?action=get_events&from=$dataStr&to=$dataStr&APIkey=$apiKey';
      debugPrint('Buscando jogos: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout ao buscar jogos'),
      );

      debugPrint('Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        
        if (dados is Map && dados.containsKey('error')) {
          debugPrint('Erro da API: ${dados['error']}');
          throw Exception(dados['error']);
        }
        
        if (dados is List) {
          debugPrint('Encontrados ${dados.length} jogos');
          cache[cacheKey] = dados;
          return dados;
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
    final doisDiasAtras = hoje.subtract(const Duration(days: 2));
    final cincoDiasFrente = hoje.add(const Duration(days: 5));
    final from = DateFormat('yyyy-MM-dd').format(doisDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(cincoDiasFrente);
    
    final cacheKey = 'destaque_$from\_$to';
    
    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para destaques');
      return cache[cacheKey] as List<dynamic>;
    }

    try {
      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$apiKey';
      debugPrint('Buscando destaques: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout ao buscar destaques'),
      );

      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        
        if (dados is List) {
          final jogosFiltrados = dados.where((jogo) {
            final home = (jogo['match_hometeam_name'] ?? '').toString();
            final away = (jogo['match_awayteam_name'] ?? '').toString();
            return topTeams.any((team) => 
              home.toLowerCase().contains(team.toLowerCase()) || 
              away.toLowerCase().contains(team.toLowerCase())
            );
          }).toList();

          jogosFiltrados.sort((a, b) {
            final aHasRealMadrid = 
              (a['match_hometeam_name'] ?? '').toString().toLowerCase().contains('real madrid') ||
              (a['match_awayteam_name'] ?? '').toString().toLowerCase().contains('real madrid');
            final bHasRealMadrid = 
              (b['match_hometeam_name'] ?? '').toString().toLowerCase().contains('real madrid') ||
              (b['match_awayteam_name'] ?? '').toString().toLowerCase().contains('real madrid');
            
            if (aHasRealMadrid && !bHasRealMadrid) return -1;
            if (!aHasRealMadrid && bHasRealMadrid) return 1;
            return 0;
          });

          debugPrint('Encontrados ${jogosFiltrados.length} jogos em destaque');
          cache[cacheKey] = jogosFiltrados;
          return jogosFiltrados;
        }
        return [];
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar destaques: $e');
      rethrow;
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
      final seteDiasAtras = hoje.subtract(const Duration(days: 7));
      final seteDiasFrente = hoje.add(const Duration(days: 7));
      final from = DateFormat('yyyy-MM-dd').format(seteDiasAtras);
      final to = DateFormat('yyyy-MM-dd').format(seteDiasFrente);

      final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$apiKey';
      debugPrint('Pesquisando: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout na pesquisa'),
      );
      
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        
        if (dados is List) {
          final resultados = dados.where((jogo) {
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
      rethrow;
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final cacheKey = 'detalhes_$jogoId';
    
    if (cache.containsKey(cacheKey)) {
      debugPrint('Usando cache para detalhes');
      return cache[cacheKey];
    }

    try {
      final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$apiKey';
      debugPrint('Buscando detalhes: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout ao buscar detalhes'),
      );
      
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        
        if (dados is List && dados.isNotEmpty) {
          cache[cacheKey] = dados[0];
          return dados[0];
        }
        return null;
      } else {
        throw Exception('Erro ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar detalhes: $e');
      rethrow;
    }
  }
}