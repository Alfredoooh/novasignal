import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  String tabAtual = 'jogos';
  String paginaAtual = 'jogos';
  List<String> historicoPaginas = [];
  String filtroJogos = 'hoje';
  DateTime dataSelecionada = DateTime.now();
  bool temaEscuro = false;
  bool notificacoesAtivas = true;
  bool atualizacaoTempoReal = true;

  Map<String, List<dynamic>> jogosCache = {};
  List<dynamic>? ligasCache;
  Map<String, List<dynamic>> classificacoesCache = {};
  Map<String, List<dynamic>> pesquisasCache = {};

  List<dynamic> todasLigas = [];
  List<dynamic> jogosHoje = [];
  bool ligasCarregadas = false;

  Timer? intervaloAtualizacao;
  Timer? timeoutPesquisa;

  String ligaDetalhesId = '';
  String ligaDetalhesTitulo = 'Liga';
  String jogoDetalhesId = '';
  String jogoDetalhesTitulo = 'Detalhes';

  static const String apiKey = '9aa85892f684f5b1f85a721e6d625df4be9065447047e065f42c211658c7cd7d';
  static const String apiBase = 'https://apiv3.apifootball.com';

  AppState() {
    _carregarConfiguracoes();
    _iniciarAtualizacaoTempoReal();
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

  void alternarAtualizacaoTempoReal(bool value) {
    atualizacaoTempoReal = value;
    _salvarConfiguracoes();
    if (atualizacaoTempoReal) {
      _iniciarAtualizacaoTempoReal();
    } else {
      _pararAtualizacaoTempoReal();
    }
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

  void setLigaDetalhes(String id, String titulo) {
    ligaDetalhesId = id;
    ligaDetalhesTitulo = titulo;
  }

  void setJogoDetalhes(String id, String titulo) {
    jogoDetalhesId = id;
    jogoDetalhesTitulo = titulo;
  }

  void _iniciarAtualizacaoTempoReal() {
    _pararAtualizacaoTempoReal();
    if (!atualizacaoTempoReal) return;
    intervaloAtualizacao = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (paginaAtual == 'jogos' && filtroJogos == 'direto') {
        notifyListeners();
      }
    });
  }

  void _pararAtualizacaoTempoReal() {
    intervaloAtualizacao?.cancel();
    intervaloAtualizacao = null;
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    temaEscuro = prefs.getBool('temaEscuro') ?? false;
    notificacoesAtivas = prefs.getBool('notificacoesAtivas') ?? true;
    atualizacaoTempoReal = prefs.getBool('atualizacaoTempoReal') ?? true;
    notifyListeners();
  }

  Future<void> _salvarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('temaEscuro', temaEscuro);
    prefs.setBool('notificacoesAtivas', notificacoesAtivas);
    prefs.setBool('atualizacaoTempoReal', atualizacaoTempoReal);
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
      jogosHoje = dados;
      return dados;
    } else {
      throw Exception('Failed to load jogos');
    }
  }

  Future<List<dynamic>> carregarLigas() async {
    if (ligasCache != null) {
      return ligasCache!;
    }
    final url = '$apiBase/?action=get_leagues&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      ligasCache = dados;
      todasLigas = dados;
      ligasCarregadas = true;
      return dados;
    } else {
      throw Exception('Failed to load ligas');
    }
  }

  Future<List<dynamic>> carregarClassificacao(String ligaId) async {
    final cacheKey = 'classificacao_$ligaId';
    if (classificacoesCache.containsKey(cacheKey)) {
      return classificacoesCache[cacheKey]!;
    }
    final url = '$apiBase/?action=get_standings&league_id=$ligaId&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      classificacoesCache[cacheKey] = dados;
      return dados;
    } else {
      throw Exception('Failed to load classificacao');
    }
  }

  Future<List<dynamic>> carregarUltimosJogosLiga(String ligaId) async {
    final hoje = DateTime.now();
    final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
    final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(hoje);
    final url = '$apiBase/?action=get_events&league_id=$ligaId&from=$from&to=$to&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return dados.reversed.toList();
    } else {
      throw Exception('Failed to load jogos liga');
    }
  }

  Future<dynamic> carregarJogoDetalhes(String jogoId) async {
    final url = '$apiBase/?action=get_events&match_id=$jogoId&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      return dados.isNotEmpty ? dados[0] : null;
    } else {
      throw Exception('Failed to load jogo detalhes');
    }
  }

  Future<List<dynamic>> executarPesquisa(String termo) async {
    final termoLower = termo.toLowerCase();
    final cacheKey = 'pesquisa_$termoLower';
    if (pesquisasCache.containsKey(cacheKey)) {
      return pesquisasCache[cacheKey]!;
    }
    final hoje = DateTime.now();
    final trintaDiasAtras = hoje.subtract(const Duration(days: 30));
    final from = DateFormat('yyyy-MM-dd').format(trintaDiasAtras);
    final to = DateFormat('yyyy-MM-dd').format(hoje);
    final url = '$apiBase/?action=get_events&from=$from&to=$to&APIkey=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dados = json.decode(response.body);
      final resultados = dados.where((jogo) {
        final hometeam = (jogo['match_hometeam_name'] ?? '').toLowerCase().contains(termoLower);
        final awayteam = (jogo['match_awayteam_name'] ?? '').toLowerCase().contains(termoLower);
        final league = (jogo['league_name'] ?? '').toLowerCase().contains(termoLower);
        final country = (jogo['country_name'] ?? '').toLowerCase().contains(termoLower);
        return hometeam || awayteam || league || country;
      }).toList();
      pesquisasCache[cacheKey] = resultados;
      return resultados;
    } else {
      throw Exception('Failed to search');
    }
  }
}