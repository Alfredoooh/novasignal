import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:feather_icons/feather_icons.dart';

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
  
  // WebView
  InAppWebViewController? _webViewController;
  
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
  
  // Controllers
  final TextEditingController _stakeController = TextEditingController(text: '1.00');
  final TextEditingController _durationController = TextEditingController(text: '5');
  final ScrollController _scrollController = ScrollController();
  
  // UI State
  bool _showTradeModal = false;
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
    if (!_chartReady || _webViewController == null) return;
    
    // Send data to WebView chart
    _webViewController!.evaluateJavascript(source: '''
      if (window.handleChartData) {
        window.handleChartData(${jsonEncode(data)});
      }
    ''');
    
    // Update current price
    if (data['msg_type'] == 'tick') {
      final price = double.tryParse(data['tick']['quote'].toString());
      if (price != null) {
        setState(() {
          _currentPrice = price;
        });
      }
    } else if (data['msg_type'] == 'ohlc') {
      final close = double.tryParse(data['ohlc']['close'].toString());
      if (close != null) {
        setState(() {
          _currentPrice = close;
        });
      }
    } else if (data['msg_type'] == 'candles') {
      final candles = data['candles'] as List?;
      if (candles != null && candles.isNotEmpty) {
        final lastCandle = candles.last;
        final close = double.tryParse(lastCandle['close'].toString());
        if (close != null) {
          setState(() {
            _currentPrice = close;
          });
        }
      }
    }
  }

  void _handleAuthorize(Map<String, dynamic> data) {
    debugPrint('Authorized: ${data['email']}');
    _requestBalance();
  }

  void _handleBalance(Map<String, dynamic> data) {
    setState(() {
      _balance = double.tryParse(data['balance'].toString()) ?? _balance;
      _currency = data['currency'] ?? _currency;
    });
  }

  void _handleProposal(Map<String, dynamic> data) {
    setState(() {
      _proposalId = data['id'];
      _loadingProposal = false;
    });
  }

  void _handleBuy(Map<String, dynamic> data) {
    debugPrint('Trade executed: ${data['contract_id']}');
    _requestBalance();
    _closeTradeModal();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trade executado com sucesso!')),
    );
  }

  void _requestBalance() {
    _wsChannel?.sink.add(jsonEncode({'balance': 1, 'subscribe': 1}));
  }

  void _onStakeChanged() {
    _requestProposal();
  }

  void _onDurationChanged() {
    _requestProposal();
  }

  void _requestProposal() {
    _proposalTimer?.cancel();
    _proposalTimer = Timer(const Duration(milliseconds: 500), () {
      final stake = double.tryParse(_stakeController.text);
      final duration = int.tryParse(_durationController.text);
      
      if (stake == null || duration == null || stake <= 0 || duration <= 0) {
        setState(() {
          _proposalId = null;
        });
        return;
      }
      
      setState(() {
        _loadingProposal = true;
      });
      
      _wsChannel?.sink.add(jsonEncode({
        'proposal': 1,
        'amount': stake,
        'basis': 'stake',
        'contract_type': _contractType,
        'currency': _currency,
        'duration': duration,
        'duration_unit': _durationUnit,
        'symbol': marketSymbol,
      }));
    });
  }

  void _onContractTypeChanged(String type) {
    setState(() {
      _contractType = type;
    });
    _requestProposal();
  }

  void _onDurationUnitChanged(String unit) {
    setState(() {
      _durationUnit = unit;
    });
    _requestProposal();
  }

  void _executeTrade() {
    if (_proposalId == null) return;
    
    _wsChannel?.sink.add(jsonEncode({
      'buy': _proposalId,
      'price': double.tryParse(_stakeController.text) ?? 1.0,
    }));
  }

  void _openTradeModal() {
    setState(() {
      _showTradeModal = true;
    });
    _requestProposal();
  }

  void _closeTradeModal() {
    setState(() {
      _showTradeModal = false;
      _proposalId = null;
    });
  }

  void _changeTimeframe(int index) {
    setState(() {
      _selectedTimeframe = _timeframes[index]['value'] as int;
    });
    _connectChartWebSocket();
  }

  void _changeChartMode(String mode) {
    setState(() {
      _chartMode = mode;
      _showMenuPopup = false;
    });
    
    // Send chart mode change to WebView
    _webViewController?.evaluateJavascript(source: '''
      if (window.switchMode) {
        window.switchMode('$mode');
      }
    ''');
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
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background-color: #ffffff;
      overflow: hidden;
    }
    #chart {
      width: 100%;
      height: 100vh;
    }
  </style>
</head>
<body>
  <div id="chart"></div>
  <script>
    let chart;
    let candleSeries;
    let lineSeries;
    let areaSeries;
    let ohlcSeries;
    let currentMode = 'candles';
    let candleData = [];
    let lineData = [];

    function initChart() {
      const chartElement = document.getElementById('chart');
      
      chart = LightweightCharts.createChart(chartElement, {
        width: chartElement.clientWidth,
        height: chartElement.clientHeight,
        layout: {
          background: { color: '#ffffff' },
          textColor: '#333',
        },
        grid: {
          vertLines: { color: '#f0f0f0' },
          horzLines: { color: '#f0f0f0' },
        },
        crosshair: {
          mode: LightweightCharts.CrosshairMode.Normal,
        },
        rightPriceScale: {
          borderColor: '#e0e0e0',
        },
        timeScale: {
          borderColor: '#e0e0e0',
          timeVisible: true,
          secondsVisible: false,
        },
      });

      // Candlestick Series
      candleSeries = chart.addCandlestickSeries({
        upColor: '#00D95F',
        downColor: '#FF5252',
        borderUpColor: '#00D95F',
        borderDownColor: '#FF5252',
        wickUpColor: '#00D95F',
        wickDownColor: '#FF5252',
      });

      // Line Series
      lineSeries = chart.addLineSeries({
        color: '#2563eb',
        lineWidth: 2,
        visible: false,
      });

      // Area Series
      areaSeries = chart.addAreaSeries({
        topColor: 'rgba(37, 99, 235, 0.4)',
        bottomColor: 'rgba(37, 99, 235, 0.0)',
        lineColor: '#2563eb',
        lineWidth: 2,
        visible: false,
      });

      // OHLC Series (usando baseline como alternativa)
      ohlcSeries = chart.addBaselineSeries({
        baseValue: { type: 'price', price: 0 },
        topLineColor: '#00D95F',
        topFillColor1: 'rgba(0, 217, 95, 0.28)',
        topFillColor2: 'rgba(0, 217, 95, 0.05)',
        bottomLineColor: '#FF5252',
        bottomFillColor1: 'rgba(255, 82, 82, 0.05)',
        bottomFillColor2: 'rgba(255, 82, 82, 0.28)',
        visible: false,
      });

      // Responsive
      window.addEventListener('resize', () => {
        chart.resize(chartElement.clientWidth, chartElement.clientHeight);
      });

      console.log('Chart initialized');
    }

    window.switchMode = function(mode) {
      currentMode = mode;
      
      candleSeries.applyOptions({ visible: mode === 'candles' });
      lineSeries.applyOptions({ visible: mode === 'line' });
      areaSeries.applyOptions({ visible: mode === 'area' });
      ohlcSeries.applyOptions({ visible: mode === 'ohlc' });
      
      console.log('Chart mode changed to:', mode);
    };

    window.handleChartData = function(data) {
      try {
        console.log('Received chart data:', data);

        if (data.msg_type === 'tick') {
          const tick = data.tick;
          const time = Math.floor(tick.epoch);
          const price = parseFloat(tick.quote);

          lineData.push({ time, value: price });
          
          if (lineData.length > 500) {
            lineData.shift();
          }
          
          lineSeries.setData(lineData);
          areaSeries.setData(lineData);

        } else if (data.msg_type === 'candles') {
          candleData = data.candles.map(candle => ({
            time: candle.epoch,
            open: parseFloat(candle.open),
            high: parseFloat(candle.high),
            low: parseFloat(candle.low),
            close: parseFloat(candle.close),
          }));
          
          candleSeries.setData(candleData);
          
          // Para OHLC, usar apenas os valores de close
          const ohlcData = candleData.map(c => ({ time: c.time, value: c.close }));
          ohlcSeries.setData(ohlcData);

        } else if (data.msg_type === 'ohlc') {
          const ohlc = data.ohlc;
          const candle = {
            time: ohlc.open_time,
            open: parseFloat(ohlc.open),
            high: parseFloat(ohlc.high),
            low: parseFloat(ohlc.low),
            close: parseFloat(ohlc.close),
          };

          // Update or add candle
          const existingIndex = candleData.findIndex(c => c.time === candle.time);
          if (existingIndex >= 0) {
            candleData[existingIndex] = candle;
          } else {
            candleData.push(candle);
          }
          
          // Keep only last 500 candles
          if (candleData.length > 500) {
            candleData.shift();
          }
          
          candleSeries.setData(candleData);
          
          // Atualizar OHLC
          const ohlcData = candleData.map(c => ({ time: c.time, value: c.close }));
          ohlcSeries.setData(ohlcData);
        }

      } catch (error) {
        console.error('Error processing chart data:', error);
      }
    };

    // Initialize on load
    document.addEventListener('DOMContentLoaded', () => {
      initChart();
      window.chartReady = true;
    });
  </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Market Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Volatility 25 Index',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _currentPrice.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00D95F),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _priceChange,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF00D95F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Balance
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
                          const SizedBox(height: 4),
                          Text(
                            '$_currency ${_balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Menu Button
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(FeatherIcons.moreVertical),
                        onPressed: () {
                          setState(() {
                            _showMenuPopup = !_showMenuPopup;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Timeframe Selector
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _timeframes.length,
                    itemBuilder: (context, index) {
                      final tf = _timeframes[index];
                      final isSelected = _selectedTimeframe == tf['value'];
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Material(
                          color: isSelected ? const Color(0xFF2563eb) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _changeTimeframe(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Text(
                                tf['label'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Chart
                Expanded(
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _getChartHtml(),
                      baseUrl: WebUri('about:blank'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                      supportZoom: false,
                      disableContextMenu: true,
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStop: (controller, url) {
                      debugPrint('Chart loaded');
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          _chartReady = true;
                        });
                        _connectChartWebSocket();
                      });
                    },
                    onConsoleMessage: (controller, message) {
                      debugPrint('Chart Console: ${message.message}');
                    },
                  ),
                ),
                
                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: const Color(0xFF00D95F),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              _onContractTypeChanged('CALL');
                              _openTradeModal();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Rise',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(FeatherIcons.arrowUp, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Material(
                          color: const Color(0xFFFF5252),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              _onContractTypeChanged('PUT');
                              _openTradeModal();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Fall',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(FeatherIcons.arrowDown, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Menu Popup
            if (_showMenuPopup)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showMenuPopup = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 70,
                        right: 16,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'TIPO DE GRÁFICO',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                
                                // Chart Types
                                _ChartTypeOption(
                                  icon: FeatherIcons.barChart2,
                                  label: 'Candles',
                                  isSelected: _chartMode == 'candles',
                                  onTap: () => _changeChartMode('candles'),
                                ),
                                _ChartTypeOption(
                                  icon: FeatherIcons.trendingUp,
                                  label: 'Line',
                                  isSelected: _chartMode == 'line',
                                  onTap: () => _changeChartMode('line'),
                                ),
                                _ChartTypeOption(
                                  icon: FeatherIcons.activity,
                                  label: 'Area',
                                  isSelected: _chartMode == 'area',
                                  onTap: () => _changeChartMode('area'),
                                ),
                                _ChartTypeOption(
                                  icon: FeatherIcons.barChart,
                                  label: 'OHLC',
                                  isSelected: _chartMode == 'ohlc',
                                  onTap: () => _changeChartMode('ohlc'),
                                ),
                                
                                // Divider
                                Divider(height: 1, color: Colors.grey.shade200),
                                
                                // Settings
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showMenuPopup = false;
                                    });
                                    _openTradeModal();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(FeatherIcons.settings, size: 20, color: Colors.grey.shade700),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Configurações',
                                          style: TextStyle(fontSize: 15),
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
                onClose: _closeTradeModal,
                onExecuteTrade: _executeTrade,
                onDurationUnitChanged: _onDurationUnitChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChartTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.black : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                FeatherIcons.check,
                size: 20,
                color: Color(0xFF2563eb),
              ),
          ],
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
  final VoidCallback onExecuteTrade;
  final Function(String) onDurationUnitChanged;

  const _TradeModal({
    required this.contractType,
    required this.stakeController,
    required this.durationController,
    required this.durationUnit,
    required this.loadingProposal,
    required this.proposalId,
    required this.onClose,
    required this.onExecuteTrade,
    required this.onDurationUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = contractType == 'CALL' 
        ? const Color(0xFF00D95F) 
        : const Color(0xFFFF5252);
    
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                contractType == 'CALL' ? 'Rise' : 'Fall',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                contractType == 'CALL' 
                                    ? FeatherIcons.arrowUp 
                                    : FeatherIcons.arrowDown,
                                color: color,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(FeatherIcons.x),
                          color: color,
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
