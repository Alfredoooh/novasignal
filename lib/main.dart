import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

void main() {
  runApp(const DerivTradingApp());
}

// Apple Dark Mode Colors
class AppColors {
  static const background = Color(0xFF000000);
  static const secondaryBackground = Color(0xFF1C1C1E);
  static const tertiaryBackground = Color(0xFF2C2C2E);
  static const groupedBackground = Color(0xFF1C1C1E);
  static const separator = Color(0xFF38383A);
  static const label = Color(0xFFFFFFFF);
  static const secondaryLabel = Color(0xFF98989D);
  static const tertiaryLabel = Color(0xFF48484A);
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);
  static const blue = Color(0xFF0A84FF);
  static const gray = Color(0xFF8E8E93);
  static const systemGray6 = Color(0xFF1C1C1E);
}

class DerivTradingApp extends StatelessWidget {
  const DerivTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Deriv Trading',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.green,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: AppColors.secondaryBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.label,
          textStyle: TextStyle(
            color: AppColors.label,
            fontFamily: '.SF Pro Text',
          ),
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
  static const String marketName = 'Volatility 25';
  static const String marketAbbrev = 'V25';

  // WebSocket
  WebSocketChannel? _wsChannel;
  WebSocketChannel? _chartWsChannel;

  // WebView
  InAppWebViewController? _webViewController;

  // State
  double _balance = 232.14;
  String _currency = 'USD';
  int _selectedTimeframe = 0;
  String _contractType = 'CALL';
  String _durationUnit = 't';
  String? _proposalId;
  double _currentPrice = 730017.68;
  double _previousPrice = 730017.68;
  Map<String, dynamic>? _currentProposal;

  // Controllers
  final TextEditingController _stakeController = TextEditingController(text: '1.00');
  final TextEditingController _durationController = TextEditingController(text: '5');
  final ScrollController _scrollController = ScrollController();

  // UI State
  bool _loadingProposal = false;
  bool _chartReady = false;
  bool _showMenuPopup = false;

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
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isAuthorized = false;

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
    _reconnectTimer?.cancel();
    super.dispose();
  }

  void _connectWebSocket() {
    try {
      final uri = Uri.parse('wss://ws.derivws.com/websockets/v3?app_id=$appId');
      _wsChannel = WebSocketChannel.connect(uri);

      _wsChannel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          setState(() => _isConnected = false);
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebSocket closed');
          setState(() => _isConnected = false);
          _scheduleReconnect();
        },
      );

      setState(() => _isConnected = true);
      _authorize();

    } catch (e) {
      debugPrint('Connection error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      debugPrint('Reconnecting...');
      _connectWebSocket();
    });
  }

  void _authorize() {
    if (_wsChannel == null) return;

    _wsChannel!.sink.add(jsonEncode({
      'authorize': apiToken,
    }));
  }

  void _connectChartWebSocket() {
    _chartWsChannel?.sink.close();

    try {
      final uri = Uri.parse('wss://ws.derivws.com/websockets/v3?app_id=$appId');
      _chartWsChannel = WebSocketChannel.connect(uri);

      _chartWsChannel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _handleChartMessage(data);
        },
        onError: (error) {
          debugPrint('Chart WebSocket error: $error');
        },
      );

      // Subscribe based on timeframe
      _subscribeToChartData();

    } catch (e) {
      debugPrint('Chart connection error: $e');
    }
  }

  void _subscribeToChartData() {
    if (_chartWsChannel == null) return;

    if (_selectedTimeframe == 0) {
      // Subscribe to ticks for tick chart
      _chartWsChannel!.sink.add(jsonEncode({
        'ticks': marketSymbol,
        'subscribe': 1,
      }));
    } else {
      // Get historical candles first
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final start = now - (_selectedTimeframe * 1000); // Get last 1000 candles

      _chartWsChannel!.sink.add(jsonEncode({
        'ticks_history': marketSymbol,
        'adjust_start_time': 1,
        'count': 1000,
        'end': 'latest',
        'start': start,
        'style': 'candles',
        'granularity': _selectedTimeframe,
      }));

      // Subscribe to live candles
      _chartWsChannel!.sink.add(jsonEncode({
        'ticks_history': marketSymbol,
        'adjust_start_time': 1,
        'count': 1,
        'end': 'latest',
        'start': 1,
        'style': 'candles',
        'granularity': _selectedTimeframe,
        'subscribe': 1,
      }));
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (data.containsKey('error')) {
      debugPrint('API Error: ${data['error']}');
      _showErrorMessage(data['error']['message'] ?? 'Erro desconhecido');
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
      case 'proposal_open_contract':
        _handleOpenContract(data['proposal_open_contract']);
        break;
    }
  }

  void _handleChartMessage(Map<String, dynamic> data) {
    if (!_chartReady || _webViewController == null) return;

    final msgType = data['msg_type'];

    // Send data to WebView chart
    _webViewController!.evaluateJavascript(source: '''
      if (window.handleChartData) {
        window.handleChartData(${jsonEncode(data)});
      }
    ''');

    // Update current price
    if (msgType == 'tick') {
      final tick = data['tick'];
      if (tick != null) {
        final price = double.tryParse(tick['quote'].toString());
        if (price != null) {
          setState(() {
            _previousPrice = _currentPrice;
            _currentPrice = price;
          });
        }
      }
    } else if (msgType == 'history' || msgType == 'candles') {
      final candles = data['candles'] as List?;
      if (candles != null && candles.isNotEmpty) {
        final lastCandle = candles.last;
        final close = double.tryParse(lastCandle['close'].toString());
        if (close != null) {
          setState(() {
            _previousPrice = _currentPrice;
            _currentPrice = close;
          });
        }
      }
    } else if (msgType == 'ohlc') {
      final ohlc = data['ohlc'];
      if (ohlc != null) {
        final close = double.tryParse(ohlc['close'].toString());
        if (close != null) {
          setState(() {
            _previousPrice = _currentPrice;
            _currentPrice = close;
          });
        }
      }
    }
  }

  void _handleAuthorize(Map<String, dynamic> authorize) {
    setState(() {
      _isAuthorized = true;
      _balance = double.tryParse(authorize['balance'].toString()) ?? _balance;
      _currency = authorize['currency'] ?? _currency;
    });

    // Subscribe to balance updates
    _wsChannel!.sink.add(jsonEncode({
      'balance': 1,
      'subscribe': 1,
    }));

    _getProposal();
  }

  void _handleBalance(Map<String, dynamic> balance) {
    setState(() {
      _balance = double.tryParse(balance['balance'].toString()) ?? _balance;
      _currency = balance['currency'] ?? _currency;
    });
  }

  void _handleProposal(Map<String, dynamic> proposal) {
    setState(() {
      _loadingProposal = false;
      _proposalId = proposal['id'];
      _currentProposal = proposal;
    });
  }

  void _handleBuy(Map<String, dynamic> buy) {
    final contractId = buy['contract_id'];

    // Subscribe to contract updates
    _wsChannel!.sink.add(jsonEncode({
      'proposal_open_contract': 1,
      'contract_id': contractId,
      'subscribe': 1,
    }));

    // Navigate to active trade screen
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => ActiveTradeScreen(
          contractId: contractId,
          wsChannel: _wsChannel!,
          initialContract: buy,
        ),
      ),
    );
  }

  void _handleOpenContract(Map<String, dynamic> contract) {
    // This will be handled by ActiveTradeScreen
  }

  void _onStakeChanged() {
    _debouncedGetProposal();
  }

  void _onDurationChanged() {
    _debouncedGetProposal();
  }

  void _debouncedGetProposal() {
    _proposalTimer?.cancel();
    _proposalTimer = Timer(const Duration(milliseconds: 500), () {
      _getProposal();
    });
  }

  void _getProposal() {
    if (!_isAuthorized || _wsChannel == null) return;

    final stake = double.tryParse(_stakeController.text);
    final duration = int.tryParse(_durationController.text);

    if (stake == null || duration == null || stake <= 0 || duration <= 0) {
      setState(() {
        _proposalId = null;
        _currentProposal = null;
      });
      return;
    }

    setState(() => _loadingProposal = true);

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
    if (_proposalId == null || !_isAuthorized) return;

    // Navigate to trade confirmation screen
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => TradeConfirmationScreen(
          proposal: _currentProposal!,
          contractType: _contractType,
          onConfirm: () {
            _wsChannel!.sink.add(jsonEncode({
              'buy': _proposalId,
              'price': _currentProposal!['ask_price'],
            }));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _changeTimeframe(int index) {
    setState(() => _selectedTimeframe = _timeframes[index]['value']);
    _connectChartWebSocket();
  }

  void _toggleContractType() {
    setState(() {
      _contractType = _contractType == 'CALL' ? 'PUT' : 'CALL';
    });
    _getProposal();
  }

  void _changeDurationUnit(String unit) {
    setState(() => _durationUnit = unit);
    _getProposal();
  }

  void _showErrorMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  String _formatBalance() {
    return '${_balance.toStringAsFixed(2)} $_currency';
  }

  Color get _priceColor {
    if (_currentPrice > _previousPrice) return AppColors.green;
    if (_currentPrice < _previousPrice) return AppColors.red;
    return AppColors.label;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Chart
            Expanded(
              child: _buildChart(),
            ),

            // Trade Panel
            _buildTradePanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Symbol
          Expanded(
            child: Row(
              children: [
                Text(
                  marketAbbrev,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatPrice(_currentPrice),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _priceColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiaryBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatBalance(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.label,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Menu button
          GestureDetector(
            onTap: () {
              setState(() => _showMenuPopup = !_showMenuPopup);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(BootstrapIcons.list, color: AppColors.label, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Timeframe selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.separator,
                  width: 0.5,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_timeframes.length, (index) {
                  final tf = _timeframes[index];
                  final isSelected = _selectedTimeframe == tf['value'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _changeTimeframe(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.tertiaryBackground
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tf['label'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.label
                                : AppColors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Chart WebView
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _getChartHtml(),
              ),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                supportZoom: false,
                disableHorizontalScroll: false,
                disableVerticalScroll: false,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStop: (controller, url) {
                setState(() => _chartReady = true);
                _connectChartWebSocket();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradePanel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Contract type selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _contractType = 'CALL');
                      _getProposal();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _contractType == 'CALL'
                            ? AppColors.green
                            : AppColors.tertiaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'COMPRA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _contractType == 'CALL'
                              ? AppColors.background
                              : AppColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _contractType = 'PUT');
                      _getProposal();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _contractType == 'PUT'
                            ? AppColors.red
                            : AppColors.tertiaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'VENDA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _contractType == 'PUT'
                              ? AppColors.background
                              : AppColors.secondaryLabel,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trade parameters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stake
                const Text(
                  'Valor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _stakeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.label,
                  ),
                ),

                const SizedBox(height: 16),

                // Duration
                const Text(
                  'Duração',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CupertinoTextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.label,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _DurationUnitButton(
                              label: 'Ticks',
                              unit: 't',
                              isSelected: _durationUnit == 't',
                              onTap: () => _changeDurationUnit('t'),
                            ),
                            _DurationUnitButton(
                              label: 'Seg',
                              unit: 's',
                              isSelected: _durationUnit == 's',
                              onTap: () => _changeDurationUnit('s'),
                            ),
                            _DurationUnitButton(
                              label: 'Min',
                              unit: 'm',
                              isSelected: _durationUnit == 'm',
                              onTap: () => _changeDurationUnit('m'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Execute button
                if (_loadingProposal)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.label),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Carregando...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_proposalId != null && _currentProposal != null)
                  GestureDetector(
                    onTap: _executeTrade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _contractType == 'CALL'
                            ? AppColors.green
                            : AppColors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Text(
                            'Executar Trade',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.background,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lucro potencial: ${_currentProposal!['payout']?.toStringAsFixed(2) ?? '0.00'} $_currency',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getChartHtml() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <script src="https://unpkg.com/lightweight-charts@4.1.0/dist/lightweight-charts.standalone.production.js"></script>
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        body {
          background: #000000;
          overflow: hidden;
        }
        #chart {
          width: 100vw;
          height: 100vh;
        }
      </style>
    </head>
    <body>
      <div id="chart"></div>
      <script>
        const chart = LightweightCharts.createChart(document.getElementById('chart'), {
          layout: {
            background: { color: '#000000' },
            textColor: '#FFFFFF',
          },
          grid: {
            vertLines: { color: '#1C1C1E' },
            horzLines: { color: '#1C1C1E' },
          },
          crosshair: {
            mode: LightweightCharts.CrosshairMode.Normal,
            vertLine: {
              color: '#48484A',
              width: 1,
              style: LightweightCharts.LineStyle.Dashed,
            },
            horzLine: {
              color: '#48484A',
              width: 1,
              style: LightweightCharts.LineStyle.Dashed,
            },
          },
          rightPriceScale: {
            borderColor: '#38383A',
          },
          timeScale: {
            borderColor: '#38383A',
            timeVisible: true,
            secondsVisible: false,
          },
        });

        let candleSeries = null;
        let lineSeries = null;
        let currentMode = 'candles';
        let candleData = [];
        let currentCandle = null;

        function initChart(mode) {
          if (candleSeries) {
            chart.removeSeries(candleSeries);
            candleSeries = null;
          }
          if (lineSeries) {
            chart.removeSeries(lineSeries);
            lineSeries = null;
          }

          currentMode = mode;

          if (mode === 'ticks') {
            lineSeries = chart.addLineSeries({
              color: '#0A84FF',
              lineWidth: 2,
            });
          } else {
            candleSeries = chart.addCandlestickSeries({
              upColor: '#30D158',
              downColor: '#FF453A',
              borderUpColor: '#30D158',
              borderDownColor: '#FF453A',
              wickUpColor: '#30D158',
              wickDownColor: '#FF453A',
            });
          }

          candleData = [];
          currentCandle = null;
        }

        window.handleChartData = function(data) {
          const msgType = data.msg_type;

          if (msgType === 'tick') {
            if (currentMode !== 'ticks') {
              initChart('ticks');
            }

            const tick = data.tick;
            const time = tick.epoch;
            const value = parseFloat(tick.quote);

            if (lineSeries) {
              lineSeries.update({ time, value });
            }
          } else if (msgType === 'history' || msgType === 'candles') {
            if (currentMode !== 'candles') {
              initChart('candles');
            }

            const candles = data.candles || [];
            const formattedCandles = candles.map(c => ({
              time: c.epoch,
              open: parseFloat(c.open),
              high: parseFloat(c.high),
              low: parseFloat(c.low),
              close: parseFloat(c.close),
            }));

            if (candleSeries && formattedCandles.length > 0) {
              candleSeries.setData(formattedCandles);
              candleData = formattedCandles;
              
              if (formattedCandles.length > 0) {
                currentCandle = formattedCandles[formattedCandles.length - 1];
              }
            }
          } else if (msgType === 'ohlc') {
            if (currentMode !== 'candles') {
              initChart('candles');
            }

            const ohlc = data.ohlc;
            const candle = {
              time: ohlc.epoch || ohlc.open_time,
              open: parseFloat(ohlc.open),
              high: parseFloat(ohlc.high),
              low: parseFloat(ohlc.low),
              close: parseFloat(ohlc.close),
            };

            if (candleSeries) {
              // Check if this is an update to the current candle or a new one
              if (currentCandle && candle.time === currentCandle.time) {
                // Update existing candle
                candleSeries.update(candle);
                currentCandle = candle;
                
                // Update in candleData array
                const index = candleData.findIndex(c => c.time === candle.time);
                if (index !== -1) {
                  candleData[index] = candle;
                }
              } else {
                // New candle
                candleSeries.update(candle);
                candleData.push(candle);
                currentCandle = candle;
              }
            }
          }
        };

        // Initialize with candles mode
        initChart('candles');

        // Auto-resize
        window.addEventListener('resize', () => {
          chart.applyOptions({
            width: window.innerWidth,
            height: window.innerHeight,
          });
        });
      </script>
    </body>
    </html>
    ''';
  }
}

class _DurationUnitButton extends StatelessWidget {
  final String label;
  final String unit;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationUnitButton({
    required this.label,
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.background : AppColors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}

// Trade Confirmation Screen
class TradeConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> proposal;
  final String contractType;
  final VoidCallback onConfirm;

  const TradeConfirmationScreen({
    super.key,
    required this.proposal,
    required this.contractType,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final payout = proposal['payout']?.toStringAsFixed(2) ?? '0.00';
    final askPrice = proposal['ask_price']?.toStringAsFixed(2) ?? '0.00';
    final profit = (proposal['payout'] - proposal['ask_price']).toStringAsFixed(2);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.secondaryBackground,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.separator,
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text(
          'Confirmar Trade',
          style: TextStyle(color: AppColors.label),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contract Type Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: contractType == 'CALL'
                      ? AppColors.green.withOpacity(0.2)
                      : AppColors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: contractType == 'CALL'
                      ? Icon(BootstrapIcons.arrow_up_circle_fill, color: AppColors.green, size: 40)
                      : Icon(BootstrapIcons.arrow_down_circle_fill, color: AppColors.red, size: 40),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                contractType == 'CALL' ? 'COMPRA' : 'VENDA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: contractType == 'CALL' ? AppColors.green : AppColors.red,
                ),
              ),

              const SizedBox(height: 40),

              // Trade Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Investimento',
                      value: '$askPrice USD',
                      valueColor: AppColors.label,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.separator, height: 1),
                    ),
                    _DetailRow(
                      label: 'Payout Potencial',
                      value: '$payout USD',
                      valueColor: AppColors.green,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.separator, height: 1),
                    ),
                    _DetailRow(
                      label: 'Lucro Potencial',
                      value: '$profit USD',
                      valueColor: AppColors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Button
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: contractType == 'CALL' ? AppColors.green : AppColors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Confirmar Trade',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.secondaryLabel,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// Active Trade Screen
class ActiveTradeScreen extends StatefulWidget {
  final String contractId;
  final WebSocketChannel wsChannel;
  final Map<String, dynamic> initialContract;

  const ActiveTradeScreen({
    super.key,
    required this.contractId,
    required this.wsChannel,
    required this.initialContract,
  });

  @override
  State<ActiveTradeScreen> createState() => _ActiveTradeScreenState();
}

class _ActiveTradeScreenState extends State<ActiveTradeScreen> {
  Map<String, dynamic>? _contract;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _contract = widget.initialContract;

    _subscription = widget.wsChannel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['msg_type'] == 'proposal_open_contract') {
        final contract = data['proposal_open_contract'];
        if (contract['contract_id'].toString() == widget.contractId) {
          setState(() => _contract = contract);

          // Check if contract is finished
          if (contract['status'] == 'sold' || contract['is_expired'] == 1) {
            _showResultDialog(contract);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _showResultDialog(Map<String, dynamic> contract) {
    final profit = (contract['profit'] ?? 0).toStringAsFixed(2);
    final isWin = (contract['profit'] ?? 0) > 0;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isWin ? 'Vitória!' : 'Derrota'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            isWin
                ? Icon(BootstrapIcons.check_circle_fill, color: AppColors.green, size: 60)
                : Icon(BootstrapIcons.x_circle_fill, color: AppColors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              '${isWin ? '+' : ''}$profit USD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isWin ? AppColors.green : AppColors.red,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close active trade screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_contract == null) {
      return CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.label),
            ),
          ),
        ),
      );
    }

    final currentSpot = _contract!['current_spot']?.toString() ?? '0.00';
    final entrySpot = _contract!['entry_spot']?.toString() ?? '0.00';
    final profit = (_contract!['profit'] ?? 0).toStringAsFixed(2);
    final buyPrice = (_contract!['buy_price'] ?? 0).toStringAsFixed(2);
    final payout = (_contract!['payout'] ?? 0).toStringAsFixed(2);
    final contractType = _contract!['contract_type'];
    final isProfit = (_contract!['profit'] ?? 0) >= 0;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.secondaryBackground,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.separator,
            width: 0.5,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(BootstrapIcons.chevron_left, color: AppColors.label, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: const Text(
          'Trade Ativo',
          style: TextStyle(color: AppColors.label),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Contract Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: contractType == 'CALL'
                      ? AppColors.green.withOpacity(0.2)
                      : AppColors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  contractType == 'CALL' ? 'COMPRA' : 'VENDA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: contractType == 'CALL' ? AppColors.green : AppColors.red,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Profit/Loss
              Text(
                '${isProfit ? '+' : ''}$profit USD',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isProfit ? AppColors.green : AppColors.red,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Lucro/Perda Atual',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryLabel,
                ),
              ),

              const SizedBox(height: 60),

              // Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Preço de Entrada',
                      value: entrySpot,
                      valueColor: AppColors.label,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.separator, height: 1),
                    ),
                    _DetailRow(
                      label: 'Preço Atual',
                      value: currentSpot,
                      valueColor: AppColors.label,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.separator, height: 1),
                    ),
                    _DetailRow(
                      label: 'Investimento',
                      value: '$buyPrice USD',
                      valueColor: AppColors.label,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.separator, height: 1),
                    ),
                    _DetailRow(
                      label: 'Payout Potencial',
                      value: '$payout USD',
                      valueColor: AppColors.green,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Status indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aguardando expiração...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryLabel,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}