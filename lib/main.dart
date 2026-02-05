import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DerivApp());
}

class DerivApp extends StatefulWidget {
  const DerivApp({super.key});

  @override
  State<DerivApp> createState() => _DerivAppState();
}

class _DerivAppState extends State<DerivApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: _themeMode == ThemeMode.light ? Colors.white : const Color(0xFF1F2937),
        statusBarIconBrightness: _themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
        statusBarBrightness: _themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'Deriv Trading',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F2937),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: TradingScreen(
        themeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class TradingScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const TradingScreen({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  InAppWebViewController? _webViewController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _balance = '232.14 USD';

  String get htmlContent => '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="${widget.themeMode == ThemeMode.light ? '#ffffff' : '#1F2937'}">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <title>Deriv Trading</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lightweight-charts/dist/lightweight-charts.standalone.production.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        * {
            -webkit-tap-highlight-color: transparent;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            user-select: none;
        }
        
        body {
            overscroll-behavior: none;
            -webkit-overflow-scrolling: touch;
            margin: 0;
            padding: 0;
            transition: background-color 0.3s, color 0.3s;
        }

        body.dark {
            background-color: #111827;
            color: #f3f4f6;
        }

        body.light {
            background-color: #ffffff;
            color: #111827;
        }

        .btn-active:active {
            transform: scale(0.97);
            opacity: 0.8;
        }

        input:focus {
            outline: none;
        }

        #main-scroll {
            height: 100vh;
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
            padding-bottom: 76px;
        }

        #chart-wrapper {
            height: 520px;
            margin: 12px;
        }

        .dark #chart-wrapper {
            border-color: #374151;
        }

        .dark .bg-gray-100 {
            background-color: #374151 !important;
        }

        .dark .bg-gray-200 {
            background-color: #4B5563 !important;
        }

        .dark .text-gray-900 {
            color: #f3f4f6 !important;
        }

        .dark .text-gray-500 {
            color: #9CA3AF !important;
        }

        .dark .border-gray-200 {
            border-color: #374151 !important;
        }

        .dark .bg-white {
            background-color: #1F2937 !important;
        }
    </style>
</head>
<body class="${widget.themeMode == ThemeMode.light ? 'light bg-white text-gray-900' : 'dark bg-gray-900 text-gray-100'}">
    <div class="h-screen flex flex-col">
        <div id="main-scroll">
            <div class="px-4 pt-3">
                <div class="bg-gray-100 rounded-lg p-0.5 flex">
                    <button id="btn-candles" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors ${widget.themeMode == ThemeMode.light ? 'bg-white text-gray-900' : 'bg-gray-800 text-gray-100'} shadow-sm">
                        <i class="bi bi-bar-chart-fill me-1"></i> Candles
                    </button>
                    <button id="btn-line" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors text-gray-500">
                        <i class="bi bi-graph-up me-1"></i> Line
                    </button>
                </div>
            </div>

            <div class="px-4 py-3 overflow-x-auto">
                <div class="flex gap-2">
                    <button data-tf="0" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active bg-gray-200 text-gray-900">1t</button>
                    <button data-tf="60" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500">1m</button>
                    <button data-tf="300" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500">5m</button>
                    <button data-tf="900" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500">15m</button>
                    <button data-tf="1800" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500">30m</button>
                    <button data-tf="3600" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500">1h</button>
                </div>
            </div>

            <div id="chart-wrapper" class="rounded-xl overflow-hidden ${widget.themeMode == ThemeMode.light ? 'bg-white border border-gray-200' : 'bg-gray-800 border border-gray-700'}">
                <div id="chart-container" class="w-full h-full"></div>
            </div>

            <div class="px-4 py-4">
                <p id="current-price" class="text-3xl font-bold ${widget.themeMode == ThemeMode.light ? 'text-gray-900' : 'text-gray-100'}">730017.68</p>
                <p id="price-change" class="text-sm mt-1 text-gray-500">
                    <i class="bi bi-arrow-up-short"></i> +0.02%
                </p>
            </div>
        </div>

        <div class="fixed bottom-0 left-0 right-0 ${widget.themeMode == ThemeMode.light ? 'bg-white border-gray-200' : 'bg-gray-900 border-gray-700'} border-t px-4 py-3 flex gap-3 z-10">
            <button id="btn-rise" class="flex-1 bg-green-500 py-4 rounded-xl font-bold text-white btn-active">
                <i class="bi bi-arrow-up-circle-fill me-2"></i> Rise
            </button>
            <button id="btn-fall" class="flex-1 bg-red-500 py-4 rounded-xl font-bold text-white btn-active">
                <i class="bi bi-arrow-down-circle-fill me-2"></i> Fall
            </button>
        </div>
    </div>

    <script>
        const API_TOKEN = 'YOUR_API_TOKEN_HERE';
        const MARKET_SYMBOL = '1HZ25V';
        const WS_URL = 'wss://ws.derivws.com/websockets/v3?app_id=1089';
        
        const state = {
            ws: null, chartWs: null, chart: null, candleSeries: null, areaSeries: null,
            selectedTimeframe: 0, chartMode: 'candles', candles: [], ticks: [],
            balance: 0, currency: 'USD', contractType: 'CALL', durationUnit: 't',
            proposalId: null, proposalTimeout: null,
            isDark: ${widget.themeMode == ThemeMode.dark ? 'true' : 'false'}
        };
        
        const el = {
            currentPrice: document.getElementById('current-price'),
            priceChange: document.getElementById('price-change'),
            chartContainer: document.getElementById('chart-container'),
            btnCandles: document.getElementById('btn-candles'),
            btnLine: document.getElementById('btn-line'),
            timeframes: document.querySelectorAll('[data-tf]'),
            btnRise: document.getElementById('btn-rise'),
            btnFall: document.getElementById('btn-fall')
        };

        function setTheme(isDark) {
            state.isDark = isDark;
            document.body.className = isDark ? 'dark bg-gray-900 text-gray-100' : 'light bg-white text-gray-900';
            if (state.chart) {
                state.chart.applyOptions({
                    layout: { background: { color: isDark ? '#1F2937' : '#ffffff' }, textColor: isDark ? '#f3f4f6' : '#374151' },
                    grid: { vertLines: { color: isDark ? '#374151' : '#f3f4f6' }, horzLines: { color: isDark ? '#374151' : '#f3f4f6' } }
                });
            }
        }

        function init() {
            state.chart = LightweightCharts.createChart(el.chartContainer, {
                width: el.chartContainer.clientWidth, height: el.chartContainer.clientHeight,
                layout: { background: { color: state.isDark ? '#1F2937' : '#ffffff' }, textColor: state.isDark ? '#f3f4f6' : '#374151' },
                grid: { vertLines: { color: state.isDark ? '#374151' : '#f3f4f6' }, horzLines: { color: state.isDark ? '#374151' : '#f3f4f6' } },
                timeScale: { timeVisible: true, secondsVisible: true },
                crosshair: { mode: LightweightCharts.CrosshairMode.Normal }
            });
            state.candleSeries = state.chart.addCandlestickSeries({ upColor: '#10b981', downColor: '#ef4444', borderUpColor: '#10b981', borderDownColor: '#ef4444', wickUpColor: '#10b981', wickDownColor: '#ef4444' });
            state.areaSeries = state.chart.addAreaSeries({ topColor: 'rgba(59, 130, 246, 0.4)', bottomColor: 'rgba(59, 130, 246, 0.0)', lineColor: '#3b82f6', lineWidth: 2 });
            state.areaSeries.setData([]);
            connectWebSocket();
            setupEventListeners();
            setTimeout(() => window.flutter_inappwebview?.callHandler('onPageLoaded'), 1000);
        }

        function connectWebSocket() {
            state.ws = new WebSocket(WS_URL);
            state.ws.onopen = () => state.ws.send(JSON.stringify({ authorize: API_TOKEN }));
            state.ws.onmessage = (e) => {
                const d = JSON.parse(e.data);
                if (d.error) return;
                if (d.msg_type === 'authorize') {
                    state.balance = parseFloat(d.authorize.balance);
                    state.currency = d.authorize.currency;
                    window.flutter_inappwebview?.callHandler('updateBalance', { balance: state.balance.toFixed(2), currency: state.currency });
                    state.ws.send(JSON.stringify({ balance: 1, subscribe: 1 }));
                } else if (d.msg_type === 'proposal') {
                    state.proposalId = d.proposal.id;
                    window.flutter_inappwebview?.callHandler('onProposal', { id: state.proposalId, payout: parseFloat(d.proposal.payout).toFixed(2), profit: (parseFloat(d.proposal.payout) - parseFloat(state.currentStake || 1)).toFixed(2), currency: state.currency });
                } else if (d.msg_type === 'buy') {
                    window.flutter_inappwebview?.callHandler('onTradeBought', { contract_id: d.buy.contract_id });
                }
            };
        }

        function setupEventListeners() {
            el.btnRise.addEventListener('click', () => window.flutter_inappwebview?.callHandler('openTradeDialog', { type: 'CALL' }));
            el.btnFall.addEventListener('click', () => window.flutter_inappwebview?.callHandler('openTradeDialog', { type: 'PUT' }));
        }

        function requestProposal(stake, duration, durationUnit, contractType) {
            state.currentStake = stake;
            state.ws.send(JSON.stringify({ proposal: 1, amount: parseFloat(stake), basis: 'stake', contract_type: contractType, currency: state.currency, duration: parseInt(duration), duration_unit: durationUnit, symbol: MARKET_SYMBOL }));
        }

        function executeTrade() {
            if (state.proposalId) state.ws.send(JSON.stringify({ buy: state.proposalId, price: parseFloat(state.currentStake) }));
        }

        init();
    </script>
</body>
</html>
  ''';

  void _reloadWebView() {
    setState(() => _isLoading = true);
    _webViewController?.loadData(data: htmlContent);
  }

  void _showTradeDialog(String type) async {
    final isDark = widget.themeMode == ThemeMode.dark;
    final stakeController = TextEditingController(text: '1.00');
    final durationController = TextEditingController(text: '5');
    String durationUnit = 't';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(type == 'CALL' ? 'Rise' : 'Fall', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    IconButton(icon: Icon(BootstrapIcons.x_lg, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(controller: stakeController, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Valor', border: const OutlineInputBorder(borderRadius: BorderRadius.zero), filled: true, fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6))),
                const SizedBox(height: 16),
                TextField(controller: durationController, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Duração', border: const OutlineInputBorder(borderRadius: BorderRadius.zero), filled: true, fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { _webViewController?.evaluateJavascript(source: 'executeTrade();'); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: type == 'CALL' ? Colors.green : Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0), child: const Text('Executar Negociação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: Icon(BootstrapIcons.list, color: isDark ? Colors.white : Colors.black), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Volatility 25 (1s) Index', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)), Text('1HZ25V', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12))]),
        actions: [Padding(padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [Text('Saldo', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 12)), Text(_balance, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold))]))],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey, width: 0.5))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(mainAxisAlignment: MainAxisAlignment.end, children: [Container(decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)), child: IconButton(icon: Icon(isDark ? BootstrapIcons.sun_fill : BootstrapIcons.moon_fill, color: isDark ? Colors.amber : Colors.indigo), onPressed: () { widget.onThemeToggle(); Navigator.pop(context); _reloadWebView(); }))]), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 30, backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), child: Icon(BootstrapIcons.person_fill, size: 35, color: isDark ? Colors.grey.shade400 : Colors.grey)), const SizedBox(height: 12), Text(_balance, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))])]),
            ),
            ListTile(leading: Icon(BootstrapIcons.wallet2, color: isDark ? Colors.white : Colors.black), title: Text('Carteira', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(BootstrapIcons.clock_history, color: isDark ? Colors.white : Colors.black), title: Text('Histórico', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(BootstrapIcons.gear, color: isDark ? Colors.white : Colors.black), title: Text('Configurações', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(context)),
            Divider(color: isDark ? const Color(0xFF374151) : Colors.grey),
            ListTile(leading: Icon(BootstrapIcons.question_circle, color: isDark ? Colors.white : Colors.black), title: Text('Ajuda', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(BootstrapIcons.box_arrow_right, color: isDark ? Colors.white : Colors.black), title: Text('Sair', style: TextStyle(color: isDark ? Colors.white : Colors.black)), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: ValueKey(widget.themeMode.toString()),
            initialData: InAppWebViewInitialData(data: htmlContent),
            initialSettings: InAppWebViewSettings(transparentBackground: true, supportZoom: false, useHybridComposition: true, javaScriptEnabled: true, domStorageEnabled: true),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              controller.addJavaScriptHandler(handlerName: 'onPageLoaded', callback: (_) => setState(() => _isLoading = false));
              controller.addJavaScriptHandler(handlerName: 'updateBalance', callback: (args) => setState(() => _balance = '${args[0]['balance']} ${args[0]['currency']}'));
              controller.addJavaScriptHandler(handlerName: 'openTradeDialog', callback: (args) => _showTradeDialog(args[0]['type']));
              controller.addJavaScriptHandler(handlerName: 'onTradeBought', callback: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Negociação executada!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)));
            },
          ),
          if (_isLoading) Container(color: isDark ? const Color(0xFF111827) : Colors.white, child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white : Colors.black)))),
        ],
      ),
    );
  }
}
