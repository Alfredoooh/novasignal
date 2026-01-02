import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class VerificacaoWebViewPage extends StatefulWidget {
  const VerificacaoWebViewPage({super.key});

  @override
  State<VerificacaoWebViewPage> createState() => _VerificacaoWebViewPageState();
}

class _VerificacaoWebViewPageState extends State<VerificacaoWebViewPage> {
  late final WebViewController controller;
  bool isLoading = true;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeWebView() {
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
              _injectCustomStyles();
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://elephantbetzone.com/app/scanTicket/manualEntry'),
      );
  }

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

  void _injectCustomStyles() {
    final themeColors = _getThemeColors();
    
    final customScript = '''
      (function() {
        try {
          $themeColors
          
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
            
            ion-header,
            ion-toolbar,
            ion-footer,
            ion-tabs,
            ion-tab-bar,
            [class*="header"],
            [class*="toolbar"],
            [class*="footer"],
            [class*="tabbar"] {
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
            
            ion-app {
              background: \${theme.background} !important;
            }
            
            ion-card,
            .card,
            [class*="card"],
            [class*="Card"] {
              background: \${theme.cardBackground} !important;
              border-radius: 16px !important;
              border: 1px solid \${theme.border} !important;
              box-shadow: 0 2px 8px rgba(0, 0, 0, \${theme.isDark ? '0.3' : '0.08'}) !important;
              margin: 12px !important;
              padding: 16px !important;
              color: \${theme.text} !important;
            }
            
            ion-card-header,
            .card-header {
              color: \${theme.text} !important;
            }
            
            ion-card-content,
            .card-content {
              color: \${theme.textSecondary} !important;
            }
            
            ion-button,
            button:not(.close):not([class*="icon"]),
            .button,
            .btn,
            [type="submit"],
            [type="button"] {
              border-radius: 12px !important;
              padding: 12px 24px !important;
              font-weight: 600 !important;
              font-size: 14px !important;
              min-height: 44px !important;
              border: none !important;
              cursor: pointer !important;
              transition: all 0.2s ease !important;
              text-transform: none !important;
            }
            
            ion-button[color="primary"],
            ion-button:not([color]),
            button.primary,
            button.btn-primary,
            .btn-primary,
            [class*="primary"] {
              --background: \${theme.primary} !important;
              background: \${theme.primary} !important;
              color: white !important;
            }
            
            ion-button[color="primary"]:hover,
            button.primary:hover,
            .btn-primary:hover {
              --background: \${theme.primaryDark} !important;
              background: \${theme.primaryDark} !important;
              transform: scale(0.98) !important;
            }
            
            ion-button[color="success"],
            button.success,
            .btn-success,
            [class*="success"]:not(ion-badge) {
              --background: \${theme.success} !important;
              background: \${theme.success} !important;
              color: white !important;
            }
            
            ion-button[color="secondary"],
            button.secondary,
            .btn-secondary {
              --background: \${theme.secondary} !important;
              background: \${theme.secondary} !important;
              color: white !important;
            }
            
            ion-button[fill="outline"],
            button.outline,
            .btn-outline {
              --background: transparent !important;
              background: transparent !important;
              border: 2px solid \${theme.primary} !important;
              color: \${theme.primary} !important;
            }
            
            ion-input,
            ion-textarea,
            ion-select,
            input:not([type="checkbox"]):not([type="radio"]):not([type="file"]),
            textarea,
            select {
              --background: \${theme.inputBackground} !important;
              --color: \${theme.text} !important;
              --placeholder-color: \${theme.textSecondary} !important;
              --border-radius: 12px !important;
              --border-width: 1px !important;
              --border-color: \${theme.border} !important;
              --padding-start: 16px !important;
              --padding-end: 16px !important;
              background: \${theme.inputBackground} !important;
              border: 1px solid \${theme.border} !important;
              border-radius: 12px !important;
              padding: 12px 16px !important;
              font-size: 14px !important;
              color: \${theme.text} !important;
              transition: all 0.2s ease !important;
            }
            
            ion-input:focus-within,
            input:focus,
            textarea:focus,
            select:focus {
              --border-color: \${theme.primary} !important;
              border-color: \${theme.primary} !important;
              box-shadow: 0 0 0 3px rgba(255, 68, 79, 0.1) !important;
              outline: none !important;
            }
            
            ::placeholder {
              color: \${theme.textSecondary} !important;
              opacity: 1 !important;
            }
            
            ion-label,
            label,
            .label {
              color: \${theme.text} !important;
              font-weight: 600 !important;
            }
            
            ion-item {
              --background: \${theme.surface} !important;
              --color: \${theme.text} !important;
              --border-color: \${theme.border} !important;
              --padding-start: 16px !important;
              --padding-end: 16px !important;
              --inner-padding-end: 0 !important;
              --min-height: 48px !important;
              border-radius: 12px !important;
            }
            
            ion-list {
              background: transparent !important;
              padding: 8px !important;
            }
            
            ion-item-divider {
              --background: transparent !important;
              --color: \${theme.text} !important;
              border-bottom: 1px solid \${theme.border} !important;
            }
            
            ion-badge,
            .badge,
            [class*="badge"] {
              border-radius: 8px !important;
              padding: 6px 12px !important;
              font-weight: 600 !important;
              font-size: 12px !important;
            }
            
            ion-badge[color="success"],
            .badge-success {
              --background: \${theme.success} !important;
              background: \${theme.success} !important;
              color: white !important;
            }
            
            ion-badge[color="danger"],
            .badge-danger {
              --background: \${theme.error} !important;
              background: \${theme.error} !important;
              color: white !important;
            }
            
            ion-badge[color="warning"],
            .badge-warning {
              --background: \${theme.warning} !important;
              background: \${theme.warning} !important;
              color: white !important;
            }
            
            ion-badge[color="primary"],
            .badge-primary {
              --background: \${theme.primary} !important;
              background: \${theme.primary} !important;
              color: white !important;
            }
            
            ion-chip {
              --background: \${theme.surfaceVariant} !important;
              --color: \${theme.text} !important;
              border-radius: 16px !important;
            }
            
            ion-spinner {
              --color: \${theme.primary} !important;
            }
            
            ion-loading {
              --background: \${theme.surface} !important;
              --spinner-color: \${theme.primary} !important;
            }
            
            ion-modal,
            ion-popover {
              --background: \${theme.surface} !important;
              --color: \${theme.text} !important;
            }
            
            ion-segment {
              --background: \${theme.surfaceVariant} !important;
              border-radius: 12px !important;
            }
            
            ion-segment-button {
              --color: \${theme.textSecondary} !important;
              --color-checked: \${theme.primary} !important;
              --indicator-color: \${theme.primary} !important;
            }
            
            ion-toggle {
              --background: \${theme.border} !important;
              --background-checked: \${theme.primary} !important;
              --handle-background: white !important;
            }
            
            ion-checkbox {
              --background: \${theme.surface} !important;
              --background-checked: \${theme.primary} !important;
              --border-color: \${theme.border} !important;
              --border-color-checked: \${theme.primary} !important;
              --checkmark-color: white !important;
            }
            
            h1, h2, h3, h4, h5, h6 {
              color: \${theme.text} !important;
            }
            
            p, span, div, a {
              color: \${theme.text} !important;
            }
            
            .text-muted,
            .text-secondary,
            [class*="secondary-text"] {
              color: \${theme.textSecondary} !important;
            }
            
            a {
              color: \${theme.primary} !important;
              text-decoration: none !important;
            }
            
            a:hover {
              color: \${theme.primaryDark} !important;
              text-decoration: underline !important;
            }
            
            table {
              background: \${theme.cardBackground} !important;
              border: 1px solid \${theme.border} !important;
              border-radius: 12px !important;
              overflow: hidden !important;
            }
            
            th {
              background: \${theme.surfaceVariant} !important;
              color: \${theme.text} !important;
              font-weight: 600 !important;
              padding: 12px !important;
            }
            
            td {
              color: \${theme.text} !important;
              padding: 12px !important;
              border-bottom: 1px solid \${theme.border} !important;
            }
            
            tr:last-child td {
              border-bottom: none !important;
            }
            
            ion-progress-bar {
              --background: \${theme.border} !important;
              --progress-background: \${theme.primary} !important;
              border-radius: 4px !important;
            }
            
            progress {
              background: \${theme.border} !important;
              border-radius: 4px !important;
            }
            
            progress::-webkit-progress-bar {
              background: \${theme.border} !important;
              border-radius: 4px !important;
            }
            
            progress::-webkit-progress-value {
              background: \${theme.primary} !important;
              border-radius: 4px !important;
            }
            
            hr,
            .divider {
              border: none !important;
              border-top: 1px solid \${theme.border} !important;
              margin: 16px 0 !important;
            }
            
            ion-alert {
              --background: \${theme.surface} !important;
              --color: \${theme.text} !important;
            }
            
            .alert,
            [class*="alert"] {
              border-radius: 12px !important;
              padding: 12px 16px !important;
              margin: 12px 0 !important;
            }
            
            .alert-success {
              background: rgba(34, 197, 94, 0.1) !important;
              border: 1px solid \${theme.success} !important;
              color: \${theme.success} !important;
            }
            
            .alert-error,
            .alert-danger {
              background: rgba(239, 68, 68, 0.1) !important;
              border: 1px solid \${theme.error} !important;
              color: \${theme.error} !important;
            }
            
            .alert-warning {
              background: rgba(245, 158, 11, 0.1) !important;
              border: 1px solid \${theme.warning} !important;
              color: \${theme.warning} !important;
            }
            
            .shadow,
            [class*="shadow"] {
              box-shadow: 0 2px 8px rgba(0, 0, 0, \${theme.isDark ? '0.3' : '0.08'}) !important;
            }
            
            ion-backdrop {
              --backdrop-opacity: \${theme.isDark ? '0.7' : '0.5'} !important;
            }
            
            .backdrop-no-scroll {
              overflow: auto !important;
              position: static !important;
            }
          \`;
          
          document.head.appendChild(styleElement);
          
          setTimeout(() => {
            document.querySelectorAll('ion-header, ion-toolbar, ion-footer, ion-tabs, ion-tab-bar').forEach(el => {
              el.style.display = 'none';
              el.style.height = '0';
              el.style.minHeight = '0';
            });
            
            document.querySelectorAll('ion-content').forEach(el => {
              el.style.setProperty('--offset-top', '0', 'important');
              el.style.setProperty('--offset-bottom', '0', 'important');
              el.style.setProperty('--padding-top', '0', 'important');
              el.style.setProperty('--padding-bottom', '0', 'important');
            });
            
            document.body.classList.remove('backdrop-no-scroll');
            document.body.style.overflow = 'auto';
            document.body.style.position = 'static';
            document.documentElement.style.overflow = 'auto';
            
            console.log('✅ Estilos aplicados com sucesso!');
          }, 200);
          
        } catch (error) {
          console.error('❌ Erro ao aplicar estilos:', error);
        }
      })();
    ''';

    try {
      controller.runJavaScript(customScript);
    } catch (e) {
      debugPrint('❌ Erro ao injetar JavaScript: $e');
    }
  }

  Future<bool> _onWillPop() async {
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
                onTap: () => controller.reload(),
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