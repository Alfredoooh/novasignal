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
  bool _showMenu = false;
  String _documentName = 'Documento sem título';
  final TextEditingController _nameController = TextEditingController();

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
      await Future.delayed(const Duration(milliseconds: 500));

      final viewId = 'pdf-preview-${DateTime.now().millisecondsSinceEpoch}';
      
      if (!_viewRegistered) {
        _registerPDFView(viewId);
        _viewRegistered = true;
      }

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
          ..style.background = '#525252'
          ..style.padding = '40px 20px'
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
        
        // Criar container temporário com margens adequadas (A4: 210mm x 297mm)
        const container = document.createElement('div');
        container.style.cssText = `
          position: absolute;
          left: -9999px;
          top: 0;
          width: 170mm;
          min-height: 257mm;
          background: white;
          padding: 20mm;
          box-sizing: content-box;
        `;
        
        container.innerHTML = `$htmlContent`;
        document.body.appendChild(container);
        
        await new Promise(resolve => setTimeout(resolve, 800));
        
        // Converter para canvas com qualidade alta
        const canvas = await html2canvas(container, {
          scale: 2,
          useCORS: true,
          logging: false,
          backgroundColor: '#ffffff',
          width: container.offsetWidth,
          height: container.offsetHeight
        });
        
        document.body.removeChild(container);
        
        // Criar PDF com margens (A4 = 210mm x 297mm)
        const pdf = new jsPDF({
          orientation: 'portrait',
          unit: 'mm',
          format: 'a4'
        });
        
        const imgData = canvas.toDataURL('image/png');
        const pdfWidth = 210;
        const pdfHeight = 297;
        
        // Área útil com margens (20mm cada lado)
        const contentWidth = 170;
        const contentHeight = 257;
        const marginX = 20;
        const marginY = 20;
        
        const imgWidth = contentWidth;
        const imgHeight = (canvas.height * contentWidth) / canvas.width;
        
        let position = marginY;
        let heightLeft = imgHeight;
        
        // Primeira página
        pdf.addImage(imgData, 'PNG', marginX, position, imgWidth, Math.min(imgHeight, contentHeight));
        heightLeft -= contentHeight;
        
        // Páginas adicionais
        while (heightLeft > 0) {
          pdf.addPage();
          position = marginY - (imgHeight - heightLeft);
          pdf.addImage(imgData, 'PNG', marginX, position, imgWidth, imgHeight);
          heightLeft -= contentHeight;
        }
        
        const pdfData = pdf.output('arraybuffer');
        
        // Renderizar preview com PDF.js
        const pdfContainer = document.getElementById('pdf-container-$viewId');
        if (!pdfContainer) return;
        
        pdfContainer.innerHTML = '';
        
        const loadingTask = pdfjsLib.getDocument({ data: pdfData });
        const pdfDoc = await loadingTask.promise;
        
        for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
          const page = await pdfDoc.getPage(pageNum);
          const scale = 1.5;
          const viewport = page.getViewport({ scale });
          
          const canvas = document.createElement('canvas');
          canvas.className = 'pdf-page-canvas';
          canvas.style.cssText = `
            background: white;
            display: block;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
            margin: 0 auto 20px auto;
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
        a.download = '${_documentName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      }
    })();
    ''';
    
    js.context.callMethod('eval', [script]);
    setState(() => _showMenu = false);
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
    setState(() => _showMenu = false);
  }

  void _showRenameDialog() {
    _nameController.text = _documentName;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
        title: Text(
          'Renomear documento',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
          decoration: InputDecoration(
            hintText: 'Nome do documento',
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey,
            ),
            filled: true,
            fillColor: themeProvider.isDarkMode 
                ? const Color(0xFF495057) 
                : const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _documentName = _nameController.text.trim().isEmpty 
                    ? 'Documento sem título' 
                    : _nameController.text.trim();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        // Conteúdo principal
        _buildContent(themeProvider),
        
        // Botão flutuante de menu
        if (_hasDocument && !_isConverting)
          Positioned(
            top: 16,
            right: 16,
            child: _buildFloatingMenu(themeProvider),
          ),
      ],
    );
  }

  Widget _buildFloatingMenu(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu expandido
        if (_showMenu)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF343A40) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Ionicons.create_outline,
                  label: 'Renomear',
                  onTap: () {
                    setState(() => _showMenu = false);
                    _showRenameDialog();
                  },
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Ionicons.download_outline,
                  label: 'Download PDF',
                  onTap: _downloadPDF,
                  themeProvider: themeProvider,
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  icon: Ionicons.print_outline,
                  label: 'Imprimir',
                  onTap: _printPDF,
                  themeProvider: themeProvider,
                ),
              ],
            ),
          ),
        
        // Botão principal
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _showMenu = !_showMenu),
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _showMenu ? Ionicons.close : Ionicons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
              ),
            ],
          ),
        ),
      ),
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
      color: const Color(0xFF525252),
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

  @override
  void dispose() {
    _nameController.dispose();
    js.context.callMethod('eval', ['delete window.currentPdfBlob;']);
    super.dispose();
  }
}