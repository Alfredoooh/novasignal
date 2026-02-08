import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElephantBet Zone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  String url = "https://elephantbetzone.com/";

  @override
  void initState() {
    super.initState();
    _updateStatusBarColor(url);
  }

  void _updateStatusBarColor(String currentUrl) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  bool _isProblematicPage(String currentUrl) {
    return currentUrl.contains('elephantbetzone.com/app/home') ||
        currentUrl.contains('elephantbetzone.com/app/lotoSports');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController?.canGoBack() ?? false) {
          webViewController?.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            useOnDownloadStart: true,
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            cacheEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            useHybridComposition: true,
            allowContentAccess: true,
            allowFileAccess: true,
            supportMultipleWindows: true,
            allowsInlineMediaPlayback: true,
            allowsBackForwardNavigationGestures: true,
            transparentBackground: false,
            verticalScrollBarEnabled: true,
            horizontalScrollBarEnabled: true,
            disableVerticalScroll: false,
            disableHorizontalScroll: false,
            supportZoom: false,
            builtInZoomControls: false,
            displayZoomControls: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            setState(() {
              this.url = url.toString();
            });
            _updateStatusBarColor(url.toString());
          },
          onLoadStop: (controller, url) async {
            setState(() {
              this.url = url.toString();
            });
            _updateStatusBarColor(url.toString());
            
            // Aplica correção APENAS nas páginas home e lotoSports
            if (_isProblematicPage(url.toString())) {
              await controller.evaluateJavascript(source: """
                (function() {
                  // Espera o DOM estar completamente carregado
                  setTimeout(function() {
                    // Corrige o AppBar/Header especificamente
                    var header = document.querySelector('header');
                    var appBar = document.querySelector('[class*="AppBar"]');
                    var toolbar = document.querySelector('[class*="Toolbar"]');
                    var nav = document.querySelector('nav');
                    
                    // Tenta encontrar o elemento do header por diferentes seletores
                    var headerElement = header || appBar || toolbar || nav;
                    
                    if (headerElement) {
                      // Força o tamanho normal do header
                      headerElement.style.cssText += `
                        height: 56px !important;
                        min-height: 56px !important;
                        max-height: 56px !important;
                        padding-top: 0 !important;
                        padding-bottom: 0 !important;
                      `;
                      
                      // Corrige elementos internos do header
                      var headerChildren = headerElement.querySelectorAll('*');
                      headerChildren.forEach(function(child) {
                        child.style.cssText += `
                          -webkit-text-size-adjust: 100% !important;
                          text-size-adjust: 100% !important;
                        `;
                      });
                    }
                    
                    // Adiciona CSS global para prevenir problemas
                    var style = document.createElement('style');
                    style.innerHTML = `
                      * {
                        -webkit-text-size-adjust: 100% !important;
                        text-size-adjust: 100% !important;
                      }
                      header, [class*="AppBar"], [class*="Toolbar"], nav {
                        height: 56px !important;
                        min-height: 56px !important;
                        max-height: 56px !important;
                      }
                    `;
                    document.head.appendChild(style);
                    
                    // Garante viewport correto
                    var meta = document.querySelector('meta[name="viewport"]');
                    if (!meta) {
                      meta = document.createElement('meta');
                      meta.name = 'viewport';
                      document.head.appendChild(meta);
                    }
                    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
                  }, 100);
                })();
              """);
            }
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            setState(() {
              this.url = url.toString();
            });
            _updateStatusBarColor(url.toString());
          },
          onConsoleMessage: (controller, consoleMessage) {
            // Opcional: para debug
            // print("Console: ${consoleMessage.message}");
          },
        ),
      ),
    );
  }
}
