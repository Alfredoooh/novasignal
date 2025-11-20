import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

// Tela Principal de Seleção
class EditorPage extends StatelessWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 1200),
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'O que você deseja criar?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Escolha o tipo de documento que deseja criar ou editar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      SizedBox(height: 60),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 1.1,
                        children: [
                          _buildOptionCard(
                            context,
                            'Documentos',
                            'Crie documentos completos com formatação rica',
                            Icons.description,
                            Color(0xFF3B82F6),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentEditorPage(),
                                ),
                              );
                            },
                          ),
                          _buildOptionCard(
                            context,
                            'Notas',
                            'Anote ideias e pensamentos rapidamente',
                            Icons.note,
                            Color(0xFF10B981),
                            () {},
                          ),
                          _buildOptionCard(
                            context,
                            'Tarefas',
                            'Organize suas tarefas e projetos',
                            Icons.check_circle,
                            Color(0xFFF59E0B),
                            () {},
                          ),
                          _buildOptionCard(
                            context,
                            'Diário',
                            'Registre seus momentos e memórias',
                            Icons.book,
                            Color(0xFFEF4444),
                            () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book, color: Color(0xFF3B82F6), size: 32),
          SizedBox(width: 12),
          Text(
            'Editor Profissional',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, String description, 
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modelo de Documento
class Document {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime modifiedAt;
  int pageCount;

  Document({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.pageCount = 1,
  });
}

// Editor de Documentos Completo
class DocumentEditorPage extends StatefulWidget {
  const DocumentEditorPage({Key? key}) : super(key: key);

  @override
  State<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends State<DocumentEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _titleController = TextEditingController(text: 'Documento sem título');
  
  // Documentos salvos
  List<Document> _savedDocuments = [];
  Document? _currentDocument;
  
  // Estado da formatação
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  bool _isSubscript = false;
  bool _isSuperscript = false;
  String _fontSize = '16';
  String _fontFamily = 'Roboto';
  Color _textColor = Colors.black;
  Color _highlightColor = Colors.transparent;
  TextAlign _textAlign = TextAlign.left;
  double _lineSpacing = 1.5;
  double _paragraphSpacing = 0;
  double _pageMargin = 40;
  
  // Configurações de página
  String _pageSize = 'A4';
  String _pageOrientation = 'portrait';
  bool _showPageNumbers = true;
  String _pageNumberPosition = 'bottom-center';
  int _currentPage = 1;
  int _totalPages = 1;
  
  // Histórico para desfazer/refazer
  List<String> _history = [''];
  int _historyIndex = 0;
  
  // Estatísticas
  int _wordCount = 0;
  int _charCount = 0;
  int _charCountNoSpaces = 0;
  int _paragraphCount = 0;
  int _lineCount = 0;
  
  // Controles UI
  bool _showSidebar = true;
  bool _showRuler = true;
  bool _showFormatting = true;
  double _zoomLevel = 1.0;
  
  // Lista de imagens inseridas
  List<Map<String, dynamic>> _insertedImages = [];
  
  // Tabelas inseridas
  List<Map<String, dynamic>> _insertedTables = [];
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateStats);
    _loadSavedDocuments();
  }
  
  void _loadSavedDocuments() {
    // Simulação de documentos salvos
    setState(() {
      _savedDocuments = [
        Document(
          id: '1',
          title: 'Relatório Anual 2024',
          content: 'Conteúdo do relatório...',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          modifiedAt: DateTime.now().subtract(Duration(hours: 2)),
          pageCount: 12,
        ),
        Document(
          id: '2',
          title: 'Proposta de Projeto',
          content: 'Conteúdo da proposta...',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          modifiedAt: DateTime.now().subtract(Duration(days: 1)),
          pageCount: 8,
        ),
        Document(
          id: '3',
          title: 'Manual de Usuário',
          content: 'Conteúdo do manual...',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          modifiedAt: DateTime.now().subtract(Duration(days: 7)),
          pageCount: 25,
        ),
      ];
    });
  }
  
  void _updateStats() {
    final text = _controller.text;
    setState(() {
      _charCount = text.length;
      _charCountNoSpaces = text.replaceAll(' ', '').length;
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
      _paragraphCount = text.isEmpty ? 0 : text.split('\n\n').where((p) => p.trim().isNotEmpty).length;
      _lineCount = text.isEmpty ? 0 : text.split('\n').length;
      _totalPages = (_lineCount / 45).ceil().clamp(1, 999);
    });
  }
  
  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }
    if (_history.isEmpty || _history.last != _controller.text) {
      _history.add(_controller.text);
      _historyIndex = _history.length - 1;
    }
  }
  
  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _controller.text = _history[_historyIndex];
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      });
    }
  }
  
  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _controller.text = _history[_historyIndex];
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
      });
    }
  }
  
  void _saveDocument() {
    final newDoc = Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _controller.text,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      pageCount: _totalPages,
    );
    
    setState(() {
      _savedDocuments.insert(0, newDoc);
      _currentDocument = newDoc;
    });
    
    _showMessage('Documento salvo com sucesso!');
  }
  
  void _openDocument(Document doc) {
    setState(() {
      _currentDocument = doc;
      _titleController.text = doc.title;
      _controller.text = doc.content;
    });
    _showMessage('Documento "${doc.title}" aberto');
  }
  
  void _newDocument() {
    setState(() {
      _currentDocument = null;
      _titleController.text = 'Documento sem título';
      _controller.clear();
      _history = [''];
      _historyIndex = 0;
    });
  }
  
  void _insertImage() {
    setState(() {
      _insertedImages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Imagem ${_insertedImages.length + 1}',
        'width': 200.0,
        'height': 150.0,
      });
    });
    _showMessage('Imagem inserida (simulação)');
  }
  
  void _insertTable(int rows, int cols) {
    setState(() {
      _insertedTables.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'rows': rows,
        'cols': cols,
      });
    });
    _showMessage('Tabela ${rows}x${cols} inserida');
  }
  
  void _insertPageBreak() {
    final cursorPos = _controller.selection.start;
    final text = _controller.text;
    final newText = text.substring(0, cursorPos) + '\n\n--- QUEBRA DE PÁGINA ---\n\n' + text.substring(cursorPos);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: cursorPos + 30);
    _addToHistory();
  }
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5E7EB),
      body: Column(
        children: [
          _buildTopToolbar(),
          _buildFormattingToolbar(),
          if (_showRuler) _buildRuler(),
          Expanded(
            child: Row(
              children: [
                if (_showSidebar) _buildSidebar(),
                Expanded(
                  child: _buildEditorArea(),
                ),
                _buildPropertiesPanel(),
              ],
            ),
          ),
          _buildStatusBar(),
        ],
      ),
    );
  }
  
  Widget _buildTopToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1F2937),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Voltar',
          ),
          SizedBox(width: 8),
          Icon(Icons.description, color: Colors.blue[400], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 36,
              child: TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.blue[400]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          _buildTopButton(Icons.create_new_folder, 'Novo', _newDocument),
          _buildTopButton(Icons.folder_open, 'Abrir', () => _showOpenDialog()),
          _buildTopButton(Icons.save, 'Salvar', _saveDocument),
          _buildTopButton(Icons.download, 'Exportar', () => _showExportDialog()),
          _buildTopButton(Icons.share, 'Compartilhar', () => _showShareDialog()),
          _buildTopButton(Icons.print, 'Imprimir', () => _showPrintDialog()),
          SizedBox(width: 8),
          Container(width: 1, height: 24, color: Colors.white24),
          SizedBox(width: 8),
          _buildTopButton(Icons.settings, 'Configurações', () => _showSettingsDialog()),
        ],
      ),
    );
  }
  
  Widget _buildTopButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
  
  Widget _buildFormattingToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton(Icons.undo, 'Desfazer (Ctrl+Z)', _undo),
            _buildToolbarButton(Icons.redo, 'Refazer (Ctrl+Y)', _redo),
            _buildDivider(),
            
            _buildFontSelector(),
            SizedBox(width: 6),
            _buildFontSizeSelector(),
            _buildDivider(),
            
            _buildToggleButton(Icons.format_bold, 'Negrito (Ctrl+B)', _isBold, () {
              setState(() => _isBold = !_isBold);
            }),
            _buildToggleButton(Icons.format_italic, 'Itálico (Ctrl+I)', _isItalic, () {
              setState(() => _isItalic = !_isItalic);
            }),
            _buildToggleButton(Icons.format_underlined, 'Sublinhado (Ctrl+U)', _isUnderline, () {
              setState(() => _isUnderline = !_isUnderline);
            }),
            _buildToggleButton(Icons.strikethrough_s, 'Tachado', _isStrikethrough, () {
              setState(() => _isStrikethrough = !_isStrikethrough);
            }),
            _buildDivider(),
            
            _buildColorPicker(Icons.format_color_text, 'Cor do texto', _textColor, (color) {
              setState(() => _textColor = color);
            }),
            _buildColorPicker(Icons.highlight, 'Realce', _highlightColor, (color) {
              setState(() => _highlightColor = color);
            }),
            _buildDivider(),
            
            _buildToggleButton(Icons.format_align_left, 'Alinhar à esquerda', 
              _textAlign == TextAlign.left, () {
              setState(() => _textAlign = TextAlign.left);
            }),
            _buildToggleButton(Icons.format_align_center, 'Centralizar', 
              _textAlign == TextAlign.center, () {
              setState(() => _textAlign = TextAlign.center);
            }),
            _buildToggleButton(Icons.format_align_right, 'Alinhar à direita', 
              _textAlign == TextAlign.right, () {
              setState(() => _textAlign = TextAlign.right);
            }),
            _buildToggleButton(Icons.format_align_justify, 'Justificar', 
              _textAlign == TextAlign.justify, () {
              setState(() => _textAlign = TextAlign.justify);
            }),
            _buildDivider(),
            
            _buildToolbarButton(Icons.format_list_bulleted, 'Lista com marcadores', () {
              _insertText('• ');
            }),
            _buildToolbarButton(Icons.format_list_numbered, 'Lista numerada', () {
              _insertText('1. ');
            }),
            _buildToolbarButton(Icons.format_indent_increase, 'Aumentar recuo', () {
              _insertText('    ');
            }),
            _buildToolbarButton(Icons.format_indent_decrease, 'Diminuir recuo', () {}),
            _buildDivider(),
            
            _buildToolbarButton(Icons.image, 'Inserir imagem', _insertImage),
            _buildToolbarButton(Icons.table_chart, 'Inserir tabela', () => _showInsertTableDialog()),
            _buildToolbarButton(Icons.insert_link, 'Inserir link', () => _showInsertLinkDialog()),
            _buildToolbarButton(Icons.functions, 'Inserir equação', () => _showInsertEquationDialog()),
            _buildToolbarButton(Icons.insert_page_break, 'Quebra de página', _insertPageBreak),
            _buildDivider(),
            
            _buildToolbarButton(Icons.format_quote, 'Citação', () {
              _insertText('" ');
            }),
            _buildToolbarButton(Icons.code, 'Código', () {
              _insertText('```\n\n```');
            }),
            _buildToolbarButton(Icons.horizontal_rule, 'Linha horizontal', () {
              _insertText('\n---\n');
            }),
            _buildDivider(),
            
            _buildToolbarButton(Icons.find_in_page, 'Localizar (Ctrl+F)', () => _showFindDialog()),
            _buildToolbarButton(Icons.find_replace, 'Substituir (Ctrl+H)', () => _showReplaceDialog()),
            _buildToolbarButton(Icons.spellcheck, 'Verificar ortografia', () => _showMessage('Verificação ortográfica')),
          ],
        ),
      ),
    );
  }
  
  void _insertText(String text) {
    final cursorPos = _controller.selection.start;
    final currentText = _controller.text;
    final newText = currentText.substring(0, cursorPos) + text + currentText.substring(cursorPos);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: cursorPos + text.length);
    _addToHistory();
  }
  
  Widget _buildRuler() {
    return Container(
      height: 30,
      color: Colors.grey[100],
      child: Row(
        children: [
          SizedBox(width: _showSidebar ? 250 : 0),
          Expanded(
            child: CustomPaint(
              painter: RulerPainter(),
            ),
          ),
          SizedBox(width: 300),
        ],
      ),
    );
  }
  
  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.blue[700], size: 20),
                SizedBox(width: 8),
                Text(
                  'Documentos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, size: 18),
                  onPressed: _loadSavedDocuments,
                  tooltip: 'Atualizar',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _savedDocuments.length,
              itemBuilder: (context, index) {
                final doc = _savedDocuments[index];
                final isSelected = _currentDocument?.id == doc.id;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : null,
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.description,
                      color: isSelected ? Colors.blue[700] : Colors.grey[600],
                    ),
                    title: Text(
                      doc.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          '${doc.pageCount} página${doc.pageCount > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          _formatDate(doc.modifiedAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    onTap: () => _openDocument(doc),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_vert, size: 18),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Renomear'),
                            ],
                          ),
                          onTap: () {},
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 18),
                              SizedBox(width: 8),
                              Text('Duplicar'),
                            ],
                          ),
                          onTap: () {},
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _savedDocuments.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Widget _buildEditorArea() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Center(
        child: Transform.scale(
          scale: _zoomLevel,
          child: Container(
            width: _pageSize == 'A4' ? 794 : 1123,
            constraints: BoxConstraints(minHeight: 1123),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(_pageMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: double.parse(_fontSize),
                          fontFamily: _fontFamily,
                          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                          decoration: _isUnderline 
                            ? TextDecoration.underline 
                            : (_isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none),
                          color: _textColor,
                          backgroundColor: _highlightColor,
                          height: _lineSpacing,
                        ),
                        textAlign: _textAlign,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Comece a escrever...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                        onChanged: (text) {
                          _addToHistory();
                        },
                      ),
                      
                      // Renderizar imagens inseridas
                      ..._insertedImages.map((img) => Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        width: img['width'],
                        height: img['height'],
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(img['name'], style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      )).toList(),
                      
                      // Renderizar tabelas inseridas
                      ..._insertedTables.map((table) => Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey[400]!),
                          children: List.generate(
                            table['rows'],
                            (row) => TableRow(
                              children: List.generate(
                                table['cols'],
                                (col) => Container(
                                  padding: EdgeInsets.all(8),
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Célula ${row + 1},${col + 1}',
                                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                    ),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                
                // Número da página
                if (_showPageNumbers)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Página $_currentPage de $_totalPages',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPropertiesPanel() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[700],
              tabs: [
                Tab(text: 'Estilo'),
                Tab(text: 'Layout'),
                Tab(text: 'Revisão'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStyleTab(),
                  _buildLayoutTab(),
                  _buildReviewTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStyleTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildPropertySection('Espaçamento', [
          _buildSlider('Entre linhas', _lineSpacing, 1.0, 3.0, (value) {
            setState(() => _lineSpacing = value);
          }),
          _buildSlider('Entre parágrafos', _paragraphSpacing, 0, 20, (value) {
            setState(() => _paragraphSpacing = value);
          }),
        ]),
        
        _buildPropertySection('Efeitos de Texto', [
          CheckboxListTile(
            title: Text('Subscrito', style: TextStyle(fontSize: 13)),
            value: _isSubscript,
            onChanged: (value) => setState(() => _isSubscript = value!),
            dense: true,
          ),
          CheckboxListTile(
            title: Text('Sobrescrito', style: TextStyle(fontSize: 13)),
            value: _isSuperscript,
            onChanged: (value) => setState(() => _isSuperscript = value!),
            dense: true,
          ),
        ]),
        
        _buildPropertySection('Estilos Predefinidos', [
          _buildStyleButton('Título 1', 32, FontWeight.bold),
          _buildStyleButton('Título 2', 24, FontWeight.bold),
          _buildStyleButton('Título 3', 18, FontWeight.w600),
          _buildStyleButton('Subtítulo', 16, FontWeight.w500),
          _buildStyleButton('Corpo', 14, FontWeight.normal),
          _buildStyleButton('Legenda', 12, FontWeight.w300),
        ]),
      ],
    );
  }
  
  Widget _buildLayoutTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildPropertySection('Configuração da Página', [
          _buildDropdown('Tamanho do papel', _pageSize, ['A4', 'A3', 'Letter', 'Legal'], (value) {
            setState(() => _pageSize = value);
          }),
          _buildDropdown('Orientação', _pageOrientation, ['portrait', 'landscape'], (value) {
            setState(() => _pageOrientation = value);
          }),
          _buildSlider('Margem', _pageMargin, 20, 80, (value) {
            setState(() => _pageMargin = value);
          }),
        ]),
        
        _buildPropertySection('Numeração de Páginas', [
          CheckboxListTile(
            title: Text('Mostrar números', style: TextStyle(fontSize: 13)),
            value: _showPageNumbers,
            onChanged: (value) => setState(() => _showPageNumbers = value!),
            dense: true,
          ),
          _buildDropdown('Posição', _pageNumberPosition, 
            ['top-left', 'top-center', 'top-right', 'bottom-left', 'bottom-center', 'bottom-right'], 
            (value) {
            setState(() => _pageNumberPosition = value);
          }),
        ]),
        
        _buildPropertySection('Colunas', [
          _buildColumnButton('1 Coluna', 1),
          _buildColumnButton('2 Colunas', 2),
          _buildColumnButton('3 Colunas', 3),
        ]),
      ],
    );
  }
  
  Widget _buildReviewTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildPropertySection('Estatísticas', [
          _buildStatRow('Palavras', _wordCount.toString()),
          _buildStatRow('Caracteres', _charCount.toString()),
          _buildStatRow('Caracteres (sem espaços)', _charCountNoSpaces.toString()),
          _buildStatRow('Parágrafos', _paragraphCount.toString()),
          _buildStatRow('Linhas', _lineCount.toString()),
          _buildStatRow('Páginas', _totalPages.toString()),
        ]),
        
        _buildPropertySection('Ferramentas', [
          ElevatedButton.icon(
            icon: Icon(Icons.spellcheck, size: 18),
            label: Text('Verificar Ortografia'),
            onPressed: () => _showMessage('Verificação ortográfica'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(40),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.translate, size: 18),
            label: Text('Traduzir Documento'),
            onPressed: () => _showMessage('Tradução'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(40),
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            icon: Icon(Icons.auto_fix_high, size: 18),
            label: Text('Sugestões de IA'),
            onPressed: () => _showMessage('Sugestões de IA'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(40),
            ),
          ),
        ]),
        
        _buildPropertySection('Tempo de Leitura', [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.access_time, size: 32, color: Colors.blue[700]),
                SizedBox(height: 8),
                Text(
                  '${(_wordCount / 200).ceil()} min',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  'Tempo estimado de leitura',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }
  
  Widget _buildPropertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        ...children,
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13)),
            Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13)),
          SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            ),
            items: items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 13)),
            )).toList(),
            onChanged: (val) => onChanged(val!),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStyleButton(String label, double size, FontWeight weight) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _fontSize = size.toString();
            _isBold = weight == FontWeight.bold;
          });
          _showMessage('Estilo "$label" aplicado');
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(fontSize: size / 2, fontWeight: weight),
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
        ),
      ),
    );
  }
  
  Widget _buildColumnButton(String label, int columns) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        icon: Icon(Icons.view_column, size: 18),
        label: Text(label),
        onPressed: () => _showMessage('$label selecionada'),
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(40),
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF1F2937),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 16),
          SizedBox(width: 8),
          Text(
            'Salvo automaticamente',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Spacer(),
          _buildZoomControls(),
          SizedBox(width: 20),
          _buildStatusItem(Icons.article, 'Pág. $_currentPage/$_totalPages'),
          SizedBox(width: 16),
          _buildStatusItem(Icons.text_fields, '$_wordCount palavras'),
          SizedBox(width: 16),
          _buildStatusItem(Icons.format_size, '$_charCount caracteres'),
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  '3 colaboradores online',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildZoomControls() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.zoom_out, color: Colors.white, size: 18),
          onPressed: () {
            setState(() {
              _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 2.0);
            });
          },
          tooltip: 'Reduzir zoom',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
        SizedBox(width: 8),
        Text(
          '${(_zoomLevel * 100).toInt()}%',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.zoom_in, color: Colors.white, size: 18),
          onPressed: () {
            setState(() {
              _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 2.0);
            });
          },
          tooltip: 'Aumentar zoom',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        ),
      ],
    );
  }
  
  Widget _buildStatusItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
  
  Widget _buildToolbarButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: Colors.grey[700],
        splashRadius: 18,
        padding: EdgeInsets.all(4),
      ),
    );
  }
  
  Widget _buildToggleButton(IconData icon, String tooltip, bool isActive, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        color: isActive ? Colors.white : Colors.grey[700],
        style: IconButton.styleFrom(
          backgroundColor: isActive ? Colors.blue[600] : Colors.transparent,
        ),
        splashRadius: 18,
        padding: EdgeInsets.all(4),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.grey[300],
      margin: EdgeInsets.symmetric(horizontal: 6),
    );
  }
  
  Widget _buildFontSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: _fontFamily,
        underline: SizedBox(),
        style: TextStyle(fontSize: 13, color: Colors.black87),
        items: [
          'Roboto',
          'Arial',
          'Times New Roman',
          'Courier New',
          'Georgia',
          'Verdana',
          'Helvetica',
          'Comic Sans MS',
          'Impact',
          'Trebuchet MS'
        ].map((font) => DropdownMenuItem(
          value: font,
          child: Text(font, style: TextStyle(fontFamily: font)),
        )).toList(),
        onChanged: (value) {
          setState(() => _fontFamily = value!);
        },
      ),
    );
  }
  
  Widget _buildFontSizeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: _fontSize,
        underline: SizedBox(),
        style: TextStyle(fontSize: 13, color: Colors.black87),
        items: ['8', '9', '10', '11', '12', '14', '16', '18', '20', '22', '24', '26', '28', '32', '36', '40', '48', '60', '72']
            .map((size) => DropdownMenuItem(
              value: size,
              child: Text(size),
            ))
            .toList(),
        onChanged: (value) {
          setState(() => _fontSize = value!);
        },
      ),
    );
  }
  
  Widget _buildColorPicker(IconData icon, String tooltip, Color currentColor, Function(Color) onColorChanged) {
    return Tooltip(
      message: tooltip,
      child: PopupMenuButton<Color>(
        icon: Icon(icon, size: 20, color: Colors.grey[700]),
        onSelected: onColorChanged,
        itemBuilder: (context) => [
          [Colors.black, 'Preto'],
          [Colors.white, 'Branco'],
          [Colors.red, 'Vermelho'],
          [Colors.blue, 'Azul'],
          [Colors.green, 'Verde'],
          [Colors.yellow, 'Amarelo'],
          [Colors.orange, 'Laranja'],
          [Colors.purple, 'Roxo'],
          [Colors.pink, 'Rosa'],
          [Colors.brown, 'Marrom'],
          [Colors.grey, 'Cinza'],
          [Colors.teal, 'Azul-petróleo'],
          [Colors.indigo, 'Índigo'],
          [Colors.cyan, 'Ciano'],
          [Colors.lime, 'Lima'],
        ].map((colorData) => PopupMenuItem(
          value: colorData[0] as Color,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorData[0] as Color,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 12),
              Text(colorData[1] as String, style: TextStyle(fontSize: 13)),
            ],
          ),
        )).toList(),
      ),
    );
  }
  
  void _showOpenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder_open, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Abrir Documento'),
          ],
        ),
        content: Container(
          width: 500,
          height: 400,
          child: _savedDocuments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum documento salvo',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _savedDocuments.length,
                  itemBuilder: (context, index) {
                    final doc = _savedDocuments[index];
                    return ListTile(
                      leading: Icon(Icons.description, color: Colors.blue[700]),
                      title: Text(doc.title),
                      subtitle: Text(
                        '${doc.pageCount} páginas • ${_formatDate(doc.modifiedAt)}',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openDocument(doc);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
  
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Exportar Documento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption(Icons.picture_as_pdf, 'PDF', 'Formato universal para impressão', Colors.red),
            _buildExportOption(Icons.article, 'DOCX', 'Microsoft Word', Colors.blue),
            _buildExportOption(Icons.text_snippet, 'TXT', 'Texto simples', Colors.grey),
            _buildExportOption(Icons.code, 'HTML', 'Página web', Colors.orange),
            _buildExportOption(Icons.description, 'RTF', 'Rich Text Format', Colors.green),
            _buildExportOption(Icons.table_chart, 'EPUB', 'E-book', Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExportOption(IconData icon, String format, String description, Color color) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(format, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(description, style: TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        _showMessage('Exportando como $format...');
      },
    );
  }
  
  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.share, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Compartilhar Documento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email do colaborador',
                hintText: 'exemplo@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Pode editar', style: TextStyle(fontSize: 14)),
                    value: true,
                    onChanged: (value) {},
                    dense: true,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Pode comentar', style: TextStyle(fontSize: 14)),
                    value: true,
                    onChanged: (value) {},
                    dense: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Convite enviado!');
            },
            child: Text('Enviar Convite'),
          ),
        ],
      ),
    );
  }
  
  void _showPrintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.print, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Imprimir Documento'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intervalo de páginas', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Todas', style: TextStyle(fontSize: 14)),
                    value: 'all',
                    groupValue: 'all',
                    onChanged: (value) {},
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('Personalizado', style: TextStyle(fontSize: 14)),
                    value: 'custom',
                    groupValue: 'all',
                    onChanged: (value) {},
                    dense: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Cópias', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '1',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Colorido', style: TextStyle(fontSize: 14)),
              value: true,
              onChanged: (value) {},
              dense: true,
            ),
            CheckboxListTile(
              title: Text('Frente e verso', style: TextStyle(fontSize: 14)),
              value: false,
              onChanged: (value) {},
              dense: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.print),
            label: Text('Imprimir'),
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Enviando para impressão...');
            },
          ),
        ],
      ),
    );
  }
  
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Configurações do Editor'),
          ],
        ),
        content: Container(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exibição', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Mostrar barra lateral'),
                  value: _showSidebar,
                  onChanged: (value) {
                    setState(() => _showSidebar = value);
                    Navigator.pop(context);
                  },
                ),
                SwitchListTile(
                  title: Text('Mostrar régua'),
                  value: _showRuler,
                  onChanged: (value) {
                    setState(() => _showRuler = value);
                    Navigator.pop(context);
                  },
                ),
                SwitchListTile(
                  title: Text('Mostrar formatação'),
                  value: _showFormatting,
                  onChanged: (value) {
                    setState(() => _showFormatting = value);
                    Navigator.pop(context);
                  },
                ),
                Divider(height: 32),
                Text('Salvamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 12),
                CheckboxListTile(
                  title: Text('Salvamento automático'),
                  subtitle: Text('Salvar a cada 30 segundos'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: Text('Criar backup'),
                  subtitle: Text('Manter versões anteriores'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  void _showInsertTableDialog() {
    int rows = 3;
    int cols = 3;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.blue[700]),
              SizedBox(width: 12),
              Text('Inserir Tabela'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Linhas', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '3',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => rows = int.tryParse(value) ?? 3);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Colunas', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '3',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() => cols = int.tryParse(value) ?? 3);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tabela de ${rows}x${cols} será inserida',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _insertTable(rows, cols);
              },
              child: Text('Inserir'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showInsertLinkDialog() {
    final textController = TextEditingController();
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.insert_link, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Inserir Link'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Texto do link',
                border: OutlineInputBorder(),
                hintText: 'Clique aqui',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                hintText: 'https://exemplo.com',
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _insertText('[${textController.text}](${urlController.text})');
            },
            child: Text('Inserir'),
          ),
        ],
      ),
    );
  }
  
  void _showInsertEquationDialog() {
    final equationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.functions, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Inserir Equação'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: equationController,
              decoration: InputDecoration(
                labelText: 'Equação LaTeX',
                border: OutlineInputBorder(),
                hintText: 'x^2 + y^2 = z^2',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use sintaxe LaTeX para escrever equações matemáticas',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _insertText('\\[${equationController.text}\\]');
            },
            child: Text('Inserir'),
          ),
        ],
      ),
    );
  }
  
  void _showFindDialog() {
    final findController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.search, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Localizar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: findController,
              decoration: InputDecoration(
                labelText: 'Localizar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Maiúsculas/minúsculas', style: TextStyle(fontSize: 13)),
                    value: false,
                    onChanged: (value) {},
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text('Palavra inteira', style: TextStyle(fontSize: 13)),
                    value: false,
                    onChanged: (value) {},
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_upward, size: 16),
            label: Text('Anterior'),
            onPressed: () => _showMessage('Anterior'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_downward, size: 16),
            label: Text('Próximo'),
            onPressed: () => _showMessage('Próximo'),
          ),
        ],
      ),
    );
  }
  
  void _showReplaceDialog() {
    final findController = TextEditingController();
    final replaceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.find_replace, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Localizar e Substituir'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: findController,
              decoration: InputDecoration(
                labelText: 'Localizar',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: replaceController,
              decoration: InputDecoration(
                labelText: 'Substituir por',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.find_replace),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () => _showMessage('Substituir'),
            child: Text('Substituir'),
          ),
          ElevatedButton(
            onPressed: () => _showMessage('Substituir Tudo'),
            child: Text('Substituir Tudo'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }
}

// Painter para a régua
class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    for (int i = 0; i <= 20; i++) {
      final x = (size.width / 20) * i;
      
      if (i % 5 == 0) {
        canvas.drawLine(
          Offset(x, size.height - 12),
          Offset(x, size.height),
          paint,
        );
        
        textPainter.text = TextSpan(
          text: '${i * 0.5}',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 10, 2));
      } else {
        canvas.drawLine(
          Offset(x, size.height - 6),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}