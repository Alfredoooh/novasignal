// lib/screens/edit_document_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// Conditional imports corrigidos
import 'edit_document_screen_web_html_stub.dart'
    if (dart.library.html) 'dart:html' as html;
import 'edit_document_screen_web_ui_stub.dart'
    if (dart.library.html) 'dart:ui_web' as ui_web;
import 'edit_document_screen_web_js_stub.dart'
    if (dart.library.html) 'dart:js_util' as js_util;

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
  static const String _editorViewType = 'professional-html-editor';
  late String _currentContent;
  bool _hasChanges = false;
  String? _viewId;
  String _selectedImageId = '';

  // Controller para Android/iOS
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentContent = _extractBodyContent(widget.htmlContent);
    _viewId = 'editor-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      _registerEditorView();
    } else {
      _textController.text = _currentContent;
      _textController.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _textController.dispose();
      _focusNode.dispose();
    }
    super.dispose();
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

  void _evalScript(String script) {
    if (!kIsWeb) return;
    try {
      js_util.callMethod(js_util.globalThis, 'eval', [script]);
    } catch (_) {}
  }

  dynamic _evalScriptWithReturn(String script) {
    if (!kIsWeb) return null;
    try {
      return js_util.callMethod(js_util.globalThis, 'eval', [script]);
    } catch (_) {
      return null;
    }
  }

  void _registerEditorView() {
    if (!kIsWeb) return;

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
          ..style.userSelect = 'text';

        editor.setInnerHtml(_currentContent, treeSanitizer: html.NodeTreeSanitizer.trusted);

        editor.onInput.listen((_) {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });

        editor.onClick.listen((event) {
          final target = event.target;
          if (target is html.ImageElement) {
            event.preventDefault();
            _selectImage(target.id);
          } else {
            _deselectAllImages();
          }
        });

        final style = html.StyleElement()
          ..text = '''
            #editor-content-$_viewId {
              word-wrap: break-word;
              overflow-wrap: break-word;
            }
            
            #editor-content-$_viewId img {
              cursor: pointer;
              transition: all 0.3s ease;
              max-width: 100%;
              height: auto;
            }
            
            #editor-content-$_viewId img.selected {
              outline: 3px solid #007AFF;
              outline-offset: 2px;
              box-shadow: 0 4px 16px rgba(0,122,255,0.3);
            }
            
            #editor-content-$_viewId img.resizable {
              resize: both;
              overflow: hidden;
              border: 2px dashed #007AFF;
              padding: 4px;
            }
            
            #editor-content-$_viewId table {
              width: 100%;
              border-collapse: collapse;
              margin: 20px 0;
              font-size: 12px;
              border: 1px solid #ddd;
            }
            
            #editor-content-$_viewId th,
            #editor-content-$_viewId td {
              border: 1px solid #ddd;
              padding: 10px;
              text-align: left;
            }
            
            #editor-content-$_viewId th {
              background-color: #f5f5f5;
              font-weight: 600;
            }
            
            #editor-content-$_viewId tr:nth-child(even) {
              background-color: #fafafa;
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
    if (!kIsWeb) return;

    _deselectAllImages();

    final script = '''
      (function() {
        var img = document.getElementById('$imageId');
        if (img) {
          img.classList.add('selected');
          img.classList.add('resizable');
        }
      })();
    ''';

    _evalScript(script);

    setState(() {
      _selectedImageId = imageId;
    });
  }

  void _deselectAllImages() {
    if (!kIsWeb) return;

    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (editor) {
          var images = editor.querySelectorAll('img');
          images.forEach(function(img) {
            img.classList.remove('selected');
            img.classList.remove('resizable');
          });
        }
      })();
    ''';

    _evalScript(script);

    setState(() {
      _selectedImageId = '';
    });
  }

  String _getEditorContent() {
    if (!kIsWeb) {
      return _textController.text;
    }

    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (!editor) return '';
        
        var images = editor.querySelectorAll('img');
        images.forEach(function(img) {
          img.classList.remove('selected');
          img.classList.remove('resizable');
          img.style.border = '';
          img.style.padding = '';
        });
        
        return editor.innerHTML;
      })();
    ''';

    final result = _evalScriptWithReturn(script);
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
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserção de imagens disponível apenas na versão web'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
              if (!editor) return;
              
              var selection = window.getSelection();
              var range;
              
              if (selection && selection.rangeCount > 0) {
                range = selection.getRangeAt(0);
              } else {
                range = document.createRange();
                range.selectNodeContents(editor);
                range.collapse(false);
              }
              
              var container = document.createElement('div');
              container.className = 'image-container';
              container.style.textAlign = 'center';
              container.style.margin = '20px 0';
              container.contentEditable = 'false';
              
              var img = document.createElement('img');
              img.id = '$imageId';
              img.src = '$dataUrl';
              img.style.maxWidth = '100%';
              img.style.height = 'auto';
              img.style.cursor = 'pointer';
              
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
              
              range.insertNode(container);
              
              range.setStartAfter(container);
              range.collapse(true);
              selection.removeAllRanges();
              selection.addRange(range);
            })();
          ''';

          _evalScript(script);

          setState(() {
            _hasChanges = true;
          });
        });

        reader.readAsDataUrl(file);
      }
    });
  }

  void _resizeSelectedImage(String size) {
    if (!kIsWeb || _selectedImageId.isEmpty) return;

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
          img.style.maxWidth = '$width';
        }
      })();
    ''';

    _evalScript(script);

    setState(() {
      _hasChanges = true;
    });
  }

  void _deleteSelectedImage() {
    if (!kIsWeb || _selectedImageId.isEmpty) return;

    final script = '''
      (function() {
        var img = document.getElementById('$_selectedImageId');
        if (img && img.parentElement) {
          img.parentElement.remove();
        }
      })();
    ''';

    _evalScript(script);

    setState(() {
      _selectedImageId = '';
      _hasChanges = true;
    });
  }

  void _applyFormatting(String command, [String? value]) {
    if (!kIsWeb) {
      _applyFormattingMobile(command, value);
      return;
    }

    final script = '''
      (function() {
        ${value != null ? "document.execCommand('$command', false, '$value');" : "document.execCommand('$command', false, null);"}
      })();
    ''';

    _evalScript(script);

    setState(() {
      _hasChanges = true;
    });
  }

  void _applyFormattingMobile(String command, [String? value]) {
    final text = _textController.text;
    final selection = _textController.selection;

    if (!selection.isValid) return;

    final selectedText = text.substring(selection.start, selection.end);
    String formattedText = selectedText;

    switch (command) {
      case 'bold':
        formattedText = '<strong>$selectedText</strong>';
        break;
      case 'italic':
        formattedText = '<em>$selectedText</em>';
        break;
      case 'underline':
        formattedText = '<u>$selectedText</u>';
        break;
      case 'insertUnorderedList':
        formattedText = '<ul><li>$selectedText</li></ul>';
        break;
      case 'insertOrderedList':
        formattedText = '<ol><li>$selectedText</li></ol>';
        break;
      case 'formatBlock':
        if (value != null) {
          formattedText = '<$value>$selectedText</$value>';
        }
        break;
      case 'foreColor':
        if (value != null) {
          formattedText = '<span style="color: $value">$selectedText</span>';
        }
        break;
      case 'fontName':
        if (value != null) {
          formattedText = '<span style="font-family: $value">$selectedText</span>';
        }
        break;
    }

    final newText = text.replaceRange(selection.start, selection.end, formattedText);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + formattedText.length),
    );

    setState(() {
      _hasChanges = true;
    });
  }

  void _insertHeading(int level) {
    _applyFormatting('formatBlock', 'h$level');
  }

  void _changeFontSize(String size) {
    if (!kIsWeb) {
      final selection = _textController.selection;
      if (!selection.isValid) return;

      final text = _textController.text;
      final selectedText = text.substring(selection.start, selection.end);
      final formattedText = '<span style="font-size: $size">$selectedText</span>';

      final newText = text.replaceRange(selection.start, selection.end, formattedText);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + formattedText.length),
      );

      setState(() => _hasChanges = true);
      return;
    }

    final script = '''
      (function() {
        var selection = window.getSelection();
        if (selection.rangeCount > 0) {
          var range = selection.getRangeAt(0);
          var span = document.createElement('span');
          span.style.fontSize = '$size';
          try {
            range.surroundContents(span);
          } catch(e) {
            console.log('Error applying font size');
          }
        }
      })();
    ''';

    _evalScript(script);

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
    if (!kIsWeb) {
      final tableHtml = '''
<table style="width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 12px; border: 1px solid #ddd;">
  <thead>
    <tr>
      <th style="border: 1px solid #ddd; padding: 10px; background-color: #f5f5f5; font-weight: 600; text-align: left;">Coluna 1</th>
      <th style="border: 1px solid #ddd; padding: 10px; background-color: #f5f5f5; font-weight: 600; text-align: left;">Coluna 2</th>
      <th style="border: 1px solid #ddd; padding: 10px; background-color: #f5f5f5; font-weight: 600; text-align: left;">Coluna 3</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
    </tr>
    <tr style="background-color: #fafafa;">
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
    </tr>
    <tr>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
      <td style="border: 1px solid #ddd; padding: 10px; text-align: left;">Dado</td>
    </tr>
  </tbody>
</table>
<div style="font-size: 11px; color: #666; font-style: italic; margin-top: 5px; text-align: center;">Tabela 1: Descrição</div>
''';

      final cursorPosition = _textController.selection.base.offset;
      final text = _textController.text;
      final newText = text.substring(0, cursorPosition) + tableHtml + text.substring(cursorPosition);

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPosition + tableHtml.length),
      );

      setState(() => _hasChanges = true);
      return;
    }

    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (!editor) return;
        
        var selection = window.getSelection();
        var range;
        
        if (selection && selection.rangeCount > 0) {
          range = selection.getRangeAt(0);
        } else {
          range = document.createRange();
          range.selectNodeContents(editor);
          range.collapse(false);
        }
        
        var table = document.createElement('table');
        table.style.width = '100%';
        table.style.borderCollapse = 'collapse';
        table.style.margin = '20px 0';
        table.style.fontSize = '12px';
        table.style.border = '1px solid #ddd';
        
        var thead = document.createElement('thead');
        var tbody = document.createElement('tbody');
        
        var headerRow = document.createElement('tr');
        for (var i = 0; i < 3; i++) {
          var th = document.createElement('th');
          th.contentEditable = 'true';
          th.textContent = 'Coluna ' + (i + 1);
          th.style.border = '1px solid #ddd';
          th.style.padding = '10px';
          th.style.backgroundColor = '#f5f5f5';
          th.style.fontWeight = '600';
          th.style.textAlign = 'left';
          headerRow.appendChild(th);
        }
        thead.appendChild(headerRow);
        
        for (var r = 0; r < 3; r++) {
          var row = document.createElement('tr');
          if (r % 2 === 1) {
            row.style.backgroundColor = '#fafafa';
          }
          for (var c = 0; c < 3; c++) {
            var td = document.createElement('td');
            td.contentEditable = 'true';
            td.textContent = 'Dado';
            td.style.border = '1px solid #ddd';
            td.style.padding = '10px';
            td.style.textAlign = 'left';
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
        caption.style.fontSize = '11px';
        caption.style.color = '#666';
        caption.style.fontStyle = 'italic';
        caption.style.marginTop = '5px';
        caption.style.textAlign = 'center';
        
        var wrapper = document.createElement('div');
        wrapper.appendChild(table);
        wrapper.appendChild(caption);
        
        range.insertNode(wrapper);
        
        range.setStartAfter(wrapper);
        range.collapse(true);
        selection.removeAllRanges();
        selection.addRange(range);
      })();
    ''';

    _evalScript(script);

    setState(() {
      _hasChanges = true;
    });
  }

  void _insertHighlight() {
    if (!kIsWeb) {
      final highlightHtml = '<div style="background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; font-style: italic;">Texto destacado importante...</div>';

      final cursorPosition = _textController.selection.base.offset;
      final text = _textController.text;
      final newText = text.substring(0, cursorPosition) + highlightHtml + text.substring(cursorPosition);

      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursorPosition + highlightHtml.length),
      );

      setState(() => _hasChanges = true);
      return;
    }

    final script = '''
      (function() {
        var editor = document.getElementById('editor-content-$_viewId');
        if (!editor) return;
        
        var selection = window.getSelection();
        var range;
        
        if (selection && selection.rangeCount > 0) {
          range = selection.getRangeAt(0);
        } else {
          range = document.createRange();
          range.selectNodeContents(editor);
          range.collapse(false);
        }
        
        var highlight = document.createElement('div');
        highlight.className = 'highlight';
        highlight.contentEditable = 'true';
        highlight.textContent = 'Texto destacado importante...';
        highlight.style.background = '#fff3cd';
        highlight.style.padding = '15px';
        highlight.style.borderLeft = '4px solid #ffc107';
        highlight.style.margin = '20px 0';
        highlight.style.fontStyle = 'italic';
        
        range.insertNode(highlight);
        
        range.selectNodeContents(highlight);
        selection.removeAllRanges();
        selection.addRange(range);
      })();
    ''';

    _evalScript(script);

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
      title: Text(
        label,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
        ),
      ),
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
            // Toolbar 1
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
                    _buildToolbarButton('B', () => _applyFormatting('bold'), themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('I', () => _applyFormatting('italic'), themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('U', () => _applyFormatting('underline'), themeProvider),
                    const SizedBox(width: 8),
                    _buildToolbarButton('Lista', () => _applyFormatting('insertUnorderedList'), themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('Num', () => _applyFormatting('insertOrderedList'), themeProvider),
                    const SizedBox(width: 8),
                    _buildToolbarButton('H1', () => _insertHeading(1), themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('H2', () => _insertHeading(2), themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('H3', () => _insertHeading(3), themeProvider),
                  ],
                ),
              ),
            ),

            // Toolbar 2
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
                    _buildToolbarButton('Tamanho', _showFontSizeDialog, themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('Cor', _showColorPicker, themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('Fonte', _showFontFamilyDialog, themeProvider),
                    const SizedBox(width: 8),
                    _buildToolbarButton('Imagem', _pickAndInsertImage, themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('Tabela', _insertTable, themeProvider),
                    const SizedBox(width: 4),
                    _buildToolbarButton('Destaque', _insertHighlight, themeProvider),
                  ],
                ),
              ),
            ),

            // Toolbar de imagem (apenas web)
            if (kIsWeb && _selectedImageId.isNotEmpty)
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
                      'Imagem selecionada - Arraste as bordas para redimensionar',
                      style: TextStyle(
                        color: Color(0xFF007AFF),
                        fontSize: 12,
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
                  : Container(
                      padding: const EdgeInsets.all(20),
                      color: themeProvider.isDarkMode ? const Color(0xFF0D1117) : Colors.white,
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Digite o conteúdo do documento...',
                            hintStyle: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
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

  Widget _buildToolbarButton(
    String label,
    VoidCallback onPressed,
    ThemeProvider themeProvider,
  ) {
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
                style: TextStyle(
                  fontFamily: font,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
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
              title: Text(
                'Pequena (30%)',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
              ),
              onTap: () {
                _resizeSelectedImage('small');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.resize_outline),
              title: Text(
                'Média (60%)',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
              ),
              onTap: () {
                _resizeSelectedImage('medium');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.expand_outline),
              title: Text(
                'Grande (100%)',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF212529),
                ),
              ),
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
}