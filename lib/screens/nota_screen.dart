import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme.dart';

// ── Modelo de nota ──────────────────────────────────────────────────────────
class _Nota {
  String id;
  String title;
  List<_NotaBlock> blocks;
  DateTime updatedAt;

  _Nota({
    required this.id,
    required this.title,
    required this.blocks,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory _Nota.fromJson(Map<String, dynamic> j) => _Nota(
        id: j['id'] ?? '',
        title: j['title'] ?? 'Sem título',
        blocks: (j['blocks'] as List? ?? [])
            .map((b) => _NotaBlock.fromJson(b))
            .toList(),
        updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
      );
}

class _NotaBlock {
  String text;
  bool bold;
  bool italic;
  bool underline;
  bool numbered; // is this a list item
  String colorHex;    // text color
  String bgColorHex;  // highlight color ('transparent' = none)
  double fontSize;

  _NotaBlock({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.numbered = false,
    this.colorHex = '#111111',
    this.bgColorHex = 'transparent',
    this.fontSize = 15,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'bold': bold,
        'italic': italic,
        'underline': underline,
        'numbered': numbered,
        'colorHex': colorHex,
        'bgColorHex': bgColorHex,
        'fontSize': fontSize,
      };

  factory _NotaBlock.fromJson(Map<String, dynamic> j) => _NotaBlock(
        text: j['text'] ?? '',
        bold: j['bold'] ?? false,
        italic: j['italic'] ?? false,
        underline: j['underline'] ?? false,
        numbered: j['numbered'] ?? false,
        colorHex: j['colorHex'] ?? '#111111',
        bgColorHex: j['bgColorHex'] ?? 'transparent',
        fontSize: (j['fontSize'] as num?)?.toDouble() ?? 15,
      );

  _NotaBlock copyWith({
    String? text,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? numbered,
    String? colorHex,
    String? bgColorHex,
    double? fontSize,
  }) =>
      _NotaBlock(
        text: text ?? this.text,
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
        underline: underline ?? this.underline,
        numbered: numbered ?? this.numbered,
        colorHex: colorHex ?? this.colorHex,
        bgColorHex: bgColorHex ?? this.bgColorHex,
        fontSize: fontSize ?? this.fontSize,
      );
}

// ── Ecrã de lista de notas ─────────────────────────────────────────────────
class NotaScreen extends StatefulWidget {
  const NotaScreen({super.key});

  @override
  State<NotaScreen> createState() => _NotaScreenState();
}

class _NotaScreenState extends State<NotaScreen> {
  List<_Nota> _notas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _load();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('aria_notas');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        _notas = list.map((j) => _Nota.fromJson(j)).toList();
        _notas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } catch (_) {}
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'aria_notas', jsonEncode(_notas.map((n) => n.toJson()).toList()));
  }

  void _newNota() async {
    final nota = _Nota(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nota sem título',
      blocks: [_NotaBlock(text: '')],
      updatedAt: DateTime.now(),
    );
    final result = await Navigator.push<_Nota>(
      context,
      MaterialPageRoute(builder: (_) => _NotaEditorScreen(nota: nota, isNew: true)),
    );
    if (result != null) {
      setState(() {
        _notas.insert(0, result);
        _notas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
      await _save();
    }
  }

  void _openNota(_Nota nota) async {
    final result = await Navigator.push<_Nota>(
      context,
      MaterialPageRoute(builder: (_) => _NotaEditorScreen(nota: nota, isNew: false)),
    );
    if (result != null) {
      setState(() {
        final idx = _notas.indexWhere((n) => n.id == result.id);
        if (idx >= 0) _notas[idx] = result;
        _notas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      });
      await _save();
    }
  }

  void _deleteNota(String id) async {
    setState(() => _notas.removeWhere((n) => n.id == id));
    await _save();
  }

  String _preview(_Nota nota) {
    final text = nota.blocks.map((b) => b.text).join(' ').trim();
    return text.isEmpty ? 'Nota vazia' : text;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    return 'Há ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkBackground    : AppColors.background;
    final card     = isDark ? const Color(0xFF1C1C1E)     : Colors.white;
    final border   = isDark ? const Color(0xFF3A3A3C)     : const Color(0xFFE5E5EA);
    final textPri  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final accent   = isDark ? const Color(0xFFFF6B9D)     : const Color(0xFFE0185E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notas',
            style: GoogleFonts.syne(
                color: textPri, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: accent, size: 26),
            onPressed: _newNota,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: border),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: accent))
          : _notas.isEmpty
              ? _Empty(isDark: isDark, onNew: _newNota, accent: accent)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: _notas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final nota = _notas[i];
                    return Dismissible(
                      key: Key(nota.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white, size: 22),
                      ),
                      onDismissed: (_) => _deleteNota(nota.id),
                      child: GestureDetector(
                        onTap: () => _openNota(nota),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(nota.title,
                                        style: GoogleFonts.syne(
                                            color: textPri,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(_timeAgo(nota.updatedAt),
                                      style: GoogleFonts.syne(
                                          color: textSec, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _preview(nota),
                                style: GoogleFonts.syne(
                                    color: textSec, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _notas.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              onPressed: _newNota,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}

class _Empty extends StatelessWidget {
  final bool isDark;
  final VoidCallback onNew;
  final Color accent;
  const _Empty({required this.isDark, required this.onNew, required this.accent});

  @override
  Widget build(BuildContext context) {
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.sticky_note_2_outlined, size: 64, color: textSec),
        const SizedBox(height: 16),
        Text('Sem notas ainda',
            style: GoogleFonts.syne(
                color: textSec, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Toca em + para criar a primeira nota',
            style: GoogleFonts.syne(color: textSec, fontSize: 13)),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onNew,
          style: TextButton.styleFrom(
            backgroundColor: accent,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          child: Text('Nova nota',
              style: GoogleFonts.syne(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ]),
    );
  }
}

// ── Editor de nota ─────────────────────────────────────────────────────────
class _NotaEditorScreen extends StatefulWidget {
  final _Nota nota;
  final bool isNew;
  const _NotaEditorScreen({required this.nota, required this.isNew});

  @override
  State<_NotaEditorScreen> createState() => _NotaEditorScreenState();
}

class _NotaEditorScreenState extends State<_NotaEditorScreen> {
  late _Nota _nota;
  late TextEditingController _titleCtrl;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _activeIdx = 0;

  // Estado de formatação do bloco activo
  bool _bold = false;
  bool _italic = false;
  bool _underline = false;
  bool _numbered = false;
  String _colorHex = '#111111';
  String _bgHex = 'transparent';
  double _fontSize = 15;

  bool _showColorPicker = false;
  bool _showBgPicker = false;
  bool _changed = false;

  final List<String> _textColors = [
    '#111111', '#FFFFFF', '#E0185E', '#FF6B9D', '#FF453A',
    '#FF9F0A', '#FFD60A', '#30D158', '#0A84FF', '#5856D6',
    '#BF5AF2', '#636366', '#8E8E93',
  ];
  final List<String> _bgColors = [
    'transparent', '#FFD60A', '#FF9F0A', '#FF453A', '#30D158',
    '#0A84FF', '#5856D6', '#BF5AF2', '#E0185E',
  ];

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _nota = _Nota(
      id: widget.nota.id,
      title: widget.nota.title,
      blocks: List.from(widget.nota.blocks.map((b) => _NotaBlock(
            text: b.text,
            bold: b.bold,
            italic: b.italic,
            underline: b.underline,
            numbered: b.numbered,
            colorHex: b.colorHex,
            bgColorHex: b.bgColorHex,
            fontSize: b.fontSize,
          ))),
      updatedAt: widget.nota.updatedAt,
    );
    _titleCtrl = TextEditingController(text: _nota.title);
    _controllers = _nota.blocks.map((b) => TextEditingController(text: b.text)).toList();
    _focusNodes = _nota.blocks.map((_) => FocusNode()).toList();
    for (int i = 0; i < _focusNodes.length; i++) {
      final idx = i;
      _focusNodes[idx].addListener(() {
        if (_focusNodes[idx].hasFocus) _setActiveBlock(idx);
      });
    }
    if (widget.isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _titleCtrl.dispose();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() {});

  void _setActiveBlock(int idx) {
    setState(() {
      _activeIdx = idx;
      final b = _nota.blocks[idx];
      _bold = b.bold;
      _italic = b.italic;
      _underline = b.underline;
      _numbered = b.numbered;
      _colorHex = b.colorHex;
      _bgHex = b.bgColorHex;
      _fontSize = b.fontSize;
    });
  }

  void _syncBlock(int idx) {
    _nota.blocks[idx] = _nota.blocks[idx].copyWith(
      text: _controllers[idx].text,
    );
    _changed = true;
  }

  void _toggleFmt(String prop) {
    setState(() {
      _changed = true;
      final b = _nota.blocks[_activeIdx];
      switch (prop) {
        case 'bold':
          _bold = !_bold;
          _nota.blocks[_activeIdx] = b.copyWith(bold: _bold);
          break;
        case 'italic':
          _italic = !_italic;
          _nota.blocks[_activeIdx] = b.copyWith(italic: _italic);
          break;
        case 'underline':
          _underline = !_underline;
          _nota.blocks[_activeIdx] = b.copyWith(underline: _underline);
          break;
        case 'numbered':
          _numbered = !_numbered;
          _nota.blocks[_activeIdx] = b.copyWith(numbered: _numbered);
          break;
      }
    });
  }

  void _setColor(String hex) {
    setState(() {
      _changed = true;
      _colorHex = hex;
      _nota.blocks[_activeIdx] = _nota.blocks[_activeIdx].copyWith(colorHex: hex);
      _showColorPicker = false;
    });
  }

  void _setBgColor(String hex) {
    setState(() {
      _changed = true;
      _bgHex = hex;
      _nota.blocks[_activeIdx] = _nota.blocks[_activeIdx].copyWith(bgColorHex: hex);
      _showBgPicker = false;
    });
  }

  void _setFontSize(double sz) {
    setState(() {
      _changed = true;
      _fontSize = sz;
      _nota.blocks[_activeIdx] = _nota.blocks[_activeIdx].copyWith(fontSize: sz);
    });
  }

  void _addBlock() {
    final newBlock = _NotaBlock(
      text: '',
      bold: _bold,
      italic: _italic,
      underline: _underline,
      numbered: _numbered,
      colorHex: _colorHex,
      bgColorHex: _bgHex,
      fontSize: _fontSize,
    );
    final idx = _activeIdx + 1;
    setState(() {
      _nota.blocks.insert(idx, newBlock);
      _controllers.insert(idx, TextEditingController());
      final fn = FocusNode();
      fn.addListener(() { if (fn.hasFocus) _setActiveBlock(idx); });
      _focusNodes.insert(idx, fn);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[idx].requestFocus();
    });
  }

  void _deleteBlock(int idx) {
    if (_nota.blocks.length <= 1) return;
    setState(() {
      _nota.blocks.removeAt(idx);
      _controllers[idx].dispose();
      _controllers.removeAt(idx);
      _focusNodes[idx].dispose();
      _focusNodes.removeAt(idx);
    });
    final newIdx = (idx - 1).clamp(0, _nota.blocks.length - 1);
    _focusNodes[newIdx].requestFocus();
  }

  void _save() {
    for (int i = 0; i < _nota.blocks.length; i++) {
      _nota.blocks[i] = _nota.blocks[i].copyWith(text: _controllers[i].text);
    }
    _nota.title = _titleCtrl.text.trim().isEmpty ? 'Nota sem título' : _titleCtrl.text.trim();
    _nota.updatedAt = DateTime.now();
    Navigator.pop(context, _nota);
  }

  Color _hexToColor(String hex) {
    if (hex == 'transparent') return Colors.transparent;
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = themeNotifier.isDark;
    final bg      = isDark ? AppColors.darkBackground    : AppColors.background;
    final card    = isDark ? const Color(0xFF1C1C1E)     : Colors.white;
    final border  = isDark ? const Color(0xFF3A3A3C)     : const Color(0xFFE5E5EA);
    final textPri = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final accent  = isDark ? const Color(0xFFFF6B9D)     : const Color(0xFFE0185E);
    final toolBg  = isDark ? const Color(0xFF1C1C1E)     : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: toolBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
          onPressed: () {
            if (_changed) _save();
            else Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _titleCtrl,
          style: GoogleFonts.syne(
              color: textPri, fontWeight: FontWeight.w800, fontSize: 17),
          decoration: InputDecoration(
            hintText: 'Título da nota',
            hintStyle: GoogleFonts.syne(color: textSec, fontSize: 17),
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (_) => _changed = true,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Guardar',
                style: GoogleFonts.syne(
                    color: accent, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: border),
        ),
      ),
      body: Column(
        children: [
          // ── Barra de ferramentas ────────────────────
          Container(
            color: toolBg,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      // Tamanho da fonte
                      _FmtDropdown(
                        value: _fontSize,
                        items: const [11, 13, 15, 17, 20, 24, 28, 32],
                        isDark: isDark,
                        onChanged: _setFontSize,
                      ),
                      const SizedBox(width: 6),
                      _Divider(isDark: isDark),
                      // Bold
                      _FmtBtn(
                          label: 'B',
                          active: _bold,
                          isDark: isDark,
                          accent: accent,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                          onTap: () => _toggleFmt('bold')),
                      // Italic
                      _FmtBtn(
                          label: 'I',
                          active: _italic,
                          isDark: isDark,
                          accent: accent,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                          onTap: () => _toggleFmt('italic')),
                      // Underline
                      _FmtBtn(
                          label: 'U',
                          active: _underline,
                          isDark: isDark,
                          accent: accent,
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                          onTap: () => _toggleFmt('underline')),
                      _Divider(isDark: isDark),
                      // Lista numerada
                      _FmtIconBtn(
                          icon: Icons.format_list_numbered_rounded,
                          active: _numbered,
                          isDark: isDark,
                          accent: accent,
                          onTap: () => _toggleFmt('numbered')),
                      // Adicionar linha
                      _FmtIconBtn(
                          icon: Icons.add_rounded,
                          active: false,
                          isDark: isDark,
                          accent: accent,
                          onTap: _addBlock),
                      _Divider(isDark: isDark),
                      // Cor do texto
                      _ColorBtn(
                        colorHex: _colorHex,
                        isActive: _showColorPicker,
                        isDark: isDark,
                        accent: accent,
                        onTap: () => setState(() {
                          _showColorPicker = !_showColorPicker;
                          _showBgPicker = false;
                        }),
                        isText: true,
                      ),
                      const SizedBox(width: 6),
                      // Cor de fundo
                      _ColorBtn(
                        colorHex: _bgHex == 'transparent' ? '#F0F0F0' : _bgHex,
                        isActive: _showBgPicker,
                        isDark: isDark,
                        accent: accent,
                        onTap: () => setState(() {
                          _showBgPicker = !_showBgPicker;
                          _showColorPicker = false;
                        }),
                        isText: false,
                      ),
                    ],
                  ),
                ),

                // Color picker de texto
                if (_showColorPicker)
                  _ColorRow(
                    colors: _textColors,
                    selected: _colorHex,
                    isDark: isDark,
                    accent: accent,
                    onSelect: _setColor,
                  ),

                // Color picker de fundo
                if (_showBgPicker)
                  _ColorRow(
                    colors: _bgColors,
                    selected: _bgHex,
                    isDark: isDark,
                    accent: accent,
                    onSelect: _setBgColor,
                    isBackground: true,
                  ),

                Container(height: 0.5, color: border),
              ],
            ),
          ),

          // ── Área de escrita ────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _nota.blocks.length,
              itemBuilder: (context, i) {
                final b = _nota.blocks[i];
                final isActive = i == _activeIdx;
                final textColor = _hexToColor(b.colorHex);
                final bgColor   = _hexToColor(b.bgColorHex);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Número (se lista numerada)
                      if (b.numbered)
                        Padding(
                          padding: const EdgeInsets.only(top: 14, right: 6),
                          child: Text(
                            '${i + 1}.',
                            style: GoogleFonts.syne(
                                color: textSec, fontSize: b.fontSize * 0.85),
                          ),
                        ),

                      // Campo de texto
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor == Colors.transparent
                                ? Colors.transparent
                                : bgColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: isActive && bgColor == Colors.transparent
                                ? Border.all(
                                    color: accent.withOpacity(0.3), width: 1)
                                : null,
                          ),
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            style: GoogleFonts.syne(
                              color: textColor == Colors.transparent
                                  ? textPri
                                  : textColor,
                              fontSize: b.fontSize,
                              fontWeight: b.bold
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              fontStyle: b.italic
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              decoration: b.underline
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                            decoration: InputDecoration(
                              hintText: i == 0 ? 'Começa a escrever…' : '',
                              hintStyle: GoogleFonts.syne(
                                  color: textSec, fontSize: b.fontSize),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 10),
                              isDense: true,
                            ),
                            onChanged: (_) => _syncBlock(i),
                            onSubmitted: (_) => _addBlock(),
                          ),
                        ),
                      ),

                      // Botão de apagar bloco (se hover/long press)
                      if (isActive && _nota.blocks.length > 1)
                        GestureDetector(
                          onTap: () => _deleteBlock(i),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 4),
                            child: Icon(Icons.remove_circle_outline_rounded,
                                color: textSec, size: 18),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────
class _FmtBtn extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final Color accent;
  final TextStyle? style;
  final VoidCallback onTap;

  const _FmtBtn({
    required this.label,
    required this.active,
    required this.isDark,
    required this.accent,
    required this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active
              ? accent.withOpacity(0.15)
              : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: (style ?? const TextStyle()).copyWith(
            color: active ? accent : (isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C)),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _FmtIconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  const _FmtIconBtn({
    required this.icon,
    required this.active,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active
              ? accent.withOpacity(0.15)
              : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon,
            size: 18,
            color: active
                ? accent
                : (isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C))),
      ),
    );
  }
}

class _FmtDropdown extends StatelessWidget {
  final double value;
  final List<double> items;
  final bool isDark;
  final void Function(double) onChanged;

  const _FmtDropdown({
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF111111);
    final bgColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: items.contains(value) ? value : items.first,
          isDense: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          style: GoogleFonts.syne(
              color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
          icon: Icon(Icons.expand_more_rounded, size: 16, color: textColor),
          items: items
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.toStringAsFixed(0)),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _ColorBtn extends StatelessWidget {
  final String colorHex;
  final bool isActive;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;
  final bool isText;

  const _ColorBtn({
    required this.colorHex,
    required this.isActive,
    required this.isDark,
    required this.accent,
    required this.onTap,
    required this.isText,
  });

  @override
  Widget build(BuildContext context) {
    Color c;
    try {
      final h = colorHex.replaceAll('#', '');
      c = Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      c = isDark ? Colors.white : Colors.black;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(8),
          border: isActive ? Border.all(color: accent, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: isText
            ? Text('A',
                style: GoogleFonts.syne(
                  color: c,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                  decorationColor: c,
                  decorationThickness: 3,
                ))
            : Container(
                width: 20,
                height: 14,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3A3A3C)
                        : const Color(0xFFE0E0E5),
                    width: 1,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final List<String> colors;
  final String selected;
  final bool isDark;
  final Color accent;
  final void Function(String) onSelect;
  final bool isBackground;

  const _ColorRow({
    required this.colors,
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.onSelect,
    this.isBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: colors.map((hex) {
          final isTransparent = hex == 'transparent';
          Color c;
          try {
            c = isTransparent
                ? Colors.transparent
                : Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
          } catch (_) {
            c = Colors.transparent;
          }
          final isSel = hex == selected;

          return GestureDetector(
            onTap: () => onSelect(hex),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSel
                      ? accent
                      : (isDark
                          ? const Color(0xFF3A3A3C)
                          : const Color(0xFFDDDDDD)),
                  width: isSel ? 2.5 : 1,
                ),
              ),
              child: isTransparent
                  ? const Center(
                      child: Icon(Icons.block_rounded,
                          color: Colors.grey, size: 16))
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E5),
    );
  }
}
