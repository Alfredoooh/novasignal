import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/document_model.dart';
import '../providers/theme_provider.dart';

// Import condicional
import '../utils/web_utils.dart'
    if (dart.library.html) '../utils/web_utils_web.dart';

// Imports para web
import 'dart:html' as html;

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
    registerWebViewFactory(
      _viewType,
      (int viewId) {
        // Injeta o CSS de zoom diretamente no HTML
        final htmlWithZoom = '''
          <style>
            body {
              zoom: 0.45 !important;
              -moz-transform: scale(0.45);
              -moz-transform-origin: 0 0;
            }
          </style>
          ${widget.document.html}
        ''';

        final iframe = html.IFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..srcdoc = htmlWithZoom;

        // Listener de load
        iframe.onLoad.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });

        // Listener de erro
        iframe.onError.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });

        return iframe;
      },
    );

    // Força o loading a desaparecer após 2 segundos mesmo que não tenha carregado
    Future.delayed(const Duration(seconds: 2), () {
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
      body: Stack(
        children: [
          // Iframe com visualização desktop
          if (kIsWeb)
            HtmlElementView(viewType: _viewType)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Visualização web disponível apenas na plataforma web',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando documento...',
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
}