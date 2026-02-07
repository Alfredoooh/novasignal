import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  InAppWebViewController? _chartController;
  String _balance = '232.14 USD';
  String _currentPrice = '--';
  String _priceChange = '--';
  String _chartType = 'candles';
  int _selectedTimeframe = 0;
  double _stake = 1.00;
  int _duration = 5;
  String _durationUnit = 't';
  
  final List<Map<String, dynamic>> _timeframes = [
    {'value': 60, 'label': '1m'},
    {'value': 120, 'label': '2m'},
    {'value': 180, 'label': '3m'},
    {'value': 240, 'label': '4m'},
    {'value': 300, 'label': '5m'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Market Info
          _buildMarketInfo(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Chart Container
                  _buildChart(),
                  
                  // Chart Controls
                  _buildChartControls(),
                  
                  // Trade Actions
                  _buildTradeActions(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: SvgPicture.string(
                _chartIconSvg,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6B7280),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                _balance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showSettingsMenu,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.string(
                _menuIconSvg,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF6B7280),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6),
            const Color(0xFF3B82F6).withOpacity(0.9),
          ],
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bitcoin / USD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentPrice,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _priceChange,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 480,
      color: Colors.white,
      child: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: _getChartHtml(),
          baseUrl: WebUri('https://app.local'),
        ),
        initialSettings: InAppWebViewSettings(
          transparentBackground: false,
          supportZoom: false,
          useHybridComposition: true,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          databaseEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
        ),
        onWebViewCreated: (controller) {
          _chartController = controller;
          
          // Add JavaScript handlers
          controller.addJavaScriptHandler(
            handlerName: 'updatePrice',
            callback: (args) {
              if (args.isNotEmpty) {
                setState(() {
                  _currentPrice = args[0].toString();
                });
              }
            },
          );
          
          controller.addJavaScriptHandler(
            handlerName: 'updateBalance',
            callback: (args) {
              if (args.isNotEmpty) {
                setState(() {
                  _balance = args[0].toString();
                });
              }
            },
          );
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint('Chart Console: ${consoleMessage.message}');
        },
      ),
    );
  }

  Widget _buildChartControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Chart Type Buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _chartTypeButton('Velas', 'candles'),
                _chartTypeButton('Área', 'area'),
                _chartTypeButton('Linha', 'line'),
                _chartTypeButton('Barras', 'bars'),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Timeframe Selector
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeframes.length,
              itemBuilder: (context, index) {
                final tf = _timeframes[index];
                final isSelected = _selectedTimeframe == index;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeframe = index;
                      });
                      _changeTimeframe(tf['value']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tf['label'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartTypeButton(String label, String type) {
    final isActive = _chartType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _chartType = type;
          });
          _changeChartType(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
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
              color: isActive ? const Color(0xFF111827) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _executeTrade('CALL'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Subir',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${(_stake * 0.95).toFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _executeTrade('PUT'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Descer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${(_stake * 0.95).toFixed(2)} USD',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: _showTradeConfigModal,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Configurar Trade',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeChartType(String type) {
    _chartController?.evaluateJavascript(source: '''
      if (typeof switchChartType === 'function') {
        switchChartType('$type');
      }
    ''');
  }

  void _changeTimeframe(int value) {
    _chartController?.evaluateJavascript(source: '''
      if (typeof changeTimeframe === 'function') {
        changeTimeframe($value);
      }
    ''');
  }

  void _executeTrade(String type) {
    _chartController?.evaluateJavascript(source: '''
      if (typeof executeDirectTrade === 'function') {
        executeDirectTrade('$type');
      }
    ''');
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configurações'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTradeConfigModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Text(
                            'Configurar Trade',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    
                    const Divider(height: 1),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONFIGURAÇÃO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Stake and Duration inputs
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Valor',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _stake = double.tryParse(value) ?? 1.0;
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Tempo',
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setModalState(() {
                                      _duration = int.tryParse(value) ?? 5;
                                    });
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Duration unit tabs
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                _durationUnitTab('Ticks', 't', setModalState),
                                _durationUnitTab('Seg', 's', setModalState),
                                _durationUnitTab('Min', 'm', setModalState),
                                _durationUnitTab('Horas', 'h', setModalState),
                                _durationUnitTab('Dias', 'd', setModalState),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Save button
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Configurações salvas!'),
                                  backgroundColor: Color(0xFF22C55E),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Guardar Configurações',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _durationUnitTab(String label, String unit, StateSetter setModalState) {
    final isActive = _durationUnit == unit;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setModalState(() {
            _durationUnit = unit;
          });
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }

  String _getChartHtml() {
    // Return the complete chart HTML here
    // This will be the HTML from deriv-fixed.html but simplified to just the chart part
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://unpkg.com/lightweight-charts@4.2.1/dist/lightweight-charts.standalone.production.js"></script>
    <style>
        body { margin: 0; padding: 0; overflow: hidden; }
        #chart-container { width: 100%; height: 480px; }
    </style>
</head>
<body>
    <div id="chart-container"></div>
    <script>
        const chart = LightweightCharts.createChart(document.getElementById('chart-container'), {
            width: window.innerWidth,
            height: 480,
            layout: {
                background: { color: '#ffffff' },
                textColor: '#333333',
            },
            grid: {
                vertLines: { color: '#f0f0f0' },
                horzLines: { color: '#f0f0f0' },
            },
        });

        const candleSeries = chart.addCandlestickSeries({
            upColor: '#22c55e',
            downColor: '#ef4444',
            borderUpColor: '#22c55e',
            borderDownColor: '#ef4444',
            wickUpColor: '#22c55e',
            wickDownColor: '#ef4444',
        });

        // WebSocket connection
        const ws = new WebSocket('wss://ws.derivws.com/websockets/v3?app_id=71954');
        
        ws.onopen = () => {
            ws.send(JSON.stringify({ authorize: 'nUYzSZmUXrXmBmD' }));
        };

        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            
            if (data.authorize) {
                window.flutter_inappwebview.callHandler('updateBalance', data.authorize.balance + ' ' + data.authorize.currency);
                
                ws.send(JSON.stringify({
                    ticks_history: '1HZ25V',
                    adjust_start_time: 1,
                    count: 1000,
                    end: 'latest',
                    granularity: 60,
                    style: 'candles'
                }));
            }
            
            if (data.candles) {
                const candles = data.candles.map(c => ({
                    time: c.epoch,
                    open: parseFloat(c.open),
                    high: parseFloat(c.high),
                    low: parseFloat(c.low),
                    close: parseFloat(c.close)
                }));
                candleSeries.setData(candles);
                
                if (candles.length > 0) {
                    window.flutter_inappwebview.callHandler('updatePrice', candles[candles.length - 1].close.toFixed(2));
                }
            }
        };

        window.addEventListener('resize', () => {
            chart.applyOptions({ width: window.innerWidth });
        });
    </script>
</body>
</html>
    ''';
  }
}

const String _chartIconSvg = '''
<svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
</svg>
''';

const String _menuIconSvg = '''
<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
  <circle cx="12" cy="5" r="2"/>
  <circle cx="12" cy="12" r="2"/>
  <circle cx="12" cy="19" r="2"/>
</svg>
''';

extension on double {
  String toFixed(int decimals) {
    return toStringAsFixed(decimals);
  }
}
