// lib/tabs/preview_tab.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js' as js;

class PreviewTab extends StatefulWidget {
  final String? htmlContent;
  
  const PreviewTab({Key? key, this.htmlContent}) : super(key: key);

  @override
  State<PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<PreviewTab> {
  static const String _previewViewType = 'pdf-preview-viewer';
  static bool _viewRegistered = false;
  bool _isConverting = false;
  bool _hasDocument = false;
  String? _pdfViewId;

  @override
  void initState() {
    super.initState();
    _initializePDFLibraries();
    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
      _convertAndRenderPDF(widget.htmlContent!);
    }
  }

  @override
  void didUpdateWidget(PreviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.htmlContent != oldWidget.htmlContent && 
        widget.htmlContent != null && 
        widget.htmlContent!.isNotEmpty) {
      _convertAndRenderPDF(widget.htmlContent!);
    }
  }

  void _initializePDFLibraries() {
    // Verificar se as bibliotecas estão carregadas
    final script1 = html.document.querySelector('script[src*="jspdf"]');
    final script2 = html.document.querySelector('script[src*="html2canvas"]');
    final script3 = html.document.querySelector('script[src*="pdf.js"]');

    if (script1 == null) {
      final jspdfScript = html.ScriptElement()
        ..src = 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'
        ..async = true;
      html.document.head?.append(jspdfScript);
    }

    if (script2 == null) {
      final html2canvasScript = html.ScriptElement()
        ..src = 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js'
        ..async = true;
      html.document.head?.append(html2canvasScript);
    }

    if (script3 == null) {
      final pdfjsScript = html.ScriptElement()
        ..src = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js'
        ..async = true;
      html.document.head?.append(pdfjsScript);

      // Worker do PDF.js
      js.context['pdfjsLib']?['GlobalWorkerOptions']?['workerSrc'] = 
        'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
    }
  }

  Future<void> _convertAndRenderPDF(String htmlContent) async {
    if (!mounted) return;

    setState(() {
      _isConverting = true;
    });

    try {
      // Aguardar carregamento das bibliotecas
      await Future.delayed(const Duration(milliseconds: 500));

      final viewId = 'pdf-preview-${DateTime.now().millisecondsSinceEpoch}';
      
      if (!_viewRegistered) {
        _registerPDFView(viewId);
        _viewRegistered = true;
      }

      // Executar conversão HTML → PDF
      await _executeHTMLtoPDF(htmlContent, viewId);

      if (mounted) {
        setState(() {
          _hasDocument = true;
          _isConverting = false;
          _pdfViewId = viewId;
        });
      }
    } catch (e) {
      debugPrint('Erro ao converter PDF: $e');
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  void _registerPDFView(String viewId) {
    ui_web.platformViewRegistry.registerViewFactory(
      '$_previewViewType-$viewId',
      (int id) {
        final container = html.DivElement()
          ..id = 'pdf-container-$viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.overflow = 'auto'
          ..style.background = '#2a2a2a'
          ..style.padding = '20px'
          ..style.boxSizing = 'border-box'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.alignItems = 'center'
          ..style.gap = '20px';

        return container;
      },
    );
  }

  Future<void> _executeHTMLtoPDF(String htmlContent, String viewId) async {
    final script = '''
    (async function() {
      try {
        const { jsPDF } = window.jspdf;
        const html2canvas = window.html2canvas;
        const pdfjsLib = window.pdfjsLib;
        
        if (!jsPDF || !html2canvas || !pdfjsLib) {
          console.error('Bibliotecas não carregadas');
          return;
        }
        
        // Criar container temporário
        const container = document.createElement('div');
        container.style.cssText = `
          position: absolute;
          left: -9999px;
          top: 0;
          width: 794px;
          min-height: 1123px;
          background: white;
          padding: 75px;
          box-sizing: border-box;
        `;
        
        container.innerHTML = `$htmlContent`;
        document.body.appendChild(container);
        
        // Aguardar renderização
        await new Promise(resolve => setTimeout(resolve, 800));
        
        // Converter para canvas
        const canvas = await html2canvas(container, {
          scale: 2,
          useCORS: true,
          logging: false,
          backgroundColor: '#ffffff',
          width: container.scrollWidth,
          height: container.scrollHeight
        });
        
        document.body.removeChild(container);
        
        // Criar PDF
        const pdf = new jsPDF({
          orientation: 'portrait',
          unit: 'mm',
          format: 'a4'
        });
        
        const imgData = canvas.toDataURL('image/png');
        const imgWidth = 210;
        const imgHeight = (canvas.height * imgWidth) / canvas.width;
        const pageHeight = 297;
        
        let position = 0;
        let heightLeft = imgHeight;
        
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
        
        while (heightLeft > 0) {
          position = heightLeft - imgHeight;
          pdf.addPage();
          pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
          heightLeft -= pageHeight;
        }
        
        // Obter array buffer do PDF
        const pdfData = pdf.output('arraybuffer');
        
        // Renderizar preview com PDF.js
        const pdfContainer = document.getElementById('pdf-container-$viewId');
        if (!pdfContainer) return;
        
        pdfContainer.innerHTML = '';
        
        const loadingTask = pdfjsLib.getDocument({ data: pdfData });
        const pdfDoc = await loadingTask.promise;
        
        for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
          const page = await pdfDoc.getPage(pageNum);
          const scale = 1.2;
          const viewport = page.getViewport({ scale });
          
          const canvas = document.createElement('canvas');
          canvas.className = 'pdf-page-canvas';
          canvas.style.cssText = `
            background: white;
            display: block;
            box-shadow: 0 4px 20px rgba(0,0,0,0.5);
            margin: 10px auto;
            border-radius: 4px;
            max-width: 100%;
            height: auto;
          `;
          
          const ctx = canvas.getContext('2d');
          canvas.width = viewport.width;
          canvas.height = viewport.height;
          
          pdfContainer.appendChild(canvas);
          
          await page.render({
            canvasContext: ctx,
            viewport: viewport
          }).promise;
        }
        
        // Salvar PDF para download
        window.currentPdfBlob = new Blob([pdfData], { type: 'application/pdf' });
        
      } catch (error) {
        console.error('Erro na conversão PDF:', error);
      }
    })();
    ''';

    js.context.callMethod('eval', [script]);
  }

  void _downloadPDF() {
    final script = '''
    (function() {
      if (window.currentPdfBlob) {
        const url = URL.createObjectURL(window.currentPdfBlob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'documento_${DateTime.now().millisecondsSinceEpoch}.pdf';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      }
    })();
    ''';
    
    js.context.callMethod('eval', [script]);
  }

  void _printPDF() {
    final script = '''
    (function() {
      if (window.currentPdfBlob) {
        const url = URL.createObjectURL(window.currentPdfBlob);
        const iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = url;
        document.body.appendChild(iframe);
        iframe.onload = function() {
          iframe.contentWindow.print();
          setTimeout(() => {
            document.body.removeChild(iframe);
            URL.revokeObjectURL(url);
          }, 100);
        };
      }
    })();
    ''';
    
    js.context.callMethod('eval', [script]);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        // Header com controles
        Container(
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
              if (_hasDocument && !_isConverting)
                Row(
                  children: [
                    _buildActionButton(
                      icon: Ionicons.download_outline,
                      label: 'Download',
                      onPressed: _downloadPDF,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Ionicons.print_outline,
                      label: 'Imprimir',
                      onPressed: _printPDF,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Content Area
        Expanded(
          child: _buildContent(themeProvider),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    if (_isConverting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: themeProvider.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'Convertendo HTML para PDF...',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasDocument) {
      return Center(
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
              'Nenhum documento gerado ainda',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.grey.shade600 
                    : Colors.grey.shade400,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gere um documento no chat para visualizar',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.grey.shade600 
                    : Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF2a2a2a),
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: HtmlElementView(
              viewType: '$_previewViewType-$_pdfViewId',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeProvider themeProvider,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode 
                ? Colors.white.withOpacity(0.1) 
                : const Color(0xFF007AFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: themeProvider.isDarkMode 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: themeProvider.isDarkMode ? Colors.white : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpar blob do PDF
    js.context.callMethod('eval', ['delete window.currentPdfBlob;']);
    super.dispose();
  }
}