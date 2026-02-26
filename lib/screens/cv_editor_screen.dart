import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';

// ════════════════════════════════════════════════════════
// MODELOS
// ════════════════════════════════════════════════════════

enum CvElementType { text, rect, circle, line, image, divider }

class CvGradient {
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  const CvGradient({required this.colors, required this.begin, required this.end});
}

class CvBorder {
  final Color color;
  final double width;
  final double radius;
  const CvBorder({this.color = Colors.transparent, this.width = 0, this.radius = 0});
  CvBorder copyWith({Color? color, double? width, double? radius}) =>
      CvBorder(color: color ?? this.color, width: width ?? this.width, radius: radius ?? this.radius);
}

class CvElement {
  final String id;
  CvElementType type;
  double x, y, w, h;
  String? text;
  double fontSize;
  FontWeight fontWeight;
  FontStyle fontStyle;
  TextAlign textAlign;
  Color textColor;
  CvGradient? textGradient;
  Color? fillColor;
  CvGradient? fillGradient;
  CvBorder border;
  double opacity;
  double rotation;
  bool locked;

  CvElement({
    required this.id,
    required this.type,
    this.x = 40,
    this.y = 40,
    this.w = 200,
    this.h = 60,
    this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.fontStyle = FontStyle.normal,
    this.textAlign = TextAlign.left,
    this.textColor = Colors.black,
    this.textGradient,
    this.fillColor,
    this.fillGradient,
    this.border = const CvBorder(),
    this.opacity = 1.0,
    this.rotation = 0,
    this.locked = false,
  });

  CvElement clone() => CvElement(
        id: id,
        type: type,
        x: x, y: y, w: w, h: h,
        text: text,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        textAlign: textAlign,
        textColor: textColor,
        textGradient: textGradient,
        fillColor: fillColor,
        fillGradient: fillGradient,
        border: border,
        opacity: opacity,
        rotation: rotation,
        locked: locked,
      );
}

class CvBoard {
  String id;
  String name;
  double width;
  double height;
  Color background;
  CvGradient? backgroundGradient;
  List<CvElement> elements;

  CvBoard({
    required this.id,
    required this.name,
    this.width = 794,
    this.height = 1123,
    this.background = Colors.white,
    this.backgroundGradient,
    List<CvElement>? elements,
  }) : elements = elements ?? [];
}

// ════════════════════════════════════════════════════════
// GRADIENTES PRÉ-DEFINIDOS
// ════════════════════════════════════════════════════════
class _Gradients {
  static const gold = CvGradient(
    colors: [Color(0xFFFFD700), Color(0xFFDAA520), Color(0xFFFFD700)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const silver = CvGradient(
    colors: [Color(0xFFC0C0C0), Color(0xFF808080), Color(0xFFC0C0C0)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const rose = CvGradient(
    colors: [Color(0xFFE0185E), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const ocean = CvGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF30D158)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const sunset = CvGradient(
    colors: [Color(0xFFFF9F0A), Color(0xFFE0185E)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const purple = CvGradient(
    colors: [Color(0xFF5856D6), Color(0xFFBF5AF2)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const dark = CvGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF3A3A3C)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const emerald = CvGradient(
    colors: [Color(0xFF16A34A), Color(0xFF30D158)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const all = [gold, silver, rose, ocean, sunset, purple, dark, emerald];
  static const names = ['Dourado', 'Prata', 'Rosa', 'Oceano', 'Pôr do Sol', 'Roxo', 'Escuro', 'Esmeralda'];
}

// ════════════════════════════════════════════════════════
// ECRÃ PRINCIPAL
// ════════════════════════════════════════════════════════
class CvEditorScreen extends StatefulWidget {
  final String? docId;
  final String? docTitle;
  const CvEditorScreen({super.key, this.docId, this.docTitle});

  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen>
    with TickerProviderStateMixin {
  // Quadros (boards)
  late List<CvBoard> _boards;
  int _activeBoardIdx = 0;
  CvBoard get _board => _boards[_activeBoardIdx];

  // Elemento seleccionado
  String? _selectedId;
  CvElement? get _selected =>
      _selectedId == null ? null : _board.elements.firstWhere(
            (e) => e.id == _selectedId,
            orElse: () => _board.elements.first,
          );

  // Painel activo no bottom sheet
  String _activePanel = ''; // '', 'text', 'fill', 'border', 'element'

  // Zoom / pan do canvas
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  // Drag state
  String? _draggingId;
  Offset _dragStart = Offset.zero;
  double _elemStartX = 0, _elemStartY = 0;

  // Resize state
  bool _resizing = false;
  double _elemStartW = 0, _elemStartH = 0;

  // Histórico de undo
  final List<List<CvElement>> _history = [];

  // Título
  late String _title;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _title = widget.docTitle ?? 'Currículo sem título';
    _boards = [
      CvBoard(
        id: 'board_1',
        name: 'Página 1',
        width: 794,
        height: 1123,
      )
    ];
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  // ── Historial ────────────────────────────────────────
  void _pushHistory() {
    _history.add(_board.elements.map((e) => e.clone()).toList());
    if (_history.length > 50) _history.removeAt(0);
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _board.elements
        ..clear()
        ..addAll(_history.removeLast());
      _selectedId = null;
    });
  }

  // ── Adicionar elemento ────────────────────────────────
  void _addElement(CvElementType type) {
    _pushHistory();
    final id = 'el_${DateTime.now().millisecondsSinceEpoch}';
    CvElement el;

    switch (type) {
      case CvElementType.text:
        el = CvElement(
          id: id, type: type,
          x: 60, y: 60, w: 280, h: 50,
          text: 'Clique para editar',
          fontSize: 20, fontWeight: FontWeight.w700,
          textColor: Colors.black,
        );
        break;
      case CvElementType.rect:
        el = CvElement(
          id: id, type: type,
          x: 60, y: 60, w: 240, h: 120,
          fillColor: const Color(0xFF1D4ED8),
          border: const CvBorder(radius: 8),
        );
        break;
      case CvElementType.circle:
        el = CvElement(
          id: id, type: type,
          x: 60, y: 60, w: 100, h: 100,
          fillColor: const Color(0xFFE0185E),
          border: const CvBorder(radius: 50),
        );
        break;
      case CvElementType.line:
        el = CvElement(
          id: id, type: type,
          x: 60, y: 200, w: 300, h: 4,
          fillColor: Colors.black,
          border: const CvBorder(radius: 2),
        );
        break;
      case CvElementType.divider:
        el = CvElement(
          id: id, type: type,
          x: 40, y: 200, w: 714, h: 2,
          fillColor: const Color(0xFFE5E5EA),
        );
        break;
      case CvElementType.image:
        el = CvElement(
          id: id, type: type,
          x: 60, y: 60, w: 200, h: 200,
          fillColor: const Color(0xFFF2F2F7),
          text: 'Imagem',
        );
        break;
    }

    setState(() {
      _board.elements.add(el);
      _selectedId = id;
      _activePanel = 'element';
    });
  }

  // ── Seleccionar elemento ──────────────────────────────
  void _selectElement(String? id) {
    setState(() {
      _selectedId = id;
      _activePanel = id != null ? 'element' : '';
    });
  }

  // ── Apagar elemento ──────────────────────────────────
  void _deleteSelected() {
    if (_selectedId == null) return;
    _pushHistory();
    setState(() {
      _board.elements.removeWhere((e) => e.id == _selectedId);
      _selectedId = null;
      _activePanel = '';
    });
  }

  // ── Duplicar elemento ─────────────────────────────────
  void _duplicateSelected() {
    if (_selected == null) return;
    _pushHistory();
    final clone = _selected!.clone();
    clone.x += 20;
    clone.y += 20;
    final newEl = CvElement(
      id: 'el_${DateTime.now().millisecondsSinceEpoch}',
      type: clone.type,
      x: clone.x, y: clone.y, w: clone.w, h: clone.h,
      text: clone.text,
      fontSize: clone.fontSize, fontWeight: clone.fontWeight,
      fontStyle: clone.fontStyle, textAlign: clone.textAlign,
      textColor: clone.textColor, textGradient: clone.textGradient,
      fillColor: clone.fillColor, fillGradient: clone.fillGradient,
      border: clone.border, opacity: clone.opacity,
    );
    setState(() {
      _board.elements.add(newEl);
      _selectedId = newEl.id;
    });
  }

  // ── Adicionar quadro ──────────────────────────────────
  void _addBoard() {
    final n = _boards.length + 1;
    setState(() {
      _boards.add(CvBoard(
        id: 'board_$n',
        name: 'Página $n',
        width: _boards.first.width,
        height: _boards.first.height,
      ));
      _activeBoardIdx = _boards.length - 1;
      _selectedId = null;
    });
  }

  void _removeBoard(int idx) {
    if (_boards.length <= 1) return;
    setState(() {
      _boards.removeAt(idx);
      _activeBoardIdx = (_activeBoardIdx).clamp(0, _boards.length - 1);
      _selectedId = null;
    });
  }

  // ── Mover elemento ───────────────────────────────────
  void _onDragStart(CvElement el, Offset localPos) {
    if (el.locked) return;
    setState(() {
      _draggingId = el.id;
      _dragStart = localPos;
      _elemStartX = el.x;
      _elemStartY = el.y;
    });
  }

  void _onDragUpdate(Offset localPos) {
    if (_draggingId == null) return;
    final delta = (localPos - _dragStart) / _scale;
    setState(() {
      final el = _board.elements.firstWhere((e) => e.id == _draggingId);
      el.x = (_elemStartX + delta.dx).clamp(0, _board.width - el.w);
      el.y = (_elemStartY + delta.dy).clamp(0, _board.height - el.h);
    });
  }

  void _onDragEnd() {
    if (_draggingId != null) _pushHistory();
    setState(() => _draggingId = null);
  }

  // ── Resize ───────────────────────────────────────────
  void _onResizeStart(CvElement el, Offset localPos) {
    setState(() {
      _resizing = true;
      _draggingId = el.id;
      _dragStart = localPos;
      _elemStartW = el.w;
      _elemStartH = el.h;
    });
  }

  void _onResizeUpdate(Offset localPos) {
    if (!_resizing || _draggingId == null) return;
    final delta = (localPos - _dragStart) / _scale;
    setState(() {
      final el = _board.elements.firstWhere((e) => e.id == _draggingId);
      el.w = (_elemStartW + delta.dx).clamp(20, _board.width.toDouble());
      el.h = (_elemStartH + delta.dy).clamp(10, _board.height.toDouble());
    });
  }

  void _onResizeEnd() {
    if (_draggingId != null) _pushHistory();
    setState(() { _resizing = false; _draggingId = null; });
  }

  // ── Export ───────────────────────────────────────────
  void _showExportOptions() {
    final isDark = themeNotifier.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ExportSheet(isDark: isDark),
    );
  }

  // ── Alterar dimensões do quadro ───────────────────────
  void _showBoardSizeDialog() {
    final isDark = themeNotifier.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BoardSizeSheet(
        board: _board,
        isDark: isDark,
        onApply: (w, h) {
          setState(() { _board.width = w; _board.height = h; });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = themeNotifier.isDark;
    final bg      = isDark ? const Color(0xFF111111) : const Color(0xFFEEEEF0);
    final headerBg= isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final border  = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final textPri = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final accent  = isDark ? const Color(0xFFFF6B9D) : const Color(0xFFE0185E);

    final canvasScale = (MediaQuery.of(context).size.width - 32) / _board.width;

    return Scaffold(
      backgroundColor: bg,
      body: Column(children: [
        // ════ HEADER ════════════════════════════════════
        Container(
          color: headerBg,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(children: [
            // Faixa topo
            SizedBox(
              height: 52,
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPri, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _renameDialog(),
                    child: Text(
                      _title,
                      style: GoogleFonts.syne(
                          color: textPri, fontWeight: FontWeight.w800, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Undo
                IconButton(
                  icon: Icon(Icons.undo_rounded,
                      color: _history.isEmpty ? textSec : textPri, size: 22),
                  onPressed: _history.isEmpty ? null : _undo,
                ),
                // Export
                IconButton(
                  icon: Icon(Icons.ios_share_rounded, color: textPri, size: 22),
                  onPressed: _showExportOptions,
                ),
                // Opções do quadro
                IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: textPri, size: 22),
                  onPressed: () => _showBoardOptions(),
                ),
              ]),
            ),
            // Toolbar de inserção
            _InsertToolbar(
              isDark: isDark,
              accent: accent,
              textSec: textSec,
              border: border,
              onAdd: _addElement,
              onBoardSize: _showBoardSizeDialog,
              onBackground: () => _showBackgroundPicker(),
            ),
          ]),
        ),

        // ════ SELECTOR DE QUADROS ════════════════════════
        Container(
          color: headerBg,
          height: 52,
          child: Row(children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _boards.length + 1,
                itemBuilder: (_, i) {
                  if (i == _boards.length) {
                    // Botão adicionar quadro
                    return GestureDetector(
                      onTap: _addBoard,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: border),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.add_rounded, size: 16, color: accent),
                          const SizedBox(width: 4),
                          Text('Novo', style: GoogleFonts.syne(
                              color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    );
                  }
                  final b = _boards[i];
                  final isActive = i == _activeBoardIdx;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _activeBoardIdx = i;
                      _selectedId = null;
                      _activePanel = '';
                    }),
                    onLongPress: _boards.length > 1
                        ? () => _removeBoard(i)
                        : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isActive
                            ? accent.withOpacity(0.15)
                            : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: isActive ? accent : border, width: isActive ? 1.5 : 1),
                      ),
                      child: Text(b.name,
                          style: GoogleFonts.syne(
                              color: isActive ? accent : textSec,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),

        Container(height: 0.5, color: border),

        // ════ CANVAS ════════════════════════════════════
        Expanded(
          child: GestureDetector(
            onTapDown: (_) => _selectElement(null),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _BoardCanvas(
                  board: _board,
                  scale: canvasScale,
                  selectedId: _selectedId,
                  draggingId: _draggingId,
                  onSelect: _selectElement,
                  onDragStart: _onDragStart,
                  onDragUpdate: _onDragUpdate,
                  onDragEnd: _onDragEnd,
                  onResizeStart: _onResizeStart,
                  onResizeUpdate: _onResizeUpdate,
                  onResizeEnd: _onResizeEnd,
                  onTextEdit: (el) => _openTextEditor(el),
                ),
              ),
            ),
          ),
        ),

        // ════ PAINEL DE PROPRIEDADES ═════════════════════
        if (_selectedId != null && _selected != null)
          _PropertiesPanel(
            element: _selected!,
            isDark: isDark,
            accent: accent,
            textPri: textPri,
            textSec: textSec,
            border: border,
            onUpdate: (updated) {
              _pushHistory();
              setState(() {
                final idx = _board.elements.indexWhere((e) => e.id == updated.id);
                if (idx >= 0) _board.elements[idx] = updated;
              });
            },
            onDelete: _deleteSelected,
            onDuplicate: _duplicateSelected,
            onLockToggle: () {
              setState(() => _selected!.locked = !_selected!.locked);
            },
            onBringForward: () {
              _pushHistory();
              setState(() {
                final idx = _board.elements.indexWhere((e) => e.id == _selectedId);
                if (idx < _board.elements.length - 1) {
                  final el = _board.elements.removeAt(idx);
                  _board.elements.insert(idx + 1, el);
                }
              });
            },
            onSendBackward: () {
              _pushHistory();
              setState(() {
                final idx = _board.elements.indexWhere((e) => e.id == _selectedId);
                if (idx > 0) {
                  final el = _board.elements.removeAt(idx);
                  _board.elements.insert(idx - 1, el);
                }
              });
            },
          ),
      ]),
    );
  }

  void _renameDialog() {
    final ctrl = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Renomear', style: GoogleFonts.syne(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.syne(),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () { setState(() => _title = ctrl.text); Navigator.pop(context); },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBoardOptions() {
    final isDark = themeNotifier.isDark;
    final accent = isDark ? const Color(0xFFFF6B9D) : const Color(0xFFE0185E);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 4, decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.photo_size_select_large_rounded, color: accent),
          title: Text('Alterar dimensões', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          onTap: () { Navigator.pop(context); _showBoardSizeDialog(); },
        ),
        ListTile(
          leading: Icon(Icons.gradient_rounded, color: accent),
          title: Text('Fundo do quadro', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          onTap: () { Navigator.pop(context); _showBackgroundPicker(); },
        ),
        ListTile(
          leading: Icon(Icons.content_copy_rounded, color: accent),
          title: Text('Duplicar quadro', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          onTap: () {
            Navigator.pop(context);
            final clone = CvBoard(
              id: 'board_${DateTime.now().millisecondsSinceEpoch}',
              name: '${_board.name} (cópia)',
              width: _board.width,
              height: _board.height,
              background: _board.background,
              backgroundGradient: _board.backgroundGradient,
              elements: _board.elements.map((e) => e.clone()).toList(),
            );
            setState(() {
              _boards.insert(_activeBoardIdx + 1, clone);
              _activeBoardIdx = _activeBoardIdx + 1;
            });
          },
        ),
        if (_boards.length > 1)
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: Text('Eliminar quadro',
                style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: Colors.red)),
            onTap: () { Navigator.pop(context); _removeBoard(_activeBoardIdx); },
          ),
        const SizedBox(height: 16),
      ]),
    );
  }

  void _showBackgroundPicker() {
    final isDark = themeNotifier.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BackgroundSheet(
        board: _board,
        isDark: isDark,
        onApply: (bg, grad) {
          setState(() {
            _board.background = bg;
            _board.backgroundGradient = grad;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openTextEditor(CvElement el) {
    final ctrl = TextEditingController(text: el.text ?? '');
    final isDark = themeNotifier.isDark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(_).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Text('Editar texto', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: null,
              style: GoogleFonts.syne(fontSize: 15),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Digite o texto…',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _pushHistory();
                setState(() => el.text = ctrl.text);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
            const SizedBox(width: 16),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// CANVAS DO QUADRO
// ════════════════════════════════════════════════════════
class _BoardCanvas extends StatelessWidget {
  final CvBoard board;
  final double scale;
  final String? selectedId;
  final String? draggingId;
  final void Function(String?) onSelect;
  final void Function(CvElement, Offset) onDragStart;
  final void Function(Offset) onDragUpdate;
  final void Function() onDragEnd;
  final void Function(CvElement, Offset) onResizeStart;
  final void Function(Offset) onResizeUpdate;
  final void Function() onResizeEnd;
  final void Function(CvElement) onTextEdit;

  const _BoardCanvas({
    required this.board,
    required this.scale,
    required this.selectedId,
    required this.draggingId,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onTextEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Background
    Decoration bgDecoration;
    if (board.backgroundGradient != null) {
      bgDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: board.backgroundGradient!.colors,
          begin: board.backgroundGradient!.begin as Alignment,
          end: board.backgroundGradient!.end as Alignment,
        ),
      );
    } else {
      bgDecoration = BoxDecoration(color: board.background);
    }

    return GestureDetector(
      onPanUpdate: (d) {
        if (draggingId != null) onDragUpdate(d.localPosition);
      },
      onPanEnd: (_) {
        onDragEnd();
        onResizeEnd();
      },
      child: Container(
        width: board.width * scale,
        height: board.height * scale,
        decoration: bgDecoration,
        clipBehavior: Clip.hardEdge,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: board.width,
            height: board.height,
            child: Stack(
              children: board.elements.map((el) {
                final isSelected = el.id == selectedId;
                return _CanvasElement(
                  key: ValueKey(el.id),
                  element: el,
                  isSelected: isSelected,
                  onTap: () => onSelect(el.id),
                  onDragStart: (pos) => onDragStart(el, pos),
                  onDragUpdate: onDragUpdate,
                  onDragEnd: onDragEnd,
                  onResizeStart: (pos) => onResizeStart(el, pos),
                  onResizeUpdate: onResizeUpdate,
                  onResizeEnd: onResizeEnd,
                  onDoubleTap: () => onTextEdit(el),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// ELEMENTO NO CANVAS
// ════════════════════════════════════════════════════════
class _CanvasElement extends StatelessWidget {
  final CvElement element;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(Offset) onDragStart;
  final void Function(Offset) onDragUpdate;
  final VoidCallback onDragEnd;
  final void Function(Offset) onResizeStart;
  final void Function(Offset) onResizeUpdate;
  final VoidCallback onResizeEnd;
  final VoidCallback onDoubleTap;

  const _CanvasElement({
    super.key,
    required this.element,
    required this.isSelected,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final el = element;

    BoxDecoration decoration;
    if (el.type == CvElementType.text) {
      decoration = const BoxDecoration();
    } else if (el.fillGradient != null) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: el.fillGradient!.colors,
          begin: el.fillGradient!.begin as Alignment,
          end: el.fillGradient!.end as Alignment,
        ),
        borderRadius: BorderRadius.circular(el.border.radius),
        border: el.border.width > 0
            ? Border.all(color: el.border.color, width: el.border.width)
            : null,
      );
    } else {
      decoration = BoxDecoration(
        color: el.fillColor,
        borderRadius: el.type == CvElementType.circle
            ? BorderRadius.circular(el.w / 2)
            : BorderRadius.circular(el.border.radius),
        border: el.border.width > 0
            ? Border.all(color: el.border.color, width: el.border.width)
            : null,
      );
    }

    Widget content;
    if (el.type == CvElementType.text && el.text != null) {
      if (el.textGradient != null) {
        content = ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: el.textGradient!.colors,
            begin: el.textGradient!.begin as Alignment,
            end: el.textGradient!.end as Alignment,
          ).createShader(r),
          child: Text(
            el.text!,
            textAlign: el.textAlign,
            style: GoogleFonts.syne(
              color: Colors.white,
              fontSize: el.fontSize,
              fontWeight: el.fontWeight,
              fontStyle: el.fontStyle,
            ),
          ),
        );
      } else {
        content = Text(
          el.text!,
          textAlign: el.textAlign,
          style: GoogleFonts.syne(
            color: el.textColor,
            fontSize: el.fontSize,
            fontWeight: el.fontWeight,
            fontStyle: el.fontStyle,
          ),
        );
      }
    } else if (el.type == CvElementType.image) {
      content = Container(
        decoration: decoration,
        child: const Center(child: Icon(Icons.image_rounded, color: Colors.grey, size: 32)),
      );
      decoration = const BoxDecoration();
    } else {
      content = Container(decoration: decoration);
      decoration = const BoxDecoration();
    }

    return Positioned(
      left: el.x,
      top: el.y,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: el.type == CvElementType.text ? onDoubleTap : null,
        onPanStart: (d) => onDragStart(d.localPosition),
        onPanUpdate: (d) => onDragUpdate(d.globalPosition),
        onPanEnd: (_) => onDragEnd(),
        child: Opacity(
          opacity: el.opacity,
          child: Transform.rotate(
            angle: el.rotation * math.pi / 180,
            child: SizedBox(
              width: el.w,
              height: el.h,
              child: Stack(
                children: [
                  // Conteúdo
                  Positioned.fill(child: content),

                  // Borda de selecção
                  if (isSelected)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFE0185E), width: 1.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                  // Handle de resize (canto inferior direito)
                  if (isSelected && !el.locked)
                    Positioned(
                      right: 0, bottom: 0,
                      child: GestureDetector(
                        onPanStart: (d) => onResizeStart(d.localPosition),
                        onPanUpdate: (d) => onResizeUpdate(d.globalPosition),
                        onPanEnd: (_) => onResizeEnd(),
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0185E),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(4)),
                          ),
                          child: const Icon(Icons.open_in_full_rounded,
                              size: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// TOOLBAR DE INSERÇÃO
// ════════════════════════════════════════════════════════
class _InsertToolbar extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final Color textSec;
  final Color border;
  final void Function(CvElementType) onAdd;
  final VoidCallback onBoardSize;
  final VoidCallback onBackground;

  const _InsertToolbar({
    required this.isDark,
    required this.accent,
    required this.textSec,
    required this.border,
    required this.onAdd,
    required this.onBoardSize,
    required this.onBackground,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Container(
      height: 48,
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(children: [
          _TBtn(icon: Icons.title_rounded, label: 'Texto',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.text)),
          _TBtn(icon: Icons.crop_square_rounded, label: 'Rect',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.rect)),
          _TBtn(icon: Icons.circle_outlined, label: 'Círculo',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.circle)),
          _TBtn(icon: Icons.horizontal_rule_rounded, label: 'Linha',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.line)),
          _TBtn(icon: Icons.remove_rounded, label: 'Divider',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.divider)),
          _TBtn(icon: Icons.image_rounded, label: 'Imagem',
              isDark: isDark, accent: accent, bg: bg,
              onTap: () => onAdd(CvElementType.image)),
          Container(width: 1, height: 24, color: border, margin: const EdgeInsets.symmetric(horizontal: 6)),
          _TBtn(icon: Icons.gradient_rounded, label: 'Fundo',
              isDark: isDark, accent: accent, bg: bg,
              onTap: onBackground),
          _TBtn(icon: Icons.photo_size_select_large_rounded, label: 'Tamanho',
              isDark: isDark, accent: accent, bg: bg,
              onTap: onBoardSize),
        ]),
      ),
    );
  }
}

class _TBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color accent;
  final Color bg;
  final VoidCallback onTap;

  const _TBtn({
    required this.icon, required this.label,
    required this.isDark, required this.accent,
    required this.bg, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.syne(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C))),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// PAINEL DE PROPRIEDADES
// ════════════════════════════════════════════════════════
class _PropertiesPanel extends StatefulWidget {
  final CvElement element;
  final bool isDark;
  final Color accent, textPri, textSec, border;
  final void Function(CvElement) onUpdate;
  final VoidCallback onDelete, onDuplicate, onLockToggle;
  final VoidCallback onBringForward, onSendBackward;

  const _PropertiesPanel({
    required this.element,
    required this.isDark,
    required this.accent,
    required this.textPri,
    required this.textSec,
    required this.border,
    required this.onUpdate,
    required this.onDelete,
    required this.onDuplicate,
    required this.onLockToggle,
    required this.onBringForward,
    required this.onSendBackward,
  });

  @override
  State<_PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<_PropertiesPanel> {
  String _tab = 'pos'; // pos, text, fill, border, fx

  @override
  Widget build(BuildContext context) {
    final el = widget.element;
    final bg = widget.isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final pill = widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);

    return Container(
      color: bg,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: 0.5, color: widget.border),

        // Acções rápidas
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            _ActBtn(Icons.delete_outline_rounded, 'Apagar', Colors.red, widget.onDelete),
            _ActBtn(Icons.content_copy_rounded, 'Duplicar', widget.accent, widget.onDuplicate),
            _ActBtn(Icons.flip_to_front_rounded, 'Frente', widget.textSec, widget.onBringForward),
            _ActBtn(Icons.flip_to_back_rounded, 'Fundo', widget.textSec, widget.onSendBackward),
            _ActBtn(
              el.locked ? Icons.lock_rounded : Icons.lock_open_rounded,
              el.locked ? 'Bloq.' : 'Desbl.',
              widget.textSec,
              widget.onLockToggle,
            ),
          ]),
        ),

        // Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            _PropTab('pos',   'Posição', _tab, widget.accent, () => setState(() => _tab = 'pos')),
            if (el.type == CvElementType.text)
              _PropTab('text', 'Texto', _tab, widget.accent, () => setState(() => _tab = 'text')),
            if (el.type != CvElementType.text)
              _PropTab('fill', 'Preench.', _tab, widget.accent, () => setState(() => _tab = 'fill')),
            _PropTab('border', 'Borda', _tab, widget.accent, () => setState(() => _tab = 'border')),
            _PropTab('fx', 'Efeitos', _tab, widget.accent, () => setState(() => _tab = 'fx')),
          ]),
        ),

        const SizedBox(height: 4),

        // Conteúdo da tab
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(children: [
            if (_tab == 'pos') _PosTab(el: el, isDark: widget.isDark, pill: pill,
                textSec: widget.textSec, onUpdate: widget.onUpdate),
            if (_tab == 'text') _TextTab(el: el, isDark: widget.isDark, pill: pill,
                accent: widget.accent, textSec: widget.textSec, onUpdate: widget.onUpdate),
            if (_tab == 'fill') _FillTab(el: el, isDark: widget.isDark, pill: pill,
                accent: widget.accent, textSec: widget.textSec, onUpdate: widget.onUpdate),
            if (_tab == 'border') _BorderTab(el: el, isDark: widget.isDark, pill: pill,
                accent: widget.accent, textSec: widget.textSec, onUpdate: widget.onUpdate),
            if (_tab == 'fx') _FxTab(el: el, isDark: widget.isDark, pill: pill,
                textSec: widget.textSec, onUpdate: widget.onUpdate),
          ]),
        ),
      ]),
    );
  }
}

// ── Tab Posição / Dimensões ──────────────────────────────
class _PosTab extends StatelessWidget {
  final CvElement el;
  final bool isDark;
  final Color pill, textSec;
  final void Function(CvElement) onUpdate;
  const _PosTab({required this.el, required this.isDark, required this.pill,
      required this.textSec, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _NumField('X', el.x, isDark, pill, textSec, (v) { el.x = v; onUpdate(el); }),
      const SizedBox(width: 8),
      _NumField('Y', el.y, isDark, pill, textSec, (v) { el.y = v; onUpdate(el); }),
      const SizedBox(width: 8),
      _NumField('L', el.w, isDark, pill, textSec, (v) { el.w = v; onUpdate(el); }),
      const SizedBox(width: 8),
      _NumField('A', el.h, isDark, pill, textSec, (v) { el.h = v; onUpdate(el); }),
      const SizedBox(width: 8),
      _NumField('°', el.rotation, isDark, pill, textSec, (v) { el.rotation = v; onUpdate(el); }),
    ]);
  }
}

// ── Tab Texto ──────────────────────────────────────────
class _TextTab extends StatelessWidget {
  final CvElement el;
  final bool isDark;
  final Color pill, accent, textSec;
  final void Function(CvElement) onUpdate;
  const _TextTab({required this.el, required this.isDark, required this.pill,
      required this.accent, required this.textSec, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _NumField('px', el.fontSize, isDark, pill, textSec, (v) { el.fontSize = v; onUpdate(el); }),
        const SizedBox(width: 8),
        _ToggleBtn('B', el.fontWeight == FontWeight.w700, isDark, accent, () {
          el.fontWeight = el.fontWeight == FontWeight.w700 ? FontWeight.w400 : FontWeight.w700;
          onUpdate(el);
        }),
        const SizedBox(width: 4),
        _ToggleBtn('I', el.fontStyle == FontStyle.italic, isDark, accent, () {
          el.fontStyle = el.fontStyle == FontStyle.italic ? FontStyle.normal : FontStyle.italic;
          onUpdate(el);
        }),
      ]),
      const SizedBox(height: 10),
      Text('Gradiente de texto', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _Gradients.all.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return GestureDetector(
                onTap: () { el.textGradient = null; el.textColor = Colors.black; onUpdate(el); },
                child: Container(
                  width: 36, height: 36, margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(8),
                    border: el.textGradient == null ? Border.all(color: accent, width: 2) : null,
                  ),
                  child: const Icon(Icons.block_rounded, size: 16, color: Colors.grey),
                ),
              );
            }
            final g = _Gradients.all[i - 1];
            final isSelected = el.textGradient == g;
            return GestureDetector(
              onTap: () { el.textGradient = g; onUpdate(el); },
              child: Container(
                width: 36, height: 36, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: g.colors,
                      begin: g.begin as Alignment, end: g.end as Alignment),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? Border.all(color: accent, width: 2) : null,
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ── Tab Preenchimento ───────────────────────────────────
class _FillTab extends StatelessWidget {
  final CvElement el;
  final bool isDark;
  final Color pill, accent, textSec;
  final void Function(CvElement) onUpdate;
  const _FillTab({required this.el, required this.isDark, required this.pill,
      required this.accent, required this.textSec, required this.onUpdate});

  static const _solidColors = [
    Color(0xFF1D4ED8), Color(0xFFE0185E), Color(0xFF16A34A),
    Color(0xFFEA580C), Color(0xFF7C3AED), Color(0xFF0A84FF),
    Color(0xFF111111), Color(0xFFFFFFFF), Color(0xFFF2F2F7),
    Color(0xFFFF9F0A), Color(0xFF30D158), Color(0xFFBF5AF2),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Cor sólida', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _solidColors.length,
          itemBuilder: (_, i) {
            final c = _solidColors[i];
            final isSel = el.fillColor == c && el.fillGradient == null;
            return GestureDetector(
              onTap: () { el.fillColor = c; el.fillGradient = null; onUpdate(el); },
              child: Container(
                width: 32, height: 32, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSel ? Border.all(color: accent, width: 2.5) :
                    Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      Text('Gradiente', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _Gradients.all.length,
          itemBuilder: (_, i) {
            final g = _Gradients.all[i];
            final isSel = el.fillGradient == g;
            return GestureDetector(
              onTap: () { el.fillGradient = g; onUpdate(el); },
              child: Container(
                width: 64, height: 36, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: g.colors,
                      begin: g.begin as Alignment, end: g.end as Alignment),
                  borderRadius: BorderRadius.circular(8),
                  border: isSel ? Border.all(color: accent, width: 2) : null,
                ),
                child: Center(child: Text(_Gradients.names[i],
                    style: GoogleFonts.syne(fontSize: 9, color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [const Shadow(color: Colors.black45, blurRadius: 4)]))),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Text('Opacidade', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
        Expanded(child: Slider(
          value: el.opacity,
          min: 0.05, max: 1.0,
          activeColor: accent,
          onChanged: (v) { el.opacity = v; onUpdate(el); },
        )),
        Text('${(el.opacity * 100).round()}%',
            style: GoogleFonts.syne(color: textSec, fontSize: 11)),
      ]),
    ]);
  }
}

// ── Tab Borda ───────────────────────────────────────────
class _BorderTab extends StatelessWidget {
  final CvElement el;
  final bool isDark;
  final Color pill, accent, textSec;
  final void Function(CvElement) onUpdate;
  const _BorderTab({required this.el, required this.isDark, required this.pill,
      required this.accent, required this.textSec, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Espessura', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
        Expanded(child: Slider(
          value: el.border.width.clamp(0.0, 20.0),
          min: 0, max: 20,
          activeColor: accent,
          onChanged: (v) { el.border = el.border.copyWith(width: v); onUpdate(el); },
        )),
        Text('${el.border.width.round()}',
            style: GoogleFonts.syne(color: textSec, fontSize: 11)),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        Text('Raio', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
        Expanded(child: Slider(
          value: el.border.radius.clamp(0.0, 100.0),
          min: 0, max: 100,
          activeColor: accent,
          onChanged: (v) { el.border = el.border.copyWith(radius: v); onUpdate(el); },
        )),
        Text('${el.border.radius.round()}',
            style: GoogleFonts.syne(color: textSec, fontSize: 11)),
      ]),
      const SizedBox(height: 8),
      Text('Cor da borda', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        Colors.black, Colors.white, const Color(0xFFE0185E),
        const Color(0xFF1D4ED8), const Color(0xFF16A34A),
        const Color(0xFFEA580C), const Color(0xFF7C3AED),
        Colors.grey,
      ].map((c) => GestureDetector(
        onTap: () { el.border = el.border.copyWith(color: c); onUpdate(el); },
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: c, shape: BoxShape.circle,
            border: el.border.color == c ? Border.all(color: accent, width: 2.5) :
              Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
        ),
      )).toList()),
    ]);
  }
}

// ── Tab Efeitos ─────────────────────────────────────────
class _FxTab extends StatelessWidget {
  final CvElement el;
  final bool isDark;
  final Color pill, textSec;
  final void Function(CvElement) onUpdate;
  const _FxTab({required this.el, required this.isDark, required this.pill,
      required this.textSec, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Opacidade', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
        Expanded(child: Slider(
          value: el.opacity,
          min: 0.05, max: 1.0,
          activeColor: const Color(0xFFE0185E),
          onChanged: (v) { el.opacity = v; onUpdate(el); },
        )),
        Text('${(el.opacity * 100).round()}%',
            style: GoogleFonts.syne(color: textSec, fontSize: 11)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Text('Rotação', style: GoogleFonts.syne(color: textSec, fontSize: 11, fontWeight: FontWeight.w700)),
        Expanded(child: Slider(
          value: el.rotation.clamp(-180.0, 180.0),
          min: -180, max: 180,
          activeColor: const Color(0xFFE0185E),
          onChanged: (v) { el.rotation = v; onUpdate(el); },
        )),
        Text('${el.rotation.round()}°',
            style: GoogleFonts.syne(color: textSec, fontSize: 11)),
      ]),
    ]);
  }
}

// ════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════
class _ActBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.syne(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _PropTab extends StatelessWidget {
  final String id, label, active;
  final Color accent;
  final VoidCallback onTap;
  const _PropTab(this.id, this.label, this.active, this.accent, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = id == active;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: isActive ? accent : Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Text(label,
            style: GoogleFonts.syne(
                color: isActive ? accent : Colors.grey,
                fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final String label;
  final double value;
  final bool isDark;
  final Color pill, textSec;
  final void Function(double) onChanged;
  const _NumField(this.label, this.value, this.isDark, this.pill, this.textSec, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: value.round().toString());
    final color = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF111111);
    return Expanded(
      child: Column(children: [
        Text(label, style: GoogleFonts.syne(color: textSec, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Container(
          height: 34,
          decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(color: color, fontSize: 12, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
                border: InputBorder.none, isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8)),
            onSubmitted: (v) => onChanged(double.tryParse(v) ?? value),
          ),
        ),
      ]),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;
  const _ToggleBtn(this.label, this.active, this.isDark, this.accent, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.15) : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(8),
          border: active ? Border.all(color: accent, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.syne(
                color: active ? accent : (isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3A3A3C)),
                fontSize: 14, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// BOTTOM SHEETS
// ════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isDark;
  const _ExportSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final accent  = isDark ? const Color(0xFFFF6B9D) : const Color(0xFFE0185E);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Container(width: 36, height: 4,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Text('Exportar', style: GoogleFonts.syne(
          color: textPri, fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 8),
      ListTile(
        leading: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade400),
        title: Text('PDF', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: textPri)),
        subtitle: Text('Todas as páginas', style: GoogleFonts.syne(fontSize: 12, color: Colors.grey)),
        onTap: () { Navigator.pop(context); },
      ),
      ListTile(
        leading: Icon(Icons.image_rounded, color: Colors.blue.shade400),
        title: Text('PNG', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: textPri)),
        subtitle: Text('Alta resolução', style: GoogleFonts.syne(fontSize: 12, color: Colors.grey)),
        onTap: () { Navigator.pop(context); },
      ),
      ListTile(
        leading: Icon(Icons.photo_rounded, color: Colors.orange.shade400),
        title: Text('JPG', style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: textPri)),
        subtitle: Text('Comprimido', style: GoogleFonts.syne(fontSize: 12, color: Colors.grey)),
        onTap: () { Navigator.pop(context); },
      ),
      const SizedBox(height: 20),
    ]);
  }
}

class _BoardSizeSheet extends StatefulWidget {
  final CvBoard board;
  final bool isDark;
  final void Function(double w, double h) onApply;
  const _BoardSizeSheet({required this.board, required this.isDark, required this.onApply});

  @override
  State<_BoardSizeSheet> createState() => _BoardSizeSheetState();
}

class _BoardSizeSheetState extends State<_BoardSizeSheet> {
  late TextEditingController _wCtrl, _hCtrl;
  final _presets = [
    {'name': 'A4 Retrato', 'w': 794.0, 'h': 1123.0},
    {'name': 'A4 Paisagem', 'w': 1123.0, 'h': 794.0},
    {'name': 'A3', 'w': 1123.0, 'h': 1587.0},
    {'name': 'Instagram Post', 'w': 1080.0, 'h': 1080.0},
    {'name': 'Instagram Story', 'w': 1080.0, 'h': 1920.0},
    {'name': 'LinkedIn Banner', 'w': 1584.0, 'h': 396.0},
    {'name': 'CV Padrão', 'w': 794.0, 'h': 1123.0},
    {'name': 'Carta EUA', 'w': 816.0, 'h': 1056.0},
  ];

  @override
  void initState() {
    super.initState();
    _wCtrl = TextEditingController(text: widget.board.width.round().toString());
    _hCtrl = TextEditingController(text: widget.board.height.round().toString());
  }

  @override
  Widget build(BuildContext context) {
    final textPri = widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final border  = widget.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final pill    = widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final accent  = widget.isDark ? const Color(0xFFFF6B9D) : const Color(0xFFE0185E);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Text('Dimensões do quadro',
            style: GoogleFonts.syne(color: textPri, fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),

        // Presets
        SizedBox(height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _presets.length,
            itemBuilder: (_, i) {
              final p = _presets[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _wCtrl.text = (p['w'] as double).round().toString();
                    _hCtrl.text = (p['h'] as double).round().toString();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: pill,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: border),
                  ),
                  child: Center(child: Text(p['name'] as String,
                      style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: textPri))),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _SizeField('Largura (px)', _wCtrl, widget.isDark, pill, textPri)),
            const SizedBox(width: 12),
            Expanded(child: _SizeField('Altura (px)', _hCtrl, widget.isDark, pill, textPri)),
          ]),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final w = double.tryParse(_wCtrl.text) ?? widget.board.width;
                final h = double.tryParse(_hCtrl.text) ?? widget.board.height;
                widget.onApply(w, h);
              },
              child: Text('Aplicar', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _SizeField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isDark;
  final Color pill, textPri;
  const _SizeField(this.label, this.ctrl, this.isDark, this.pill, this.textPri);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.syne(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Container(
        height: 42,
        decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.syne(color: textPri, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
        ),
      ),
    ]);
  }
}

class _BackgroundSheet extends StatelessWidget {
  final CvBoard board;
  final bool isDark;
  final void Function(Color, CvGradient?) onApply;
  const _BackgroundSheet({required this.board, required this.isDark, required this.onApply});

  static const _colors = [
    Colors.white, Color(0xFFF5F5F7), Color(0xFF111111),
    Color(0xFF1C1C1E), Color(0xFFE8F0FE), Color(0xFFFFF3E0),
    Color(0xFFE8F5E9), Color(0xFFFCE4EC), Color(0xFFEDE7F6),
  ];

  @override
  Widget build(BuildContext context) {
    final textPri = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 12),
      Text('Fundo do quadro',
          style: GoogleFonts.syne(color: textPri, fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cor sólida', style: GoogleFonts.syne(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: _colors.map((c) =>
            GestureDetector(
              onTap: () => onApply(c, null),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
                ),
              ),
            )
          ).toList()),
          const SizedBox(height: 16),
          Text('Gradiente', style: GoogleFonts.syne(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: List.generate(_Gradients.all.length, (i) {
            final g = _Gradients.all[i];
            return GestureDetector(
              onTap: () => onApply(Colors.white, g),
              child: Container(
                width: 80, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: g.colors,
                      begin: g.begin as Alignment, end: g.end as Alignment),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(_Gradients.names[i],
                    style: GoogleFonts.syne(fontSize: 10, color: Colors.white,
                        fontWeight: FontWeight.w700))),
              ),
            );
          })),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}
