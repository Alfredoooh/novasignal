import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF18191A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    if (isDark) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    }
    
    return MaterialApp(
      title: 'WebView App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        dialogBackgroundColor: bgColor,
        colorScheme: ColorScheme.light(
          surface: bgColor,
          primary: bgColor,
          onSurface: textColor,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          titleLarge: TextStyle(color: textColor),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: bgColor,
          surfaceTintColor: Colors.transparent,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: textColor,
          ),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF18191A),
        dialogBackgroundColor: const Color(0xFF18191A),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF18191A),
          primary: Color(0xFF18191A),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFF18191A),
          surfaceTintColor: Colors.transparent,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _hasError = false;
  String _errorMessage = '';
  String? _pageUrl;
  bool _isInitialized = false;

  final String _jsonUrl = 'https://alfredoooh.github.io/database/API/config.json';

  @override
  void initState() {
    super.initState();
    _checkConnectionAndInitialize();
  }

  Color get _bgColor {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? const Color(0xFF18191A) : Colors.white;
  }

  Color get _textColor {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color get _textSecondaryColor {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
  }

  Future<void> _checkConnectionAndInitialize() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _initializeWebView();
      }
    } catch (_) {
      _showDialog('Sem conexão', 'Verifique sua conexão com a internet.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectionAndInitialize();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeWebView() async {
    if (_isInitialized) return;
    
    setState(() {
      _hasError = false;
    });

    try {
      final url = await _fetchUrlFromGitHub();
      
      if (url == null || url.isEmpty) {
        _showDialog('Erro', 'URL não encontrada no arquivo de configuração.');
        return;
      }

      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        _showDialog('Erro', 'URL inválida: $url');
        return;
      }

      setState(() {
        _pageUrl = url;
      });

      late final PlatformWebViewControllerCreationParams params;
      
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(_bgColor);
      await controller.enableZoom(false);

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(false);
        (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
        
        // Configurações para melhor qualidade de renderização
        await (controller.platform as AndroidWebViewController).setGeolocationPermissionsPromptCallbacks(
          onShowPrompt: (request) async {
            return GeolocationPermissionsResponse(
              allow: true,
              retain: true,
            );
          },
        );
      }

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _hasError = false;
            });
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout) {
              _showDialog('Erro de conexão', 'Não foi possível carregar a página.');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

      // User Agent mais moderno para melhor renderização
      await controller.setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
      );

      await controller.loadRequest(Uri.parse(url));

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });

    } catch (e) {
      _showDialog('Erro', 'Erro ao inicializar o aplicativo.');
    }
  }

  Future<String?> _fetchUrlFromGitHub() async {
    try {
      print('Buscando URL de: $_jsonUrl');
      
      final response = await http.get(
        Uri.parse(_jsonUrl),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(
        const Duration(seconds: 10),
      );
      
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final url = jsonData['url'] as String?;
        
        print('URL extraída: $url');
        
        if (url == null || url.isEmpty) {
          print('ERRO: URL vazia ou nula no JSON');
          return null;
        }
        
        return url;
      } else {
        print('ERRO: Status code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('ERRO ao buscar URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: _bgColor,
        child: _isInitialized && _pageUrl != null
            ? WebViewWidget(controller: _controller)
            : Container(
                width: double.infinity,
                height: double.infinity,
                color: _bgColor,
              ),
      ),
    );
  }
}