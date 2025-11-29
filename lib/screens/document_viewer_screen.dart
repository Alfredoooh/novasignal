import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import '../utils/web_utils.dart';

// REMOVIDO: import 'dart:html' as html;
// Agora usa tipos dinâmicos para evitar erro no Android

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
  dynamic _iframe; // MUDADO: html.IFrameElement? -> dynamic

  @override
  void initState() {
    super.initState();
    _viewType = 'document-iframe-${widget.document.id}-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      _registerWebView();
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _iframe != null) {
      _iframe.remove();
      _iframe = null;
    }
    super.dispose();
  }

  void _registerWebView() {
    registerWebViewFactory(
      _viewType,
      (int viewId) {
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

        // MUDADO: Usa import condicional via web_utils
        if (kIsWeb) {
          // O dart:html será importado apenas no web_utils_web.dart
          final iframe = createIFrameElement(htmlWithZoom);
          _iframe = iframe;

          // Listeners
          addIFrameLoadListener(iframe, () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });

          addIFrameErrorListener(iframe, () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });

          return iframe;
        }
        throw UnsupportedError('Web only');
      },
    );

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
    final theme = widget.themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          if (kIsWeb)
            HtmlElementView(
              key: ValueKey(_viewType),
              viewType: _viewType,
            )
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