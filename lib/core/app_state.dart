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

  Map<String, List<dynamic>> jogosCache = {};
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
    final prefs = await SharedPreferences.getInstance();
    temaEscuro = prefs.getBool('temaEscuro') ?? false;
    notificacoesAtivas = prefs.getBool('notificacoesAtivas') ?? true;
    notifyListeners();
  }

  Future<void> _salvarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('temaEscuro', temaEscuro);
    prefs.setBool('notificacoesAtivas', notificacoesAtivas);
  }

  Future<List<dynamic>> carregarJogosDoDia(DateTime data) async {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    final cacheKey = 'jogos_$dataStr';
    if (jogosCache.containsKey(cacheKey)) {
      return jogosCache[cacheKey]!;
    }
    final url = '$apiBase/?action=get_events&from=$dataStr&to=$dataStr&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      jogosCache[cacheKey] = dados;
      return dados;
    }
    return [];
  }

  Future<List<dynamic>> carregarJogosDestaque(List<String> topTeams) async {
    final hoje = DateTime.now();
    final doisDiasAtras = hoje.subtract(const Duration(days: 2));
    final cincoDiasFrente = hoje.add(const Duration(days: 5));
    final from = DateFormat('yyyy-MM-dd').format(doisDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(cincoDiasFrente);
    
    final cacheKey = 'destaque_$from\_$to';
    if (jogosCache.containsKey(cacheKey)) {
      return jogosCache[cacheKey]!;
    }

    final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      
      // Filtrar jogos de times grandes
      final jogosFiltrados = dados.where((jogo) {
        final home = jogo['match_hometeam_name'] ?? '';
        final away = jogo['match_awayteam_name'] ?? '';
        return topTeams.any((team) => home.contains(team) || away.contains(team));
      }).toList();

      // Ordenar: Real Madrid primeiro, depois outros
      jogosFiltrados.sort((a, b) {
        final aHasRealMadrid = (a['match_hometeam_name'] ?? '').contains('Real Madrid') ||
                               (a['match_awayteam_name'] ?? '').contains('Real Madrid');
        final bHasRealMadrid = (b['match_hometeam_name'] ?? '').contains('Real Madrid') ||
                               (b['match_awayteam_name'] ?? '').contains('Real Madrid');
        
        if (aHasRealMadrid && !bHasRealMadrid) return -1;
        if (!aHasRealMadrid && bHasRealMadrid) return 1;
        return 0;
      });

      jogosCache[cacheKey] = jogosFiltrados;
      return jogosFiltrados;
    }
    return [];
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return dados.isNotEmpty ? dados[0] : null;
    }
    return null;
  }
}