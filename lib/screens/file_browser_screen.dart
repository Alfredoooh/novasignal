import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../widgets/theme.dart';
import 'editor_screen.dart';
import 'pdf_viewer_screen.dart';

// ─── SVGs ────────────────────────────────────────────
const _folderSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M22,4H14.414L12.707,2.293A1,1,0,0,0,12,2H2A2,2,0,0,0,0,4V20a2,2,0,0,0,2,2H22a2,2,0,0,0,2-2V6A2,2,0,0,0,22,4ZM2,4H11.586l1.707,1.707A1,1,0,0,0,14,6H22V20H2Z"/>
</svg>
''';

const _fileSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/>
</svg>
''';

const _searchSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23.707,22.293l-5.969-5.969a10.016,10.016,0,1,0-1.414,1.414l5.969,5.969a1,1,0,0,0,1.414-1.414ZM10,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,10,18Z"/>
</svg>
''';

const _backSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M.88,14.09,4.75,18a1,1,0,0,0,1.42,0h0a1,1,0,0,0,0-1.42L2.61,13H23a1,1,0,0,0,1-1h0a1,1,0,0,0-1-1H2.55L6.17,7.38A1,1,0,0,0,6.17,6h0A1,1,0,0,0,4.75,6L.88,9.85A3,3,0,0,0,.88,14.09Z"/></svg>';

const _supportedExtensions = ['pdf', 'docx', 'doc', 'txt', 'rtf', 'md'];

Widget _svg(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ─── Model ───────────────────────────────────────────
class _FsItem {
  final String name;
  final String path;
  final bool isDir;
  final int size;
  final DateTime modified;

  _FsItem({
    required this.name,
    required this.path,
    required this.isDir,
    this.size = 0,
    required this.modified,
  });

  String get ext => isDir ? '' : p.extension(name).replaceFirst('.', '').toLowerCase();

  bool get isSupported => _supportedExtensions.contains(ext);
}

// ─── Screen ──────────────────────────────────────────
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

  Future<void> _init() async {
    // Request storage permission
    PermissionStatus status;
    if (Platform.isAndroid) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        // Try manage external storage for Android 11+
        status = await Permission.manageExternalStorage.request();
      }
    } else {
      status = PermissionStatus.granted;
    }

    if (!status.isGranted) {
      if (mounted) setState(() { _loading = false; _permissionDenied = true; });
      return;
    }

    String rootPath;
    if (Platform.isAndroid) {
      rootPath = '/storage/emulated/0';
    } else {
      final dir = await getApplicationDocumentsDirectory();
      rootPath = dir.path;
    }

    _currentPath = rootPath;
    await _loadDir(rootPath);
  }

  Future<void> _loadDir(String dirPath) async {
    if (mounted) setState(() => _loading = true);
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final entities = await dir.list(followLinks: false).toList();
      final items = <_FsItem>[];

      for (final e in entities) {
        try {
          final stat = await e.stat();
          final name = p.basename(e.path);
          if (name.startsWith('.')) continue; // skip hidden
          if (e is Directory) {
            items.add(_FsItem(
              name: name, path: e.path,
              isDir: true, modified: stat.modified,
            ));
          } else if (e is File) {
            final ext = p.extension(name).replaceFirst('.', '').toLowerCase();
            if (_supportedExtensions.contains(ext)) {
              items.add(_FsItem(
                name: name, path: e.path,
                isDir: false, size: stat.size, modified: stat.modified,
              ));
            }
          }
        } catch (_) {}
      }

      // Sort: directories first, then files, alphabetically
      items.sort((a, b) {
        if (a.isDir && !b.isDir) return -1;
        if (!a.isDir && b.isDir) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      if (mounted) setState(() {
        _items = items;
        _currentPath = dirPath;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() { _searching = false; _searchResults = []; _searchQuery = ''; });
      return;
    }
    setState(() { _searching = true; _searchQuery = query; _loading = true; });

    final rootPath = Platform.isAndroid ? '/storage/emulated/0' : _currentPath;
    final results = <_FsItem>[];
    await _searchDir(Directory(rootPath), query.toLowerCase(), results);

    if (mounted) setState(() { _searchResults = results; _loading = false; });
  }

  Future<void> _searchDir(Directory dir, String query, List<_FsItem> results) async {
    try {
      final entities = await dir.list(followLinks: false).toList();
      for (final e in entities) {
        final name = p.basename(e.path);
        if (name.startsWith('.')) continue;
        if (e is File) {
          final ext = p.extension(name).replaceFirst('.', '').toLowerCase();
          if (_supportedExtensions.contains(ext) && name.toLowerCase().contains(query)) {
            final stat = await e.stat();
            results.add(_FsItem(name: name, path: e.path, isDir: false, size: stat.size, modified: stat.modified));
            if (results.length >= 100) return;
          }
        } else if (e is Directory) {
          await _searchDir(e, query, results);
          if (results.length >= 100) return;
        }
      }
    } catch (_) {}
  }

  void _navigate(String path) {
    _pathHistory.add(_currentPath);
    _loadDir(path);
  }

  bool _canGoBack() => _pathHistory.isNotEmpty;

  void _goBack() {
    if (_pathHistory.isEmpty) return;
    final prev = _pathHistory.removeLast();
    _loadDir(prev);
  }

  Future<void> _openFile(_FsItem item) async {
    setState(() => _loading = true);
    try {
      final file = File(item.path);
      final bytes = await file.readAsBytes();
      final ext = item.ext;

      if (!mounted) return;
      setState(() => _loading = false);

      if (ext == 'pdf') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(path: item.path, title: item.name),
          ),
        );
      } else if (ext == 'txt' || ext == 'md') {
        final text = utf8.decode(bytes, allowMalformed: true);
        final html = '<p>${text.replaceAll('\n\n', '</p><p>').replaceAll('\n', '<br/>')}</p>';
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(
              importHtml: html,
              importTitle: item.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
            ),
          ),
        );
        widget.onDocImported?.call();
        if (mounted) Navigator.of(context).pop();
      } else if (ext == 'docx' || ext == 'doc') {
        final b64 = base64Encode(bytes);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(
              importDocxBase64: b64,
              importTitle: item.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
            ),
          ),
        );
        widget.onDocImported?.call();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Open file error: $e');
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor = isDark ? AppColors.darkDivider : AppColors.divider;
    final surfBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final acc = accColor(isDark);

    final displayItems = _searching ? _searchResults : _items;
    final relPath = _currentPath.replaceFirst('/storage/emulated/0', 'Armazenamento');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: _svg(_backSvg, textPrimary, s: 22),
          onPressed: () {
            if (_canGoBack() && !_searching) {
              _goBack();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Carregar ficheiro',
          style: GoogleFonts.syne(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: divColor),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            height: 44,
            decoration: BoxDecoration(
              color: surfBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: divColor),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                _svg(_searchSvg, textSec, s: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _search(v),
                    style: GoogleFonts.syne(color: textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar ficheiros…',
                      hintStyle: GoogleFonts.syne(color: textSec, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searching)
                  IconButton(
                    icon: Icon(Icons.close, color: textSec, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() { _searching = false; _searchResults = []; _searchQuery = ''; });
                    },
                  ),
              ],
            ),
          ),
          // Breadcrumb
          if (!_searching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _svg(_folderSvg, textSec, s: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      relPath,
                      style: GoogleFonts.syne(color: textSec, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(height: 0.5, color: divColor),
          // Content
          Expanded(
            child: _permissionDenied
                ? _buildPermissionDenied(textPrimary, textSec, acc)
                : _loading
                    ? Center(child: CircularProgressIndicator(color: acc, strokeWidth: 2))
                    : displayItems.isEmpty
                        ? Center(child: Text(
                            _searching ? 'Sem resultados para "$_searchQuery"' : 'Pasta vazia',
                            style: GoogleFonts.syne(color: textSec, fontSize: 14),
                          ))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: displayItems.length,
                            itemBuilder: (ctx, i) => _buildItem(
                              displayItems[i], textPrimary, textSec, divColor, acc,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDenied(Color tp, Color ts, Color acc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined, color: ts, size: 64),
            const SizedBox(height: 16),
            Text('Permissão negada',
                style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 8),
            Text('Precisamos de acesso ao armazenamento para listar os teus ficheiros.',
                style: GoogleFonts.syne(color: ts, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              style: ElevatedButton.styleFrom(backgroundColor: acc, foregroundColor: Colors.white),
              child: Text('Abrir definições', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(_FsItem item, Color tp, Color ts, Color div, Color acc) {
    final color = item.isDir ? acc : (item.isSupported ? acc : ts);
    final iconSvg = item.isDir ? _folderSvg : _fileSvg;
    final iconBg = item.isDir
        ? acc.withOpacity(0.1)
        : (item.isSupported ? acc.withOpacity(0.1) : ts.withOpacity(0.1));

    return InkWell(
      onTap: item.isDir ? () => _navigate(item.path) : () => _openFile(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: div, width: 0.5))),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Center(child: _svg(iconSvg, color, s: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    item.isDir ? 'Pasta' : '${item.ext.toUpperCase()} · ${_formatSize(item.size)}',
                    style: GoogleFonts.syne(color: ts, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (item.isDir)
              Icon(Icons.chevron_right, color: ts, size: 20),
          ],
        ),
      ),
    );
  }
}
