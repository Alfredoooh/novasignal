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
  bool _isConverting = false;
  bool _hasDocument = false;
  String? _pdfViewId;
  String _documentName = 'Documento sem título';
  final TextEditingController _nameController = TextEditingController();
  String? _lastProcessedContent;

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
        widget.htmlContent!.isNotEmpty &&
        widget.htmlContent != _lastProcessedContent) {
      _lastProcessedContent = widget.htmlContent;
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
      _hasDocument = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final viewId = 'pdf-preview-${DateTime.now().millisecondsSinceEpoch}';

      _registerPDFView(viewId);

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
        
        // Tamanho A4 em pixels (300 DPI): 2480 x 3508
        // Tamanho A4 em mm: 210 x 297
        const a4Width = 210; // mm
        const a4Height = 297; // mm
        const pxWidth = 2480; // pixels para alta resolução
        const pxHeight = 3508;
        
        // Margens em pixels (equivalente a ~20mm em cada lado)
        const marginPx = 189; // ~20mm nas bordas
        const contentWidth = pxWidth - (marginPx * 2);
        
        const container = document.createElement('div');
        container.style.cssText = \`
          position: absolute;
          left: -99999px;
          top: 0;
          width: \${contentWidth}px;
          background: white;
          padding: \${marginPx}px;
          box-sizing: content-box;
          font-family: Arial, sans-serif;
          line-height: 1.6;
        \`;
        
        container.innerHTML = \`$htmlContent\`;
        document.body.appendChild(container);
        
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        const canvas = await html2canvas(container, {
          scale: 2,
          useCORS: true,
          logging: false,
          backgroundColor: '#ffffff',
          width: pxWidth,
          windowWidth: pxWidth,
          scrollY: -window.scrollY,
          scrollX: -window.scrollX,
        });
        
        document.body.removeChild(container);
        
        const pdf = new jsPDF({
          orientation: 'portrait',
          unit: 'mm',
          format: 'a4',
          compress: true
        });
        
        const imgData = canvas.toDataURL('image/jpeg', 0.95);
        
        // Calcular quantas páginas são necessárias
        const imgWidth = a4Width;
        const imgHeight = (canvas.height * a4Width) / canvas.width;
        const pageHeight = a4Height;
        let heightLeft = imgHeight;
        let position = 0;
        
        // Adicionar primeira página
        pdf.addImage(imgData, 'JPEG', 0, position, imgWidth, imgHeight, '', 'FAST');
        heightLeft -= pageHeight;
        
        // Adicionar páginas extras se necessário
        while (heightLeft > 0) {
          position = heightLeft - imgHeight;
          pdf.addPage();
          pdf.addImage(imgData, 'JPEG', 0, position, imgWidth, imgHeight, '', 'FAST');
          heightLeft -= pageHeight;
        }
        
        const pdfData = pdf.output('arraybuffer');
        const pdfBlob = new Blob([pdfData], { type: 'application/pdf' });
        
        // Salvar globalmente para download
        window.currentPdfData = pdfData;
        window.currentPdfBlob = pdfBlob;
        
        // Renderizar visualização
        const pdfContainer = document.getElementById('pdf-container-$viewId');
        if (!pdfContainer) return;
        
        pdfContainer.innerHTML = '';
        
        const loadingTask = pdfjsLib.getDocument({ data: pdfData });
        const pdfDoc = await loadingTask.promise;
        
        for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {
          const page = await pdfDoc.getPage(pageNum);
          const scale = 1.5;
          const viewport = page.getViewport({ scale });
          
          const pageContainer = document.createElement('div');
          pageContainer.style.cssText = \`
            background: white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            margin: 0 auto 20px auto;
            position: relative;
          \`;
          
          const canvas = document.createElement('canvas');
          canvas.style.cssText = 'display: block; width: 100%; height: auto;';
          
          const ctx = canvas.getContext('2d');
          canvas.width = viewport.width;
          canvas.height = viewport.height;
          
          pageContainer.appendChild(canvas);
          pdfContainer.appendChild(pageContainer);
          
          await page.render({
            canvasContext: ctx,
            viewport: viewport
          }).promise;
        }
        
      } catch (error) {
        console.error('Erro na conversão PDF:', error);
        throw error;
      }
    })();
    ''';

    js.context.callMethod('eval', [script]);
  }

  void _downloadPDF() {
    try {
      final sanitizedName = _documentName
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(' ', '_');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${sanitizedName}_$timestamp.pdf';

      final script = '''
      (function() {
        try {
          if (!window.currentPdfBlob) {
            console.error('PDF blob não encontrado');
            alert('Erro: PDF não está pronto para download. Tente novamente.');
            return;
          }
          
          const blob = window.currentPdfBlob;
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.style.display = 'none';
          a.href = url;
          a.download = '$filename';
          
          document.body.appendChild(a);
          a.click();
          
          setTimeout(() => {
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
          }, 100);
          
          console.log('Download iniciado com sucesso');
        } catch (error) {
          console.error('Erro no download:', error);
          alert('Erro ao fazer download: ' + error.message);
        }
      })();
      ''';

      js.context.callMethod('eval', [script]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download iniciado: $filename'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro ao baixar PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao fazer download do PDF'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _printPDF() {
    final script = '''
    (function() {
      try {
        if (!window.currentPdfBlob) {
          console.error('PDF blob não encontrado');
          alert('Erro: PDF não está pronto para impressão.');
          return;
        }
        
        const blob = window.currentPdfBlob;
        const url = URL.createObjectURL(blob);
        const iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = url;
        
        document.body.appendChild(iframe);
        
        iframe.onload = function() {
          try {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
            
            setTimeout(() => {
              document.body.removeChild(iframe);
              URL.revokeObjectURL(url);
            }, 1000);
          } catch (e) {
            console.error('Erro ao imprimir:', e);
            alert('Erro ao abrir janela de impressão');
          }
        };
      } catch (error) {
        console.error('Erro na impressão:', error);
        alert('Erro ao preparar impressão: ' + error.message);
      }
    })();
    ''';

    js.context.callMethod('eval', [script]);
  }

  void _showRenameDialog() {
    _nameController.text = _documentName;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                ? const Color(0xFF2D333B) 
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

  void _showOptionsModal() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDEE2E6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildModalOption(
                    icon: Ionicons.create_outline,
                    title: 'Renomear',
                    subtitle: 'Alterar nome do documento',
                    onTap: () {
                      Navigator.pop(context);
                      _showRenameDialog();
                    },
                    themeProvider: themeProvider,
                    isFirst: true,
                  ),
                  const SizedBox(height: 2),
                  _buildModalOption(
                    icon: Ionicons.download_outline,
                    title: 'Download PDF',
                    subtitle: 'Baixar documento em PDF',
                    onTap: () {
                      Navigator.pop(context);
                      _downloadPDF();
                    },
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(height: 2),
                  _buildModalOption(
                    icon: Ionicons.print_outline,
                    title: 'Imprimir',
                    subtitle: 'Enviar para impressora',
                    onTap: () {
                      Navigator.pop(context);
                      _printPDF();
                    },
                    themeProvider: themeProvider,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : const Radius.circular(2),
          bottom: isLast ? const Radius.circular(12) : const Radius.circular(2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF868E96),
            ),
          ),
        ),
        trailing: Icon(
          Ionicons.chevron_forward,
          color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFFADB5BD),
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Stack(
      children: [
        _buildContent(themeProvider),

        if (_hasDocument && !_isConverting)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: _showOptionsModal,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Ionicons.list_outline,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(ThemeProvider themeProvider) {
    if (_isConverting) {
      return Container(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: Center(
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
        ),
      );
    }

    if (!_hasDocument) {
      return Container(
        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: Center(
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
        ),
      );
    }

    return Container(
      color: themeProvider.isDarkMode ? Colors.black : Colors.white,
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
    js.context.callMethod('eval', [
      'delete window.currentPdfBlob; delete window.currentPdfData;'
    ]);
    super.dispose();
  }
}