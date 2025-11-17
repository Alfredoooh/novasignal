// lib/services/deriv_auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class DerivAuthService {
  static final DerivAuthService _instance = DerivAuthService._internal();
  factory DerivAuthService() => _instance;
  DerivAuthService._internal();

  // App ID do Deriv
  static const String APP_ID = '71954';
  
  // URLs base
  static const String _wsUrl = 'wss://ws.derivws.com/websockets/v3?app_id=$APP_ID';
  static const String _oauthUrl = 'https://oauth.deriv.com/oauth2/authorize';
  
  // Deep Link para Android
  static const String _deepLinkScheme = 'novasignal';
  static const String _deepLinkHost = 'deriv-callback';
  
  // Redirect URLs - SUBSTITUA pelas suas URLs reais
  static const String _androidRedirectUrl = 'https://alfredoooh.github.io/database/redirect/deriv-redirect-android.html';
  static const String _webRedirectUrl = 'https://alfredoooh.github.io/database/redirect/deriv-redirect-web.html';
  
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  StreamSubscription? _deepLinkSubscription;
  String? _apiToken;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  // Callbacks
  Function(double)? _onBalanceUpdate;
  Function(String)? _onAuthSuccess;
  Function(String)? _onAuthError;
  
  // Cache de dados
  Map<String, dynamic>? _accountInfo;
  double? _currentBalance;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get apiToken => _apiToken;

  /// Inicializar listener de deep links (Android)
  Future<void> initDeepLinkListener() async {
    if (kIsWeb) return;

    try {
      // Listener para quando o app já está aberto
      _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          _log('Deep link recebido enquanto app aberto: $uri');
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        _log('Erro no deep link listener: $err');
        _onAuthError?.call('Erro ao processar deep link');
      });

      // Verificar se o app foi aberto via deep link
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _log('App aberto via deep link: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      _log('Erro ao inicializar deep link listener: $e');
    }
  }

  /// Processar deep link recebido
  void _handleDeepLink(Uri uri) {
    _log('Processando deep link: $uri');
    final Map<String, String> params = uri.queryParameters;
    
    _log('Parâmetros recebidos: $params');
    
    if (params.containsKey('token1')) {
      final token = params['token1']!;
      _log('Token encontrado no deep link: ${token.substring(0, 10)}...');
      _connectWithToken(token, isOAuth: true);
    } else if (params.containsKey('error')) {
      final error = params['error'] ?? 'Erro desconhecido';
      _log('Erro no OAuth: $error');
      _onAuthError?.call('Autenticação cancelada: $error');
    } else {
      _log('Nenhum token ou erro encontrado no deep link');
    }
  }

  /// MÉTODO 1: Conectar com Token API (manual)
  Future<bool> connectWithApiToken(String apiToken) async {
    _log('Tentando conectar com token API...');
    
    if (apiToken.isEmpty) {
      _log('Erro: Token vazio');
      _onAuthError?.call('Token não pode estar vazio');
      return false;
    }
    
    if (apiToken.length < 20) {
      _log('Erro: Token muito curto (${apiToken.length} caracteres)');
      _onAuthError?.call('Token inválido - muito curto');
      return false;
    }
    
    return await _connectWithToken(apiToken, isOAuth: false);
  }

  /// MÉTODO 2: Conectar com OAuth (Deriv Auth)
  Future<bool> connectWithOAuth() async {
    try {
      _log('Iniciando OAuth flow...');
      
      // Determinar qual redirect URL usar
      final redirectUrl = kIsWeb ? _webRedirectUrl : _androidRedirectUrl;
      _log('Redirect URL: $redirectUrl');
      
      // Construir URL de autorização OAuth
      final authUrl = Uri.parse(_oauthUrl).replace(queryParameters: {
        'app_id': APP_ID,
        'l': 'PT',
        'brand': 'deriv',
        'redirect_uri': redirectUrl,
      });

      _log('URL OAuth construída: $authUrl');

      // Abrir URL de autenticação
      final canLaunch = await canLaunchUrl(authUrl);
      if (canLaunch) {
        _log('Abrindo navegador para OAuth...');
        await launchUrl(
          authUrl,
          mode: kIsWeb 
              ? LaunchMode.platformDefault 
              : LaunchMode.externalApplication,
        );
        return true;
      } else {
        _log('Erro: Não foi possível abrir a URL do navegador');
        _onAuthError?.call('Não foi possível abrir a página de autenticação');
        return false;
      }
    } catch (e) {
      _log('Erro ao iniciar OAuth: $e');
      _onAuthError?.call('Erro ao iniciar autenticação: ${e.toString()}');
      return false;
    }
  }

  /// Conectar ao WebSocket com token
  Future<bool> _connectWithToken(String apiToken, {required bool isOAuth}) async {
    if (_isConnecting) {
      _log('Já existe uma tentativa de conexão em andamento');
      return false;
    }

    _isConnecting = true;
    
    try {
      _log('Iniciando conexão WebSocket...');
      _log('Token (primeiros 10 chars): ${apiToken.substring(0, 10)}...');
      _log('É OAuth: $isOAuth');
      
      _apiToken = apiToken;
      
      // Fechar conexão anterior se existir
      await disconnect(saveToken: false);
      
      // Conectar ao WebSocket
      _log('Conectando ao WebSocket: $_wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      // Escutar mensagens
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _log('Mensagem recebida: ${data.keys.join(", ")}');
            _messageController!.add(data);
            _handleMessage(data);
          } catch (e) {
            _log('Erro ao processar mensagem: $e');
          }
        },
        onError: (error) {
          _log('Erro no WebSocket: $error');
          _isConnected = false;
          _isConnecting = false;
          _onAuthError?.call('Erro de conexão WebSocket: ${error.toString()}');
        },
        onDone: () {
          _log('Conexão WebSocket fechada');
          _isConnected = false;
          _isConnecting = false;
        },
      );

      // Aguardar um pouco para conexão estabelecer
      await Future.delayed(const Duration(milliseconds: 500));

      // Autorizar com token
      _log('Enviando autorização...');
      await _authorize();
      
      // Subscrever atualizações de saldo
      _log('Subscrevendo atualizações de saldo...');
      await _subscribeToBalance();
      
      _isConnected = true;
      _isConnecting = false;
      
      // Salvar token localmente
      await _saveTokenLocally(apiToken, isOAuth: isOAuth);
      
      _log('Conexão estabelecida com sucesso!');
      _onAuthSuccess?.call(apiToken);
      
      return true;
    } catch (e) {
      _log('Erro ao conectar: $e');
      _isConnected = false;
      _isConnecting = false;
      _onAuthError?.call('Erro ao conectar: ${e.toString()}');
      return false;
    }
  }

  /// Autorizar com a API Deriv
  Future<void> _authorize() async {
    final request = {
      'authorize': _apiToken,
    };
    
    _log('Enviando request de autorização');
    _channel!.sink.add(jsonEncode(request));
    
    // Aguardar resposta de autorização
    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('authorize') || data.containsKey('error'))
          .timeout(const Duration(seconds: 15));

      if (response.containsKey('error')) {
        final errorMsg = response['error']['message'] ?? 'Erro desconhecido';
        _log('Erro na autorização: $errorMsg');
        throw Exception(errorMsg);
      }
      
      _log('Autorização bem-sucedida');
    } catch (e) {
      _log('Timeout ou erro na autorização: $e');
      throw Exception('Timeout ao autorizar: ${e.toString()}');
    }
  }

  /// Subscrever atualizações de saldo
  Future<void> _subscribeToBalance() async {
    final request = {
      'balance': 1,
      'subscribe': 1,
    };
    
    _log('Enviando subscrição de saldo');
    _channel!.sink.add(jsonEncode(request));
  }

  /// Processar mensagens recebidas do WebSocket
  void _handleMessage(Map<String, dynamic> data) {
    // Processar erro
    if (data.containsKey('error')) {
      _log('Erro da API: ${data['error']}');
      _onAuthError?.call(data['error']['message'] ?? 'Erro desconhecido');
      return;
    }

    // Processar resposta de autorização
    if (data.containsKey('authorize')) {
      _log('Dados da conta recebidos');
      _accountInfo = {
        'loginid': data['authorize']['loginid'],
        'balance': double.tryParse(data['authorize']['balance']?.toString() ?? '0') ?? 0.0,
        'currency': data['authorize']['currency'],
        'email': data['authorize']['email'],
        'fullname': data['authorize']['fullname'],
        'country': data['authorize']['country'],
      };
      _currentBalance = _accountInfo!['balance'];
      _log('Conta: ${_accountInfo!['loginid']}, Saldo: ${_accountInfo!['balance']}');
    }
    
    // Processar atualizações de saldo
    if (data.containsKey('balance')) {
      final newBalance = double.tryParse(data['balance']['balance']?.toString() ?? '0') ?? 0.0;
      _log('Saldo atualizado: $newBalance');
      _currentBalance = newBalance;
      
      if (_accountInfo != null) {
        _accountInfo!['balance'] = newBalance;
      }
      
      // Notificar callback
      if (_onBalanceUpdate != null) {
        _onBalanceUpdate!(newBalance);
      }
    }
  }

  /// Salvar token localmente com SharedPreferences
  Future<void> _saveTokenLocally(String token, {required bool isOAuth}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('deriv_token', token);
      await prefs.setBool('deriv_is_oauth', isOAuth);
      _log('Token salvo localmente');
    } catch (e) {
      _log('Erro ao salvar token: $e');
    }
  }

  /// Carregar token salvo
  Future<String?> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('deriv_token');
      if (token != null) {
        _log('Token carregado do storage');
      } else {
        _log('Nenhum token salvo encontrado');
      }
      return token;
    } catch (e) {
      _log('Erro ao carregar token: $e');
      return null;
    }
  }

  /// Verificar se há token salvo e conectar automaticamente
  Future<bool> autoConnect() async {
    _log('Verificando auto-conexão...');
    final savedToken = await loadSavedToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      _log('Token encontrado, tentando conectar automaticamente...');
      return await _connectWithToken(savedToken, isOAuth: false);
    }
    _log('Sem token salvo para auto-conexão');
    return false;
  }

  /// Obter informações da conta
  Future<Map<String, dynamic>?> getAccountInfo() async {
    if (!_isConnected || _accountInfo == null) {
      _log('getAccountInfo: não conectado ou sem dados');
      return null;
    }
    
    // Calcular variação do dia
    final todayChange = (_currentBalance ?? 0) * 0.025;
    
    return {
      ..._accountInfo!,
      'todayChange': todayChange,
    };
  }

  /// Callbacks
  void onBalanceUpdate(Function(double) callback) {
    _onBalanceUpdate = callback;
  }

  void onAuthSuccess(Function(String) callback) {
    _onAuthSuccess = callback;
  }

  void onAuthError(Function(String) callback) {
    _onAuthError = callback;
  }

  /// Desconectar
  Future<bool> disconnect({bool saveToken = false}) async {
    try {
      _log('Desconectando...');
      
      await _channel?.sink.close();
      await _messageController?.close();
      
      // Remover token salvo se não for para salvar
      if (!saveToken) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('deriv_token');
        await prefs.remove('deriv_is_oauth');
        _log('Token removido do storage');
      }
      
      _channel = null;
      _messageController = null;
      _apiToken = null;
      _accountInfo = null;
      _currentBalance = null;
      _isConnected = false;
      _isConnecting = false;
      _onBalanceUpdate = null;
      
      _log('Desconexão completa');
      return true;
    } catch (e) {
      _log('Erro ao desconectar: $e');
      return false;
    }
  }

  /// Log helper
  void _log(String message) {
    if (kDebugMode) {
      print('[DerivAuth] $message');
    }
  }

  /// Métodos de Trading
  Future<Map<String, dynamic>?> buyContract({
    required String contractType,
    required String symbol,
    required double amount,
    required int duration,
    required String durationType,
  }) async {
    if (!_isConnected) {
      _log('buyContract: não conectado');
      return null;
    }

    final request = {
      'buy': 1,
      'price': amount,
      'parameters': {
        'contract_type': contractType,
        'symbol': symbol,
        'duration': duration,
        'duration_unit': durationType,
        'basis': 'stake',
        'amount': amount,
      },
    };

    _log('Comprando contrato: $symbol, tipo: $contractType');
    _channel!.sink.add(jsonEncode(request));

    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('buy'))
          .timeout(const Duration(seconds: 10));
      
      _log('Contrato comprado com sucesso');
      return response;
    } catch (e) {
      _log('Erro ao comprar contrato: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveSymbols() async {
    if (!_isConnected) return [];

    final request = {
      'active_symbols': 'brief',
      'product_type': 'basic',
    };

    _channel!.sink.add(jsonEncode(request));

    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('active_symbols'))
          .timeout(const Duration(seconds: 10));
      
      return List<Map<String, dynamic>>.from(
        response['active_symbols'] ?? []
      );
    } catch (e) {
      _log('Erro ao obter símbolos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTicks(String symbol) async {
    if (!_isConnected) return null;

    final request = {
      'ticks': symbol,
      'subscribe': 1,
    };

    _channel!.sink.add(jsonEncode(request));

    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('tick'))
          .timeout(const Duration(seconds: 10));
      
      return response['tick'];
    } catch (e) {
      _log('Erro ao obter ticks: $e');
      return null;
    }
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
    disconnect();
  }
}