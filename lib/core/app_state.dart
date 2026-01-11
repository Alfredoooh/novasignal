import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppState with ChangeNotifier {
  // ========== CONFIGURAÇÕES DE TEMA ==========
  bool _temaEscuro = false;
  bool _temaAmoled = false;
  bool _temaEscuroProfundo = false;
  bool _corDinamica = true;
  bool _notificacoesAtivas = true;
  ThemeMode _modoTema = ThemeMode.system;

  // Estado de navegação
  String tabAtual = 'home';
  String paginaAtual = 'home';
  List<String> historicoPaginas = [];

  // Estado de produtos e categorias
  Map<String, dynamic> _ecommerceData = {};
  List<dynamic> _todasCategorias = [];
  List<dynamic> _todosProdutos = [];
  List<dynamic> _produtosDestaque = [];
  bool _isLoadingProducts = true;
  String? _errorProducts;

  // Carrinho de compras
  List<Map<String, dynamic>> _carrinho = [];
  
  // Produto selecionado
  Map<String, dynamic>? _produtoSelecionado;

  // ========== GETTERS ==========
  bool get temaEscuro => _temaEscuro;
  bool get temaAmoled => _temaAmoled;
  bool get temaEscuroProfundo => _temaEscuroProfundo;
  bool get corDinamica => _corDinamica;
  bool get notificacoesAtivas => _notificacoesAtivas;
  ThemeMode get modoTema => _modoTema;
  
  Map<String, dynamic> get ecommerceData => _ecommerceData;
  List<dynamic> get categorias => _todasCategorias;
  List<dynamic> get produtos => _todosProdutos;
  List<dynamic> get produtosDestaque => _produtosDestaque;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get errorProducts => _errorProducts;
  List<Map<String, dynamic>> get carrinho => _carrinho;
  Map<String, dynamic>? get produtoSelecionado => _produtoSelecionado;

  int get totalItensCarrinho => _carrinho.fold(0, (sum, item) => sum + (item['quantidade'] as int));
  double get totalCarrinho => _carrinho.fold(0.0, (sum, item) => 
    sum + ((item['preco'] as num) * (item['quantidade'] as int)));

  AppState() {
    _carregarPreferencias();
    _carregarProdutos();
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

      final modoTemaIndex = prefs.getInt('modo_tema') ?? 0;
      _modoTema = ThemeMode.values[modoTemaIndex];

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

  Future<void> alterarModoTema(ThemeMode novoModo) async {
    _modoTema = novoModo;

    if (novoModo == ThemeMode.dark) {
      _temaEscuro = true;
    } else if (novoModo == ThemeMode.light) {
      _temaEscuro = false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('modo_tema', novoModo.index);
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

  // ========== PRODUTOS ==========

  Future<void> _carregarProdutos() async {
    try {
      _isLoadingProducts = true;
      _errorProducts = null;
      notifyListeners();

      debugPrint('📦 Carregando produtos do JSON...');

      final String jsonString = await rootBundle.loadString('assets/products.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _ecommerceData = jsonData['ecommerce'];
      _todasCategorias = _ecommerceData['categorias'] ?? [];

      // Extrair todos os produtos de todas as categorias
      _todosProdutos = [];
      for (var categoria in _todasCategorias) {
        if (categoria['produtos'] != null) {
          for (var produto in categoria['produtos']) {
            _todosProdutos.add({
              ...produto,
              'categoria': categoria['nome'],
              'categoriaId': categoria['id'],
            });
          }
        }
      }

      // Produtos em destaque (primeiros 10)
      _produtosDestaque = _todosProdutos.take(10).toList();

      debugPrint('✅ ${_todosProdutos.length} produtos carregados');
      debugPrint('✅ ${_todasCategorias.length} categorias carregadas');

      _isLoadingProducts = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erro ao carregar produtos: $e');
      _errorProducts = e.toString();
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  List<dynamic> obterProdutosPorCategoria(int categoriaId) {
    return _todosProdutos.where((produto) => produto['categoriaId'] == categoriaId).toList();
  }

  Map<String, dynamic>? obterProdutoPorId(int produtoId) {
    try {
      return _todosProdutos.firstWhere((produto) => produto['id'] == produtoId);
    } catch (e) {
      return null;
    }
  }

  void setProdutoSelecionado(Map<String, dynamic>? produto) {
    _produtoSelecionado = produto;
    notifyListeners();
  }

  List<dynamic> pesquisarProdutos(String termo) {
    if (termo.isEmpty) return _todosProdutos;

    final termoLower = termo.toLowerCase();
    return _todosProdutos.where((produto) {
      final nome = (produto['nome'] ?? '').toString().toLowerCase();
      final marca = (produto['marca'] ?? '').toString().toLowerCase();
      final descricao = (produto['descricao'] ?? '').toString().toLowerCase();
      final categoria = (produto['categoria'] ?? '').toString().toLowerCase();

      return nome.contains(termoLower) ||
             marca.contains(termoLower) ||
             descricao.contains(termoLower) ||
             categoria.contains(termoLower);
    }).toList();
  }

  // ========== CARRINHO ==========

  void adicionarAoCarrinho(Map<String, dynamic> produto, {int quantidade = 1}) {
    final index = _carrinho.indexWhere((item) => item['id'] == produto['id']);

    if (index != -1) {
      _carrinho[index]['quantidade'] += quantidade;
    } else {
      _carrinho.add({
        'id': produto['id'],
        'nome': produto['nome'],
        'preco': produto['preco'],
        'imagem': produto['imagem'],
        'marca': produto['marca'],
        'quantidade': quantidade,
      });
    }

    notifyListeners();
    debugPrint('🛒 ${produto['nome']} adicionado ao carrinho');
  }

  void removerDoCarrinho(int produtoId) {
    _carrinho.removeWhere((item) => item['id'] == produtoId);
    notifyListeners();
    debugPrint('🗑️ Produto removido do carrinho');
  }

  void atualizarQuantidade(int produtoId, int novaQuantidade) {
    if (novaQuantidade <= 0) {
      removerDoCarrinho(produtoId);
      return;
    }

    final index = _carrinho.indexWhere((item) => item['id'] == produtoId);
    if (index != -1) {
      _carrinho[index]['quantidade'] = novaQuantidade;
      notifyListeners();
    }
  }

  void limparCarrinho() {
    _carrinho.clear();
    notifyListeners();
    debugPrint('🗑️ Carrinho limpo');
  }

  // ========== UTILIDADES ==========

  Future<void> recarregarProdutos() async {
    await _carregarProdutos();
  }
}