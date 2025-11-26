import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';

// Imports condicionais
import 'dart:html' as html show IFrameElement;
import 'dart:ui' as ui;

class DocumentViewerScreen extends StatefulWidget {
  final DocumentModel document;
  final ThemeProvider themeProvider;

  const DocumentViewerScreen({
    Key? key,
    required this.document,
    required this.themeProvider,
  }) : super(key: key);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'document-iframe-${DateTime.now().millisecondsSinceEpoch}';
    
    if (kIsWeb) {
      _registerWebView();
    }
  }

  void _registerWebView() {
    // Registra o iframe para web
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        // Cria iframe
        final iframe = html.IFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none';

        // Carrega o HTML que vem da API
        // O document.html já é uma string HTML completa
        iframe.srcdoc = widget.document.html;

        // Listener para detectar quando carregou
        iframe.onLoad.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });

        // Tratamento de erro
        iframe.onError.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error loading document'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });

        return iframe;
      },
    );

    // Fallback: remove loading após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.document.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/share.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/download.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              _downloadDocument();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? HtmlElementView(viewType: _viewType)
                  : Center(
                      child: Text(
                        'Web view only available on web platform',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
            ),
          ),
          if (_isLoading)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading document...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _downloadDocument() {
    if (kIsWeb) {
      // Cria um blob com o HTML
      final blob = html.Blob([widget.document.html], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Cria link de download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${widget.document.name}.html')
        ..click();
      
      // Limpa o URL
      html.Url.revokeObjectUrl(url);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download only available on web'),
        ),
      );
    }
  }
}