// lib/screens/edit_document_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class EditDocumentScreen extends StatefulWidget {
  final String htmlContent;
  final String documentName;

  const EditDocumentScreen({
    Key? key,
    required this.htmlContent,
    required this.documentName,
  }) : super(key: key);

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  static const String _editorViewType = 'html-editor-view';
  static bool _editorViewRegistered = false;
  late String _currentContent;
  html.DivElement? _editorElement;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.htmlContent;
    if (kIsWeb) {
      _registerEditorView();
    }
  }

  void _registerEditorView() {
    if (_editorViewRegistered) return;

    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final bgColor = themeProvider.isDarkMode ? '#1C2128' : '#FFFFFF';
      final textColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';
      final borderColor = themeProvider.isDarkMode ? '#2D333B' : '#DEE2E6';

      ui_web.platformViewRegistry.registerViewFactory(_editorViewType, (int viewId) {
        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.overflow = 'hidden';

        _editorElement = html.DivElement()
          ..id = 'editor-$viewId'
          ..contentEditable = 'true'
          ..spellcheck = false
          ..style.flex = '1'
          ..style.padding = '20px'
          ..style.overflow = 'auto'
          ..style.backgroundColor = bgColor
          ..style.color = textColor
          ..style.border = '1px solid $borderColor'
          ..style.borderRadius = '12px'
          ..style.fontSize = '16px'
          ..style.lineHeight = '1.6'
          ..style.fontFamily = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
          ..style.outline = 'none'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..innerHtml = _currentContent;

        // Detectar mudanças
        _editorElement!.onInput.listen((_) {
          if (!_hasChanges) {
            setState(() {
              _hasChanges = true;
            });
          }
        });

        // Adicionar CSS para imagens dentro do editor
        final style = html.StyleElement()
          ..text = '''
            #editor-$viewId img {
              max-width: 100%;
              height: auto;
              display: block;
              margin: 10px 0;
              border-radius: 8px;
            }
            #editor-$viewId h1 {
              font-size: 32px;
              font-weight: 700;
              margin: 20px 0 10px 0;
            }
            #editor-$viewId h2 {
              font-size: 24px;
              font-weight: 600;
              margin: 18px 0 8px 0;
            }
            #editor-$viewId h3 {
              font-size: 20px;
              font-weight: 600;
              margin: 16px 0 8px 0;
            }
            #editor-$viewId p {
              margin: 8px 0;
            }
            #editor-$viewId ul, #editor-$viewId ol {
              margin: 10px 0;
              padding-left: 30px;
            }
            #editor-$viewId li {
              margin: 5px 0;
            }
            #editor-$viewId strong {
              font-weight: 700;
            }
            #editor-$viewId em {
              font-style: italic;
            }
            #editor-$viewId code {
              background: ${themeProvider.isDarkMode ? '#2D333B' : '#F1F3F5'};
              padding: 2px 6px;
              border-radius: 4px;
              font-family: 'Courier New', monospace;
            }
            #editor-$viewId pre {
              background: ${themeProvider.isDarkMode ? '#2D333B' : '#F1F3F5'};
              padding: 12px;
              border-radius: 8px;
              overflow-x: auto;
              margin: 10px 0;
            }
            #editor-$viewId blockquote {
              border-left: 4px solid ${themeProvider.isDarkMode ? '#58A6FF' : '#0366D6'};
              padding-left: 16px;
              margin: 12px 0;
              color: ${themeProvider.isDarkMode ? '#ADB5BD' : '#6C757D'};
            }
            #editor-$viewId a {
              color: ${themeProvider.isDarkMode ? '#58A6FF' : '#0366D6'};
              text-decoration: none;
            }
            #editor-$viewId a:hover {
              text-decoration: underline;
            }
          ''';

        wrapper.append(style);
        wrapper.append(_editorElement!);

        return wrapper;
      });

      _editorViewRegistered = true;
    } catch (e) {
      debugPrint('Erro ao registrar editor: $e');
    }
  }

  String _getEditorContent() {
    if (_editorElement != null) {
      return _editorElement!.innerHtml ?? _currentContent;
    }
    return _currentContent;
  }

  void _saveAndClose() {
    final content = _getEditorContent();
    Navigator.pop(context, content);
  }

  void _showDiscardDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Descartar alterações?',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Você tem alterações não salvas. Deseja descartar?',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : const Color(0xFF6C757D),
            fontSize: 16,
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
              Navigator.pop(context); // Fecha o diálogo
              Navigator.pop(context); // Fecha a tela de edição
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  void _insertImage() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserir imagem',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: urlController,
          autofocus: true,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'URL da imagem',
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
              final url = urlController.text.trim();
              if (url.isNotEmpty && _editorElement != null) {
                final imgHtml = '<img src="$url" alt="Imagem" style="max-width: 100%; height: auto; display: block; margin: 10px 0; border-radius: 8px;">';
                _editorElement!.insertAdjacentHtml('beforeend', imgHtml);
                setState(() {
                  _hasChanges = true;
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
            child: const Text('Inserir'),
          ),
        ],
      ),
    );
  }

  void _applyFormatting(String tag) {
    if (_editorElement != null) {
      html.document.execCommand(tag, false, null);
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _showDiscardDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Ionicons.close_outline,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
            onPressed: () {
              if (_hasChanges) {
                _showDiscardDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Editar documento',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: _saveAndClose,
              icon: Icon(
                Ionicons.checkmark_outline,
                color: const Color(0xFF007AFF),
              ),
              label: Text(
                'Concluir',
                style: TextStyle(
                  color: const Color(0xFF007AFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Barra de ferramentas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: themeProvider.isDarkMode
                        ? const Color(0xFF2D333B)
                        : const Color(0xFFDEE2E6),
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'Negrito',
                      onPressed: () => _applyFormatting('bold'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'Itálico',
                      onPressed: () => _applyFormatting('italic'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.list_outline,
                      label: 'Lista',
                      onPressed: () => _applyFormatting('insertUnorderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.image_outline,
                      label: 'Imagem',
                      onPressed: _insertImage,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? const Color(0xFF2D333B)
                          : const Color(0xFFDEE2E6),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? HtmlElementView(
                            viewType: _editorViewType,
                            key: ValueKey('editor-${themeProvider.isDarkMode}'),
                          )
                        : Center(
                            child: Text(
                              'Editor disponível apenas na web',
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF6C757D),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? const Color(0xFF2D333B)
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}