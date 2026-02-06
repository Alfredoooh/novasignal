/*import 'package:flutter/material.dart';
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
  String _balance = '--- USD';

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

        .btn-active:active {
            transform: scale(0.97);
            opacity: 0.8;
        }

        .modal-enter {
            animation: modalSlide 0.3s cubic-bezier(0.32, 0.72, 0, 1);
        }

        @keyframes modalSlide {
            from { transform: translateY(100%); }
            to { transform: translateY(0); }
        }

        input:focus {
            outline: none;
        }

        #main-scroll {
            height: 100vh;
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
        }

        #chart-wrapper {
            height: 520px;
            margin: 12px;
        }
    </style>
</head>
<body class="${widget.themeMode == ThemeMode.light ? 'bg-white text-gray-900' : 'bg-gray-900 text-white'}">
    <div class="h-screen flex flex-col">
        <!-- Scrollable Content -->
        <div id="main-scroll">
            <!-- Chart Type Toggle -->
            <div class="px-4 pt-3">
                <div class="${widget.themeMode == ThemeMode.light ? 'bg-gray-100' : 'bg-gray-800'} rounded-lg p-0.5 flex">
                    <button id="btn-candles" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors ${widget.themeMode == ThemeMode.light ? 'bg-white text-gray-900' : 'bg-gray-700 text-white'} shadow-sm">
                        Candles
                    </button>
                    <button id="btn-line" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">
                        Line
                    </button>
                </div>
            </div>

            <!-- Timeframes -->
            <div class="px-4 py-3 overflow-x-auto">
                <div class="flex gap-2">
                    <button data-tf="0" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'bg-gray-200 text-gray-900' : 'bg-gray-700 text-white'}">1t</button>
                    <button data-tf="60" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">1m</button>
                    <button data-tf="300" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">5m</button>
                    <button data-tf="900" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">15m</button>
                    <button data-tf="1800" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">30m</button>
                    <button data-tf="3600" class="px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">1h</button>
                </div>
            </div>

            <!-- Chart Container -->
            <div id="chart-wrapper" class="rounded-xl overflow-hidden ${widget.themeMode == ThemeMode.light ? 'bg-white border border-gray-200' : 'bg-gray-800 border border-gray-700'}">
                <div id="chart-container" class="w-full h-full"></div>
            </div>

            <!-- Price Display -->
            <div class="px-4 py-4 pb-32">
                <p id="current-price" class="text-3xl font-bold ${widget.themeMode == ThemeMode.light ? 'text-gray-900' : 'text-white'}">---</p>
                <p id="price-change" class="text-sm mt-1 ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">---</p>
            </div>
        </div>

        <!-- Trade Buttons - Fixed Bottom -->
        <div class="fixed bottom-0 left-0 right-0 ${widget.themeMode == ThemeMode.light ? 'bg-white border-gray-200' : 'bg-gray-900 border-gray-800'} border-t px-4 py-3 flex gap-3 z-10">
            <button id="btn-rise" class="flex-1 bg-green-500 py-4 rounded-xl font-bold text-white btn-active">
                Rise
            </button>
            <button id="btn-fall" class="flex-1 bg-red-500 py-4 rounded-xl font-bold text-white btn-active">
                Fall
            </button>
        </div>

        <!-- Trade Modal -->
        <div id="trade-modal" class="fixed inset-0 z-50 hidden">
            <div class="absolute inset-0 bg-black/30" id="modal-overlay"></div>
            <div class="modal-enter absolute bottom-0 left-0 right-0 ${widget.themeMode == ThemeMode.light ? 'bg-white' : 'bg-gray-800'} rounded-t-2xl max-h-[70vh] shadow-2xl">
                <div class="p-5 ${widget.themeMode == ThemeMode.light ? 'border-gray-200' : 'border-gray-700'} border-b flex items-center justify-between">
                    <h3 id="modal-title" class="text-xl font-semibold ${widget.themeMode == ThemeMode.light ? 'text-gray-900' : 'text-white'}">Rise</h3>
                    <button id="modal-close" class="btn-active p-1 ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">
                        <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="p-4 overflow-y-auto" style="max-height: calc(70vh - 120px);">
                    <div class="mb-4">
                        <label class="text-sm font-semibold ${widget.themeMode == ThemeMode.light ? 'text-gray-600' : 'text-gray-300'} mb-2 block">Valor</label>
                        <input type="number" id="stake-input" value="1.00" step="0.01" min="0.35"
                            class="w-full ${widget.themeMode == ThemeMode.light ? 'bg-gray-100 border-gray-200 text-gray-900' : 'bg-gray-700 border-gray-600 text-white'} px-4 py-3 rounded-xl border">
                    </div>

                    <div class="mb-4">
                        <label class="text-sm font-semibold ${widget.themeMode == ThemeMode.light ? 'text-gray-600' : 'text-gray-300'} mb-2 block">Duração</label>
                        <div class="flex gap-2">
                            <input type="number" id="duration-input" value="5" min="1"
                                class="flex-1 ${widget.themeMode == ThemeMode.light ? 'bg-gray-100 border-gray-200 text-gray-900' : 'bg-gray-700 border-gray-600 text-white'} px-4 py-3 rounded-xl border">
                            <div class="${widget.themeMode == ThemeMode.light ? 'bg-gray-100 border-gray-200' : 'bg-gray-700 border-gray-600'} rounded-xl flex p-1 border">
                                <button data-unit="t" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit bg-green-500 text-white">
                                    Ticks
                                </button>
                                <button data-unit="s" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">
                                    Seg
                                </button>
                                <button data-unit="m" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ${widget.themeMode == ThemeMode.light ? 'text-gray-500' : 'text-gray-400'}">
                                    Min
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="pb-3">
                        <div id="loading-proposal" class="${widget.themeMode == ThemeMode.light ? 'bg-gray-100 border-gray-200' : 'bg-gray-700 border-gray-600'} border py-4 rounded-xl flex items-center justify-center gap-2">
                            <div class="w-5 h-5 border-2 ${widget.themeMode == ThemeMode.light ? 'border-gray-300 border-t-gray-600' : 'border-gray-600 border-t-gray-300'} rounded-full animate-spin"></div>
                            <span class="${widget.themeMode == ThemeMode.light ? 'text-gray-600' : 'text-gray-300'} font-semibold">Carregando...</span>
                        </div>
                        <button id="execute-trade" class="hidden w-full py-4 rounded-xl font-bold text-white btn-active">
                            Executar Trade
                        </button>
                    </div>
                </div>
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
            chartWs: null,
            chart: null,
            candleSeries: null,
            areaSeries: null,
            balance: null,
            currency: 'USD',
            contractType: 'CALL',
            proposalId: null,
            durationUnit: 't',
            chartMode: 'candles',
            selectedTimeframe: 0,
            candles: [],
            ticks: [],
            proposalTimeout: null
        };

        const el = {
            mainScroll: document.getElementById('main-scroll'),
            btnCandles: document.getElementById('btn-candles'),
            btnLine: document.getElementById('btn-line'),
            timeframes: document.querySelectorAll('[data-tf]'),
            chartWrapper: document.getElementById('chart-wrapper'),
            chartContainer: document.getElementById('chart-container'),
            currentPrice: document.getElementById('current-price'),
            priceChange: document.getElementById('price-change'),
            btnRise: document.getElementById('btn-rise'),
            btnFall: document.getElementById('btn-fall'),
            tradeModal: document.getElementById('trade-modal'),
            modalOverlay: document.getElementById('modal-overlay'),
            modalClose: document.getElementById('modal-close'),
            modalTitle: document.getElementById('modal-title'),
            stakeInput: document.getElementById('stake-input'),
            durationInput: document.getElementById('duration-input'),
            durationUnits: document.querySelectorAll('.duration-unit'),
            loadingProposal: document.getElementById('loading-proposal'),
            executeTradeBtn: document.getElementById('execute-trade')
        };

        function init() {
            initChart();
            connectWebSocket();
            setupEventListeners();
            setTimeout(() => window.flutter_inappwebview?.callHandler('onPageLoaded'), 1000);
        }

        function initChart() {
            const isDark = ${widget.themeMode == ThemeMode.dark};
            state.chart = LightweightCharts.createChart(el.chartContainer, {
                width: el.chartContainer.clientWidth,
                height: el.chartContainer.clientHeight,
                layout: {
                    background: { color: isDark ? '#1F2937' : '#ffffff' },
                    textColor: isDark ? '#9ca3af' : '#374151'
                },
                grid: {
                    vertLines: { color: isDark ? '#374151' : '#f3f4f6' },
                    horzLines: { color: isDark ? '#374151' : '#f3f4f6' }
                },
                rightPriceScale: { visible: true, borderVisible: false },
                timeScale: { rightOffset: 12, barSpacing: 12, visible: true }
            });

            state.candleSeries = state.chart.addCandlestickSeries({
                upColor: '#10b981',
                downColor: '#ef4444',
                wickUpColor: '#10b981',
                wickDownColor: '#ef4444',
                borderVisible: false
            });

            state.areaSeries = state.chart.addAreaSeries({
                topColor: 'rgba(16, 185, 129, 0.4)',
                bottomColor: 'rgba(16, 185, 129, 0)',
                lineColor: '#10b981',
                lineWidth: 2
            });

            state.areaSeries.setData([]);
        }

        function connectWebSocket() {
            state.ws = new WebSocket(WS_URL);
            
            state.ws.onopen = () => {
                console.log('Connected to API');
                state.ws.send(JSON.stringify({ authorize: API_TOKEN }));
            };
            
            state.ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                if (data.error) {
                    console.error('API Error:', data.error);
                    return;
                }
                
                if (data.msg_type === 'authorize') {
                    state.balance = parseFloat(data.authorize.balance);
                    state.currency = data.authorize.currency;
                    window.flutter_inappwebview?.callHandler('updateBalance', {
                        balance: state.balance.toFixed(2),
                        currency: state.currency
                    });
                    state.ws.send(JSON.stringify({ balance: 1, subscribe: 1 }));
                    connectChartWebSocket();
                } else if (data.msg_type === 'balance') {
                    state.balance = parseFloat(data.balance.balance);
                    state.currency = data.balance.currency;
                    window.flutter_inappwebview?.callHandler('updateBalance', {
                        balance: state.balance.toFixed(2),
                        currency: state.currency
                    });
                } else if (data.msg_type === 'proposal') {
                    if (data.proposal.id) {
                        state.proposalId = data.proposal.id;
                        el.loadingProposal.classList.add('hidden');
                        el.executeTradeBtn.classList.remove('hidden');
                    }
                } else if (data.msg_type === 'buy') {
                    if (data.buy.contract_id) {
                        closeTradeModal();
                        showNotification('Trade executado com sucesso!');
                        window.flutter_inappwebview?.callHandler('onTradeBought', {
                            contract_id: data.buy.contract_id
                        });
                    }
                }
            };
            
            state.ws.onerror = (error) => console.error('WS Error:', error);
            state.ws.onclose = () => setTimeout(connectWebSocket, 3000);
        }

        function connectChartWebSocket() {
            if (state.chartWs) {
                state.chartWs.close();
            }
            
            state.candles = [];
            state.ticks = [];
            
            state.chartWs = new WebSocket(WS_URL);
            
            state.chartWs.onopen = () => {
                if (state.selectedTimeframe === 0) {
                    state.chartWs.send(JSON.stringify({
                        ticks: MARKET_SYMBOL,
                        subscribe: 1
                    }));
                } else {
                    state.chartWs.send(JSON.stringify({
                        ticks_history: MARKET_SYMBOL,
                        adjust_start_time: 1,
                        count: 100,
                        end: 'latest',
                        granularity: state.selectedTimeframe,
                        style: 'candles',
                        subscribe: 1
                    }));
                }
            };
            
            state.chartWs.onmessage = (event) => {
                const data = JSON.parse(event.data);
                if (data.error) return;
                
                if (data.msg_type === 'history') {
                    const prices = data.history.prices;
                    const times = data.history.times;
                    
                    if (state.selectedTimeframe === 0) {
                        state.ticks = times.map((time, i) => ({
                            time: time,
                            value: parseFloat(prices[i])
                        }));
                    }
                    
                    updateChart();
                } else if (data.msg_type === 'tick') {
                    const price = parseFloat(data.tick.quote);
                    el.currentPrice.textContent = price.toFixed(2);
                    
                    state.ticks.push({
                        time: data.tick.epoch,
                        value: price
                    });
                    
                    if (state.chartMode === 'line') {
                        state.areaSeries.update({
                            time: data.tick.epoch,
                            value: price
                        });
                    }
                } else if (data.msg_type === 'ohlc') {
                    const candle = {
                        time: data.ohlc.epoch,
                        open: parseFloat(data.ohlc.open),
                        high: parseFloat(data.ohlc.high),
                        low: parseFloat(data.ohlc.low),
                        close: parseFloat(data.ohlc.close)
                    };
                    
                    const lastIndex = state.candles.length - 1;
                    if (lastIndex >= 0 && state.candles[lastIndex].time === candle.time) {
                        state.candles[lastIndex] = candle;
                    } else {
                        state.candles.push(candle);
                    }
                    
                    if (state.chartMode === 'candles') {
                        state.candleSeries.update(candle);
                    }
                    
                    el.currentPrice.textContent = candle.close.toFixed(2);
                }
            };
        }

        function updateChart() {
            if (state.chartMode === 'candles') {
                state.areaSeries.setData([]);
                if (state.candles.length > 0) {
                    state.candleSeries.setData(state.candles);
                }
            } else {
                state.candleSeries.setData([]);
                if (state.candles.length > 0) {
                    const lineData = state.candles.map(c => ({ time: c.time, value: c.close }));
                    state.areaSeries.setData(lineData);
                } else if (state.ticks.length > 0) {
                    state.areaSeries.setData(state.ticks);
                }
            }
            
            if (state.chart) {
                state.chart.timeScale().fitContent();
            }
        }

        function setupEventListeners() {
            const isDark = ${widget.themeMode == ThemeMode.dark};
            
            el.btnCandles.addEventListener('click', () => {
                state.chartMode = 'candles';
                el.btnCandles.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors ' + (isDark ? 'bg-gray-700 text-white' : 'bg-white text-gray-900') + ' shadow-sm';
                el.btnLine.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors ' + (isDark ? 'text-gray-400' : 'text-gray-500');
                updateChart();
            });
            
            el.btnLine.addEventListener('click', () => {
                state.chartMode = 'line';
                el.btnLine.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors ' + (isDark ? 'bg-gray-700 text-white' : 'bg-white text-gray-900') + ' shadow-sm';
                el.btnCandles.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors ' + (isDark ? 'text-gray-400' : 'text-gray-500');
                updateChart();
            });
            
            el.timeframes.forEach(btn => {
                btn.addEventListener('click', () => {
                    el.timeframes.forEach(b => {
                        b.className = 'px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ' + (isDark ? 'text-gray-400' : 'text-gray-500');
                    });
                    btn.className = 'px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active ' + (isDark ? 'bg-gray-700 text-white' : 'bg-gray-200 text-gray-900');
                    state.selectedTimeframe = parseInt(btn.dataset.tf);
                    connectChartWebSocket();
                });
            });
            
            el.btnRise.addEventListener('click', () => openTradeModal('CALL'));
            el.btnFall.addEventListener('click', () => openTradeModal('PUT'));
            el.modalClose.addEventListener('click', closeTradeModal);
            el.modalOverlay.addEventListener('click', closeTradeModal);
            
            el.durationUnits.forEach(btn => {
                btn.addEventListener('click', () => {
                    state.durationUnit = btn.dataset.unit;
                    const color = state.contractType === 'CALL' ? 'bg-green-500' : 'bg-red-500';
                    el.durationUnits.forEach(b => {
                        b.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ' + (isDark ? 'text-gray-400' : 'text-gray-500');
                    });
                    btn.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ' + color + ' text-white';
                    requestProposal();
                });
            });
            
            el.stakeInput.addEventListener('input', () => {
                clearTimeout(state.proposalTimeout);
                state.proposalTimeout = setTimeout(requestProposal, 500);
            });
            
            el.durationInput.addEventListener('input', () => {
                clearTimeout(state.proposalTimeout);
                state.proposalTimeout = setTimeout(requestProposal, 500);
            });
            
            el.executeTradeBtn.addEventListener('click', executeTrade);
            
            window.addEventListener('resize', () => {
                if (state.chart) {
                    state.chart.applyOptions({
                        width: el.chartContainer.clientWidth,
                        height: el.chartContainer.clientHeight
                    });
                }
            });
        }

        function openTradeModal(type) {
            state.contractType = type;
            el.modalTitle.textContent = type === 'CALL' ? 'Rise' : 'Fall';
            el.tradeModal.classList.remove('hidden');
            
            const color = type === 'CALL' ? 'bg-green-500' : 'bg-red-500';
            el.executeTradeBtn.className = 'w-full py-4 rounded-xl font-bold text-white btn-active ' + color;
            
            const isDark = ${widget.themeMode == ThemeMode.dark};
            el.durationUnits.forEach(btn => {
                if (btn.dataset.unit === state.durationUnit) {
                    btn.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ' + color + ' text-white';
                } else {
                    btn.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ' + (isDark ? 'text-gray-400' : 'text-gray-500');
                }
            });
            
            requestProposal();
        }

        function closeTradeModal() {
            el.tradeModal.classList.add('hidden');
            state.proposalId = null;
        }

        function requestProposal() {
            el.loadingProposal.classList.remove('hidden');
            el.executeTradeBtn.classList.add('hidden');
            state.proposalId = null;
            
            state.ws.send(JSON.stringify({
                proposal: 1,
                amount: parseFloat(el.stakeInput.value) || 1.0,
                basis: 'stake',
                contract_type: state.contractType,
                currency: state.currency,
                duration: parseInt(el.durationInput.value) || 5,
                duration_unit: state.durationUnit,
                symbol: MARKET_SYMBOL
            }));
        }

        function executeTrade() {
            if (!state.proposalId) return;
            state.ws.send(JSON.stringify({
                buy: state.proposalId,
                price: parseFloat(el.stakeInput.value) || 1.0
            }));
        }

        function showNotification(message) {
            const n = document.createElement('div');
            n.className = 'fixed top-4 left-4 right-4 p-4 rounded-xl font-semibold z-50 bg-green-500 text-white shadow-lg';
            n.textContent = message;
            document.body.appendChild(n);
            setTimeout(() => {
                n.style.opacity = '0';
                n.style.transition = 'opacity 0.3s';
                setTimeout(() => n.remove(), 300);
            }, 3000);
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
                handlerName: 'onTradeBought',
                callback: (args) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trade executado! ID: ${args[0]['contract_id']}'),
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
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const DerivApp());
}

class DerivApp extends StatelessWidget {
  const DerivApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deriv Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
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
  InAppWebViewController? _webViewController;

  final String htmlContent = '''
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#ffffff">
    <meta name="apple-mobile-web-app-capable" content="yes">
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

        .btn-active:active {
            transform: scale(0.97);
            opacity: 0.8;
        }

        .modal-enter {
            animation: modalSlide 0.3s cubic-bezier(0.32, 0.72, 0, 1);
        }

        @keyframes modalSlide {
            from { 
                transform: translateY(100%);
            }
            to { 
                transform: translateY(0);
            }
        }

        input:focus {
            outline: none;
        }

        #main-scroll {
            height: calc(100vh - 76px);
            overflow-y: auto;
            overflow-x: hidden;
            -webkit-overflow-scrolling: touch;
        }

        #chart-wrapper {
            height: 520px;
            margin: 12px;
        }
    </style>
</head>
<body class="bg-white text-gray-900">
    <div class="h-screen flex flex-col">
        <!-- Header -->
        <header class="bg-white border-b border-gray-200 px-4 py-3 flex items-center justify-between flex-shrink-0">
            <div class="flex items-center gap-3 flex-1 min-w-0">
                <div class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center flex-shrink-0">
                    <svg class="w-5 h-5 text-gray-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                    </svg>
                </div>
                <div class="flex-1 min-w-0">
                    <h1 class="text-sm font-bold truncate">Volatility 25 (1s) Index</h1>
                    <p class="text-xs text-gray-500">1HZ25V</p>
                </div>
            </div>
            <div class="text-right">
                <p class="text-xs text-gray-500">Saldo</p>
                <p id="balance" class="text-sm font-bold">232.14 USD</p>
            </div>
        </header>

        <!-- Scrollable Content -->
        <div id="main-scroll">
            <!-- Chart Type Toggle -->
            <div class="px-4 pt-3">
                <div class="bg-gray-100 rounded-lg p-0.5 flex">
                    <button id="btn-candles" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors bg-white text-gray-900 shadow-sm">
                        Candles
                    </button>
                    <button id="btn-line" class="flex-1 py-2 rounded-md text-sm font-semibold transition-colors text-gray-500">
                        Line
                    </button>
                </div>
            </div>

            <!-- Timeframes -->
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

            <!-- Chart Container -->
            <div id="chart-wrapper" class="rounded-xl overflow-hidden bg-white border border-gray-200">
                <div id="chart-container" class="w-full h-full"></div>
            </div>

            <!-- Price Display -->
            <div class="px-4 py-4 pb-32">
                <p id="current-price" class="text-3xl font-bold text-gray-900">730017.68</p>
                <p id="price-change" class="text-sm mt-1 text-gray-500">+0.02%</p>
            </div>
        </div>

        <!-- Trade Buttons - Fixed Bottom -->
        <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-4 py-3 flex gap-3 z-10">
            <button id="btn-rise" class="flex-1 bg-green-500 py-4 rounded-xl font-bold text-white btn-active">
                Rise
            </button>
            <button id="btn-fall" class="flex-1 bg-red-500 py-4 rounded-xl font-bold text-white btn-active">
                Fall
            </button>
        </div>

        <!-- Trade Modal -->
        <div id="trade-modal" class="fixed inset-0 z-50 hidden">
            <div class="absolute inset-0 bg-black/30" id="modal-overlay"></div>
            <div class="modal-enter absolute bottom-0 left-0 right-0 bg-white rounded-t-2xl max-h-[70vh] shadow-2xl">
                <div class="p-5 border-b border-gray-200 flex items-center justify-between">
                    <h3 id="modal-title" class="text-xl font-semibold text-gray-900">Rise</h3>
                    <button id="modal-close" class="btn-active p-1 text-gray-500">
                        <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="p-4 overflow-y-auto" style="max-height: calc(70vh - 120px);">
                    <div class="mb-4">
                        <label class="text-sm font-semibold text-gray-600 mb-2 block">Valor</label>
                        <input type="number" id="stake-input" value="1.00" step="0.01" min="0.35"
                            class="w-full bg-gray-100 px-4 py-3 rounded-xl text-gray-900 border border-gray-200">
                    </div>

                    <div class="mb-4">
                        <label class="text-sm font-semibold text-gray-600 mb-2 block">Duração</label>
                        <div class="flex gap-2">
                            <input type="number" id="duration-input" value="5" min="1"
                                class="flex-1 bg-gray-100 px-4 py-3 rounded-xl text-gray-900 border border-gray-200">
                            <div class="bg-gray-100 rounded-xl flex p-1 border border-gray-200">
                                <button data-unit="t" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit bg-green-500 text-white">
                                    Ticks
                                </button>
                                <button data-unit="s" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500">
                                    Seg
                                </button>
                                <button data-unit="m" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500">
                                    Min
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="pb-3">
                        <div id="loading-proposal" class="bg-gray-100 border border-gray-200 py-4 rounded-xl flex items-center justify-center gap-2">
                            <div class="w-5 h-5 border-2 border-gray-300 border-t-gray-600 rounded-full animate-spin"></div>
                            <span class="text-gray-600 font-semibold">Carregando...</span>
                        </div>
                        <button id="execute-trade" class="hidden w-full py-4 rounded-xl font-bold text-white btn-active">
                            <div class="text-center">
                                <div class="text-lg">Executar Trade</div>
                                <div id="payout-display" class="text-sm opacity-90 mt-1">Lucro potencial: 0.00 USD</div>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const APP_ID = 71954;
        const API_TOKEN = 'nUYzSZmUXrXmBmD';
        const MARKET_SYMBOL = '1HZ25V';
        const WS_URL = `wss://ws.derivws.com/websockets/v3?app_id=${'\\$'}{APP_ID}`;

        const state = {
            ws: null,
            chartWs: null,
            chart: null,
            candleSeries: null,
            areaSeries: null,
            balance: 232.14,
            currency: 'USD',
            chartMode: 'candles',
            selectedTimeframe: 0,
            contractType: 'CALL',
            proposalId: null,
            durationUnit: 't',
            candles: [],
            ticks: [],
            proposalTimeout: null
        };

        const el = {
            balance: document.getElementById('balance'),
            btnCandles: document.getElementById('btn-candles'),
            btnLine: document.getElementById('btn-line'),
            timeframes: document.querySelectorAll('[data-tf]'),
            chartContainer: document.getElementById('chart-container'),
            currentPrice: document.getElementById('current-price'),
            priceChange: document.getElementById('price-change'),
            btnRise: document.getElementById('btn-rise'),
            btnFall: document.getElementById('btn-fall'),
            tradeModal: document.getElementById('trade-modal'),
            modalOverlay: document.getElementById('modal-overlay'),
            modalClose: document.getElementById('modal-close'),
            modalTitle: document.getElementById('modal-title'),
            stakeInput: document.getElementById('stake-input'),
            durationInput: document.getElementById('duration-input'),
            durationUnits: document.querySelectorAll('.duration-unit'),
            loadingProposal: document.getElementById('loading-proposal'),
            executeTradeBtn: document.getElementById('execute-trade'),
            payoutDisplay: document.getElementById('payout-display')
        };

        function init() {
            connectWebSocket();
            initChart();
            connectChartWebSocket();
            setupEventListeners();
        }

        function connectWebSocket() {
            state.ws = new WebSocket(WS_URL);
            
            state.ws.onopen = () => {
                console.log('Connected');
                state.ws.send(JSON.stringify({ authorize: API_TOKEN }));
            };
            
            state.ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleMessage(data);
            };
            
            state.ws.onerror = (error) => {
                console.error('WebSocket error:', error);
            };
            
            state.ws.onclose = () => {
                console.log('Disconnected');
                setTimeout(connectWebSocket, 3000);
            };
        }

        function handleMessage(data) {
            if (data.error) {
                console.error('API Error:', data.error);
                return;
            }
            
            const msgType = data.msg_type;
            
            if (msgType === 'authorize') {
                state.balance = parseFloat(data.authorize.balance);
                state.currency = data.authorize.currency;
                el.balance.textContent = `${'\\$'}{state.balance.toFixed(2)} ${'\\$'}{state.currency}`;
                
                state.ws.send(JSON.stringify({ balance: 1, subscribe: 1 }));
            } else if (msgType === 'balance') {
                state.balance = parseFloat(data.balance.balance);
                state.currency = data.balance.currency;
                el.balance.textContent = `${'\\$'}{state.balance.toFixed(2)} ${'\\$'}{state.currency}`;
            } else if (msgType === 'proposal') {
                state.proposalId = data.proposal.id;
                const payout = parseFloat(data.proposal.payout || 0);
                const stake = parseFloat(el.stakeInput.value || 0);
                const profit = payout - stake;
                el.payoutDisplay.textContent = `Lucro potencial: ${'\\$'}{profit.toFixed(2)} USD`;
                el.loadingProposal.classList.add('hidden');
                el.executeTradeBtn.classList.remove('hidden');
            } else if (msgType === 'buy') {
                showNotification('Trade executado com sucesso!');
                closeTradeModal();
            }
        }

        function initChart() {
            state.chart = LightweightCharts.createChart(el.chartContainer, {
                width: el.chartContainer.clientWidth,
                height: el.chartContainer.clientHeight,
                layout: {
                    background: { color: '#ffffff' },
                    textColor: '#6b7280'
                },
                grid: {
                    vertLines: { color: '#f3f4f6' },
                    horzLines: { color: '#f3f4f6' }
                },
                rightPriceScale: {
                    borderVisible: false
                },
                timeScale: {
                    borderVisible: false,
                    timeVisible: true
                }
            });

            state.candleSeries = state.chart.addCandlestickSeries({
                upColor: '#10b981',
                downColor: '#ef4444',
                wickUpColor: '#10b981',
                wickDownColor: '#ef4444',
                borderVisible: false
            });

            state.areaSeries = state.chart.addAreaSeries({
                topColor: 'rgba(16, 185, 129, 0.4)',
                bottomColor: 'rgba(16, 185, 129, 0)',
                lineColor: '#10b981',
                lineWidth: 2
            });

            updateChart();
        }

        function connectChartWebSocket() {
            if (state.chartWs) {
                state.chartWs.close();
            }

            state.chartWs = new WebSocket(WS_URL);
            
            state.chartWs.onopen = () => {
                subscribeToChartData();
            };
            
            state.chartWs.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleChartData(data);
            };
        }

        function subscribeToChartData() {
            state.candles = [];
            state.ticks = [];

            if (state.selectedTimeframe === 0) {
                state.chartWs.send(JSON.stringify({
                    ticks: MARKET_SYMBOL,
                    subscribe: 1
                }));
            } else {
                const now = Math.floor(Date.now() / 1000);
                const start = now - (state.selectedTimeframe * 1000);

                state.chartWs.send(JSON.stringify({
                    ticks_history: MARKET_SYMBOL,
                    adjust_start_time: 1,
                    count: 1000,
                    end: 'latest',
                    start: start,
                    style: 'candles',
                    granularity: state.selectedTimeframe
                }));

                state.chartWs.send(JSON.stringify({
                    ticks_history: MARKET_SYMBOL,
                    adjust_start_time: 1,
                    count: 1,
                    end: 'latest',
                    start: 1,
                    style: 'candles',
                    granularity: state.selectedTimeframe,
                    subscribe: 1
                }));
            }
        }

        function handleChartData(data) {
            if (data.msg_type === 'history' && data.candles) {
                state.candles = data.candles.map(c => ({
                    time: c.epoch,
                    open: parseFloat(c.open),
                    high: parseFloat(c.high),
                    low: parseFloat(c.low),
                    close: parseFloat(c.close)
                }));
                updateChart();
                if (state.candles.length > 0) {
                    const last = state.candles[state.candles.length - 1];
                    el.currentPrice.textContent = last.close.toFixed(2);
                }
            } else if (data.msg_type === 'tick') {
                const price = parseFloat(data.tick.quote);
                el.currentPrice.textContent = price.toFixed(2);
                
                state.ticks.push({
                    time: data.tick.epoch,
                    value: price
                });
                
                if (state.chartMode === 'line' && state.selectedTimeframe === 0) {
                    state.areaSeries.update({
                        time: data.tick.epoch,
                        value: price
                    });
                }
            } else if (data.msg_type === 'ohlc') {
                const candle = {
                    time: data.ohlc.epoch,
                    open: parseFloat(data.ohlc.open),
                    high: parseFloat(data.ohlc.high),
                    low: parseFloat(data.ohlc.low),
                    close: parseFloat(data.ohlc.close)
                };
                
                const lastIndex = state.candles.length - 1;
                if (lastIndex >= 0 && state.candles[lastIndex].time === candle.time) {
                    state.candles[lastIndex] = candle;
                } else {
                    state.candles.push(candle);
                }
                
                if (state.chartMode === 'candles') {
                    state.candleSeries.update(candle);
                }
                
                el.currentPrice.textContent = candle.close.toFixed(2);
            }
        }

        function updateChart() {
            if (state.chartMode === 'candles') {
                state.areaSeries.setData([]);
                if (state.candles.length > 0) {
                    state.candleSeries.setData(state.candles);
                }
            } else {
                state.candleSeries.setData([]);
                if (state.candles.length > 0) {
                    const lineData = state.candles.map(c => ({ time: c.time, value: c.close }));
                    state.areaSeries.setData(lineData);
                } else if (state.ticks.length > 0) {
                    state.areaSeries.setData(state.ticks);
                }
            }
            
            if (state.chart) {
                state.chart.timeScale().fitContent();
            }
        }

        function setupEventListeners() {
            el.btnCandles.addEventListener('click', () => {
                state.chartMode = 'candles';
                el.btnCandles.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors bg-white text-gray-900 shadow-sm';
                el.btnLine.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors text-gray-500';
                updateChart();
            });
            
            el.btnLine.addEventListener('click', () => {
                state.chartMode = 'line';
                el.btnLine.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors bg-white text-gray-900 shadow-sm';
                el.btnCandles.className = 'flex-1 py-2 rounded-md text-sm font-semibold transition-colors text-gray-500';
                updateChart();
            });
            
            el.timeframes.forEach(btn => {
                btn.addEventListener('click', () => {
                    el.timeframes.forEach(b => {
                        b.className = 'px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active text-gray-500';
                    });
                    btn.className = 'px-4 py-1.5 rounded-lg text-sm font-semibold whitespace-nowrap btn-active bg-gray-200 text-gray-900';
                    state.selectedTimeframe = parseInt(btn.dataset.tf);
                    connectChartWebSocket();
                });
            });
            
            el.btnRise.addEventListener('click', () => openTradeModal('CALL'));
            el.btnFall.addEventListener('click', () => openTradeModal('PUT'));
            el.modalClose.addEventListener('click', closeTradeModal);
            el.modalOverlay.addEventListener('click', closeTradeModal);
            
            el.durationUnits.forEach(btn => {
                btn.addEventListener('click', () => {
                    state.durationUnit = btn.dataset.unit;
                    const color = state.contractType === 'CALL' ? 'bg-green-500' : 'bg-red-500';
                    el.durationUnits.forEach(b => {
                        b.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500';
                    });
                    btn.className = `px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ${'\\$'}{color} text-white`;
                    requestProposal();
                });
            });
            
            el.stakeInput.addEventListener('input', () => {
                clearTimeout(state.proposalTimeout);
                state.proposalTimeout = setTimeout(requestProposal, 500);
            });
            
            el.durationInput.addEventListener('input', () => {
                clearTimeout(state.proposalTimeout);
                state.proposalTimeout = setTimeout(requestProposal, 500);
            });
            
            el.executeTradeBtn.addEventListener('click', executeTrade);
            
            window.addEventListener('resize', () => {
                if (state.chart) {
                    state.chart.applyOptions({
                        width: el.chartContainer.clientWidth,
                        height: el.chartContainer.clientHeight
                    });
                }
            });
        }

        function openTradeModal(type) {
            state.contractType = type;
            el.modalTitle.textContent = type === 'CALL' ? 'Rise' : 'Fall';
            el.tradeModal.classList.remove('hidden');
            
            const color = type === 'CALL' ? 'bg-green-500' : 'bg-red-500';
            el.executeTradeBtn.className = `w-full py-4 rounded-xl font-bold text-white btn-active ${'\\$'}{color}`;
            
            el.durationUnits.forEach(btn => {
                if (btn.dataset.unit === state.durationUnit) {
                    btn.className = `px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit ${'\\$'}{color} text-white`;
                } else {
                    btn.className = 'px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500';
                }
            });
            
            requestProposal();
        }

        function closeTradeModal() {
            el.tradeModal.classList.add('hidden');
            state.proposalId = null;
        }

        function requestProposal() {
            el.loadingProposal.classList.remove('hidden');
            el.executeTradeBtn.classList.add('hidden');
            state.proposalId = null;
            
            state.ws.send(JSON.stringify({
                proposal: 1,
                amount: parseFloat(el.stakeInput.value) || 1.0,
                basis: 'stake',
                contract_type: state.contractType,
                currency: state.currency,
                duration: parseInt(el.durationInput.value) || 5,
                duration_unit: state.durationUnit,
                symbol: MARKET_SYMBOL
            }));
        }

        function executeTrade() {
            if (!state.proposalId) return;
            state.ws.send(JSON.stringify({
                buy: state.proposalId,
                price: parseFloat(el.stakeInput.value) || 1.0
            }));
        }

        function showNotification(message) {
            const n = document.createElement('div');
            n.className = 'fixed top-4 left-4 right-4 p-4 rounded-xl font-semibold z-50 bg-green-500 text-white shadow-lg';
            n.textContent = message;
            document.body.appendChild(n);
            setTimeout(() => {
                n.style.opacity = '0';
                n.style.transition = 'opacity 0.3s';
                setTimeout(() => n.remove(), 300);
            }, 3000);
        }

        init();
    </script>
</body>
</html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: InAppWebView(
          initialData: InAppWebViewInitialData(data: htmlContent),
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
            _webViewController = controller;
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint('Console: ${consoleMessage.message}');
          },
        ),
      ),
    );
  }
}
