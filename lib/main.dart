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
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  
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
    // Lista de páginas que devem ter statusbar com a cor do site
    bool isMainPage = currentUrl.contains('elephantbetzone.com/app/home') ||
        currentUrl.contains('elephantbetzone.com/app/lotoSports') ||
        currentUrl == 'https://elephantbetzone.com/' ||
        currentUrl.contains('elephantbetzone.com/#');

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
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
        backgroundColor: const Color(0xFF1976D2),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color(0xFF1976D2),
            ),
            Expanded(
              child: InAppWebView(
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
                  
                  // Injeta CSS para garantir que o header do site fique correto
                  await controller.evaluateJavascript(source: """
                    (function() {
                      var meta = document.querySelector('meta[name="viewport"]');
                      if (!meta) {
                        meta = document.createElement('meta');
                        meta.name = 'viewport';
                        document.head.appendChild(meta);
                      }
                      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
                      
                      var style = document.createElement('style');
                      style.innerHTML = 'body { padding-top: 0 !important; margin-top: 0 !important; }';
                      document.head.appendChild(style);
                    })();
                  """);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
