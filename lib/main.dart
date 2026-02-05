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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
  String _balance = '0.00 USD';

  String get htmlContent => '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="${widget.themeMode == ThemeMode.light ? '#ffffff' : '#1F2937'}">
    <title>Deriv Trading</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lightweight-charts/dist/lightweight-charts.standalone.production.js"></script>
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
        }
        #main-scroll { height: 100vh; overflow-y: auto; }
    </style>
</head>
<body class="${widget.themeMode == ThemeMode.light ? 'bg-white' : 'bg-gray-900'} ${widget.themeMode == ThemeMode.light ? 'text-black' : 'text-white'}">
    <div id="main-scroll">
        <div id="chart-container" style="width: 100%; height: 400px;"></div>
        <div class="p-4 space-y-4">
            <div class="grid grid-cols-2 gap-4">
                <button id="btn-rise" class="py-4 bg-green-500 text-white font-bold text-lg rounded-lg shadow-lg active:scale-95">Rise</button>
                <button id="btn-fall" class="py-4 bg-red-500 text-white font-bold text-lg rounded-lg shadow-lg active:scale-95">Fall</button>
            </div>
        </div>
    </div>
    <script>
        const APP_ID = 71954;
        const API_TOKEN = 'nUYzSZmUXrXmBmD';
        const WS_URL = 'wss://ws.derivws.com/websockets/v3?app_id=' + APP_ID;
        const MARKET_SYMBOL = '1HZ25V';

        const state = {
            ws: null,
            chart: null,
            candleSeries: null,
            areaSeries: null,
            balance: null,
            currency: 'USD',
            contractType: 'CALL',
            proposalId: null,
            durationUnit: 't',
            isDark: ${widget.themeMode == ThemeMode.dark}
        };

        const elements = {
            chartContainer: document.getElementById('chart-container'),
            btnRise: document.getElementById('btn-rise'),
            btnFall: document.getElementById('btn-fall')
        };

        function init() {
            initChart();
            connectWebSocket();
            setupEventListeners();
            setTimeout(() => window.flutter_inappwebview?.callHandler('onPageLoaded'), 1000);
        }

        function initChart() {
            state.chart = LightweightCharts.createChart(elements.chartContainer, {
                width: elements.chartContainer.clientWidth,
                height: elements.chartContainer.clientHeight,
                layout: {
                    background: { color: state.isDark ? '#1F2937' : '#ffffff' },
                    textColor: state.isDark ? '#f3f4f6' : '#374151'
                },
                grid: {
                    vertLines: { color: state.isDark ? '#374151' : '#f3f4f6' },
                    horzLines: { color: state.isDark ? '#374151' : '#f3f4f6' }
                },
                timeScale: { timeVisible: true, secondsVisible: true },
                crosshair: { mode: LightweightCharts.CrosshairMode.Normal }
            });

            state.candleSeries = state.chart.addCandlestickSeries({
                upColor: '#10b981',
                downColor: '#ef4444',
                borderUpColor: '#10b981',
                borderDownColor: '#ef4444',
                wickUpColor: '#10b981',
                wickDownColor: '#ef4444'
            });

            state.areaSeries = state.chart.addAreaSeries({
                topColor: 'rgba(59, 130, 246, 0.4)',
                bottomColor: 'rgba(59, 130, 246, 0.0)',
                lineColor: '#3b82f6',
                lineWidth: 2
            });

            state.areaSeries.setData([]);
        }

        function connectWebSocket() {
            state.ws = new WebSocket(WS_URL);
            
            state.ws.onopen = () => {
                console.log('Connected');
                authorize();
            };
            
            state.ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleMessage(data);
            };
            
            state.ws.onerror = (error) => console.error('WS Error:', error);
            state.ws.onclose = () => setTimeout(connectWebSocket, 3000);
        }

        function authorize() {
            send({ authorize: API_TOKEN });
        }

        function handleMessage(data) {
            if (data.error) {
                console.error('API Error:', data.error);
                return;
            }
            
            switch (data.msg_type) {
                case 'authorize':
                    handleAuthorize(data.authorize);
                    break;
                case 'balance':
                    handleBalance(data.balance);
                    break;
                case 'proposal':
                    handleProposal(data.proposal);
                    break;
                case 'buy':
                    handleBuy(data.buy);
                    break;
            }
        }

        function handleAuthorize(data) {
            state.balance = parseFloat(data.balance);
            state.currency = data.currency;
            
            window.flutter_inappwebview?.callHandler('updateBalance', {
                balance: state.balance.toFixed(2),
                currency: state.currency
            });
            
            subscribeBalance();
        }

        function handleBalance(data) {
            state.balance = parseFloat(data.balance);
            state.currency = data.currency;
            
            window.flutter_inappwebview?.callHandler('updateBalance', {
                balance: state.balance.toFixed(2),
                currency: state.currency
            });
        }

        function handleProposal(proposal) {
            if (proposal.id) {
                state.proposalId = proposal.id;
                const payout = parseFloat(proposal.payout);
                const stake = parseFloat(proposal.ask_price);
                
                window.flutter_inappwebview?.callHandler('onProposal', {
                    id: state.proposalId,
                    payout: payout.toFixed(2),
                    profit: (payout - stake).toFixed(2),
                    currency: state.currency
                });
            }
        }

        function handleBuy(data) {
            if (data.contract_id) {
                window.flutter_inappwebview?.callHandler('onTradeBought', {
                    contract_id: data.contract_id
                });
            }
        }

        function setupEventListeners() {
            elements.btnRise.addEventListener('click', () => {
                window.flutter_inappwebview?.callHandler('openTradeDialog', { type: 'CALL' });
            });
            
            elements.btnFall.addEventListener('click', () => {
                window.flutter_inappwebview?.callHandler('openTradeDialog', { type: 'PUT' });
            });
        }

        function requestProposal(stake, duration, durationUnit, contractType) {
            state.contractType = contractType;
            state.durationUnit = durationUnit;
            
            window.flutter_inappwebview?.callHandler('proposalLoading');
            
            send({
                proposal: 1,
                amount: parseFloat(stake),
                basis: 'stake',
                contract_type: contractType,
                currency: state.currency,
                duration: parseInt(duration),
                duration_unit: durationUnit,
                symbol: MARKET_SYMBOL
            });
        }

        function executeTrade(stake) {
            if (!state.proposalId) {
                console.error('No proposal ID');
                return;
            }
            
            send({
                buy: state.proposalId,
                price: parseFloat(stake)
            });
        }

        function send(data) {
            if (state.ws && state.ws.readyState === WebSocket.OPEN) {
                state.ws.send(JSON.stringify(data));
            }
        }

        function subscribeBalance() {
            send({ balance: 1, subscribe: 1 });
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
    bool isLoadingProposal = true;
    bool canExecute = false;
    String proposalInfo = '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Função para solicitar proposta
          void _requestProposal() {
            setDialogState(() {
              isLoadingProposal = true;
              canExecute = false;
              proposalInfo = '';
            });

            final stake = stakeController.text.trim();
            final duration = durationController.text.trim();

            if (stake.isNotEmpty && duration.isNotEmpty) {
              _webViewController?.evaluateJavascript(
                source: "requestProposal('$stake', '$duration', '$durationUnit', '$type');"
              );
            }
          }

          // Solicita proposta inicial
          if (isLoadingProposal && proposalInfo.isEmpty) {
            Future.delayed(Duration.zero, _requestProposal);
          }

          return Dialog(
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
                      Text(
                        type == 'CALL' ? 'Rise' : 'Fall',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          BootstrapIcons.x_lg,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: stakeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Valor (Stake)',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    ),
                    onChanged: (_) {
                      Future.delayed(const Duration(milliseconds: 500), _requestProposal);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Duração',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    ),
                    onChanged: (_) {
                      Future.delayed(const Duration(milliseconds: 500), _requestProposal);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: durationUnit,
                    dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                    ),
                    items: [
                      DropdownMenuItem(value: 't', child: Text('Ticks', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                      DropdownMenuItem(value: 's', child: Text('Segundos', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                      DropdownMenuItem(value: 'm', child: Text('Minutos', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                      DropdownMenuItem(value: 'h', child: Text('Horas', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                      DropdownMenuItem(value: 'd', child: Text('Dias', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        durationUnit = value!;
                      });
                      _requestProposal();
                    },
                  ),
                  if (proposalInfo.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Text(
                        proposalInfo,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoadingProposal || !canExecute
                          ? null
                          : () {
                              final stake = stakeController.text.trim();
                              _webViewController?.evaluateJavascript(
                                source: "executeTrade('$stake');"
                              );
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: type == 'CALL' ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isLoadingProposal
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Executar Negociação',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        leading: IconButton(
          icon: Icon(BootstrapIcons.list, color: isDark ? Colors.white : Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volatility 25 (1s) Index',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '1HZ25V',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Saldo',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _balance,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF374151) : Colors.grey,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isDark ? BootstrapIcons.sun_fill : BootstrapIcons.moon_fill,
                            color: isDark ? Colors.amber : Colors.indigo,
                          ),
                          onPressed: () {
                            widget.onThemeToggle();
                            Navigator.pop(context);
                            _reloadWebView();
                          },
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        child: Icon(
                          BootstrapIcons.person_fill,
                          size: 35,
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _balance,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(BootstrapIcons.wallet2, color: isDark ? Colors.white : Colors.black),
              title: Text('Carteira', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(BootstrapIcons.clock_history, color: isDark ? Colors.white : Colors.black),
              title: Text('Histórico', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(BootstrapIcons.gear, color: isDark ? Colors.white : Colors.black),
              title: Text('Configurações', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
            Divider(color: isDark ? const Color(0xFF374151) : Colors.grey),
            ListTile(
              leading: Icon(BootstrapIcons.question_circle, color: isDark ? Colors.white : Colors.black),
              title: Text('Ajuda', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(BootstrapIcons.box_arrow_right, color: isDark ? Colors.white : Colors.black),
              title: Text('Sair', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: ValueKey(widget.themeMode.toString()),
            initialData: InAppWebViewInitialData(data: htmlContent),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              supportZoom: false,
              useHybridComposition: true,
              javaScriptEnabled: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              
              controller.addJavaScriptHandler(
                handlerName: 'onPageLoaded',
                callback: (_) => setState(() => _isLoading = false),
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'updateBalance',
                callback: (args) {
                  setState(() {
                    _balance = '${args[0]['balance']} ${args[0]['currency']}';
                  });
                },
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'openTradeDialog',
                callback: (args) => _showTradeDialog(args[0]['type']),
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'onProposal',
                callback: (args) {
                  // Atualiza o diálogo com info da proposta
                  // (Isso seria melhor com um gerenciador de estado, mas por simplicidade...)
                },
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'onTradeBought',
                callback: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Negociação executada com sucesso!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
