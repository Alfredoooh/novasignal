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
  static const String _editorViewType = 'advanced-html-editor';
  late String _currentContent;
  bool _hasChanges = false;
  String? _viewId;
  String _selectedImageId = '';

  @override
  void initState() {
    super.initState();
    _currentContent = _extractBodyContent(widget.htmlContent);
    _viewId = 'editor-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _registerEditorView();
    }
  }

  String _extractBodyContent(String html) {
    // Extrair apenas o conteúdo do body, mantendo os estilos inline
    final bodyStart = html.indexOf('<body');
    final bodyEnd = html.lastIndexOf('</body>');
    
    if (bodyStart != -1 && bodyEnd != -1) {
      final bodyTag = html.substring(bodyStart, html.indexOf('>', bodyStart) + 1);
      final content = html.substring(html.indexOf('>', bodyStart) + 1, bodyEnd);
      return content;
    }
    
    return html;
  }

  String _rebuildFullHtml(String bodyContent) {
    // Reconstruir o HTML completo mantendo o estilo original
    final originalHtml = widget.htmlContent;
    final headStart = originalHtml.indexOf('<head>');
    final headEnd = originalHtml.indexOf('</head>');
    
    if (headStart != -1 && headEnd != -1) {
      final head = originalHtml.substring(headStart, headEnd + 7);
      
      return '''<!DOCTYPE html>
<html lang="pt-BR">
$head
<body>
$bodyContent
</body>
</html>''';
    }
    
    return bodyContent;
  }

  void _registerEditorView() {
    ui_web.platformViewRegistry.registerViewFactory(
      '$_editorViewType-$_viewId',
      (int id) {
        final container = html.DivElement()
          ..id = 'editor-container-$_viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.overflow = 'hidden'
          ..style.backgroundColor = '#e0e0e0';

        // Wrapper para simular página A4
        final pageWrapper = html.DivElement()
          ..id = 'page-wrapper-$_viewId'
          ..style.flex = '1'
          ..style.overflow = 'auto'
          ..style.padding = '20px'
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'flex-start';

        // Container A4
        final a4Container = html.DivElement()
          ..id = 'a4-page-$_viewId'
          ..style.width = '210mm'
          ..style.minHeight = '297mm'
          ..style.backgroundColor = 'white'
          ..style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)'
          ..style.padding = '25mm'
          ..style.boxSizing = 'border-box'
          ..style.margin = '0';

        // Editor contenteditable
        final editor = html.DivElement()
          ..id = 'editor-content-$_viewId'
          ..contentEditable = 'true'
          ..spellcheck = false
          ..style.outline = 'none'
          ..style.minHeight = '247mm'
          ..style.fontFamily = 'Georgia, "Times New Roman", serif'
          ..style.fontSize = '12px'
          ..style.lineHeight = '1.8'
          ..style.color = '#34495e'
          ..style.textAlign = 'justify'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..innerHtml = _currentContent;

        // Event listeners
        editor.onInput.listen((_) {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });

        // Listener para seleção de imagens
        editor.onClick.listen((event) {
          final target = event.target;
          if (target is html.ImageElement) {
            _selectImage(target.id);
          } else {
            _deselectAllImages();
          }
        });

        // Estilos CSS avançados
        final style = html.StyleElement()
          ..text = '''
            /* Reset e base */
            #editor-content-$_viewId * {
              margin: 0;
              padding: 0;
            }
            
            #editor-content-$_viewId {
              word-wrap: break-word;
              overflow-wrap: break-word;
            }
            
            /* Títulos */
            #editor-content-$_viewId h1 {
              color: #2c3e50;
              font-size: 28px;
              margin: 0 0 10px 0;
              text-align: center;
              border-bottom: 3px solid #3498db;
              padding-bottom: 10px;
            }
            
            #editor-content-$_viewId h2 {
              color: #34495e;
              font-size: 20px;
              margin: 25px 0 15px 0;
              border-left: 4px solid #3498db;
              padding-left: 10px;
            }
            
            #editor-content-$_viewId h3 {
              color: #555;
              font-size: 16px;
              margin: 20px 0 10px 0;
            }
            
            /* Subtítulos */
            #editor-content-$_viewId .subtitle {
              text-align: center;
              color: #7f8c8d;
              font-style: italic;
              margin-bottom: 30px;
              font-size: 14px;
            }
            
            /* Parágrafos */
            #editor-content-$_viewId p {
              text-align: justify;
              line-height: 1.8;
              color: #34495e;
              margin-bottom: 15px;
              font-size: 12px;
            }
            
            /* Primeira letra grande */
            #editor-content-$_viewId .first-letter::first-letter {
              font-size: 48px;
              font-weight: bold;
              float: left;
              line-height: 40px;
              padding-right: 8px;
              color: #3498db;
            }
            
            /* Destaques */
            #editor-content-$_viewId .highlight {
              background: #fff3cd;
              padding: 15px;
              border-left: 4px solid #ffc107;
              margin: 20px 0;
              font-style: italic;
            }
            
            /* Listas */
            #editor-content-$_viewId ul,
            #editor-content-$_viewId ol {
              margin: 15px 0;
              padding-left: 30px;
            }
            
            #editor-content-$_viewId li {
              margin-bottom: 8px;
              line-height: 1.6;
            }
            
            /* Tabelas */
            #editor-content-$_viewId table {
              width: 100%;
              border-collapse: collapse;
              margin: 20px 0;
              font-size: 11px;
            }
            
            #editor-content-$_viewId th {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 12px;
              text-align: left;
              font-weight: 600;
            }
            
            #editor-content-$_viewId td {
              padding: 10px 12px;
              border-bottom: 1px solid #e0e0e0;
            }
            
            #editor-content-$_viewId tr:hover {
              background-color: #f5f5f5;
            }
            
            #editor-content-$_viewId tr:nth-child(even) {
              background-color: #fafafa;
            }
            
            #editor-content-$_viewId .table-caption {
              font-size: 11px;
              color: #666;
              font-style: italic;
              margin-top: 5px;
              text-align: center;
            }
            
            /* Imagens */
            #editor-content-$_viewId .image-container {
              text-align: center;
              margin: 25px 0;
              position: relative;
            }
            
            #editor-content-$_viewId img {
              max-width: 100%;
              height: auto;
              border-radius: 8px;
              box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              cursor: pointer;
              transition: all 0.3s ease;
            }
            
            #editor-content-$_viewId img.selected {
              outline: 3px solid #007AFF;
              outline-offset: 2px;
              box-shadow: 0 4px 16px rgba(0,122,255,0.3);
            }
            
            #editor-content-$_viewId img:hover {
              box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            }
            
            #editor-content-$_viewId .image-caption {
              font-size: 11px;
              color: #666;
              font-style: italic;
              margin-top: 8px;
            }
            
            /* Footer */
            #editor-content-$_viewId .footer {
              text-align: center;
              font-size: 10px;
              color: #95a5a6;
              border-top: 1px solid #ecf0f1;
              padding-top: 10px;
              margin-top: 30px;
            }
            
            /* Formatação de texto */
            #editor-content-$_viewId strong,
            #editor-content-$_viewId b {
              font-weight: 700;
            }
            
            #editor-content-$_viewId em,
            #editor-content-$_viewId i {
              font-style: italic;
            }
            
            #editor-content-$_viewId u {
              text-decoration: underline;
            }
            
            /* Scrollbar personalizada */
            #page-wrapper-$_viewId::-webkit-scrollbar {
              width: 8px;
            }
            
            #page-wrapper-$_viewId::-webkit-scrollbar-track {
              background: #f1f1f1;
            }
            
            #page-wrapper-$_viewId::-webkit-scrollbar-thumb {
              background: #888;
              border-radius: 4px;
            }
            
            #page-wrapper-$_viewId::-webkit-scrollbar-thumb:hover {
              background: #555;
            }
          ''';

        a4Container.append(editor);
        pageWrapper.append(a4Container);
        container.append(style);
        container.append(pageWrapper);

        return container;
      },
    );
  }

  void _selectImage(String imageId) {
    _deselectAllImages();
    
    final script = '''
      (function() {
        var img = document.getElementById('$imageId');
        if (img) {
          img.classList.add('selected');
        }
      })();
    ''';
    
    js.context.callMethod('eval', [script]);
    
    setState(() {
      _selectedImageId = imageId;
    });
  }

  void _deselectAllImages() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (editor) {
          var images = editor.querySelectorAll('img');
          images.forEach(function(img) {
            img.classList.remove('selected');
          });
        }
      })();
    ''';
    
    js.context.callMethod('eval', [script]);
    
    setState(() {
      _selectedImageId = '';
    });
  }

  String _getEditorContent() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (!editor) return '';
        
        // Limpar classes de seleção antes de retornar
        var images = editor.querySelectorAll('img');
        images.forEach(function(img) {
          img.classList.remove('selected');
        });
        
        return editor.innerHTML;
      })();
    ''';

    final result = js.context.callMethod('eval', [script]);
    return result?.toString() ?? _currentContent;
  }

  void _saveAndClose() {
    final bodyContent = _getEditorContent();
    final fullHtml = _rebuildFullHtml(bodyContent);
    Navigator.pop(context, fullHtml);
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
          final imageId = 'img-${DateTime.now().millisecondsSinceEpoch}';

          final script = '''
            (function() {
              var editor = document.getElementById('editor-content-$_viewId');
              if (editor) {
                var container = document.createElement('div');
                container.className = 'image-container';
                
                var img = document.createElement('img');
                img.id = '$imageId';
                img.src = '$dataUrl';
                img.className = 'document-image';
                
                var caption = document.createElement('div');
                caption.className = 'image-caption';
                caption.contentEditable = 'true';
                caption.textContent = 'Figura: Descrição da imagem';
                
                container.appendChild(img);
                container.appendChild(caption);
                
                editor.appendChild(container);
                
                // Focar na legenda
                caption.focus();
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

  void _resizeSelectedImage(String size) {
    if (_selectedImageId.isEmpty) return;

    String width = '100%';
    switch (size) {
      case 'small':
        width = '30%';
        break;
      case 'medium':
        width = '60%';
        break;
      case 'large':
        width = '100%';
        break;
    }

    final script = '''
      (function() {
        var img = document.getElementById('$_selectedImageId');
        if (img) {
          img.style.width = '$width';
          img.style.height = 'auto';
        }
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _hasChanges = true;
    });
  }

  void _deleteSelectedImage() {
    if (_selectedImageId.isEmpty) return;

    final script = '''
      (function() {
        var img = document.getElementById('$_selectedImageId');
        if (img && img.parentElement) {
          img.parentElement.remove();
        }
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _selectedImageId = '';
      _hasChanges = true;
    });
  }

  void _applyFormatting(String command, [String? value]) {
    final script = '''
      (function() {
        ${value != null ? "document.execCommand('$command', false, '$value');" : "document.execCommand('$command', false, null);"}
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _hasChanges = true;
    });
  }

  void _insertHeading(int level) {
    _applyFormatting('formatBlock', 'h$level');
  }

  void _insertTable() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (editor) {
          var table = document.createElement('table');
          var thead = document.createElement('thead');
          var tbody = document.createElement('tbody');
          
          var headerRow = document.createElement('tr');
          for (var i = 0; i < 3; i++) {
            var th = document.createElement('th');
            th.contentEditable = 'true';
            th.textContent = 'Coluna ' + (i + 1);
            headerRow.appendChild(th);
          }
          thead.appendChild(headerRow);
          
          for (var r = 0; r < 3; r++) {
            var row = document.createElement('tr');
            for (var c = 0; c < 3; c++) {
              var td = document.createElement('td');
              td.contentEditable = 'true';
              td.textContent = 'Dado';
              row.appendChild(td);
            }
            tbody.appendChild(row);
          }
          
          table.appendChild(thead);
          table.appendChild(tbody);
          
          var caption = document.createElement('div');
          caption.className = 'table-caption';
          caption.contentEditable = 'true';
          caption.textContent = 'Tabela 1: Descrição';
          
          editor.appendChild(table);
          editor.appendChild(caption);
        }
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _hasChanges = true;
    });
  }

  void _insertHighlight() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (editor) {
          var highlight = document.createElement('div');
          highlight.className = 'highlight';
          highlight.contentEditable = 'true';
          highlight.textContent = 'Texto destacado importante...';
          editor.appendChild(highlight);
          highlight.focus();
        }
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _hasChanges = true;
    });
  }

  void _setTextAlignment(String alignment) {
    final commands = {
      'left': 'justifyLeft',
      'center': 'justifyCenter',
      'right': 'justifyRight',
      'justify': 'justifyFull',
    };

    _applyFormatting(commands[alignment]!);
  }

  void _changeFontSize(String size) {
    _applyFormatting('fontSize', size);
  }

  void _showImageOptionsDialog() {
    if (_selectedImageId.isEmpty) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Opções da Imagem',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Ionicons.contract_outline),
              title: const Text('Pequena (30%)'),
              onTap: () {
                _resizeSelectedImage('small');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.resize_outline),
              title: const Text('Média (60%)'),
              onTap: () {
                _resizeSelectedImage('medium');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.expand_outline),
              title: const Text('Grande (100%)'),
              onTap: () {
                _resizeSelectedImage('large');
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Ionicons.trash_outline, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                _deleteSelectedImage();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
                'Salvar',
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
            // Toolbar principal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      label: 'B',
                      onPressed: () => _applyFormatting('bold'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'I',
                      onPressed: () => _applyFormatting('italic'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'U',
                      onPressed: () => _applyFormatting('underline'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.list_outline,
                      label: 'Lista',
                      onPressed: () => _applyFormatting('insertUnorderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.list_outline,
                      label: 'Num',
                      onPressed: () => _applyFormatting('insertOrderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'H1',
                      onPressed: () => _insertHeading(1),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'H2',
                      onPressed: () => _insertHeading(2),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.text_outline,
                      label: 'H3',
                      onPressed: () => _insertHeading(3),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      icon: Ionicons.image_outline,
                      label: 'Imagem',
                      onPressed: _pickAndInsertImage,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.grid_outline,
                      label: 'Tabela',
                      onPressed: _insertTable,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      icon: Ionicons.bookmark_outline,
                      label: 'Destaque',
                      onPressed: _insertHighlight,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar de imagem (aparece quando imagem selecionada)
            if (_selectedImageId.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF007AFF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Ionicons.image,
                      size: 18,
                      color: const Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Imagem selecionada',
                      style: TextStyle(
                        color: const Color(0xFF007AFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showImageOptionsDialog,
                      child: const Text('Opções'),
                    ),
                  ],
                ),
              ),

            // Editor
            Expanded(
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? const Color(0xFF2D333B)
                : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? const Color(0xFF444C56)
                  : const Color(0xFFDEE2E6),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            ),
          ),
        ),
      ),
    );
  }
}