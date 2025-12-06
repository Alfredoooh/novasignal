// lib/screens/edit_document_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'dart:js' as js;

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
  late String _currentContent;
  bool _hasChanges = false;
  String? _viewId;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.htmlContent;
    _viewId = 'editor-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _registerEditorView();
    }
  }

  void _registerEditorView() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bgColor = themeProvider.isDarkMode ? '#1C2128' : '#FFFFFF';
    final textColor = themeProvider.isDarkMode ? '#FFFFFF' : '#212529';

    ui_web.platformViewRegistry.registerViewFactory(
      '$_editorViewType-$_viewId',
      (int id) {
        final container = html.DivElement()
          ..id = 'editor-container-$_viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.overflow = 'hidden';

        final editor = html.DivElement()
          ..id = 'editor-content-$_viewId'
          ..contentEditable = 'true'
          ..spellcheck = false
          ..style.flex = '1'
          ..style.padding = '20px'
          ..style.overflow = 'auto'
          ..style.backgroundColor = bgColor
          ..style.color = textColor
          ..style.fontSize = '16px'
          ..style.lineHeight = '1.6'
          ..style.fontFamily = 'Arial, Helvetica, sans-serif'
          ..style.outline = 'none'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..innerHtml = _currentContent;

        editor.onInput.listen((_) {
          if (!_hasChanges) {
            _hasChanges = true;
          }
        });

        final style = html.StyleElement()
          ..text = '''
            #editor-content-$_viewId img {
              max-width: 100%;
              height: auto;
              display: block;
              margin: 10px 0;
              border-radius: 8px;
            }
            #editor-content-$_viewId h1 {
              font-size: 32px;
              font-weight: 700;
              margin: 20px 0 10px 0;
            }
            #editor-content-$_viewId h2 {
              font-size: 24px;
              font-weight: 600;
              margin: 18px 0 8px 0;
            }
            #editor-content-$_viewId h3 {
              font-size: 20px;
              font-weight: 600;
              margin: 16px 0 8px 0;
            }
            #editor-content-$_viewId p {
              margin: 8px 0;
            }
            #editor-content-$_viewId ul, #editor-content-$_viewId ol {
              margin: 10px 0;
              padding-left: 30px;
            }
            #editor-content-$_viewId li {
              margin: 5px 0;
            }
            #editor-content-$_viewId strong {
              font-weight: 700;
            }
            #editor-content-$_viewId em {
              font-style: italic;
            }
          ''';

        container.append(style);
        container.append(editor);

        return container;
      },
    );
  }

  String _getEditorContent() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        return editor ? editor.innerHTML : '';
      })();
    ''';
    
    final result = js.context.callMethod('eval', [script]);
    return result?.toString() ?? _currentContent;
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
              Navigator.pop(context);
              Navigator.pop(context);
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

  void _pickAndInsertImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        
        reader.onLoadEnd.listen((e) {
          final dataUrl = reader.result as String;
          
          final script = '''
            (function() {
              var editor = document.getElementById('editor-content-$_viewId');
              if (editor) {
                var img = document.createElement('img');
                img.src = '$dataUrl';
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                img.style.display = 'block';
                img.style.margin = '10px 0';
                img.style.borderRadius = '8px';
                editor.appendChild(img);
              }
            })();
          ''';
          
          js.context.callMethod('eval', [script]);
          
          setState(() {
            _hasChanges = true;
          });
        });
        
        reader.readAsDataUrl(file);
      }
    });
  }

  void _applyFormatting(String command) {
    final script = '''
      (function() {
        document.execCommand('$command', false, null);
      })();
    ''';
    
    js.context.callMethod('eval', [script]);
    
    setState(() {
      _hasChanges = true;
    });
  }

  void _insertHeading(int level) {
    final script = '''
      (function() {
        document.execCommand('formatBlock', false, 'h$level');
      })();
    ''';
    
    js.context.callMethod('eval', [script]);
    
    setState(() {
      _hasChanges = true;
    });
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
            'Editar: ${widget.documentName}',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: _saveAndClose,
              icon: const Icon(
                Ionicons.checkmark_circle,
                color: Color(0xFF007AFF),
              ),
              label: const Text(
                'Concluir',
                style: TextStyle(
                  color: Color(0xFF007AFF),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'Itálico',
                      onPressed: () => _applyFormatting('italic'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'Sublinhado',
                      onPressed: () => _applyFormatting('underline'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.list_outline,
                      label: 'Lista',
                      onPressed: () => _applyFormatting('insertUnorderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.list_outline,
                      label: 'Numerada',
                      onPressed: () => _applyFormatting('insertOrderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'H1',
                      onPressed: () => _insertHeading(1),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'H2',
                      onPressed: () => _insertHeading(2),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 6),
                    _buildToolbarButton(
                      icon: Ionicons.image_outline,
                      label: 'Imagem',
                      onPressed: _pickAndInsertImage,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),

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
                            viewType: '$_editorViewType-$_viewId',
                            key: ValueKey('editor-$_viewId-${themeProvider.isDarkMode}'),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? const Color(0xFF2D333B)
                : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
}