import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

// ── Design tokens (mirror agenda_screen) ─────────────
const _kPill  = 999.0;
const _kCard  = 18.0;
const _kModal = 20.0;

Widget buildEditorView(BuildContext context, EditorController controller) =>
    _NativeEditorView(controller: controller);

// ═══════════════════════════════════════════════════════
class _NativeEditorView extends StatefulWidget {
  final EditorController controller;
  const _NativeEditorView({required this.controller});
  @override
  State<_NativeEditorView> createState() => _NativeEditorViewState();
}

class _NativeEditorViewState extends State<_NativeEditorView> {
  InAppWebViewController? _wvc;
  bool _loading = true;

  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    mediaPlaybackRequiresUserGesture: false,
    transparentBackground: false,
    useShouldOverrideUrlLoading: false,
    disallowOverScroll: true,
    textZoom: 100,
  );

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    final isDark = themeNotifier.isDark;
    _wvc?.evaluateJavascript(
      source: 'if(typeof window.setTheme==="function") window.setTheme(${isDark ? 'true' : 'false'});',
    );
  }

  // ── Injecta JS para passar resultado do modal nativo ──
  Future<void> _injectModalResult(Map<String, dynamic> data) async {
    final js = jsonEncode(data);
    await _wvc?.evaluateJavascript(
      source: 'if(typeof window._modalResult==="function") window._modalResult($js);',
    );
  }

  // ═════════════════════════════════════════════════════
  // MODAIS NATIVOS FLUTTER
  // ═════════════════════════════════════════════════════

  // ── Link ─────────────────────────────────────────────
  Future<void> _showLinkModal(String? selectedText) async {
    final isDark = themeNotifier.isDark;
    final urlCtrl  = TextEditingController();
    final textCtrl = TextEditingController(text: selectedText ?? '');
    final acc = accColor(isDark);

    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Inserir Link',
        isDark: isDark, acc: acc,
        fields: [
          _FieldDef(ctrl: urlCtrl,  label: 'URL', hint: 'https://exemplo.com', icon: Icons.link_rounded, keyboard: TextInputType.url),
          _FieldDef(ctrl: textCtrl, label: 'Texto (opcional)', hint: selectedText?.isNotEmpty==true ? selectedText! : 'Texto do link', icon: Icons.text_fields_rounded),
        ],
        confirmLabel: 'Inserir link',
        onConfirm: () {
          final url = urlCtrl.text.trim();
          if (url.isEmpty) return null;
          return {'type':'link','url':url,'text':textCtrl.text.trim()};
        },
      ),
    );

    if (result != null) await _injectModalResult(result);
  }

  // ── Image ─────────────────────────────────────────────
  Future<void> _showImageModal() async {
    final isDark = themeNotifier.isDark;
    final urlCtrl = TextEditingController();
    final altCtrl = TextEditingController();
    final acc = accColor(isDark);

    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Inserir Imagem',
        isDark: isDark, acc: acc,
        fields: [
          _FieldDef(ctrl: urlCtrl, label: 'URL da imagem', hint: 'https://exemplo.com/imagem.jpg', icon: Icons.image_outlined, keyboard: TextInputType.url),
          _FieldDef(ctrl: altCtrl, label: 'Descrição (alt)', hint: 'Descrição da imagem', icon: Icons.description_outlined),
        ],
        confirmLabel: 'Inserir imagem',
        onConfirm: () {
          final url = urlCtrl.text.trim();
          if (url.isEmpty) return null;
          return {'type':'image','url':url,'alt':altCtrl.text.trim()};
        },
      ),
    );

    if (result != null) await _injectModalResult(result);
  }

  // ── Table ─────────────────────────────────────────────
  Future<void> _showTableModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    int rows = 3, cols = 3;

    final result = await _openSheet<Map<String,String>>((_) =>
      _TablePickerSheet(isDark: isDark, acc: acc, initialRows: rows, initialCols: cols),
    );

    if (result != null) await _injectModalResult(result);
  }

  // ── Generic sheet helper ──────────────────────────────
  Future<T?> _openSheet<T>(Widget Function(BuildContext) builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: builder,
    );

  // ═════════════════════════════════════════════════════
  // PDF EXPORT
  // ═════════════════════════════════════════════════════
  Future<void> _handleExportPdf(Map<String,dynamic> data) async {
    try {
      final base64Str = data['base64'] as String? ?? '';
      final title     = (data['title'] as String?)?.isNotEmpty == true
          ? data['title'] as String : 'documento';

      if (base64Str.isEmpty) {
        _showSnack('Erro ao gerar PDF. Tente novamente.', isError: true);
        return;
      }

      final bytes = base64Decode(base64Str);
      final dir   = await getTemporaryDirectory();
      final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
      final file  = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: title,
      );
    } catch (e) {
      debugPrint('PDF export error: $e');
      _showSnack('Erro ao exportar PDF.', isError: true);
    }
  }

  // ═════════════════════════════════════════════════════
  // INJECT DOCUMENT
  // ═════════════════════════════════════════════════════
  void _inject() async {
    final ctrl = _wvc;
    if (ctrl == null) return;

    final doc      = widget.controller.document;
    final impHtml  = widget.controller.importHtml;
    final impTitle = widget.controller.importTitle;
    final impDocx  = widget.controller.importDocxBase64;

    if (impDocx != null && impDocx.isNotEmpty) {
      final te = (impTitle ?? 'Sem título').replaceAll("'", r"\'");
      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        if (typeof window.loadContent === "function") {
          window.loadContent("", "$te", null, true);
        }
        if (typeof window.loadDocxBase64 === "function") {
          window.loadDocxBase64("$impDocx");
        }
      ''');
    } else if (impHtml != null && impHtml.isNotEmpty) {
      final he = _escapeJs(impHtml);
      final te = _escapeJs(impTitle ?? 'Sem título');
      await ctrl.evaluateJavascript(source: '''
        if (typeof window.loadContent === "function") {
          window.loadContent("$he", "$te", null, false);
        }
      ''');
    } else if (doc == null) {
      // Novo documento — sem placeholder pois é documento vazio real
      await ctrl.evaluateJavascript(source: '''
        if (typeof window.loadContent === "function") {
          window.loadContent("", "", null, true);
        }
      ''');
    } else {
      // Documento existente — não mostrar placeholder
      final he = _escapeJs(doc.htmlContent);
      final te = _escapeJs(doc.title);
      final id = doc.id;
      // Se o HTML está vazio, tratar como novo mas sem placeholder
      final isEmpty = doc.htmlContent.trim().isEmpty;
      await ctrl.evaluateJavascript(source: '''
        if (typeof window.loadContent === "function") {
          window.loadContent("$he", "$te", "$id", ${isEmpty ? 'true' : 'false'});
          // Se existente e vazio, esconde placeholder
          if (!$isEmpty && window.pages && window.pages.length > 0) {
            window.pages[0].editor.removeAttribute("data-placeholder");
          }
        }
      ''');
    }
  }

  String _escapeJs(String s) => s
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll('"', r'\"')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', '');

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final acc = isError ? const Color(0xFFDC2626) : accColor(themeNotifier.isDark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: acc,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  // ═════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8);

    return Stack(children: [
      InAppWebView(
        initialFile: 'assets/editor/editor.html',
        initialSettings: _settings,

        onWebViewCreated: (ctrl) {
          _wvc = ctrl;

          ctrl.addJavaScriptHandler(
            handlerName: 'FlutterBridge',
            callback: (args) async {
              try {
                final raw = args.isNotEmpty ? args[0] : null;
                if (raw == null) return;
                final msg = raw is String ? raw : jsonEncode(raw);
                final d = jsonDecode(msg) as Map<String, dynamic>;

                switch (d['action']) {
                  // ── Guardar ──────────────────────────
                  case 'save':
                    widget.controller.setSaving(true);
                    await widget.controller.handleSaveMessage(d);
                    break;

                  // ── Voltar ───────────────────────────
                  case 'back':
                    widget.controller.handleBack();
                    break;

                  // ── Export PDF ───────────────────────
                  case 'exportPDF':
                    await _handleExportPdf(d);
                    break;

                  // ── Export PDF fallback (HTML) ────────
                  case 'exportPDF_html':
                    // Fallback: share raw HTML as a text file if pdf2 fails
                    final html = d['html'] as String? ?? '';
                    final title = (d['title'] as String? ?? 'documento').replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
                    if (html.isNotEmpty) {
                      final dir = await getTemporaryDirectory();
                      final file = File('${dir.path}/$title.html');
                      await file.writeAsString(html);
                      await Share.shareXFiles([XFile(file.path)], subject: title);
                    }
                    break;

                  // ── Modais nativos ───────────────────
                  case 'modal':
                    final type = d['type'] as String? ?? '';
                    switch (type) {
                      case 'link':
                        await _showLinkModal(d['text'] as String?);
                        break;
                      case 'image':
                        await _showImageModal();
                        break;
                      case 'table':
                        await _showTableModal();
                        break;
                    }
                    break;
                }
              } catch (e) {
                debugPrint('FlutterBridge error: $e');
              }
            },
          );
        },

        onLoadStop: (ctrl, url) async {
          if (mounted) setState(() => _loading = false);
          final isDark = themeNotifier.isDark;
          await ctrl.evaluateJavascript(
            source: 'if(typeof window.setTheme==="function") window.setTheme(${isDark ? 'true' : 'false'});',
          );
          _inject();
        },

        onConsoleMessage: (ctrl, msg) {
          debugPrint('[WebView] ${msg.message}');
        },
      ),

      if (_loading)
        Container(
          color: bg,
          child: Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.accDark : AppColors.acc,
              strokeWidth: 2,
            ),
          ),
        ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// ── SHEETS / MODAIS NATIVOS ─────────────────────────────
// ═══════════════════════════════════════════════════════

class _FieldDef {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData? icon;
  final TextInputType keyboard;
  const _FieldDef({required this.ctrl, required this.label, required this.hint, this.icon, this.keyboard = TextInputType.text});
}

// ── Generic form sheet ────────────────────────────────
class _SimpleFormSheet extends StatelessWidget {
  final String title, confirmLabel;
  final bool isDark;
  final Color acc;
  final List<_FieldDef> fields;
  final Map<String,String>? Function() onConfirm;

  const _SimpleFormSheet({
    required this.title, required this.confirmLabel,
    required this.isDark, required this.acc,
    required this.fields, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
            child: Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
          // Header
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,16),
            child: Row(children: [
              Expanded(child: Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
            ])),
          Container(height: 0.5, color: div),
          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(20,16,20,0),
            child: Column(children: fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _tf(f, tp, ts, div, acc, isDark),
            )).toList()),
          ),
          // Confirm btn
          Padding(
            padding: const EdgeInsets.fromLTRB(20,8,20,24),
            child: GestureDetector(
              onTap: () {
                final r = onConfirm();
                if (r != null) Navigator.pop(context, r);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                child: Text(confirmLabel, textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tf(_FieldDef f, Color tp, Color ts, Color div, Color acc, bool isDark) =>
    TextField(
      controller: f.ctrl,
      keyboardType: f.keyboard,
      style: GoogleFonts.roboto(color: tp, fontSize: 14),
      decoration: InputDecoration(
        labelText: f.label,
        hintText: f.hint,
        labelStyle: GoogleFonts.roboto(color: ts, fontSize: 13),
        hintStyle: GoogleFonts.roboto(color: ts.withOpacity(.6), fontSize: 13),
        prefixIcon: f.icon != null ? Icon(f.icon, size: 18, color: ts) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_kCard), borderSide: BorderSide(color: div)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_kCard), borderSide: BorderSide(color: acc, width: 1.5)),
        filled: true,
        fillColor: isDark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
      ),
    );
}

// ── Table picker sheet ────────────────────────────────
class _TablePickerSheet extends StatefulWidget {
  final bool isDark;
  final Color acc;
  final int initialRows, initialCols;
  const _TablePickerSheet({required this.isDark, required this.acc, this.initialRows = 3, this.initialCols = 3});
  @override
  State<_TablePickerSheet> createState() => _TablePickerSheetState();
}

class _TablePickerSheetState extends State<_TablePickerSheet> {
  int rows = 3, cols = 3;
  int _hoverRow = 0, _hoverCol = 0;

  @override
  void initState() {
    super.initState();
    rows = widget.initialRows; cols = widget.initialCols;
    _hoverRow = rows; _hoverCol = cols;
  }

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    const maxR = 8, maxC = 8;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
          child: Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
        // Title
        Padding(padding: const EdgeInsets.fromLTRB(20,16,20,6),
          child: Row(children: [
            Expanded(child: Text('Inserir Tabela', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
            Text('${_hoverRow}×${_hoverCol}', style: GoogleFonts.roboto(color: acc, fontSize: 16, fontWeight: FontWeight.w800)),
          ])),
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Text('Toca para selecionar o tamanho', style: GoogleFonts.roboto(color: ts, fontSize: 12))),
        Container(height: 0.5, color: div),

        // Grid picker
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: List.generate(maxR, (r) =>
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(maxC, (c) {
                final isActive = r < _hoverRow && c < _hoverCol;
                return GestureDetector(
                  onTap: () => setState(() { rows = r+1; cols = c+1; _hoverRow = r+1; _hoverCol = c+1; }),
                  onPanUpdate: (d) {
                    final rr = ((d.globalPosition.dy - 20 - MediaQuery.of(context).padding.top - 120) / 40).ceil().clamp(1, maxR);
                    final cc = ((d.globalPosition.dx - 20) / 40).ceil().clamp(1, maxC);
                    setState(() { _hoverRow = rr; _hoverCol = cc; });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: 36, height: 36, margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isActive ? acc.withOpacity(.15) : Colors.transparent,
                      border: Border.all(color: isActive ? acc : div, width: isActive ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),
            ),
          )),
        ),

        // Confirm
        Padding(
          padding: const EdgeInsets.fromLTRB(20,0,20,24),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, <String,String>{
              'type':'table', 'rows':'$_hoverRow', 'cols':'$_hoverCol',
            }),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Inserir tabela $_hoverRow×$_hoverCol', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}
