import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';

// Import condicional apenas para mobile
import 'package:webview_flutter/webview_flutter.dart'
    if (dart.library.html) 'webview_flutter_stub.dart';

// Imports condicionais para web
import 'web_view_stub.dart'
    if (dart.library.html) 'web_view_web.dart';

class VerificacaoWebViewPage extends StatefulWidget {
  const VerificacaoWebViewPage({super.key});

  @override
  State<VerificacaoWebViewPage> createState() => _VerificacaoWebViewPageState();
}

class _VerificacaoWebViewPageState extends State<VerificacaoWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  double loadingProgress = 0.0;
  final String url = 'https://elephantbetzone.com/app/scanTicket/manualEntry';

  // Web specific
  dynamic _webViewHelper;
  String _viewId = 'webview-iframe-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebPlatform();
    } else {
      _initializeMobileWebView();
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _webViewHelper != null) {
      _webViewHelper?.dispose();
    }
    super.dispose();
  }

  // ==================== WEB PLATFORM ====================
  void _initializeWebPlatform() {
    if (!kIsWeb) return;

    _webViewHelper = createWebViewHelper(
      url: url,
      viewId: _viewId,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            loadingProgress = progress;
            isLoading = progress < 1.0;
          });
        }
      },
    );

    _webViewHelper?.initialize();

    Future.delayed(const Duration(milliseconds: 1500), () {
      _injectWebStyles();
    });
  }

  void _injectWebStyles() {
    if (!kIsWeb || _webViewHelper == null) return;

    try {
      final themeColors = _getThemeColors();
      final script = '''
        (function() {
          try {
            $themeColors
            ${_getStyleInjectionScript()}
          } catch (e) {
            console.error('Erro ao aplicar estilos:', e);
          }
        })();
      ''';

      _webViewHelper?.injectScript(script);
      debugPrint('✅ Estilos enviados para iframe web');
    } catch (e) {
      debugPrint('❌ Erro ao injetar estilos web: $e');
    }
  }

  void _reloadWebView() {
    if (!kIsWeb) return;

    if (_webViewHelper != null) {
      _webViewHelper?.reload();
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _injectWebStyles();
        }
      });
    }
  }

  // ==================== MOBILE PLATFORM ====================
  void _initializeMobileWebView() {
    if (kIsWeb) return;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                loadingProgress = progress / 100;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            Future.delayed(const Duration(milliseconds: 300), () {
              _injectMobileStyles();
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _injectMobileStyles() {
    if (kIsWeb) return;

    final themeColors = _getThemeColors();
    final script = '''
      (function() {
        try {
          $themeColors
          ${_getStyleInjectionScript()}
        } catch (error) {
          console.error('❌ Erro ao aplicar estilos:', error);
        }
      })();
    ''';

    try {
      controller.runJavaScript(script);
    } catch (e) {
      debugPrint('❌ Erro ao injetar JavaScript: $e');
    }
  }

  // ==================== THEME COLORS ====================
  String _getThemeColors() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return '''
        const theme = {
          background: '#121212',
          surface: '#1E1E1E',
          surfaceVariant: '#2C2C2E',
          primary: '#FF444F',
          primaryLight: '#FF6B73',
          primaryDark: '#E63946',
          secondary: '#1E88E5',
          text: '#FFFFFF',
          textSecondary: '#B0B0B0',
          border: '#3A3A3C',
          success: '#22C55E',
          error: '#EF4444',
          warning: '#F59E0B',
          cardBackground: '#2C2C2E',
          inputBackground: '#1E1E1E',
          isDark: true
        };
      ''';
    } else {
      return '''
        const theme = {
          background: '#FFFFFF',
          surface: '#F9F9F9',
          surfaceVariant: '#F3F3F3',
          primary: '#FF444F',
          primaryLight: '#FF6B73',
          primaryDark: '#E63946',
          secondary: '#1E88E5',
          text: '#1A1A1A',
          textSecondary: '#6B6B6B',
          border: '#E5E7EB',
          success: '#22C55E',
          error: '#EF4444',
          warning: '#F59E0B',
          cardBackground: '#FFFFFF',
          inputBackground: '#F9F9F9',
          isDark: false
        };
      ''';
    }
  }

  // ==================== STYLE INJECTION SCRIPT ====================
  String _getStyleInjectionScript() {
    return '''
      console.log('🎨 Aplicando tema:', theme.isDark ? 'Dark' : 'Light');
      
      const metaViewport = document.querySelector('meta[name="viewport"]') || document.createElement('meta');
      metaViewport.name = 'viewport';
      metaViewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
      if (!document.querySelector('meta[name="viewport"]')) {
        document.head.appendChild(metaViewport);
      }
      
      const styleId = 'custom-app-styles';
      let styleElement = document.getElementById(styleId);
      
      if (styleElement) {
        styleElement.remove();
      }
      
      styleElement = document.createElement('style');
      styleElement.id = styleId;
      styleElement.textContent = \`
        * {
          -webkit-tap-highlight-color: transparent !important;
          -webkit-font-smoothing: antialiased !important;
          -moz-osx-font-smoothing: grayscale !important;
        }
        
        html, body {
          background: \${theme.background} !important;
          color: \${theme.text} !important;
          overflow-x: hidden !important;
          overflow-y: auto !important;
          -webkit-overflow-scrolling: touch !important;
          margin: 0 !important;
          padding: 0 !important;
        }
        
        ::-webkit-scrollbar {
          display: none !important;
          width: 0 !important;
          height: 0 !important;
        }
        
        * {
          -ms-overflow-style: none !important;
          scrollbar-width: none !important;
        }
        
        ion-header, ion-toolbar, ion-footer, ion-tabs, ion-tab-bar,
        [class*="header"], [class*="toolbar"], [class*="footer"], [class*="tabbar"] {
          display: none !important;
          visibility: hidden !important;
          height: 0 !important;
          min-height: 0 !important;
          overflow: hidden !important;
        }
        
        ion-content {
          --background: \${theme.background} !important;
          --color: \${theme.text} !important;
          --padding-top: 0 !important;
          --padding-bottom: 0 !important;
          --offset-top: 0 !important;
          --offset-bottom: 0 !important;
        }
        
        ion-button, button:not(.close):not([class*="icon"]) {
          border-radius: 12px !important;
          padding: 12px 24px !important;
          font-weight: 600 !important;
          min-height: 44px !important;
        }
        
        ion-button[color="primary"], button.primary {
          --background: \${theme.primary} !important;
          background: \${theme.primary} !important;
          color: white !important;
        }
        
        ion-input, input:not([type="checkbox"]):not([type="radio"]) {
          --background: \${theme.inputBackground} !important;
          --color: \${theme.text} !important;
          background: \${theme.inputBackground} !important;
          border: 1px solid \${theme.border} !important;
          border-radius: 12px !important;
          padding: 12px 16px !important;
        }
      \`;
      
      document.head.appendChild(styleElement);
      
      setTimeout(() => {
        document.querySelectorAll('ion-header, ion-toolbar, ion-footer').forEach(el => {
          el.style.display = 'none';
        });
        console.log('✅ Estilos aplicados com sucesso!');
      }, 200);
    ''';
  }

  Future<bool> _onWillPop() async {
    if (kIsWeb) {
      return true;
    }
    if (await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9),
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.back,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          title: Text(
            'Verificação',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  if (kIsWeb) {
                    _reloadWebView();
                  } else {
                    controller.reload();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.refresh,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: isLoading
                ? LinearProgressIndicator(
                    value: loadingProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF444F),
                    ),
                    minHeight: 3,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: Stack(
          children: [
            if (kIsWeb)
              getWebView(_viewId)
            else
              WebViewWidget(controller: controller),

            if (isLoading && loadingProgress < 0.5)
              Container(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF444F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carregando...',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}