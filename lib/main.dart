/* import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_screen.dart';
import 'screens/security_screen.dart';
import 'screens/account_screen.dart';
import 'screens/product_details_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/cart_provider.dart';

const Color transparent = Color(0x00000000);
const Color primaryColor = Color(0xFF2C3E50);

void main() {
  runApp(const SportsApp());
}

class SportsApp extends StatefulWidget {
  const SportsApp({Key? key}) : super(key: key);

  @override
  State<SportsApp> createState() => _SportsAppState();
}

class _SportsAppState extends State<SportsApp> {
  bool _isDark = false;
  String _locale = 'pt';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDark') ?? false;
      _locale = prefs.getString('locale') ?? 'pt';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    await prefs.setString('locale', _locale);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isDark: _isDark,
      toggleTheme: (v) {
        setState(() => _isDark = v);
        _savePreferences();
      },
      child: LocaleProvider(
        locale: _locale,
        changeLocale: (v) {
          setState(() => _locale = v);
          _savePreferences();
        },
        child: ChangeNotifierProvider(
          create: (context) => CartProvider(),
          child: WidgetsApp(
            color: const Color(0xFFFFFFFF),
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/settings':
                  page = const SettingsScreen();
                  break;
                case '/help':
                  page = const HelpScreen();
                  break;
                case '/security':
                  page = const SecurityScreen();
                  break;
                case '/account':
                  page = const AccountScreen();
                  break;
                case '/product_details':
                  page = ProductDetailsScreen(product: settings.arguments as Map<String, dynamic>);
                  break;
                default:
                  page = const HomeScreen();
              }

              // Transição nativa do iOS
              return CupertinoPageRoute(
                settings: settings,
                builder: (context) => page,
              );
            },
          ),
        ),
      ),
    );
  }
}*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:candlesticks/candlesticks.dart';

void main() {
  runApp(const DerivTradingApp());
}

class DerivTradingApp extends StatelessWidget {
  const DerivTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deriv Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const TradingScreen(),
    );
  }
}

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  // Constants
  static const String appId = '71954';
  static const String apiToken = 'nUYzSZmUXrXmBmD';
  static const String marketSymbol = '1HZ25V';
  
  // WebSocket
  WebSocketChannel? _wsChannel;
  WebSocketChannel? _chartWsChannel;
  
  // State
  double _balance = 232.14;
  String _currency = 'USD';
  String _chartMode = 'candles';
  int _selectedTimeframe = 0;
  String _contractType = 'CALL';
  String _durationUnit = 't';
  String? _proposalId;
  double _currentPrice = 730017.68;
  String _priceChange = '+0.02%';
  
  // Chart data
  List<Candle> _candles = [];
  List<Map<String, dynamic>> _ticks = [];
  
  // Controllers
  final TextEditingController _stakeController = TextEditingController(text: '1.00');
  final TextEditingController _durationController = TextEditingController(text: '5');
  final ScrollController _scrollController = ScrollController();
  
  // UI State
  bool _showTradeModal = false;
  bool _loadingProposal = false;
  
  // Timeframe buttons
  final List<Map<String, dynamic>> _timeframes = [
    {'label': '1t', 'value': 0},
    {'label': '1m', 'value': 60},
    {'label': '5m', 'value': 300},
    {'label': '15m', 'value': 900},
    {'label': '30m', 'value': 1800},
    {'label': '1h', 'value': 3600},
  ];
  
  Timer? _proposalTimer;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _stakeController.addListener(_onStakeChanged);
    _durationController.addListener(_onDurationChanged);
  }

  @override
  void dispose() {
    _wsChannel?.sink.close();
    _chartWsChannel?.sink.close();
    _stakeController.dispose();
    _durationController.dispose();
    _scrollController.dispose();
    _proposalTimer?.cancel();
    super.dispose();
  }

  void _connectWebSocket() {
    final uri = Uri.parse('wss://ws.derivws.com/websockets/v3?app_id=$appId');
    _wsChannel = WebSocketChannel.connect(uri);
    
    _wsChannel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _handleMessage(data);
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
      onDone: () {
        debugPrint('WebSocket closed, reconnecting...');
        Future.delayed(const Duration(seconds: 3), _connectWebSocket);
      },
    );
  }

  void _connectChartWebSocket() {
    _chartWsChannel?.sink.close();
    
    final uri = Uri.parse('wss://ws.derivws.com/websockets/v3?app_id=$appId');
    _chartWsChannel = WebSocketChannel.connect(uri);
    
    _chartWsChannel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        _handleChartMessage(data);
      },
    );
    
    // Subscribe to ticks or candles based on timeframe
    if (_selectedTimeframe == 0) {
      _chartWsChannel!.sink.add(jsonEncode({
        'ticks': marketSymbol,
        'subscribe': 1,
      }));
    } else {
      _chartWsChannel!.sink.add(jsonEncode({
        'ticks_history': marketSymbol,
        'adjust_start_time': 1,
        'count': 1000,
        'end': 'latest',
        'start': 1,
        'style': 'candles',
        'granularity': _selectedTimeframe,
      }));
      
      _chartWsChannel!.sink.add(jsonEncode({
        'ohlc': marketSymbol,
        'granularity': _selectedTimeframe,
        'subscribe': 1,
      }));
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      debugPrint('API Error: ${data['error']}');
      return;
    }
    
    final msgType = data['msg_type'];
    
    switch (msgType) {
      case 'authorize':
        _handleAuthorize(data['authorize']);
        break;
      case 'balance':
        _handleBalance(data['balance']);
        break;
      case 'proposal':
        _handleProposal(data['proposal']);
        break;
      case 'buy':
        _handleBuy(data['buy']);
        break;
    }
  }

  void _handleChartMessage(Map<String, dynamic> data) {
    if (data.containsKey('error')) return;
    
    final msgType = data['msg_type'];
    
    if (msgType == 'candles') {
      final candles = data['candles'] as List;
      setState(() {
        _candles = candles.map((c) {
          return Candle(
            date: DateTime.fromMillisecondsSinceEpoch(c['epoch'] * 1000),
            open: double.parse(c['open'].toString()),
            high: double.parse(c['high'].toString()),
            low: double.parse(c['low'].toString()),
            close: double.parse(c['close'].toString()),
            volume: 0,
          );
        }).toList();
        
        if (_candles.isNotEmpty) {
          _currentPrice = _candles.last.close;
        }
      });
    } else if (msgType == 'tick') {
      final tick = data['tick'];
      final price = double.parse(tick['quote'].toString());
      final epoch = tick['epoch'];
      
      setState(() {
        _currentPrice = price;
        _ticks.add({
          'time': epoch,
          'value': price,
        });
      });
    } else if (msgType == 'ohlc') {
      final ohlc = data['ohlc'];
      final candle = Candle(
        date: DateTime.fromMillisecondsSinceEpoch(ohlc['epoch'] * 1000),
        open: double.parse(ohlc['open'].toString()),
        high: double.parse(ohlc['high'].toString()),
        low: double.parse(ohlc['low'].toString()),
        close: double.parse(ohlc['close'].toString()),
        volume: 0,
      );
      
      setState(() {
        if (_candles.isNotEmpty && 
            _candles.last.date.millisecondsSinceEpoch == candle.date.millisecondsSinceEpoch) {
          _candles[_candles.length - 1] = candle;
        } else {
          _candles.add(candle);
        }
        _currentPrice = candle.close;
      });
    }
  }

  void _handleAuthorize(Map<String, dynamic> data) {
    setState(() {
      _balance = double.parse(data['balance'].toString());
      _currency = data['currency'];
    });
    
    _wsChannel!.sink.add(jsonEncode({
      'balance': 1,
      'subscribe': 1,
    }));
    
    _connectChartWebSocket();
  }

  void _handleBalance(Map<String, dynamic> data) {
    setState(() {
      _balance = double.parse(data['balance'].toString());
      _currency = data['currency'];
    });
  }

  void _handleProposal(Map<String, dynamic> data) {
    if (data.containsKey('id')) {
      setState(() {
        _proposalId = data['id'];
        _loadingProposal = false;
      });
    }
  }

  void _handleBuy(Map<String, dynamic> data) {
    if (data.containsKey('contract_id')) {
      _showNotification('Trade executado. Contrato: ${data['contract_id']}');
      setState(() {
        _showTradeModal = false;
        _proposalId = null;
      });
    }
  }

  void _authorize() {
    _wsChannel!.sink.add(jsonEncode({
      'authorize': apiToken,
    }));
  }

  void _requestProposal() {
    setState(() {
      _loadingProposal = true;
      _proposalId = null;
    });
    
    final stake = double.tryParse(_stakeController.text) ?? 1.0;
    final duration = int.tryParse(_durationController.text) ?? 5;
    
    _wsChannel!.sink.add(jsonEncode({
      'proposal': 1,
      'amount': stake,
      'basis': 'stake',
      'contract_type': _contractType,
      'currency': _currency,
      'duration': duration,
      'duration_unit': _durationUnit,
      'symbol': marketSymbol,
    }));
  }

  void _executeTrade() {
    if (_proposalId == null) return;
    
    final stake = double.tryParse(_stakeController.text) ?? 1.0;
    
    _wsChannel!.sink.add(jsonEncode({
      'buy': _proposalId,
      'price': stake,
    }));
  }

  void _onStakeChanged() {
    _proposalTimer?.cancel();
    _proposalTimer = Timer(const Duration(milliseconds: 500), _requestProposal);
  }

  void _onDurationChanged() {
    _proposalTimer?.cancel();
    _proposalTimer = Timer(const Duration(milliseconds: 500), _requestProposal);
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openTradeModal(String type) {
    setState(() {
      _contractType = type;
      _showTradeModal = true;
    });
    _requestProposal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Volatility 25 (1s) Index',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '1HZ25V',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Saldo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '${_balance.toStringAsFixed(2)} $_currency',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Chart Type Toggle
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ChartModeButton(
                                  label: 'Candles',
                                  isSelected: _chartMode == 'candles',
                                  onTap: () {
                                    setState(() {
                                      _chartMode = 'candles';
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: _ChartModeButton(
                                  label: 'Line',
                                  isSelected: _chartMode == 'line',
                                  onTap: () {
                                    setState(() {
                                      _chartMode = 'line';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Timeframes
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _timeframes.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final tf = _timeframes[index];
                            final isSelected = _selectedTimeframe == tf['value'];
                            return _TimeframeButton(
                              label: tf['label'],
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedTimeframe = tf['value'];
                                  _candles.clear();
                                  _ticks.clear();
                                });
                                _connectChartWebSocket();
                              },
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Chart Container
                      Container(
                        height: 520,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _candles.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Candlesticks(
                                candles: _candles,
                              ),
                      ),
                      
                      // Price Display
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPrice.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _priceChange,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Trade Buttons - Fixed Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _TradeButton(
                      label: 'Rise',
                      color: Colors.green,
                      onPressed: () => _openTradeModal('CALL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TradeButton(
                      label: 'Fall',
                      color: Colors.red,
                      onPressed: () => _openTradeModal('PUT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Trade Modal
          if (_showTradeModal)
            _TradeModal(
              contractType: _contractType,
              stakeController: _stakeController,
              durationController: _durationController,
              durationUnit: _durationUnit,
              loadingProposal: _loadingProposal,
              proposalId: _proposalId,
              onClose: () {
                setState(() {
                  _showTradeModal = false;
                  _proposalId = null;
                });
              },
              onDurationUnitChanged: (unit) {
                setState(() {
                  _durationUnit = unit;
                });
                _requestProposal();
              },
              onExecuteTrade: _executeTrade,
            ),
        ],
      ),
    );
  }
}

class _ChartModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _TimeframeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeframeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5E7EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _TradeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _TradeButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _TradeModal extends StatelessWidget {
  final String contractType;
  final TextEditingController stakeController;
  final TextEditingController durationController;
  final String durationUnit;
  final bool loadingProposal;
  final String? proposalId;
  final VoidCallback onClose;
  final Function(String) onDurationUnitChanged;
  final VoidCallback onExecuteTrade;

  const _TradeModal({
    required this.contractType,
    required this.stakeController,
    required this.durationController,
    required this.durationUnit,
    required this.loadingProposal,
    required this.proposalId,
    required this.onClose,
    required this.onDurationUnitChanged,
    required this.onExecuteTrade,
  });

  @override
  Widget build(BuildContext context) {
    final color = contractType == 'CALL' ? Colors.green : Colors.red;
    
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            contractType == 'CALL' ? 'Rise' : 'Fall',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stake Input
                          const Text(
                            'Valor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: stakeController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Duration Input
                          const Text(
                            'Duração',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFF3F4F6),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    _DurationUnitButton(
                                      label: 'Ticks',
                                      unit: 't',
                                      isSelected: durationUnit == 't',
                                      color: color,
                                      onTap: () => onDurationUnitChanged('t'),
                                    ),
                                    _DurationUnitButton(
                                      label: 'Seg',
                                      unit: 's',
                                      isSelected: durationUnit == 's',
                                      color: color,
                                      onTap: () => onDurationUnitChanged('s'),
                                    ),
                                    _DurationUnitButton(
                                      label: 'Min',
                                      unit: 'm',
                                      isSelected: durationUnit == 'm',
                                      color: color,
                                      onTap: () => onDurationUnitChanged('m'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Execute Button or Loading
                          if (loadingProposal)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Carregando...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (proposalId != null)
                            Material(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: onExecuteTrade,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Executar Trade',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationUnitButton extends StatelessWidget {
  final String label;
  final String unit;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DurationUnitButton({
    required this.label,
    required this.unit,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
