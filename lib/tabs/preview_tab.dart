// lib/tabs/preview_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:convert';

class PreviewTab extends StatefulWidget {
  final String? htmlContent;
  
  const PreviewTab({Key? key, this.htmlContent}) : super(key: key);

  @override
  State<PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<PreviewTab> {
  static const String _pdfViewType = 'pdf-viewer';
  static bool _viewRegistered = false;
  String? _currentPdfUrl;

  @override
  void initState() {
    super.initState();
    if (widget.htmlContent != null) {
      _convertHtmlToPdf(widget.htmlContent!);
    }
  }

  @override
  void didUpdateWidget(PreviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.htmlContent != oldWidget.htmlContent && widget.htmlContent != null) {
      _convertHtmlToPdf(widget.htmlContent!);
    }
  }

  void _convertHtmlToPdf(String htmlContent) {
    try {
      // Criar um iframe oculto para renderizar o HTML
      final iframe = html.IFrameElement()
        ..style.position = 'absolute'
        ..style.width = '210mm'
        ..style.height = '297mm'
        ..style.left = '-9999px';

      html.document.body?.append(iframe);

      final iframeDoc = iframe.contentDocument;
      iframeDoc?.write(htmlContent);
      iframeDoc?.close();

      // Simular conversão para PDF criando um blob URL
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final blob = html.Blob([htmlContent], 'text/html');
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          setState(() {
            _currentPdfUrl = url;
          });

          iframe.remove();
          _registerPdfView();
        }
      });
    } catch (e) {
      debugPrint('Erro ao converter HTML para PDF: $e');
    }
  }

  void _registerPdfView() {
    if (_viewRegistered || _currentPdfUrl == null) return;

    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _pdfViewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = _currentPdfUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';

          return iframe;
        },
      );
      _viewRegistered = true;
    } catch (e) {
      debugPrint('Erro ao registrar visualizador PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
              ),
              if (_currentPdfUrl != null)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Ionicons.download_outline,
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      ),
                      onPressed: _downloadPdf,
                      tooltip: 'Baixar PDF',
                    ),
                    IconButton(
                      icon: Icon(
                        Ionicons.share_outline,
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                      ),
                      onPressed: _sharePdf,
                      tooltip: 'Compartilhar',
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _currentPdfUrl == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.document_text_outline,
                        size: 64,
                        color: themeProvider.isDarkMode 
                            ? Colors.grey.shade700 
                            : Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum documento',
                        style: TextStyle(
                          color: themeProvider.isDarkMode 
                              ? Colors.grey.shade600 
                              : Colors.grey.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gere um documento para visualizar',
                        style: TextStyle(
                          color: themeProvider.isDarkMode 
                              ? Colors.grey.shade600 
                              : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
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
                    child: HtmlElementView(
                      viewType: _pdfViewType,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _downloadPdf() {
    if (_currentPdfUrl == null) return;
    
    final anchor = html.AnchorElement(href: _currentPdfUrl)
      ..download = 'documento_${DateTime.now().millisecondsSinceEpoch}.html'
      ..click();
  }

  void _sharePdf() {
    // Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de compartilhamento em desenvolvimento'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    if (_currentPdfUrl != null) {
      html.Url.revokeObjectUrl(_currentPdfUrl!);
    }
    super.dispose();
  }
}