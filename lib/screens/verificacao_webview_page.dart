// ==================== verificacao_webview_page.dart ====================
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true) // Habilita zoom para melhor qualidade
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _injectCustomStyles();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao carregar: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://elephantbetzone.com/app/scanTicket/manualEntry'),
      );
  }

  void _injectCustomStyles() {
    final customScript = '''
      (function() {
        // Define viewport para alta resolução
        let viewport = document.querySelector('meta[name="viewport"]');
        if (viewport) {
          viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes');
        } else {
          viewport = document.createElement('meta');
          viewport.name = 'viewport';
          viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
          document.head.appendChild(viewport);
        }
        
        // Remove classes que bloqueiam scroll
        document.body.classList.remove('backdrop-no-scroll');
        document.documentElement.style.overflow = 'auto';
        document.body.style.overflow = 'auto';
        document.body.style.position = 'static';
        
        const style = document.createElement('style');
        style.textContent = \`
          /* ========== REMOVE SCROLLBARS ========== */
          ::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
          }
          
          html, body, * {
            -ms-overflow-style: none !important;
            scrollbar-width: none !important;
          }
          
          html, body {
            overflow-y: auto !important;
            overflow-x: hidden !important;
            -webkit-overflow-scrolling: touch !important;
            scroll-behavior: smooth !important;
            position: static !important;
          }
          
          /* ========== ESCONDE HEADER/TOOLBAR DO IONIC ========== */
          ion-header,
          ion-toolbar,
          [class*="toolbar"],
          [class*="header-md"],
          [class*="header-ios"],
          .header,
          .toolbar {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            min-height: 0 !important;
            max-height: 0 !important;
            overflow: hidden !important;
          }
          
          /* ========== ESCONDE FOOTER/TABS DO IONIC ========== */
          ion-footer,
          ion-tabs,
          ion-tab-bar,
          [class*="footer"],
          [class*="tabbar"],
          [class*="tabs-md"],
          [class*="tabs-ios"],
          .footer,
          .tabs {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
            min-height: 0 !important;
            max-height: 0 !important;
            overflow: hidden !important;
          }
          
          /* ========== AJUSTA ION-CONTENT PARA TELA CHEIA ========== */
          ion-content {
            --padding-top: 0 !important;
            --padding-bottom: 0 !important;
            --offset-top: 0 !important;
            --offset-bottom: 0 !important;
            top: 0 !important;
            bottom: 0 !important;
          }
          
          ion-app {
            padding-top: 0 !important;
            padding-bottom: 0 !important;
          }
          
          /* ========== REMOVE BACKGROUND BACKDROP ========== */
          .backdrop-no-scroll {
            position: static !important;
            overflow: auto !important;
          }
          
          /* ========== ESTILO CARDS (Como o seu app) ========== */
          ion-card,
          .card, 
          [class*="card"], 
          [class*="Card"],
          .ticket-card,
          .bet-card {
            border-radius: 16px !important;
            border: 1px solid #E5E7EB !important;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08) !important;
            margin: 12px 8px !important;
            padding: 16px !important;
            background: white !important;
            overflow: visible !important;
          }
          
          /* ========== BOTÕES ESTILO SEU APP ========== */
          ion-button,
          button, 
          .button, 
          .btn,
          [class*="button"],
          input[type="submit"],
          input[type="button"] {
            border-radius: 12px !important;
            padding: 12px 24px !important;
            font-weight: 600 !important;
            border: none !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            text-transform: none !important;
            font-size: 14px !important;
            min-height: 44px !important;
          }
          
          /* Botão Verde (Ganho/Sucesso) */
          .btn-success,
          .success,
          [class*="success"],
          [class*="green"],
          [class*="win"],
          ion-button[color="success"],
          button.success {
            --background: #22C55E !important;
            background: #22C55E !important;
            color: white !important;
          }
          
          .btn-success:hover,
          .success:hover {
            --background: #16A34A !important;
            background: #16A34A !important;
            transform: scale(0.98) !important;
          }
          
          /* Botão Vermelho (Primário) */
          .btn-primary,
          .primary,
          [class*="primary"],
          ion-button[color="primary"],
          button.primary {
            --background: #FF444F !important;
            background: #FF444F !important;
            color: white !important;
          }
          
          /* Botão Azul (Secundário) */
          .btn-secondary,
          .secondary,
          [class*="secondary"],
          ion-button[color="secondary"] {
            --background: #1E88E5 !important;
            background: #1E88E5 !important;
            color: white !important;
          }
          
          /* ========== STATUS BADGES ========== */
          ion-badge,
          .badge,
          .status,
          [class*="badge"],
          [class*="status"] {
            border-radius: 8px !important;
            padding: 6px 12px !important;
            font-weight: 600 !important;
            font-size: 12px !important;
            display: inline-block !important;
          }
          
          /* ========== INPUTS ESTILIZADOS ========== */
          ion-input,
          ion-textarea,
          ion-select,
          input:not([type="checkbox"]):not([type="radio"]),
          textarea,
          select {
            border-radius: 12px !important;
            border: 1px solid #E5E7EB !important;
            padding: 12px 16px !important;
            font-size: 14px !important;
            transition: all 0.2s ease !important;
            --border-radius: 12px !important;
            --border-width: 1px !important;
            --border-color: #E5E7EB !important;
          }
          
          ion-input:focus-within,
          input:focus,
          textarea:focus,
          select:focus {
            --border-color: #FF444F !important;
            border-color: #FF444F !important;
            box-shadow: 0 0 0 3px rgba(255, 68, 79, 0.1) !important;
            outline: none !important;
          }
          
          /* ========== LISTA/ITEMS ========== */
          ion-item {
            --border-radius: 12px !important;
            --padding-start: 16px !important;
            --padding-end: 16px !important;
            --inner-padding-end: 0 !important;
            --min-height: 48px !important;
          }
          
          ion-list {
            padding: 8px !important;
            background: transparent !important;
          }
          
          /* ========== PERFORMANCE OTIMIZAÇÃO ========== */
          * {
            -webkit-tap-highlight-color: transparent !important;
            -webkit-touch-callout: none !important;
          }
          
          img, video, ion-img {
            transform: translateZ(0) !important;
            backface-visibility: hidden !important;
          }
          
          *:focus {
            outline: none !important;
          }
          
          html {
            -webkit-font-smoothing: antialiased !important;
            -moz-osx-font-smoothing: grayscale !important;
            text-rendering: optimizeLegibility !important;
          }
          
          /* ========== MELHORA QUALIDADE DE IMAGENS E TEXTOS ========== */
          img, ion-img {
            image-rendering: -webkit-optimize-contrast !important;
            image-rendering: crisp-edges !important;
            transform: translateZ(0) !important;
            backface-visibility: hidden !important;
          }
          
          * {
            -webkit-font-smoothing: antialiased !important;
            -moz-osx-font-smoothing: grayscale !important;
            text-rendering: optimizeLegibility !important;
            font-smooth: always !important;
            -webkit-backface-visibility: hidden !important;
            -moz-backface-visibility: hidden !important;
            backface-visibility: hidden !important;
          }
          
          body, html {
            -webkit-text-size-adjust: 100% !important;
            text-size-adjust: 100% !important;
          }
          
          /* ========== DIVIDERS ========== */
          ion-item-divider,
          hr,
          .divider {
            border: none !important;
            border-top: 1px solid #E5E7EB !important;
            margin: 12px 0 !important;
            --border-width: 0 !important;
            --border-style: none !important;
            min-height: 0 !important;
          }
          
          /* ========== LOADING/SPINNER ========== */
          ion-spinner {
            --color: #1E88E5 !important;
          }
          
          ion-loading {
            --spinner-color: #1E88E5 !important;
          }
          
          /* ========== REMOVER ELEMENTOS ESPECÍFICOS DO IONIC ========== */
          .toolbar-background,
          .toolbar-container,
          ion-back-button {
            display: none !important;
          }
        \`;
        
        document.head.appendChild(style);
        
        // Remove elementos manualmente também
        setTimeout(() => {
          document.querySelectorAll('ion-header, ion-toolbar').forEach(el => {
            el.style.display = 'none';
            el.style.height = '0';
          });
          
          document.querySelectorAll('ion-footer, ion-tabs, ion-tab-bar').forEach(el => {
            el.style.display = 'none';
            el.style.height = '0';
          });
          
          document.querySelectorAll('ion-content').forEach(el => {
            el.style.setProperty('--offset-top', '0', 'important');
            el.style.setProperty('--offset-bottom', '0', 'important');
          });
        }, 100);
        
        console.log('✅ Estilos customizados aplicados!');
      })();
    ''';

    controller.runJavaScript(customScript);
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
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: _AnimatedIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Verificação',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            _AnimatedIconButton(
              icon: Icons.refresh,
              onPressed: () {
                controller.reload();
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: isLoading
                ? LinearProgressIndicator(
                    value: loadingProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF444F),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),

            // Overlay de loading inicial
            if (isLoading && loadingProgress < 0.3)
              Container(
                color: cs.surface,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF444F),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Botão de ícone animado
class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(widget.icon),
        onPressed: _handleTap,
      ),
    );
  }
}