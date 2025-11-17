// lib/services/deriv_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DerivService {
  static final DerivService _instance = DerivService._internal();
  factory DerivService() => _instance;
  DerivService._internal();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  String? _apiToken;
  bool _isConnected = false;

  final String _wsUrl = 'wss://ws.derivws.com/websockets/v3?app_id=1089';
  static const String _tokenKey = 'deriv_api_token';

  // Callbacks
  Function(double)? _onBalanceUpdate;

  // Cache de dados
  Map<String, dynamic>? _accountInfo;
  double? _currentBalance;

  // CORRIGIDO: Agora é um getter que retorna Future
  Future<bool> get isConnected async {
    if (_isConnected) return true;
    
    // Tentar reconectar automaticamente se tiver token salvo
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      
      if (savedToken != null && savedToken.isNotEmpty) {
        await connect(savedToken);
        return _isConnected;
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao verificar conexão: $e');
    }
    
    return _isConnected;
  }

  Future<bool> connect(String apiToken) async {
    try {
      _apiToken = apiToken;

      // Salvar token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, apiToken);

      // Conectar ao WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _messageController = StreamController<Map<String, dynamic>>.broadcast();

      // Escutar mensagens
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _messageController!.add(data);
            _handleMessage(data);
          } catch (e) {
            if (kDebugMode) print('Erro ao processar mensagem: $e');
          }
        },
        onError: (error) {
          if (kDebugMode) print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          if (kDebugMode) print('WebSocket connection closed');
          _isConnected = false;
        },
      );

      // Aguardar um pouco para conexão estabelecer
      await Future.delayed(const Duration(milliseconds: 500));

      // Autorizar com token
      await _authorize();

      // Subscrever atualizações de saldo
      await _subscribeToBalance();

      _isConnected = true;
      return true;
    } catch (e) {
      if (kDebugMode) print('Error connecting to Deriv: $e');
      _isConnected = false;
      return false;
    }
  }

  Future<void> _authorize() async {
    try {
      final request = {
        'authorize': _apiToken,
      };

      _channel!.sink.add(jsonEncode(request));

      // Aguardar resposta de autorização
      await _messageController!.stream
          .firstWhere((data) => data.containsKey('authorize') || data.containsKey('error'))
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (kDebugMode) print('Erro na autorização: $e');
      throw Exception('Falha na autorização');
    }
  }

  Future<void> _subscribeToBalance() async {
    try {
      final request = {
        'balance': 1,
        'subscribe': 1,
      };

      _channel!.sink.add(jsonEncode(request));
    } catch (e) {
      if (kDebugMode) print('Erro ao subscrever saldo: $e');
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    // Processar erros
    if (data.containsKey('error')) {
      if (kDebugMode) print('Erro da API: ${data['error']['message']}');
      return;
    }

    // Processar resposta de autorização
    if (data.containsKey('authorize')) {
      _accountInfo = {
        'loginid': data['authorize']['loginid'],
        'balance': double.tryParse(data['authorize']['balance']?.toString() ?? '0') ?? 0.0,
        'currency': data['authorize']['currency'],
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

  Future<Map<String, dynamic>?> getAccountInfo() async {
    // Se não estiver conectado, retorna null
    if (!_isConnected || _accountInfo == null) {
      return null;
    }

    // Adicionar variação do dia (simulado por enquanto)
    final todayChange = ((_currentBalance ?? 0) / 10000) * 2.5;

    return {
      ..._accountInfo!,
      'todayChange': todayChange,
    };
  }

  void onBalanceUpdate(Function(double) callback) {
    _onBalanceUpdate = callback;
  }

  Future<bool> disconnect() async {
    try {
      // Limpar token salvo
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);

      await _channel?.sink.close();
      await _messageController?.close();

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

  // Métodos de trading
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

    // Aguardar resposta
    try {
      final response = await _messageController!.stream
          .firstWhere((data) => data.containsKey('buy') || data.containsKey('error'))
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
          .firstWhere((data) => data.containsKey('active_symbols') || data.containsKey('error'))
          .timeout(const Duration(seconds: 10));

      if (response.containsKey('error')) return [];

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
          .firstWhere((data) => data.containsKey('tick') || data.containsKey('error'))
          .timeout(const Duration(seconds: 10));

      if (response.containsKey('error')) return null;

      return response['tick'];
    } catch (e) {
      if (kDebugMode) print('Error getting ticks: $e');
      return null;
    }
  }

  void dispose() {
    disconnect();
  }
}