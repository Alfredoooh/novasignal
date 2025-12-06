// lib/tabs/preview_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/edit_document_screen.dart';
import '../utils/web_utils.dart'
    if (dart.library.html) '../utils/web_utils_web.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class PreviewTab extends StatefulWidget {
  final String? htmlContent;
  final Function(String)? onContentUpdated;

  const PreviewTab({Key? key, this.htmlContent, this.onContentUpdated}) : super(key: key);

  @override
  State<PreviewTab> createState() => _PreviewTabState();
}

class _PreviewTabState extends State<PreviewTab> {
  static const String _renameInputViewType = 'rename-input-field';
  static bool _renameViewRegistered = false;

  bool _isLoading = false;
  bool _hasDocument = false;
  String? _iframeViewId;
  String _documentName = 'Documento sem título';
  final TextEditingController _nameController = TextEditingController();
  String? _lastProcessedContent;
  String? _currentHtmlContent;
  html.InputElement? _htmlRenameInput;

  @override
  void initState() {
    super.initState();
    if (widget.htmlContent != null && widget.htmlContent!.isNotEmpty) {
      _currentHtmlContent = widget.htmlContent;
      _renderHTML(widget.htmlContent!);
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
      _renderHTML(widget.htmlContent!);
    }
  }

  Future<void> _renderHTML(String htmlContent) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasDocument = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final viewId = 'html-preview-${DateTime.now().millisecondsSinceEpoch}';
      _registerHTMLView(viewId, htmlContent);

      if (mounted) {
        setState(() {
          _hasDocument = true;
          _isLoading = false;
          _iframeViewId = viewId;
        });
      }

      // Timeout de segurança
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Erro ao renderizar HTML: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _registerHTMLView(String viewId, String htmlContent) {
    registerWebViewFactory(
      'html-viewer-$viewId',
      (int id) {
        // Aplica zoom bem reduzido
        final htmlWithZoom = '''
          <style>
            html, body {
              zoom: 0.03 !important;
              -moz-transform: scale(0.03);
              -moz-transform-origin: 0 0;
              margin: 0;
              padding: 0;
            }
          </style>
          $htmlContent
        ''';

        final iframe = html.IFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..srcdoc = htmlWithZoom;

        // Salvar referência global para download/impressão
        js.context['currentDocumentHTML'] = htmlContent;

        iframe.onLoad.listen((event) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });

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
  }

  void _downloadPDF() {
    try {
      final sanitizedName = _documentName
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(' ', '_');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${sanitizedName}_$timestamp.pdf';

      final script = '''
      (async function() {
        try {
          const { jsPDF } = window.jspdf;
          const html2canvas = window.html2canvas;
          
          if (!jsPDF || !html2canvas) {
            console.error('Bibliotecas não carregadas');
            alert('Aguarde o carregamento das bibliotecas...');
            return;
          }

          const htmlContent = window.currentDocumentHTML;
          if (!htmlContent) {
            console.error('Conteúdo HTML não encontrado');
            return;
          }

          // Criar container temporário
          const container = document.createElement('div');
          container.style.cssText = `
            position: absolute;
            left: -99999px;
            top: 0;
            width: 794px;
            background: white;
          `;
          container.innerHTML = htmlContent;
          document.body.appendChild(container);

          // Aguardar imagens
          const images = container.querySelectorAll('img');
          await Promise.all(
            Array.from(images).map(img => {
              return new Promise((resolve) => {
                if (img.complete) resolve();
                else {
                  img.onload = resolve;
                  img.onerror = resolve;
                  setTimeout(resolve, 3000);
                }
              });
            })
          );

          await new Promise(resolve => setTimeout(resolve, 500));

          // Renderizar canvas
          const canvas = await html2canvas(container, {
            scale: 2,
            useCORS: true,
            logging: false,
            backgroundColor: '#ffffff',
          });

          document.body.removeChild(container);

          // Criar PDF
          const pdf = new jsPDF({
            orientation: 'portrait',
            unit: 'mm',
            format: 'a4',
          });

          const imgData = canvas.toDataURL('image/png');
          const imgWidth = 210;
          const imgHeight = (canvas.height * imgWidth) / canvas.width;
          const pageHeight = 297;
          let heightLeft = imgHeight;
          let position = 0;

          pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
          heightLeft -= pageHeight;

          while (heightLeft > 0) {
            position = heightLeft - imgHeight;
            pdf.addPage();
            pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
            heightLeft -= pageHeight;
          }

          pdf.save('$filename');
        } catch (error) {
          console.error('Erro ao gerar PDF:', error);
          alert('Erro ao gerar PDF: ' + error.message);
        }
      })();
      ''';

      _loadLibrariesAndExecute(script);
    } catch (e) {
      debugPrint('Erro ao baixar PDF: $e');
    }
  }

  void _printPDF() {
    final script = '''
    (function() {
      try {
        const htmlContent = window.currentDocumentHTML;
        if (!htmlContent) {
          console.error('Conteúdo HTML não encontrado');
          return;
        }

        const printWindow = window.open('', '_blank');
        if (!printWindow) {
          console.error('Não foi possível abrir janela de impressão');
          return;
        }

        printWindow.document.write(htmlContent);
        printWindow.document.close();
        
        printWindow.onload = function() {
          printWindow.focus();
          printWindow.print();
        };
      } catch (error) {
        console.error('Erro na impressão:', error);
      }
    })();
    ''';

    js.context.callMethod('eval', [script]);
  }

  void _loadLibrariesAndExecute(String script) {
    // Verificar se bibliotecas já estão carregadas
    final checkAndExecute = '''
    (function() {
      if (window.jspdf && window.html2canvas) {
        $script
      } else {
        // Carregar bibliotecas
        const loadScript = (src) => {
          return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = src;
            script.onload = resolve;
            script.onerror = reject;
            document.head.appendChild(script);
          });
        };

        Promise.all([
          window.jspdf ? Promise.resolve() : loadScript('https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js'),
          window.html2canvas ? Promise.resolve() : loadScript('https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js')
        ]).then(() => {
          setTimeout(() => {
            $script
          }, 500);
        }).catch(err => {
          console.error('Erro ao carregar bibliotecas:', err);
          alert('Erro ao carregar bibliotecas necessárias');
        });
      }
    })();
    ''';

    js.context.callMethod('eval', [checkAndExecute]);
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

      _renderHTML(result);
    }
  }

  void _registerRenameInputView() {
    if (_renameViewRegistered) return;

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final inputBgColor = themeProvider.isDarkMode ? '#2D333B' : '#F1F3F5';
      final inputTextColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';
      final inputPlaceholderColor = themeProvider.isDarkMode ? '#ADB5BD' : '#6C757D';

      registerWebViewFactory(_renameInputViewType, (int viewId) {
        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center';

        _htmlRenameInput = html.InputElement()
          ..id = 'renameInput-$viewId'
          ..type = 'text'
          ..value = _documentName
          ..placeholder = 'Nome do documento'
          ..setAttribute('autocomplete', 'off')
          ..setAttribute('spellcheck', 'false')
          ..style.flex = '1'
          ..style.padding = '12px 16px'
          ..style.border = 'none'
          ..style.borderRadius = '8px'
          ..style.fontSize = '16px'
          ..style.outline = 'none'
          ..style.backgroundColor = inputBgColor
          ..style.color = inputTextColor
          ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
          ..style.transition = 'background-color 0.3s'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text';

        final style = html.StyleElement()
          ..text = '''
            #renameInput-$viewId::placeholder { color: $inputPlaceholderColor; }
            #renameInput-$viewId:focus { box-shadow: none !important; outline: none !important; }
          ''';

        wrapper.append(style);
        wrapper.append(_htmlRenameInput!);

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
              if (kIsWeb) {
                final newName = _htmlRenameInput?.value?.trim() ?? '';
                setState(() {
                  _documentName = newName.isEmpty ? 'Documento sem título' : newName;
                });
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
        if (_hasDocument && !_isLoading)
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
    if (_isLoading) {
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
                'Carregando documento...',
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
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: HtmlElementView(
            viewType: 'html-viewer-$_iframeViewId',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    js.context.callMethod('eval', ['delete window.currentDocumentHTML;']);
    super.dispose();
  }
}