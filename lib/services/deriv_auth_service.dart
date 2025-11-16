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

  // ⚠️ SEU APP ID DO DERIV
  static const String APP_ID = '71954';
  
  // URLs base
  static const String _wsUrl = 'wss://ws.derivws.com/websockets/v3?app_id=$APP_ID';
  static const String _oauthUrl = 'https://oauth.deriv.com/oauth2/authorize';
  
  // Deep Link para Android
  static const String _deepLinkScheme = 'novasignal';
  static const String _deepLinkHost = 'deriv-callback';
  
  // Redirect URLs configurados no Deriv Dashboard
  // SUBSTITUA pelas suas URLs reais de redirect
  static const String _androidRedirectUrl = 'https://SEU-DOMINIO.com/deriv-redirect-android.html';
  static const String _webRedirectUrl = 'https://SEU-DOMINIO.com/deriv-redirect-web.html';
  
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  StreamSubscription? _deepLinkSubscription;
  String? _apiToken;
  bool _isConnected = false;
  
  // Callbacks
  Function(double)? _onBalanceUpdate;
  Function(String)? _onAuthSuccess;
  Function(String)? _onAuthError;
  
  // Cache de dados
  Map<String, dynamic>? _accountInfo;
  double? _currentBalance;

  bool get isConnected => _isConnected;
  String? get apiToken => _apiToken;

  /// Inicializar listener de deep links (Android)
  Future<void> initDeepLinkListener() async {
    if (kIsWeb) return;

    // Listener para quando o app já está aberto
    _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      if (kDebugMode) print('Deep link error: $err');
      _onAuthError?.call('Erro ao processar deep link');
    });

    // Verificar se o app foi aberto via deep link
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      if (kDebugMode) print('Error getting initial URI: $e');
    }
  }

  /// Processar deep link recebido
  void _handleDeepLink(Uri uri) {
    if (kDebugMode) print('Deep link received: $uri');

    final Map<String, String> params = uri.queryParameters;
    
    if (params.containsKey('token1')) {
      final token = params['token1']!;
      _connectWithToken(token, isOAuth: true);
    } else if (params.containsKey('error')) {
      _onAuthError?.call('Autenticação cancelada: ${params['error']}');
    }
  }

  /// MÉTODO 1: Conectar com Token API (manual)
  Future<bool> connectWithApiToken(String apiToken) async {
    return await _connectWithToken(apiToken, isOAuth: false);
  }

  /// MÉTODO 2: Conectar com OAuth (Deriv Auth)
  Future<bool> connectWithOAuth() async {
    try {
      // Determinar qual redirect URL usar
      final redirectUrl = kIsWeb ? _webRedirectUrl : _androidRedirectUrl;
      
      // Construir URL de autorização OAuth
      final authUrl = Uri.parse(_oauthUrl).replace(queryParameters: {
        'app_id': APP_ID,
        'l': 'PT', // Idioma português
        'brand': 'deriv',
        'redirect_uri': redirectUrl, // URL de redirect configurada
      });

      if (kDebugMode) print('Opening OAuth URL: $authUrl');

      // Abrir URL de autenticação
      final canLaunch = await canLaunchUrl(authUrl);
      if (canLaunch) {
        await launchUrl(
          authUrl,
          mode: kIsWeb 
              ? LaunchMode.platformDefault 
              : LaunchMode.externalApplication,
        );
        return true;
      } else {
        _onAuthError?.call('Não foi possível abrir a página de autenticação');
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Error initiating OAuth: $e');
      _onAuthError?.call('Erro ao iniciar autenticação: ${e.toString()}');
      return false;
    }
  }

  /// Conectar ao WebSocket com token
  Future<bool> _connectWithToken(String apiToken, {required bool isOAuth}) async {
    try {
      _apiToken = apiToken;
      
      // Fechar conexão anterior se existir
      await disconnect();
      
      // Conectar ao WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
      
      // Escutar mensagens
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _messageController!.add(data);
          _handleMessage(data);
        },
        onError: (error) {
          if (kDebugMode) print('WebSocket error: $error');
          _isConnected = false;
          _onAuthError?.call('Erro de conexão WebSocket');
        },
        onDone: () {
          if (kDebugMode) print('WebSocket connection closed');
          _isConnected = false;
        },
      );

      // Autorizar com token
      await _authorize();
      
      // Subscrever atualizações de saldo
      await _subscribeToBalance();
      
      _isConnected = true;
      
      // Salvar token localmente
      await _saveTokenLocally(apiToken, isOAuth: isOAuth);
      
      _onAuthSuccess?.call(apiToken);
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error connecting to Deriv: $e');
      _isConnected = false;
      _onAuthError?.call('Erro ao conectar: ${e.toString()}');
      return false;
    }
  }

  /// Autorizar com a API Deriv
  Future<void> _authorize() async {
    final request = {
      'authorize': _apiToken,
    };
    
    _channel!.sink.add(jsonEncode(request));
    
    // Aguardar resposta de autorização
    final response = await _messageController!.stream
        .firstWhere((data) => data.containsKey('authorize') || data.containsKey('error'))
        .timeout(const Duration(seconds: 10));

    if (response.containsKey('error')) {
      throw Exception(response['error']['message']);
    }
  }

  /// Subscrever atualizações de saldo
  Future<void> _subscribeToBalance() async {
    final request = {
      'balance': 1,
      'subscribe': 1,
    };
    
    _channel!.sink.add(jsonEncode(request));
  }

  /// Processar mensagens recebidas do WebSocket
  void _handleMessage(Map<String, dynamic> data) {
    // Processar erro
    if (data.containsKey('error')) {
      if (kDebugMode) print('API Error: ${data['error']}');
      _onAuthError?.call(data['error']['message'] ?? 'Erro desconhecido');
      return;
    }

    // Processar resposta de autorização
    if (data.containsKey('authorize')) {
      _accountInfo = {
        'loginid': data['authorize']['loginid'],
        'balance': double.tryParse(data['authorize']['balance']?.toString() ?? '0') ?? 0.0,
        'currency': data['authorize']['currency'],
        'email': data['authorize']['email'],
        'fullname': data['authorize']['fullname'],
        'country': data['authorize']['country'],
      };
      _currentBalance = _accountInfo!['balance'];
    }
    
    // Processar atualizações de saldo
    if (data.containsKey('balance')) {
      final newBalance = double.tryParse(data['balance']['balance']?.toString() ?? '0') ?? 0.0;
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
      if (kDebugMode) print('Token saved locally');
    } catch (e) {
      if (kDebugMode) print('Error saving token: $e');
    }
  }

  /// Carregar token salvo
  Future<String?> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('deriv_token');
    } catch (e) {
      if (kDebugMode) print('Error loading token: $e');
      return null;
    }
  }

  /// Verificar se há token salvo e conectar automaticamente
  Future<bool> autoConnect() async {
    final savedToken = await loadSavedToken();
    if (savedToken != null) {
      return await _connectWithToken(savedToken, isOAuth: false);
    }
    return false;
  }

  /// Obter informações da conta
  Future<Map<String, dynamic>?> getAccountInfo() async {
    if (!_isConnected || _accountInfo == null) {
      return null;
    }
    
    // Calcular variação do dia (pode ser obtida da API)
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
  Future<bool> disconnect() async {
    try {
      await _channel?.sink.close();
      await _messageController?.close();
      
      // Remover token salvo
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('deriv_token');
      await prefs.remove('deriv_is_oauth');
      
      _channel = null;
      _messageController = null;
      _apiToken = null;
      _accountInfo = null;
      _currentBalance = null;
      _isConnected = false;
      _onBalanceUpdate = null;
      
      return true;
    } catch (e) {
      if (kDebugMode) print('Error disconnecting: $e');
      return false;
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
    if (!_isConnected) return null;

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

    _channel!.sink.add(jsonEncode(request));

    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('buy'))
          .timeout(const Duration(seconds: 10));
      
      return response;
    } catch (e) {
      if (kDebugMode) print('Error buying contract: $e');
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
      if (kDebugMode) print('Error getting active symbols: $e');
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
      if (kDebugMode) print('Error getting ticks: $e');
      return null;
    }
  }

  void dispose() {
    _deepLinkSubscription?.cancel();
    disconnect();
  }
}