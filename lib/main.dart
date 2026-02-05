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
                        <input type="number" id="duration-input" value="5" step="1" min="1"
                            class="w-full bg-gray-100 px-4 py-3 rounded-xl text-gray-900 border border-gray-200">
                    </div>

                    <div class="mb-6 flex gap-2">
                        <button data-unit="t" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit bg-green-500 text-white">
                            Ticks
                        </button>
                        <button data-unit="s" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500">
                            Segundos
                        </button>
                        <button data-unit="m" class="px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit text-gray-500">
                            Minutos
                        </button>
                    </div>

                    <div id="loading-proposal" class="p-4 bg-gray-100 rounded-xl mb-4">
                        <p class="text-center text-gray-500">Carregando cotação...</p>
                    </div>

                    <div id="proposal-info" class="hidden mb-4 p-4 bg-gray-100 rounded-xl">
                        <div class="flex justify-between mb-2">
                            <span class="text-gray-600">Lucro Potencial:</span>
                            <span id="payout" class="font-bold text-gray-900">0.00 USD</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-600">Retorno:</span>
                            <span id="return" class="font-bold text-green-600">0%</span>
                        </div>
                    </div>

                    <button id="execute-trade" class="hidden w-full py-4 rounded-xl font-bold text-white btn-active bg-green-500">
                        Executar Negociação
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        const API_TOKEN = 'YOUR_API_TOKEN_HERE';
        const MARKET_SYMBOL = '1HZ25V';
        const WS_URL = 'wss://ws.derivws.com/websockets/v3?app_id=1089';
        
        const state = {
            ws: null,
            chartWs: null,
            chart: null,
            candleSeries: null,
            areaSeries: null,
            selectedTimeframe: 0,
            chartMode: 'candles',
            candles: [],
            ticks: [],
            balance: 0,
            currency: 'USD',
            contractType: 'CALL',
            durationUnit: 't',
            proposalId: null,
            proposalTimeout: null
        };
        
        const el = {
            balance: document.getElementById('balance'),
            currentPrice: document.getElementById('current-price'),
            priceChange: document.getElementById('price-change'),
            chartContainer: document.getElementById('chart-container'),
            btnCandles: document.getElementById('btn-candles'),
            btnLine: document.getElementById('btn-line'),
            timeframes: document.querySelectorAll('[data-tf]'),
            btnRise: document.getElementById('btn-rise'),
            btnFall: document.getElementById('btn-fall'),
            tradeModal: document.getElementById('trade-modal'),
            modalTitle: document.getElementById('modal-title'),
            modalClose: document.getElementById('modal-close'),
            modalOverlay: document.getElementById('modal-overlay'),
            stakeInput: document.getElementById('stake-input'),
            durationInput: document.getElementById('duration-input'),
            durationUnits: document.querySelectorAll('.duration-unit'),
            loadingProposal: document.getElementById('loading-proposal'),
            proposalInfo: document.getElementById('proposal-info'),
            payout: document.getElementById('payout'),
            returnEl: document.getElementById('return'),
            executeTradeBtn: document.getElementById('execute-trade')
        };

        function init() {
            initChart();
            connectWebSocket();
            setupEventListeners();
        }

        function initChart() {
            state.chart = LightweightCharts.createChart(el.chartContainer, {
                width: el.chartContainer.clientWidth,
                height: el.chartContainer.clientHeight,
                layout: {
                    background: { color: '#ffffff' },
                    textColor: '#374151'
                },
                grid: {
                    vertLines: { color: '#f3f4f6' },
                    horzLines: { color: '#f3f4f6' }
                },
                timeScale: {
                    timeVisible: true,
                    secondsVisible: true
                },
                crosshair: {
                    mode: LightweightCharts.CrosshairMode.Normal
                }
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
                console.log('Trading WebSocket Connected');
                state.ws.send(JSON.stringify({
                    authorize: API_TOKEN
                }));
            };
            
            state.ws.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleMessage(data);
            };
            
            state.ws.onerror = (error) => {
                console.error('Trading WebSocket Error:', error);
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
                el.balance.textContent = `\$\${state.balance.toFixed(2)} \${state.currency}`;
                
                state.ws.send(JSON.stringify({ balance: 1, subscribe: 1 }));
            } else if (msgType === 'balance') {
                state.balance = parseFloat(data.balance.balance);
                state.currency = data.balance.currency;
                el.balance.textContent = `\$\${state.balance.toFixed(2)} \${state.currency}`;
            } else if (msgType === 'proposal') {
                state.proposalId = data.proposal.id;
                const payout = parseFloat(data.proposal.payout);
                const stake = parseFloat(el.stakeInput.value);
                const profit = payout - stake;
                const returnPct = ((profit / stake) * 100).toFixed(2);
                
                el.payout.textContent = `\${profit.toFixed(2)} \${state.currency}`;
                el.returnEl.textContent = `\${returnPct}%`;
                
                el.loadingProposal.classList.add('hidden');
                el.proposalInfo.classList.remove('hidden');
                el.executeTradeBtn.classList.remove('hidden');
            } else if (msgType === 'buy') {
                closeTradeModal();
                showNotification('Negociação executada com sucesso!');
            }
        }

        function connectChartWebSocket() {
            if (state.chartWs) {
                state.chartWs.close();
            }
            
            state.candles = [];
            state.ticks = [];
            updateChart();
            
            state.chartWs = new WebSocket(WS_URL);
            
            state.chartWs.onopen = () => {
                console.log('Chart WebSocket Connected');
                
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
                        start: 1,
                        style: 'candles',
                        granularity: state.selectedTimeframe
                    }));
                }
            };
            
            state.chartWs.onmessage = (event) => {
                const data = JSON.parse(event.data);
                handleChartMessage(data);
            };
            
            state.chartWs.onerror = (error) => {
                console.error('Chart WebSocket Error:', error);
            };
        }

        function handleChartMessage(data) {
            if (data.error) {
                console.error('Chart API Error:', data.error);
                return;
            }
            
            const msgType = data.msg_type;
            
            if (msgType === 'tick') {
                const tick = {
                    time: Math.floor(data.tick.epoch),
                    value: parseFloat(data.tick.quote)
                };
                
                state.ticks.push(tick);
                if (state.ticks.length > 100) state.ticks.shift();
                
                if (state.chartMode === 'line' && state.selectedTimeframe === 0) {
                    state.areaSeries.update(tick);
                }
                
                el.currentPrice.textContent = tick.value.toFixed(2);
            } else if (msgType === 'candles' || msgType === 'history') {
                const candles = data.candles || [];
                state.candles = candles.map(c => ({
                    time: c.epoch,
                    open: parseFloat(c.open),
                    high: parseFloat(c.high),
                    low: parseFloat(c.low),
                    close: parseFloat(c.close)
                }));
                
                updateChart();
                
                if (state.candles.length > 0) {
                    const lastCandle = state.candles[state.candles.length - 1];
                    el.currentPrice.textContent = lastCandle.close.toFixed(2);
                }
                
                if (msgType === 'candles') {
                    state.chartWs.send(JSON.stringify({
                        ticks_history: MARKET_SYMBOL,
                        adjust_start_time: 1,
                        count: 100,
                        end: 'latest',
                        start: 1,
                        style: 'candles',
                        granularity: state.selectedTimeframe,
                        subscribe: 1
                    }));
                }
            } else if (msgType === 'ohlc') {
                const candle = {
                    time: data.ohlc.open_time,
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
                    btn.className = `px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit \${color} text-white`;
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
            el.executeTradeBtn.className = `w-full py-4 rounded-xl font-bold text-white btn-active \${color}`;
            
            el.durationUnits.forEach(btn => {
                if (btn.dataset.unit === state.durationUnit) {
                    btn.className = `px-3 py-2 rounded-lg text-sm font-semibold btn-active duration-unit \${color} text-white`;
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