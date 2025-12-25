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
  String inspectorResult = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(false)
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
          onPageFinished: (String url) async {
            setState(() {
              isLoading = false;
            });
            
            // PASSO 1: Inspecionar o site PRIMEIRO
            await _inspectWebsite();
            
            // PASSO 2: Depois aplicar customizações
            // _injectCustomStyles(); // Descomente depois de ver os resultados
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

  Future<void> _inspectWebsite() async {
    final inspectorScript = '''
      (function() {
        const report = {
          appBars: [],
          bottomBars: [],
          allElements: [],
          fixedElements: [],
          colors: new Set(),
        };
        
        // Procura por todos os elementos no topo
        document.querySelectorAll('*').forEach((el, index) => {
          const styles = window.getComputedStyle(el);
          const rect = el.getBoundingClientRect();
          
          // Elementos fixos ou sticky
          if (styles.position === 'fixed' || styles.position === 'sticky') {
            report.fixedElements.push({
              index: index,
              tag: el.tagName,
              id: el.id || 'sem-id',
              classes: Array.from(el.classList).join(' ') || 'sem-classes',
              position: styles.position,
              top: styles.top,
              bottom: styles.bottom,
              height: rect.height + 'px',
              width: rect.width + 'px',
              zIndex: styles.zIndex,
              display: styles.display,
            });
          }
          
          // Elementos no topo (primeiros 100px)
          if (rect.top >= 0 && rect.top <= 100 && rect.height > 30) {
            report.appBars.push({
              index: index,
              tag: el.tagName,
              id: el.id || 'sem-id',
              classes: Array.from(el.classList).join(' ') || 'sem-classes',
              top: rect.top + 'px',
              height: rect.height + 'px',
              position: styles.position,
              background: styles.backgroundColor,
            });
          }
          
          // Elementos no fundo (últimos 100px)
          const windowHeight = window.innerHeight;
          if (rect.bottom >= windowHeight - 100 && rect.bottom <= windowHeight && rect.height > 30) {
            report.bottomBars.push({
              index: index,
              tag: el.tagName,
              id: el.id || 'sem-id',
              classes: Array.from(el.classList).join(' ') || 'sem-classes',
              bottom: (windowHeight - rect.bottom) + 'px',
              height: rect.height + 'px',
              position: styles.position,
              background: styles.backgroundColor,
            });
          }
          
          // Coleta cores
          if (styles.backgroundColor && styles.backgroundColor !== 'rgba(0, 0, 0, 0)') {
            report.colors.add(styles.backgroundColor);
          }
        });
        
        // Procura especificamente por nav, header, footer
        const navs = document.querySelectorAll('nav, header, [role="banner"], [role="navigation"]');
        const footers = document.querySelectorAll('footer, [role="contentinfo"]');
        
        report.navsFound = Array.from(navs).map(el => ({
          tag: el.tagName,
          id: el.id || 'sem-id',
          classes: Array.from(el.classList).join(' ') || 'sem-classes',
          html: el.outerHTML.substring(0, 200),
        }));
        
        report.footersFound = Array.from(footers).map(el => ({
          tag: el.tagName,
          id: el.id || 'sem-id',
          classes: Array.from(el.classList).join(' ') || 'sem-classes',
          html: el.outerHTML.substring(0, 200),
        }));
        
        report.colors = Array.from(report.colors);
        report.pageTitle = document.title;
        report.bodyClasses = Array.from(document.body.classList).join(' ');
        
        return JSON.stringify(report, null, 2);
      })();
    ''';

    try {
      final result = await controller.runJavaScriptReturningResult(inspectorScript);
      setState(() {
        inspectorResult = result.toString();
      });
      
      // Mostra os resultados no console
      debugPrint('\n==========================================');
      debugPrint('🔍 INSPEÇÃO DO SITE');
      debugPrint('==========================================');
      debugPrint(result.toString());
      debugPrint('==========================================\n');
      
      // Mostra dialog com os resultados
      if (mounted) {
        _showInspectorDialog();
      }
    } catch (e) {
      debugPrint('❌ Erro ao inspecionar: $e');
    }
  }

  void _showInspectorDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF1E88E5)),
                  const SizedBox(width: 8),
                  const Text(
                    'Inspeção do Site',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Aqui você pode copiar os resultados
                      debugPrint('📋 Copiar resultados');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    inspectorResult,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _injectCustomStyles();
                  },
                  icon: const Icon(Icons.brush),
                  label: const Text('Aplicar Estilos Customizados'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _injectCustomStyles() {
    // Este script será atualizado depois que você me passar os resultados do inspector
    final customScript = '''
      (function() {
        const style = document.createElement('style');
        style.textContent = \`
          /* Remove scrollbars */
          ::-webkit-scrollbar {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
          }
          
          * {
            -ms-overflow-style: none !important;
            scrollbar-width: none !important;
          }
          
          html, body {
            overflow-x: hidden !important;
            -webkit-overflow-scrolling: touch !important;
            scroll-behavior: smooth !important;
          }
          
          /* TEMPORÁRIO - Remove elementos comuns de AppBar/BottomBar */
          /* Você vai me dizer os seletores corretos depois da inspeção */
          header, 
          nav,
          footer,
          [role="banner"],
          [role="navigation"],
          [role="contentinfo"] {
            display: none !important;
            visibility: hidden !important;
            height: 0 !important;
          }
          
          /* Estilo para cards */
          .card, [class*="card"], [class*="Card"] {
            border-radius: 16px !important;
            border: 1px solid #E5E7EB !important;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08) !important;
            margin: 12px !important;
            padding: 16px !important;
            background: white !important;
          }
          
          /* Botões verdes */
          button, .button, .btn {
            border-radius: 12px !important;
            padding: 12px 24px !important;
            font-weight: 600 !important;
            border: none !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
          }
          
          /* Performance */
          * {
            -webkit-tap-highlight-color: transparent !important;
          }
        \`;
        
        document.head.appendChild(style);
        console.log('✅ Estilos aplicados (versão temporária)');
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E88E5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Meu ingresso',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () async {
                await _inspectWebsite();
              },
              tooltip: 'Inspecionar Site',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                controller.reload();
              },
              tooltip: 'Recarregar',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: isLoading
                ? LinearProgressIndicator(
                    value: loadingProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),

            if (isLoading && loadingProgress < 0.3)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E88E5),
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