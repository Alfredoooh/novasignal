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
  static const String _editorViewType = 'wysiwyg-html-editor';
  late String _currentContent;
  bool _hasChanges = false;
  String? _viewId;
  String _selectedImageId = '';
  String _currentFontSize = '12px';
  String _currentColor = '#34495e';
  String _currentFontFamily = 'Georgia';

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
    final bodyStart = html.indexOf('<body');
    final bodyEnd = html.lastIndexOf('</body>');
    
    if (bodyStart != -1 && bodyEnd != -1) {
      return html.substring(html.indexOf('>', bodyStart) + 1, bodyEnd);
    }
    
    return html;
  }

  String _rebuildFullHtml(String bodyContent) {
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
          ..id = 'editor-wrapper-$_viewId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.flexDirection = 'column'
          ..style.overflow = 'hidden'
          ..style.backgroundColor = '#e0e0e0';

        final pageWrapper = html.DivElement()
          ..id = 'page-wrapper-$_viewId'
          ..style.flex = '1'
          ..style.overflow = 'auto'
          ..style.padding = '20px'
          ..style.display = 'flex'
          ..style.justifyContent = 'center'
          ..style.alignItems = 'flex-start';

        final a4Container = html.DivElement()
          ..id = 'a4-page-$_viewId'
          ..style.width = '210mm'
          ..style.minHeight = '297mm'
          ..style.backgroundColor = 'white'
          ..style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)'
          ..style.padding = '25mm'
          ..style.boxSizing = 'border-box'
          ..style.margin = '0';

        final editor = html.DivElement()
          ..id = 'editor-content-$_viewId'
          ..contentEditable = 'true'
          ..spellcheck = false
          ..style.outline = 'none'
          ..style.minHeight = '247mm'
          ..style.setProperty('-webkit-user-select', 'text')
          ..style.userSelect = 'text'
          ..innerHTML = _currentContent;

        // Events
        editor.onInput.listen((_) {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });

        editor.onMouseUp.listen((_) {
          _updateFormatState();
        });

        editor.onKeyUp.listen((_) {
          _updateFormatState();
        });

        editor.onClick.listen((event) {
          final target = event.target;
          if (target is html.ImageElement) {
            _selectImage(target.id);
          } else {
            _deselectAllImages();
          }
        });

        // CSS mantém TODOS os estilos originais
        final style = html.StyleElement()
          ..text = '''
            #editor-content-$_viewId {
              word-wrap: break-word;
              overflow-wrap: break-word;
            }
            
            #editor-content-$_viewId * {
              /* Manter estilos inline e classes */
            }
            
            #editor-content-$_viewId img {
              max-width: 100%;
              height: auto;
              cursor: pointer;
              transition: all 0.3s ease;
            }
            
            #editor-content-$_viewId img.selected {
              outline: 3px solid #007AFF;
              outline-offset: 2px;
              box-shadow: 0 4px 16px rgba(0,122,255,0.3);
            }
            
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

  void _updateFormatState() {
    final script = '''
      (function() {
        try {
          var selection = window.getSelection();
          if (!selection || selection.rangeCount === 0) return '{}';
          
          var range = selection.getRangeAt(0);
          var node = range.startContainer;
          
          if (node.nodeType === 3) node = node.parentNode;
          
          var computedStyle = window.getComputedStyle(node);
          
          return JSON.stringify({
            fontSize: computedStyle.fontSize || '12px',
            color: computedStyle.color || 'rgb(52, 73, 94)',
            fontFamily: computedStyle.fontFamily || 'Georgia',
            fontWeight: computedStyle.fontWeight || 'normal',
            fontStyle: computedStyle.fontStyle || 'normal',
            textDecoration: computedStyle.textDecoration || 'none'
          });
        } catch(e) {
          return '{}';
        }
      })();
    ''';

    try {
      final result = js.context.callMethod('eval', [script]);
      if (result != null && result.toString().isNotEmpty) {
        // Atualizar estado com as propriedades detectadas
        debugPrint('Formato detectado: $result');
      }
    } catch (e) {
      debugPrint('Erro ao detectar formato: $e');
    }
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
                container.style.textAlign = 'center';
                container.style.margin = '25px 0';
                
                var img = document.createElement('img');
                img.id = '$imageId';
                img.src = '$dataUrl';
                img.className = 'document-image';
                img.style.maxWidth = '100%';
                img.style.height = 'auto';
                img.style.borderRadius = '8px';
                img.style.boxShadow = '0 2px 8px rgba(0,0,0,0.1)';
                
                var caption = document.createElement('div');
                caption.className = 'image-caption';
                caption.contentEditable = 'true';
                caption.textContent = 'Figura: Descrição da imagem';
                caption.style.fontSize = '11px';
                caption.style.color = '#666';
                caption.style.fontStyle = 'italic';
                caption.style.marginTop = '8px';
                
                container.appendChild(img);
                container.appendChild(caption);
                
                editor.appendChild(container);
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

  void _changeFontSize(String size) {
    final script = '''
      (function() {
        var selection = window.getSelection();
        if (selection.rangeCount > 0) {
          var range = selection.getRangeAt(0);
          var span = document.createElement('span');
          span.style.fontSize = '$size';
          range.surroundContents(span);
        }
      })();
    ''';

    js.context.callMethod('eval', [script]);

    setState(() {
      _hasChanges = true;
    });
  }

  void _changeTextColor(String color) {
    _applyFormatting('foreColor', color);
  }

  void _changeFontFamily(String font) {
    _applyFormatting('fontName', font);
  }

  void _insertTable() {
    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (editor) {
          var table = document.createElement('table');
          table.style.width = '100%';
          table.style.borderCollapse = 'collapse';
          table.style.margin = '20px 0';
          table.style.fontSize = '11px';
          
          var thead = document.createElement('thead');
          var tbody = document.createElement('tbody');
          
          var headerRow = document.createElement('tr');
          for (var i = 0; i < 3; i++) {
            var th = document.createElement('th');
            th.contentEditable = 'true';
            th.textContent = 'Coluna ' + (i + 1);
            th.style.background = 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
            th.style.color = 'white';
            th.style.padding = '12px';
            th.style.textAlign = 'left';
            th.style.fontWeight = '600';
            headerRow.appendChild(th);
          }
          thead.appendChild(headerRow);
          
          for (var r = 0; r < 3; r++) {
            var row = document.createElement('tr');
            for (var c = 0; c < 3; c++) {
              var td = document.createElement('td');
              td.contentEditable = 'true';
              td.textContent = 'Dado';
              td.style.padding = '10px 12px';
              td.style.borderBottom = '1px solid #e0e0e0';
              row.appendChild(td);
            }
            if (r % 2 === 1) {
              row.style.backgroundColor = '#fafafa';
            }
            tbody.appendChild(row);
          }
          
          table.appendChild(thead);
          table.appendChild(tbody);
          
          var caption = document.createElement('div');
          caption.className = 'table-caption';
          caption.contentEditable = 'true';
          caption.textContent = 'Tabela 1: Descrição';
          caption.style.fontSize = '11px';
          caption.style.color = '#666';
          caption.style.fontStyle = 'italic';
          caption.style.marginTop = '5px';
          caption.style.textAlign = 'center';
          
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
          highlight.style.background = '#fff3cd';
          highlight.style.padding = '15px';
          highlight.style.borderLeft = '4px solid #ffc107';
          highlight.style.margin = '20px 0';
          highlight.style.fontStyle = 'italic';
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

  void _showFontSizeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tamanho da Fonte',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption('Pequeno (10px)', '10px', themeProvider),
            _buildFontSizeOption('Normal (12px)', '12px', themeProvider),
            _buildFontSizeOption('Médio (14px)', '14px', themeProvider),
            _buildFontSizeOption('Grande (16px)', '16px', themeProvider),
            _buildFontSizeOption('Muito Grande (20px)', '20px', themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String label, String size, ThemeProvider themeProvider) {
    return ListTile(
      title: Text(label),
      onTap: () {
        _changeFontSize(size);
        Navigator.pop(context);
      },
    );
  }

  void _showColorPicker() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final colors = [
      {'name': 'Preto', 'value': '#000000'},
      {'name': 'Cinza Escuro', 'value': '#34495e'},
      {'name': 'Azul', 'value': '#3498db'},
      {'name': 'Verde', 'value': '#27ae60'},
      {'name': 'Vermelho', 'value': '#e74c3c'},
      {'name': 'Laranja', 'value': '#e67e22'},
      {'name': 'Roxo', 'value': '#9b59b6'},
      {'name': 'Amarelo', 'value': '#f39c12'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cor do Texto',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                _changeTextColor(color['value']!);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(int.parse(color['value']!.substring(1), radix: 16) + 0xFF000000),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontFamilyDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final fonts = [
      'Georgia',
      'Times New Roman',
      'Arial',
      'Helvetica',
      'Courier New',
      'Verdana',
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C2128) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fonte',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) {
            return ListTile(
              title: Text(
                font,
                style: TextStyle(fontFamily: font),
              ),
              onTap: () {
                _changeFontFamily(font);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
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
            // Toolbar 1: Formatação básica
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
                      label: 'B',
                      onPressed: () => _applyFormatting('bold'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'I',
                      onPressed: () => _applyFormatting('italic'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'U',
                      onPressed: () => _applyFormatting('underline'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      label: 'Lista',
                      onPressed: () => _applyFormatting('insertUnorderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'Num',
                      onPressed: () => _applyFormatting('insertOrderedList'),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      label: 'H1',
                      onPressed: () => _insertHeading(1),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'H2',
                      onPressed: () => _insertHeading(2),
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'H3',
                      onPressed: () => _insertHeading(3),
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar 2: Formatação avançada
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
                      label: 'Tamanho',
                      onPressed: _showFontSizeDialog,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'Cor',
                      onPressed: _showColorPicker,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'Fonte',
                      onPressed: _showFontFamilyDialog,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildToolbarButton(
                      label: 'Imagem',
                      onPressed: _pickAndInsertImage,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'Tabela',
                      onPressed: _insertTable,
                      themeProvider: themeProvider,
                    ),
                    const SizedBox(width: 4),
                    _buildToolbarButton(
                      label: 'Destaque',
                      onPressed: _insertHighlight,
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),

            // Toolbar de imagem (quando selecionada)
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
                    const Icon(
                      Ionicons.image,
                      size: 18,
                      color: Color(0xFF007AFF),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Imagem selecionada',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
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