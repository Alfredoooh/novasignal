// lib/services/deriv_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class DerivService {
  static final DerivService _instance = DerivService._internal();
  factory DerivService() => _instance;
  DerivService._internal();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  String? _apiToken;
  bool _isConnected = false;
  
  final String _wsUrl = 'wss://ws.derivws.com/websockets/v3?app_id=1089';
  
  // Callbacks
  Function(double)? _onBalanceUpdate;
  
  // Cache de dados
  Map<String, dynamic>? _accountInfo;
  double? _currentBalance;

  bool get isConnected => _isConnected;

  Future<bool> connect(String apiToken) async {
    try {
      _apiToken = apiToken;
      
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
      return true;
    } catch (e) {
      if (kDebugMode) print('Error connecting to Deriv: $e');
      _isConnected = false;
      return false;
    }
  }

  Future<void> _authorize() async {
    final request = {
      'authorize': _apiToken,
    };
    
    _channel!.sink.add(jsonEncode(request));
    
    // Aguardar resposta de autorização
    await _messageController!.stream
        .firstWhere((data) => data.containsKey('authorize'))
        .timeout(const Duration(seconds: 10));
  }

  Future<void> _subscribeToBalance() async {
    final request = {
      'balance': 1,
      'subscribe': 1,
    };
    
    _channel!.sink.add(jsonEncode(request));
  }

  void _handleMessage(Map<String, dynamic> data) {
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
    if (!_isConnected || _accountInfo == null) {
      return null;
    }
    
    // Adicionar variação do dia (simulado por enquanto)
    final todayChange = (_currentBalance ?? 0) * 0.025; // 2.5% de exemplo
    
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
    disconnect();
  }
}