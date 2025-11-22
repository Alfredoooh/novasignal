import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';
import '../widgets/page_widget.dart';
import '../widgets/formatting_toolbar.dart';
import '../models/document_model.dart';
import '../services/export_service.dart';

class EditorScreen extends StatefulWidget {
  final DocumentModel? document;

  const EditorScreen({super.key, this.document});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final List<TextEditingController> _pageControllers = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  String _currentFont = 'Roboto';
  double _fontSize = 12.0;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  TextAlign _textAlign = TextAlign.left;
  PaperSize _paperSize = PaperSize.a4;
  
  int _characterCount = 0;
  int _wordCount = 0;
  int _currentPage = 1;
  String _documentTitle = 'Novo Documento';

  @override
  void initState() {
    super.initState();
    _addNewPage();
    _updateStats();
  }

  @override
  void dispose() {
    for (var controller in _pageControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewPage() {
    setState(() {
      final controller = TextEditingController();
      controller.addListener(_updateStats);
      _pageControllers.add(controller);
    });
  }

  void _updateStats() {
    int totalChars = 0;
    int totalWords = 0;

    for (var controller in _pageControllers) {
      final text = controller.text;
      totalChars += text.length;
      if (text.isNotEmpty) {
        totalWords += text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
      }
    }

    setState(() {
      _characterCount = totalChars;
      _wordCount = totalWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _pageControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: PageWidget(
                    controller: _pageControllers[index],
                    pageNumber: index + 1,
                    totalPages: _pageControllers.length,
                    fontSize: _fontSize,
                    fontFamily: _currentFont,
                    isBold: _isBold,
                    isItalic: _isItalic,
                    isUnderline: _isUnderline,
                    textAlign: _textAlign,
                    paperSize: _paperSize,
                    onTextChanged: () {
                      _checkPageOverflow(index);
                    },
                  ),
                );
              },
            ),
          ),
          FormattingToolbar(
            fontSize: _fontSize,
            isBold: _isBold,
            isItalic: _isItalic,
            isUnderline: _isUnderline,
            textAlign: _textAlign,
            currentFont: _currentFont,
            onFontSizeChanged: (size) => setState(() => _fontSize = size),
            onBoldToggle: () => setState(() => _isBold = !_isBold),
            onItalicToggle: () => setState(() => _isItalic = !_isItalic),
            onUnderlineToggle: () => setState(() => _isUnderline = !_isUnderline),
            onAlignChanged: (align) => setState(() => _textAlign = align),
            onFontChanged: (font) => setState(() => _currentFont = font),
            onAddPage: _addNewPage,
            onExport: _showExportOptions,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Ionicons.chevron_back, color: Color(0xFF1C1C1E)),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: GestureDetector(
        onTap: _renameDocument,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _documentTitle,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Ionicons.create_outline,
              size: 16,
              color: Color(0xFF8E8E93),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Ionicons.albums_outline, color: Color(0xFF1C1C1E)),
          onPressed: _showPaperSizePicker,
        ),
        IconButton(
          icon: const Icon(Ionicons.checkmark_circle, color: Color(0xFFFF375F)),
          onPressed: _saveDocument,
        ),
        IconButton(
          icon: const Icon(Ionicons.ellipsis_horizontal, color: Color(0xFF1C1C1E)),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Ionicons.document_text_outline, '$_wordCount palavras'),
          _buildStatItem(Ionicons.text_outline, '$_characterCount caracteres'),
          _buildStatItem(Ionicons.albums_outline, 'Página $_currentPage/${_pageControllers.length}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF8E8E93)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _checkPageOverflow(int pageIndex) {
    final controller = _pageControllers[pageIndex];
    final text = controller.text;
    final dimensions = PaperDimensions.dimensions[_paperSize]!;
    
    if (text.length > dimensions.maxChars) {
      if (pageIndex == _pageControllers.length - 1) {
        _addNewPage();
      }
    }
  }

  void _saveDocument() {
    HapticFeedback.mediumImpact();
    
    final content = _pageControllers.map((c) => c.text).join('\n---PAGE_BREAK---\n');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Ionicons.checkmark_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Documento salvo com sucesso!'),
          ],
        ),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showPaperSizePicker() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withOpacity(0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tamanho do Papel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ...PaperSize.values.map((size) {
                  final dimensions = PaperDimensions.dimensions[size]!;
                  final isSelected = size == _paperSize;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _paperSize = size);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF375F).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF375F)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                size.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  size.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${dimensions.maxChars} caracteres • ${dimensions.linesPerPage} linhas',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Ionicons.checkmark_circle,
                              color: Color(0xFFFF375F),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withOpacity(0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOption(
                  icon: Ionicons.create_outline,
                  title: 'Renomear',
                  onTap: () {
                    Navigator.pop(context);
                    _renameDocument();
                  },
                ),
                _buildOption(
                  icon: Ionicons.copy_outline,
                  title: 'Duplicar',
                  onTap: () {
                    Navigator.pop(context);
                    _duplicateDocument();
                  },
                ),
                _buildOption(
                  icon: Ionicons.share_outline,
                  title: 'Compartilhar',
                  onTap: () {
                    Navigator.pop(context);
                    _shareDocument();
                  },
                ),
                _buildOption(
                  icon: Ionicons.trash_outline,
                  title: 'Excluir',
                  color: const Color(0xFFFF375F),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteDocument();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showExportOptions() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E).withOpacity(0.95),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Exportar Documento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _buildExportOption(
                  icon: Ionicons.document_text_outline,
                  title: 'PDF',
                  subtitle: 'Formato universal - Melhor para impressão',
                  color: const Color(0xFFFF375F),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportAsPDF();
                  },
                ),
                _buildExportOption(
                  icon: Ionicons.book_outline,
                  title: 'EPUB',
                  subtitle: 'Livro eletrônico - Para leitores digitais',
                  color: const Color(0xFF007AFF),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportAsEPUB();
                  },
                ),
                _buildExportOption(
                  icon: Ionicons.code_outline,
                  title: 'TXT',
                  subtitle: 'Texto simples - Compatível com tudo',
                  color: const Color(0xFF34C759),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportAsTXT();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Ionicons.chevron_forward,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPDF() async {
    try {
      final content = _pageControllers.map((c) => c.text).join('\n\n');
      await ExportService.exportAsPDF(content);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Ionicons.checkmark_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('PDF exportado com sucesso!'),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Ionicons.alert_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao exportar: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF375F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportAsEPUB() async {
    try {
      final content = _pageControllers.map((c) => c.text).join('\n\n');
      await ExportService.exportAsEPUB(content);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Ionicons.checkmark_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('EPUB exportado com sucesso!'),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Ionicons.alert_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao exportar: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF375F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _exportAsTXT() async {
    try {
      final content = _pageControllers.map((c) => c.text).join('\n\n---PÁGINA---\n\n');
      await ExportService.exportAsTXT(content);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Ionicons.checkmark_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('TXT exportado com sucesso!'),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Ionicons.alert_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao exportar: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFFF375F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _renameDocument() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _documentTitle);
        
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Renomear Documento',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nome do documento',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFF375F)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                setState(() => _documentTitle = controller.text);
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text('Salvar', style: TextStyle(color: Color(0xFFFF375F))),
            ),
          ],
        );
      },
    );
  }

  void _duplicateDocument() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Ionicons.copy_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Documento duplicado!'),
          ],
        ),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareDocument() {
    HapticFeedback.lightImpact();
    _showExportOptions();
  }

  void _deleteDocument() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Excluir Documento',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este documento? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            child: const Text('Excluir', style: TextStyle(color: Color(0xFFFF375F))),
          ),
        ],
      ),
    );
  }
}