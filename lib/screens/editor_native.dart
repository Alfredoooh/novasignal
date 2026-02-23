import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

Widget buildEditorView(BuildContext context, EditorController controller) {
  return _NativeEditorView(controller: controller);
}

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

  // ── Quando o tema muda, injeta no HTML sem recarregar ──
  void _onThemeChanged() {
    final isDark = themeNotifier.isDark;
    _wvc?.evaluateJavascript(
      source: 'if(typeof window.setTheme==="function") window.setTheme(${isDark ? 'true' : 'false'});',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF242424) : Colors.white;

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
                  case 'save':
                    widget.controller.handleSaveMessage(d);
                    break;
                  case 'back':
                    widget.controller.handleBack();
                    break;
                  case 'exportPDF':
                    // Recebe PDF como base64 do html2pdf.js e partilha
                    await _handleExportPdf(d);
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
          // Aplicar tema actual ao HTML
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

  // ── Exportar PDF recebido como base64 ──────────────────
  Future<void> _handleExportPdf(Map<String, dynamic> data) async {
    try {
      final base64Str = data['base64'] as String? ?? '';
      final title     = (data['title'] as String?)?.isNotEmpty == true
          ? data['title'] as String
          : 'documento';

      if (base64Str.isEmpty) return;

      final bytes = base64Decode(base64Str);
      final dir   = await getTemporaryDirectory();
      // Sanitizar nome do ficheiro
      final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final file  = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title,
        text: title,
      );
    } catch (e) {
      debugPrint('PDF export error: $e');
    }
  }

  // ── Injecta o documento no editor HTML ────────────────
  void _inject() async {
    final ctrl = _wvc;
    if (ctrl == null) return;

    final doc       = widget.controller.document;
    final impHtml   = widget.controller.importHtml;
    final impTitle  = widget.controller.importTitle;
    final impDocx   = widget.controller.importDocxBase64;

    if (impDocx != null && impDocx.isNotEmpty) {
      // ── DOCX via mammoth.js ──
      final te = (impTitle ?? 'Sem título').replaceAll("'", r"\'");
      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        window._docTitle = '$te';
        const el = document.getElementById('doc-title-text');
        if (el) el.textContent = '$te';
        if (typeof window.loadDocxBase64 === 'function') {
          window.loadDocxBase64('$impDocx');
        } else {
          // fallback: aguarda carregamento
          window._pendingDocx = '$impDocx';
        }
      ''');
    } else if (impHtml != null && impHtml.isNotEmpty) {
      // ── HTML importado (TXT/MD) ──
      final he = impHtml
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\n')
          .replaceAll('\r', '');
      final te = (impTitle ?? 'Sem título').replaceAll("'", r"\'");

      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        window._docTitle = '$te';
        const el = document.getElementById('doc-title-text');
        if (el) el.textContent = '$te';
        if (typeof createPage === 'function') {
          document.getElementById('doc-pages').innerHTML = '';
          pages = []; activePg = 0;
          createPage(0); applyScale(); updateMeta();
          if (pages[0]) { pages[0].editor.innerHTML = '$he'; updateMeta(); }
        }
      ''');
    } else if (doc == null) {
      // ── Documento novo ──
      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        window._docTitle = 'Sem título';
        if (typeof createPage === 'function' && pages.length === 0) {
          createPage(0); applyScale(); updateMeta();
          setTimeout(() => pages[0]?.editor?.focus(), 300);
        }
      ''');
    } else {
      // ── Documento existente ──
      final he = doc.htmlContent
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\n')
          .replaceAll('\r', '');
      final te = doc.title.replaceAll("'", r"\'");

      await ctrl.evaluateJavascript(source: '''
        window._docId = '${doc.id}';
        window._docTitle = '$te';
        const el = document.getElementById('doc-title-text');
        if (el) el.textContent = '$te';
        if (typeof createPage === 'function') {
          document.getElementById('doc-pages').innerHTML = '';
          pages = []; activePg = 0;
          createPage(0); applyScale(); updateMeta();
          if (pages[0]) { pages[0].editor.innerHTML = '$he'; updateMeta(); }
        }
      ''');
    }
  }
}
