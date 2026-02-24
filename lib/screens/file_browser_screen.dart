import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../widgets/theme.dart';
import 'editor_screen.dart';
import 'pdf_viewer_screen.dart';

// ── Design tokens ─────────────────────────────────────
const _kPill  = 999.0;
const _kCard  = 14.0;
const _kModal = 10.0;

// ── SVGs ──────────────────────────────────────────────
const _backSvg   = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';
const _searchSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/></svg>';
const _folderSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22,4H14.414L12.707,2.293A1,1,0,0,0,12,2H2A2,2,0,0,0,0,4V20a2,2,0,0,0,2,2H22a2,2,0,0,0,2-2V6A2,2,0,0,0,22,4ZM2,4H11.586l1.707,1.707A1,1,0,0,0,14,6H22V20H2Z"/></svg>';
const _fileSvg   = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/></svg>';

Widget _svgW(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ── Extensions ────────────────────────────────────────
const _supportedExts = ['pdf', 'docx', 'doc', 'txt', 'rtf', 'md'];

Color _extColor(String ext, Color acc) {
  switch (ext) {
    case 'pdf':        return const Color(0xFFDC2626);
    case 'docx':
    case 'doc':        return const Color(0xFF2563EB);
    case 'txt':
    case 'md':         return const Color(0xFF16A34A);
    case 'rtf':        return const Color(0xFF9333EA);
    default:           return acc;
  }
}

// ── Sort modes ────────────────────────────────────────
enum _Sort { name, nameDesc, date, dateDesc, size, sizeDesc, type }
const _sortLabels = {
  _Sort.name:     'Nome (A→Z)',
  _Sort.nameDesc: 'Nome (Z→A)',
  _Sort.date:     'Data (mais recente)',
  _Sort.dateDesc: 'Data (mais antigo)',
  _Sort.size:     'Tamanho (maior)',
  _Sort.sizeDesc: 'Tamanho (menor)',
  _Sort.type:     'Tipo de ficheiro',
};

// ── Model ─────────────────────────────────────────────
class _FsItem {
  final String name, path;
  final bool isDir;
  final int size;
  final DateTime modified;

  _FsItem({required this.name, required this.path, required this.isDir, this.size = 0, required this.modified});

  String get ext => isDir ? '' : p.extension(name).replaceFirst('.', '').toLowerCase();
  bool get isSupported => _supportedExts.contains(ext);
}

// ── Relative date helper ──────────────────────────────
String _relDate(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays == 0) return 'hoje';
  if (diff.inDays == 1) return 'ontem';
  if (diff.inDays < 7)  return '${diff.inDays}d atrás';
  return DateFormat('d MMM yyyy', 'pt').format(d);
}

// ══════════════════════════════════════════════════════
class FileBrowserScreen extends StatefulWidget {
  final void Function()? onDocImported;
  const FileBrowserScreen({super.key, this.onDocImported});
  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  bool _loading = true;
  bool _permissionDenied = false;
  String _currentPath = '';
  List<_FsItem> _items = [];
  List<_FsItem> _searchResults = [];
  bool _searching = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final _pathHistory = <String>[];

  // Options
  _Sort _sort = _Sort.name;
  bool _gridView = false;
  bool _showHidden = false;
  bool _foldersOnly = false;
  String? _filterExt;

  // Multi-select
  bool _multiSelect = false;
  final _selected = <String>{};

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _init();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() {});

  // ── Init / permissions ──────────────────────────────
  Future<void> _init() async {
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
    } else {
      status = PermissionStatus.granted;
    }
    if (!status.isGranted) {
      if (mounted) setState(() { _loading = false; _permissionDenied = true; });
      return;
    }
    final root = Platform.isAndroid
        ? '/storage/emulated/0'
        : (await getApplicationDocumentsDirectory()).path;
    _currentPath = root;
    await _loadDir(root);
  }

  // ── Load directory ───────────────────────────────────
  Future<void> _loadDir(String dir) async {
    if (mounted) setState(() => _loading = true);
    try {
      final d = Directory(dir);
      if (!await d.exists()) { if (mounted) setState(() => _loading = false); return; }

      final entities = await d.list(followLinks: false).toList();
      final items = <_FsItem>[];

      for (final e in entities) {
        try {
          final name = p.basename(e.path);
          if (!_showHidden && name.startsWith('.')) continue;
          final stat = await e.stat();

          if (e is Directory) {
            items.add(_FsItem(name: name, path: e.path, isDir: true, modified: stat.modified));
          } else if (e is File && !_foldersOnly) {
            final ext = p.extension(name).replaceFirst('.', '').toLowerCase();
            if (_supportedExts.contains(ext) && (_filterExt == null || _filterExt == ext)) {
              items.add(_FsItem(name: name, path: e.path, isDir: false, size: stat.size, modified: stat.modified));
            }
          }
        } catch (_) {}
      }

      _doSort(items);
      if (mounted) setState(() { _items = items; _currentPath = dir; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Sort ─────────────────────────────────────────────
  void _doSort(List<_FsItem> items) {
    items.sort((a, b) {
      if (_sort != _Sort.type) {
        if (a.isDir && !b.isDir) return -1;
        if (!a.isDir && b.isDir) return 1;
      }
      switch (_sort) {
        case _Sort.name:     return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _Sort.nameDesc: return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _Sort.date:     return b.modified.compareTo(a.modified);
        case _Sort.dateDesc: return a.modified.compareTo(b.modified);
        case _Sort.size:     return b.size.compareTo(a.size);
        case _Sort.sizeDesc: return a.size.compareTo(b.size);
        case _Sort.type:     return a.ext.compareTo(b.ext);
      }
    });
  }

  // ── Search ───────────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() { _searching = false; _searchResults = []; _searchQuery = ''; });
      return;
    }
    setState(() { _searching = true; _searchQuery = query; _loading = true; });
    final root = Platform.isAndroid ? '/storage/emulated/0' : _currentPath;
    final results = <_FsItem>[];
    await _searchDir(Directory(root), query.toLowerCase(), results);
    _doSort(results);
    if (mounted) setState(() { _searchResults = results; _loading = false; });
  }

  Future<void> _searchDir(Directory dir, String q, List<_FsItem> res) async {
    try {
      for (final e in await dir.list(followLinks: false).toList()) {
        final name = p.basename(e.path);
        if (!_showHidden && name.startsWith('.')) continue;
        if (e is File) {
          final ext = p.extension(name).replaceFirst('.', '').toLowerCase();
          if (_supportedExts.contains(ext) && name.toLowerCase().contains(q) &&
              (_filterExt == null || _filterExt == ext)) {
            final stat = await e.stat();
            res.add(_FsItem(name: name, path: e.path, isDir: false, size: stat.size, modified: stat.modified));
            if (res.length >= 150) return;
          }
        } else if (e is Directory) {
          await _searchDir(e, q, res);
          if (res.length >= 150) return;
        }
      }
    } catch (_) {}
  }

  // ── Navigation ───────────────────────────────────────
  void _navigate(String path) {
    _multiSelect = false; _selected.clear();
    _pathHistory.add(_currentPath);
    _loadDir(path);
  }

  void _handleBack() {
    if (_multiSelect) { setState(() { _multiSelect = false; _selected.clear(); }); return; }
    if (_searching) { _searchCtrl.clear(); setState(() { _searching = false; _searchResults = []; _searchQuery = ''; }); return; }
    if (_pathHistory.isNotEmpty) { _loadDir(_pathHistory.removeLast()); return; }
    Navigator.of(context).pop();
  }

  // ── Open file ────────────────────────────────────────
  Future<void> _openFile(_FsItem item) async {
    if (_multiSelect) {
      setState(() { _selected.contains(item.path) ? _selected.remove(item.path) : _selected.add(item.path); });
      return;
    }
    setState(() => _loading = true);
    try {
      final bytes = await File(item.path).readAsBytes();
      final ext = item.ext;
      if (!mounted) return;
      setState(() => _loading = false);

      if (ext == 'pdf') {
        await Navigator.push(context, MaterialPageRoute(
            builder: (_) => PdfViewerScreen(path: item.path, title: item.name)));
      } else if (ext == 'txt' || ext == 'md' || ext == 'rtf') {
        final text = utf8.decode(bytes, allowMalformed: true);
        final html = '<p>${text.replaceAll('\n\n', '</p><p>').replaceAll('\n', '<br/>')}</p>';
        await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(
          importHtml: html, importTitle: item.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        )));
        widget.onDocImported?.call();
        if (mounted) Navigator.of(context).pop();
      } else if (ext == 'docx' || ext == 'doc') {
        final b64 = base64Encode(bytes);
        await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(
          importDocxBase64: b64, importTitle: item.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
        )));
        widget.onDocImported?.call();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Size formatter ───────────────────────────────────
  String _size(int b) {
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    return '${(b / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  String get _relPath => _currentPath.replaceFirst('/storage/emulated/0', 'Armazenamento');

  // ── File info sheet ──────────────────────────────────
  void _showInfo(_FsItem item) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);
    final col = item.isDir ? acc : _extColor(item.ext, acc);

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 3.5, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill)))),
          Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: col.withOpacity(.12), shape: BoxShape.circle),
                child: Center(child: _svgW(item.isDir ? _folderSvg : _fileSvg, col, s: 24))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: GoogleFonts.roboto(color: tp, fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(item.isDir ? 'Pasta' : item.ext.toUpperCase(),
                  style: GoogleFonts.roboto(color: col, fontSize: 11, fontWeight: FontWeight.w800)),
            ])),
          ]),
          const SizedBox(height: 20),
          _iRow('Caminho completo', item.path, tp, ts, div),
          if (!item.isDir) _iRow('Tamanho', _size(item.size), tp, ts, div),
          _iRow('Modificado em', DateFormat('d MMMM yyyy, HH:mm', 'pt').format(item.modified), tp, ts, div),
          const SizedBox(height: 20),
          if (!item.isDir) GestureDetector(
            onTap: () { Navigator.pop(context); _openFile(item); },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Abrir ficheiro', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _iRow(String label, String value, Color tp, Color ts, Color div) => Column(children: [
    Padding(padding: const EdgeInsets.symmetric(vertical: 11), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 13))),
        Expanded(child: Text(value, style: GoogleFonts.roboto(color: tp, fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 3, overflow: TextOverflow.ellipsis)),
      ],
    )),
    Container(height: 0.5, color: div),
  ]);

  // ── Options / sort sheet ─────────────────────────────
  void _showOptions() {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = accColor(isDark);

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 3.5, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill)))),

            // ── Ordenação ──
            _sectionLabel('ORDENAÇÃO', ts),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _Sort.values.map((s) {
              final sel = _sort == s;
              return GestureDetector(
                onTap: () {
                  setS(() {});
                  setState(() => _sort = s);
                  if (_searching) { _doSort(_searchResults); setState(() {}); }
                  else _loadDir(_currentPath);
                  Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? acc.withOpacity(.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(_kPill),
                    border: Border.all(color: sel ? acc : div, width: sel ? 1.5 : 1),
                  ),
                  child: Text(_sortLabels[s]!, style: GoogleFonts.roboto(
                      color: sel ? acc : ts, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList()),

            const SizedBox(height: 20),
            Container(height: 0.5, color: div),
            const SizedBox(height: 16),

            // ── Visualização ──
            _sectionLabel('VISUALIZAÇÃO', ts),
            const SizedBox(height: 12),
            _optSwitch('Vista em grelha', _gridView, tp, acc, (v) { setS(() {}); setState(() => _gridView = v); }),
            _optSwitch('Mostrar ficheiros ocultos', _showHidden, tp, acc, (v) { setS(() {}); setState(() => _showHidden = v); _loadDir(_currentPath); }),
            _optSwitch('Apenas pastas', _foldersOnly, tp, acc, (v) { setS(() {}); setState(() => _foldersOnly = v); _loadDir(_currentPath); }),

            const SizedBox(height: 16),
            Container(height: 0.5, color: div),
            const SizedBox(height: 16),

            // ── Filtro por tipo ──
            _sectionLabel('FILTRAR POR TIPO', ts),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [null, ..._supportedExts].map((ext) {
              final sel = _filterExt == ext;
              return GestureDetector(
                onTap: () {
                  setS(() {}); setState(() => _filterExt = ext);
                  _loadDir(_currentPath); Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? acc.withOpacity(.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(_kPill),
                    border: Border.all(color: sel ? acc : div, width: sel ? 1.5 : 1),
                  ),
                  child: Text(ext?.toUpperCase() ?? 'Todos', style: GoogleFonts.roboto(
                      color: sel ? acc : ts, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList()),
          ]),
        ),
      )),
    );
  }

  Widget _sectionLabel(String t, Color ts) =>
    Text(t, style: GoogleFonts.roboto(color: ts, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3));

  Widget _optSwitch(String label, bool value, Color tp, Color acc, ValueChanged<bool> onChange) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
      Expanded(child: Text(label, style: GoogleFonts.roboto(color: tp, fontSize: 14, fontWeight: FontWeight.w500))),
      _AriaSwitch(value: value, onChanged: onChange, acc: acc),
    ]));

  // ════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg   = isDark ? AppColors.darkBackground   : AppColors.background;
    final tp   = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div  = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc  = accColor(isDark);
    final pill = isDark ? const Color(0xFF363636)     : const Color(0xFFF2F2F7);
    final btnBg= isDark ? const Color(0xFF2E2E2E)     : const Color(0xFFF0F0F0);

    final display = _searching ? _searchResults : _items;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent,

        // ── Back — idêntico ao da tela de atividades ──
        leading: GestureDetector(
          onTap: _handleBack,
          child: Center(child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: btnBg, shape: BoxShape.circle),
            child: Center(child: _svgW(_backSvg, _multiSelect ? acc : tp, s: 16)),
          )),
        ),

        title: _multiSelect
            ? Text('${_selected.length} selecionado${_selected.length != 1 ? 's' : ''}',
                style: GoogleFonts.roboto(color: acc, fontSize: 17, fontWeight: FontWeight.w800))
            : Text('Ficheiros',
                style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800)),

        actions: [
          // Grid/list toggle
          GestureDetector(
            onTap: () => setState(() => _gridView = !_gridView),
            child: Container(
              margin: const EdgeInsets.only(right: 6), width: 36, height: 36,
              decoration: BoxDecoration(color: btnBg, shape: BoxShape.circle),
              child: Icon(_gridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: ts, size: 18),
            ),
          ),
          // Options/sort
          GestureDetector(
            onTap: _showOptions,
            child: Container(
              margin: const EdgeInsets.only(right: 14), width: 36, height: 36,
              decoration: BoxDecoration(
                color: _sort != _Sort.name || _filterExt != null || _foldersOnly || _showHidden
                    ? acc : btnBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.tune_rounded,
                  color: _sort != _Sort.name || _filterExt != null || _foldersOnly || _showHidden
                      ? Colors.white : ts,
                  size: 18),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: div),
        ),
      ),

      body: Column(children: [
        // ── Search ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            height: 42,
            decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(_kPill)),
            child: Row(children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _svgW(_searchSvg, ts, s: 15)),
              Expanded(child: TextField(
                controller: _searchCtrl, onChanged: _search,
                style: GoogleFonts.roboto(color: tp, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Pesquisar ficheiros…',
                  hintStyle: GoogleFonts.roboto(color: ts, fontSize: 14),
                  border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                  isDense: true, contentPadding: EdgeInsets.zero,
                ),
              )),
              if (_searching) GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() { _searching = false; _searchResults = []; _searchQuery = ''; }); },
                child: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(Icons.close_rounded, color: ts, size: 18)),
              ),
            ]),
          ),
        ),

        // ── Breadcrumb + filters ─────────────────────────
        if (!_searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(children: [
              _svgW(_folderSvg, ts, s: 12),
              const SizedBox(width: 5),
              Expanded(child: Text(_relPath, style: GoogleFonts.roboto(color: ts, fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              // Active filter badge
              if (_filterExt != null)
                GestureDetector(
                  onTap: () { setState(() => _filterExt = null); _loadDir(_currentPath); },
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: acc.withOpacity(.12), borderRadius: BorderRadius.circular(_kPill),
                      border: Border.all(color: acc.withOpacity(.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(_filterExt!.toUpperCase(), style: GoogleFonts.roboto(color: acc, fontSize: 10, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.close_rounded, color: acc, size: 11),
                    ]),
                  ),
                ),
              // Sort indicator
              if (_sort != _Sort.name)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ts.withOpacity(.08), borderRadius: BorderRadius.circular(_kPill),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.sort_rounded, size: 10, color: ts),
                    const SizedBox(width: 3),
                    Text(_sortLabels[_sort]!.split(' ').first, style: GoogleFonts.roboto(color: ts, fontSize: 10)),
                  ]),
                ),
            ]),
          ),

        // ── Multi-select bar ─────────────────────────────
        if (_multiSelect)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: acc.withOpacity(.08), borderRadius: BorderRadius.circular(_kCard),
              border: Border.all(color: acc.withOpacity(.2)),
            ),
            child: Row(children: [
              Text('${_selected.length} selecionado(s)',
                  style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() { _selected.clear(); _selected.addAll(display.where((i) => !i.isDir).map((i) => i.path)); }),
                child: Text('Selecionar tudo', style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() { _multiSelect = false; _selected.clear(); }),
                child: Text('Cancelar', style: GoogleFonts.roboto(color: ts, fontSize: 12)),
              ),
            ]),
          ),

        const SizedBox(height: 8),
        Container(height: 0.5, color: div),

        // ── Content ──────────────────────────────────────
        Expanded(
          child: _permissionDenied
              ? _buildDenied(tp, ts, acc)
              : _loading
                  ? Center(child: CircularProgressIndicator(color: acc, strokeWidth: 2))
                  : display.isEmpty
                      ? _buildEmpty(ts)
                      : _gridView
                          ? _buildGrid(display, tp, ts, div, acc)
                          : _buildList(display, tp, ts, div, acc),
        ),
      ]),
    );
  }

  // ── Empty ──────────────────────────────────────────────
  Widget _buildEmpty(Color ts) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.folder_open_rounded, size: 56, color: ts.withOpacity(.25)),
    const SizedBox(height: 12),
    Text(_searching ? 'Sem resultados para "$_searchQuery"' : 'Pasta vazia',
        style: GoogleFonts.roboto(color: ts, fontSize: 14)),
  ]));

  // ── Permission denied ──────────────────────────────────
  Widget _buildDenied(Color tp, Color ts, Color acc) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: acc.withOpacity(.08), shape: BoxShape.circle),
          child: Icon(Icons.folder_off_rounded, color: acc, size: 36)),
      const SizedBox(height: 20),
      Text('Acesso negado', style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w800, fontSize: 18)),
      const SizedBox(height: 8),
      Text('Precisamos de permissão para aceder ao armazenamento e listar os teus ficheiros.',
          style: GoogleFonts.roboto(color: ts, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: openAppSettings,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
          child: Text('Abrir definições', style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ),
    ]),
  ));

  // ── List ──────────────────────────────────────────────
  Widget _buildList(List<_FsItem> items, Color tp, Color ts, Color div, Color acc) =>
    ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final col = item.isDir ? acc : _extColor(item.ext, acc);
        final isSel = _selected.contains(item.path);
        return GestureDetector(
          onTap: () => item.isDir ? _navigate(item.path) : _openFile(item),
          onLongPress: () { if (!item.isDir) setState(() { _multiSelect = true; _selected.add(item.path); }); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? acc.withOpacity(.07) : Colors.transparent,
              border: Border(bottom: BorderSide(color: div, width: 0.5)),
            ),
            child: Row(children: [
              // Icon / checkbox
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: _multiSelect
                    ? Container(key: const ValueKey('c'), width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isSel ? acc : Colors.transparent, shape: BoxShape.circle,
                          border: Border.all(color: isSel ? acc : div, width: 1.5),
                        ),
                        child: isSel ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null)
                    : Container(key: const ValueKey('i'), width: 44, height: 44,
                        decoration: BoxDecoration(color: col.withOpacity(.1), shape: BoxShape.circle),
                        child: Center(child: _svgW(item.isDir ? _folderSvg : _fileSvg, col, s: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  if (!item.isDir) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: col.withOpacity(.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.ext.toUpperCase(), style: GoogleFonts.roboto(color: col, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 6),
                    Text(_size(item.size), style: GoogleFonts.roboto(color: ts, fontSize: 12)),
                    const SizedBox(width: 6),
                  ],
                  Text(item.isDir ? 'Pasta' : _relDate(item.modified),
                      style: GoogleFonts.roboto(color: ts.withOpacity(.7), fontSize: 11)),
                ]),
              ])),
              // Action
              if (!_multiSelect)
                item.isDir
                    ? Icon(Icons.chevron_right_rounded, color: ts, size: 20)
                    : GestureDetector(
                        onTap: () => _showInfo(item),
                        child: Padding(padding: const EdgeInsets.all(8),
                            child: Icon(Icons.info_outline_rounded, color: ts.withOpacity(.4), size: 18))),
            ]),
          ),
        );
      },
    );

  // ── Grid ──────────────────────────────────────────────
  Widget _buildGrid(List<_FsItem> items, Color tp, Color ts, Color div, Color acc) {
    final isDark = themeNotifier.isDark;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final col = item.isDir ? acc : _extColor(item.ext, acc);
        final isSel = _selected.contains(item.path);
        return GestureDetector(
          onTap: () => item.isDir ? _navigate(item.path) : _openFile(item),
          onLongPress: () { if (!item.isDir) setState(() { _multiSelect = true; _selected.add(item.path); }); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: isSel ? acc.withOpacity(.1) : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSel ? acc : div.withOpacity(.5), width: isSel ? 1.5 : 0.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .2 : .05), blurRadius: 5, offset: const Offset(0, 2))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: col.withOpacity(.1), shape: BoxShape.circle),
                child: Center(child: _svgW(item.isDir ? _folderSvg : _fileSvg, col, s: 24))),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(item.name, style: GoogleFonts.roboto(color: tp, fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
              if (!item.isDir) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: col.withOpacity(.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(item.ext.toUpperCase(), style: GoogleFonts.roboto(color: col, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

// ── Aria Switch ───────────────────────────────────────
class _AriaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color acc;
  const _AriaSwitch({required this.value, required this.onChanged, required this.acc});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220), curve: Curves.easeInOut,
      width: 50, height: 28, padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? acc : const Color(0xFF8E8E93).withOpacity(.3),
        borderRadius: BorderRadius.circular(_kPill),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 220), curve: Curves.easeInOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(width: 22, height: 22, decoration: const BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
        )),
      ),
    ),
  );
}
