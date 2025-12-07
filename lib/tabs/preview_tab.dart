// lib/tabs/preview_tab.dart  
import 'package:flutter/material.dart';  
import 'package:flutter/foundation.dart' show kIsWeb;  
import 'package:ionicons/ionicons.dart';  
import 'package:provider/provider.dart';  
import '../providers/theme_provider.dart';  
import '../screens/edit_document_screen.dart';

// Conditional imports corrigidos
import 'preview_tab_web_stub.dart'
    if (dart.library.html) 'dart:html' as html;
import 'preview_tab_ui_web_stub.dart'
    if (dart.library.html) 'dart:ui_web' as ui_web;
import 'preview_tab_js_stub.dart'
    if (dart.library.html) 'dart:js_util' as js_util;

class PreviewTab extends StatefulWidget {  
  final String? htmlContent;  
  final Function(String)? onContentUpdated;

  const PreviewTab({Key? key, this.htmlContent, this.onContentUpdated}) : super(key: key);  

  @override  
  State<PreviewTab> createState() => _PreviewTabState();  
}  

class _PreviewTabState extends State<PreviewTab> {  
  static const String _previewViewType = 'pdf-preview-viewer';  
  static const String _renameInputViewType = 'rename-input-field';  
  static bool _renameViewRegistered = false;  

  bool _isConverting = false;  
  bool _hasDocument = false;  
  String? _pdfViewId;  
  String _documentName = 'Documento sem título';  
  final TextEditingController _nameController = TextEditingController();  
  String? _lastProcessedContent;  
  String? _currentHtmlContent;
  dynamic _htmlRenameInput;  

  @override  
  void initState() {  
    super.initState();  
    if (kIsWeb) {
      _initializePDFLibraries();  
    }
    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {  
      _currentHtmlContent = widget.htmlContent;
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
      _currentHtmlContent = widget.htmlContent;
      _convertAndRenderPDF(widget.htmlContent!);  
    }  
  }  

  void _initializePDFLibraries() {
    if (!kIsWeb) return;

    try {
      final doc = js_util.getProperty(js_util.globalThis, 'document');
      final head = js_util.getProperty(doc, 'head');
      
      // Verificar se scripts já existem
      final hasJsPDF = js_util.callMethod(doc, 'querySelector', ['script[src*="jspdf"]']) != null;
      final hasHtml2Canvas = js_util.callMethod(doc, 'querySelector', ['script[src*="html2canvas"]']) != null;
      final hasPdfJs = js_util.callMethod(doc, 'querySelector', ['script[src*="pdf.js"]']) != null;

      if (!hasJsPDF) {
        final script = js_util.callMethod(doc, 'createElement', ['script']);
        js_util.setProperty(script, 'src', 'https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js');
        js_util.setProperty(script, 'async', true);
        js_util.callMethod(head, 'appendChild', [script]);
      }

      if (!hasHtml2Canvas) {
        final script = js_util.callMethod(doc, 'createElement', ['script']);
        js_util.setProperty(script, 'src', 'https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js');
        js_util.setProperty(script, 'async', true);
        js_util.callMethod(head, 'appendChild', [script]);
      }

      if (!hasPdfJs) {
        final script = js_util.callMethod(doc, 'createElement', ['script']);
        js_util.setProperty(script, 'src', 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js');
        js_util.setProperty(script, 'async', true);
        js_util.callMethod(head, 'appendChild', [script]);

        // Configurar worker
        _evalScript('''
          if (typeof pdfjsLib !== 'undefined') {
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';
          }
        ''');
      }
    } catch (e) {
      debugPrint('Erro ao inicializar bibliotecas PDF: $e');
    }
  }

  void _evalScript(String script) {
    if (!kIsWeb) return;
    try {
      js_util.callMethod(js_util.globalThis, 'eval', [script]);
    } catch (e) {
      debugPrint('Erro ao executar script: $e');
    }
  }

  dynamic _evalScriptWithReturn(String script) {
    if (!kIsWeb) return null;
    try {
      return js_util.callMethod(js_util.globalThis, 'eval', [script]);
    } catch (e) {
      debugPrint('Erro ao executar script: $e');
      return null;
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
    if (!kIsWeb) return;

    try {
      ui_web.platformViewRegistry.registerViewFactory(  
        '$_previewViewType-$viewId',  
        (int id) {
          final doc = js_util.getProperty(js_util.globalThis, 'document');
          final container = js_util.callMethod(doc, 'createElement', ['div']);
          
          js_util.setProperty(container, 'id', 'pdf-container-$viewId');
          
          final style = js_util.getProperty(container, 'style');
          js_util.setProperty(style, 'width', '100%');
          js_util.setProperty(style, 'height', '100%');
          js_util.setProperty(style, 'overflow', 'auto');
          js_util.setProperty(style, 'padding', '20px');
          js_util.setProperty(style, 'boxSizing', 'border-box');
          js_util.setProperty(style, 'display', 'flex');
          js_util.setProperty(style, 'flexDirection', 'column');
          js_util.setProperty(style, 'alignItems', 'center');
          js_util.setProperty(style, 'gap', '20px');
          js_util.setProperty(style, 'backgroundColor', '#e0e0e0');

          return container;  
        },  
      );
    } catch (e) {
      debugPrint('Erro ao registrar view PDF: $e');
    }
  }  

  Future<void> _executeHTMLtoPDF(String htmlContent, String viewId) async {  
    final script = '''  
    (async function() {  
      try {  
        const { jsPDF } = window.jspdf;  
        const html2canvas = window.html2canvas;  
        const pdfjsLib = window.pdfjsLib;  
          
        if (!jsPDF || !html2canvas || !pdfjsLib) {  
          console.error('❌ Bibliotecas não carregadas');  
          return;  
        }  
        
        console.log('🚀 Iniciando conversão HTML → PDF de alta qualidade');
        
        const a4WidthMm = 210;  
        const a4HeightMm = 297;  
        const marginMm = 25;
        const contentWidthMm = a4WidthMm - (marginMm * 2);
        const contentHeightMm = a4HeightMm - (marginMm * 2);
        
        const dpi = 150;
        const mmToPx = dpi / 25.4;
        const contentWidthPx = Math.floor(contentWidthMm * mmToPx);
        const contentHeightPx = Math.floor(contentHeightMm * mmToPx);
          
        const container = document.createElement('div');  
        container.style.cssText = \`  
          position: absolute;  
          left: -99999px;  
          top: 0;  
          width: \${contentWidthPx}px;  
          background: white;  
          padding: 0;
          margin: 0;
          box-sizing: border-box;
        \`;  
          
        container.innerHTML = \`$htmlContent\`;  
        document.body.appendChild(container);
        
        console.log('⏳ Aguardando imagens...');
        const images = container.querySelectorAll('img');
        await Promise.all(
          Array.from(images).map(img => {
            return new Promise((resolve) => {
              if (img.complete) {
                resolve();
              } else {
                img.onload = resolve;
                img.onerror = () => {
                  console.warn('⚠️ Falha ao carregar:', img.src);
                  resolve();
                };
                setTimeout(resolve, 5000);
              }
            });
          })
        );
          
        await new Promise(resolve => setTimeout(resolve, 1000));  
          
        console.log('🎨 Renderizando canvas em alta qualidade...');
        const canvas = await html2canvas(container, {  
          scale: 3,
          useCORS: true,  
          logging: false,  
          backgroundColor: '#ffffff',  
          width: contentWidthPx,
          windowWidth: contentWidthPx,
          allowTaint: false,
          imageTimeout: 15000,
          letterRendering: true,
          removeContainer: false,
          foreignObjectRendering: false,
        });  
        
        console.log('✅ Canvas renderizado:', canvas.width, 'x', canvas.height);
        document.body.removeChild(container);  
          
        const pdf = new jsPDF({  
          orientation: 'portrait',  
          unit: 'mm',  
          format: 'a4',  
          compress: false
        });  
          
        const imgData = canvas.toDataURL('image/png');
        const imgWidthMm = contentWidthMm;
        const imgHeightMm = (canvas.height * contentWidthMm) / canvas.width;
        const pageContentHeight = contentHeightMm;
        
        console.log('📊 Dimensões:', {
          imgWidthMm: imgWidthMm.toFixed(2),
          imgHeightMm: imgHeightMm.toFixed(2),
          pageContentHeight: pageContentHeight.toFixed(2)
        });
        
        let yOffset = 0;
        let pageNumber = 1;
        
        while (yOffset < imgHeightMm) {
          if (pageNumber > 1) {
            pdf.addPage();
          }
          
          const remainingHeight = imgHeightMm - yOffset;
          const pageHeight = Math.min(pageContentHeight, remainingHeight);
          
          const canvasSourceY = (yOffset / imgHeightMm) * canvas.height;
          const canvasSourceHeight = (pageHeight / imgHeightMm) * canvas.height;
          
          const pageCanvas = document.createElement('canvas');
          pageCanvas.width = canvas.width;
          pageCanvas.height = Math.ceil(canvasSourceHeight);
          
          const pageCtx = pageCanvas.getContext('2d', { alpha: false });
          pageCtx.fillStyle = '#ffffff';
          pageCtx.fillRect(0, 0, pageCanvas.width, pageCanvas.height);
          
          pageCtx.drawImage(
            canvas,
            0, Math.floor(canvasSourceY),
            canvas.width, Math.ceil(canvasSourceHeight),
            0, 0,
            pageCanvas.width, pageCanvas.height
          );
          
          const pageImgData = pageCanvas.toDataURL('image/png');
          
          pdf.addImage(
            pageImgData, 
            'PNG', 
            marginMm, 
            marginMm, 
            imgWidthMm, 
            pageHeight,
            \`page\${pageNumber}\`,
            'SLOW'
          );
          
          console.log(\`✅ Página \${pageNumber} (offset: \${yOffset.toFixed(2)}mm, altura: \${pageHeight.toFixed(2)}mm)\`);
          
          yOffset += pageContentHeight;
          pageNumber++;
        }
        
        console.log(\`📚 Total de páginas: \${pageNumber - 1}\`);
          
        const pdfData = pdf.output('arraybuffer');  
        const pdfBlob = new Blob([pdfData], { type: 'application/pdf' });  
          
        window.currentPdfData = pdfData;  
        window.currentPdfBlob = pdfBlob;  
        
        console.log('💾 PDF salvo');
          
        console.log('🖼️ Renderizando preview...');
        const pdfContainer = document.getElementById('pdf-container-$viewId');  
        if (!pdfContainer) {
          console.error('❌ Container não encontrado');
          return;
        }
          
        pdfContainer.innerHTML = '';  
          
        const loadingTask = pdfjsLib.getDocument({ data: pdfData });  
        const pdfDoc = await loadingTask.promise;  
        
        const containerWidth = pdfContainer.offsetWidth;
        const isMobile = containerWidth < 768;
        const maxPageWidth = isMobile ? containerWidth - 40 : Math.min(containerWidth - 80, 800);
        
        for (let pageNum = 1; pageNum <= pdfDoc.numPages; pageNum++) {  
          const page = await pdfDoc.getPage(pageNum);  
          
          const viewport = page.getViewport({ scale: 1.0 });
          const scale = maxPageWidth / viewport.width;
          const scaledViewport = page.getViewport({ scale });
            
          const pageContainer = document.createElement('div');  
          pageContainer.style.cssText = \`  
            width: \${scaledViewport.width}px;
            height: \${scaledViewport.height}px;
            background: white;  
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);  
            margin: 0 auto;
            position: relative;
            overflow: hidden;
          \`;  
            
          const canvas = document.createElement('canvas');  
          canvas.style.cssText = 'display: block; width: 100%; height: 100%;';  
            
          const ctx = canvas.getContext('2d');  
          canvas.width = scaledViewport.width;  
          canvas.height = scaledViewport.height;  
            
          pageContainer.appendChild(canvas);  
          pdfContainer.appendChild(pageContainer);  
            
          await page.render({  
            canvasContext: ctx,  
            viewport: scaledViewport,
            intent: 'print'
          }).promise;
          
          console.log(\`✅ Página \${pageNum} renderizada\`);
        }  
        
        console.log('🎉 Conversão concluída com ALTA QUALIDADE!');
          
      } catch (error) {  
        console.error('💥 Erro:', error);  
        throw error;  
      }  
    })();  
    ''';  

    _evalScript(script);  
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
        } catch (error) {  
          console.error('Erro no download:', error);  
        }  
      })();  
      ''';  

      _evalScript(script);  
    } catch (e) {  
      debugPrint('Erro ao baixar PDF: $e');  
    }  
  }  

  void _printPDF() {  
    final script = '''  
    (function() {  
      try {  
        if (!window.currentPdfBlob) {  
          console.error('PDF blob não encontrado');  
          return;  
        }  
          
        const blob = window.currentPdfBlob;  
        const url = URL.createObjectURL(blob);  
          
        const printWindow = window.open(url, '_blank');  
          
        if (printWindow) {  
          printWindow.onload = function() {  
            printWindow.focus();  
            printWindow.print();  
          };  
            
          setTimeout(() => {  
            URL.revokeObjectURL(url);  
          }, 60000);  
        } else {  
          console.error('Não foi possível abrir janela de impressão');  
        }  
      } catch (error) {  
        console.error('Erro na impressão:', error);  
      }  
    })();  
    ''';  

    _evalScript(script);  
  }  

  void _editDocument() async {
    if (_currentHtmlContent == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDocumentScreen(
          htmlContent: _currentHtmlContent!,
          documentName: _documentName,
        ),
      ),
    );

    if (result != null && result is String && mounted) {
      setState(() {
        _currentHtmlContent = result;
        _lastProcessedContent = result;
      });

      if (widget.onContentUpdated != null) {
        widget.onContentUpdated!(result);
      }

      _convertAndRenderPDF(result);
    }
  }

  void _registerRenameInputView() {  
    if (_renameViewRegistered || !kIsWeb) return;  

    try {  
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);  
      final inputBgColor = themeProvider.isDarkMode ? '#2D333B' : '#F1F3F5';  
      final inputTextColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';  
      final inputPlaceholderColor = themeProvider.isDarkMode ? '#ADB5BD' : '#6C757D';  

      ui_web.platformViewRegistry.registerViewFactory(_renameInputViewType, (int viewId) {
        final doc = js_util.getProperty(js_util.globalThis, 'document');
        
        final wrapper = js_util.callMethod(doc, 'createElement', ['div']);
        final wrapperStyle = js_util.getProperty(wrapper, 'style');
        js_util.setProperty(wrapperStyle, 'width', '100%');
        js_util.setProperty(wrapperStyle, 'height', '100%');
        js_util.setProperty(wrapperStyle, 'display', 'flex');
        js_util.setProperty(wrapperStyle, 'alignItems', 'center');

        _htmlRenameInput = js_util.callMethod(doc, 'createElement', ['input']);
        js_util.setProperty(_htmlRenameInput, 'id', 'renameInput-$viewId');
        js_util.setProperty(_htmlRenameInput, 'type', 'text');
        js_util.setProperty(_htmlRenameInput, 'value', _documentName);
        js_util.setProperty(_htmlRenameInput, 'placeholder', 'Nome do documento');
        js_util.callMethod(_htmlRenameInput, 'setAttribute', ['autocomplete', 'off']);
        js_util.callMethod(_htmlRenameInput, 'setAttribute', ['spellcheck', 'false']);
        
        final inputStyle = js_util.getProperty(_htmlRenameInput, 'style');
        js_util.setProperty(inputStyle, 'flex', '1');
        js_util.setProperty(inputStyle, 'padding', '12px 16px');
        js_util.setProperty(inputStyle, 'border', 'none');
        js_util.setProperty(inputStyle, 'borderRadius', '8px');
        js_util.setProperty(inputStyle, 'fontSize', '16px');
        js_util.setProperty(inputStyle, 'outline', 'none');
        js_util.setProperty(inputStyle, 'backgroundColor', inputBgColor);
        js_util.setProperty(inputStyle, 'color', inputTextColor);
        js_util.setProperty(inputStyle, 'fontFamily', '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif');
        js_util.setProperty(inputStyle, 'transition', 'background-color 0.3s');
        js_util.callMethod(inputStyle, 'setProperty', ['-webkit-user-select', 'text']);
        js_util.setProperty(inputStyle, 'userSelect', 'text');

        final style = js_util.callMethod(doc, 'createElement', ['style']);
        js_util.setProperty(style, 'textContent', '''  
          #renameInput-$viewId::placeholder { color: $inputPlaceholderColor; }  
          #renameInput-$viewId:focus { box-shadow: none !important; outline: none !important; }  
        ''');

        js_util.callMethod(wrapper, 'appendChild', [style]);
        js_util.callMethod(wrapper, 'appendChild', [_htmlRenameInput]);

        return wrapper;  
      });  

      _renameViewRegistered = true;  
    } catch (e) {  
      debugPrint('Error registering rename input view: $e');  
    }  
  }  

  void _showRenameDialog() {  
    _nameController.text = _documentName;  
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);  

    if (kIsWeb) {  
      _registerRenameInputView();  
    }  

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
        content: SizedBox(  
          height: 48,  
          child: kIsWeb  
              ? HtmlElementView(  
                  viewType: _renameInputViewType,  
                  key: ValueKey('rename-${themeProvider.isDarkMode}'),  
                )  
              : TextField(  
                  controller: _nameController,  
                  autofocus: true,  
                  style: TextStyle(  
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),  
                    fontSize: 16,  
                  ),  
                  decoration: InputDecoration(  
                    hintText: 'Nome do documento',  
                    hintStyle: TextStyle(  
                      color: themeProvider.isDarkMode ? Colors.white54 : Colors.grey,  
                    ),  
                    filled: true,  
                    fillColor: themeProvider.isDarkMode   
                        ? const Color(0xFF2D333B)   
                        : const Color(0xFFF1F3F5),  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(8),  
                      borderSide: BorderSide.none,  
                    ),  
                    contentPadding: const EdgeInsets.symmetric(  
                      horizontal: 16,  
                      vertical: 12,  
                    ),  
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
              if (kIsWeb && _htmlRenameInput != null) {
                try {
                  final newName = js_util.getProperty(_htmlRenameInput, 'value')?.toString().trim() ?? '';
                  setState(() {  
                    _documentName = newName.isEmpty ? 'Documento sem título' : newName;  
                  });
                } catch (e) {
                  debugPrint('Erro ao obter valor do input: $e');
                }
              } else {  
                setState(() {  
                  _documentName = _nameController.text.trim().isEmpty   
                      ? 'Documento sem título'   
                      : _nameController.text.trim();  
                });  
              }  
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
                    title: 'Editar',  
                    subtitle: 'Editar conteúdo do documento',  
                    onTap: () {  
                      Navigator.pop(context);  
                      _editDocument();  
                    },  
                    themeProvider: themeProvider,  
                    isFirst: true,  
                  ),  
                  const SizedBox(height: 2),  
                  _buildModalOption(  
                    icon: Ionicons.text_outline,  
                    title: 'Renomear',  
                    subtitle: 'Alterar nome do documento',  
                    onTap: () {  
                      Navigator.pop(context);  
                      _showRenameDialog();  
                    },  
                    themeProvider: themeProvider,  
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
            child: kIsWeb
                ? HtmlElementView(  
                    viewType: '$_previewViewType-$_pdfViewId',  
                  )
                : const Center(
                    child: Text('Preview disponível apenas na web'),
                  ),
          ),  
        ),  
      ),  
    );  
  }  

  @override  
  void dispose() {  
    _nameController.dispose();
    if (kIsWeb) {
      _evalScript('delete window.currentPdfBlob; delete window.currentPdfData;');
    }
    super.dispose();  
  }  
}