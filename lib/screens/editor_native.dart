import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

  // Opções do InAppWebView — equivalente ao JavaScriptMode.unrestricted
  final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    mediaPlaybackRequiresUserGesture: false,
    transparentBackground: false,
    useShouldOverrideUrlLoading: false,
    // Desabilita scroll bounce no iOS para parecer mais nativo
    disallowOverScroll: true,
    // Melhor rendering de texto
    textZoom: 100,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg = isDark ? const Color(0xFF0D0D0D) : Colors.white;

    return Stack(children: [
      InAppWebView(
        // Carrega o HTML do asset directamente
        initialFile: 'assets/editor/editor.html',
        initialSettings: _settings,

        onWebViewCreated: (ctrl) {
          _wvc = ctrl;

          // Canal de mensagens HTML → Flutter
          // Equivalente ao addJavaScriptChannel do webview_flutter
          ctrl.addJavaScriptHandler(
            handlerName: 'FlutterBridge',
            callback: (args) {
              try {
                final raw = args.isNotEmpty ? args[0] : null;
                if (raw == null) return;
                final msg = raw is String ? raw : jsonEncode(raw);
                final d = jsonDecode(msg) as Map<String, dynamic>;
                if (d['action'] == 'save') widget.controller.handleSaveMessage(d);
                if (d['action'] == 'back')  widget.controller.handleBack();
              } catch (e) {
                debugPrint('FlutterBridge error: $e');
              }
            },
          );
        },

        onLoadStop: (ctrl, url) async {
          if (mounted) setState(() => _loading = false);
          _inject();
        },

        onConsoleMessage: (ctrl, msg) {
          debugPrint('[WebView console] ${msg.message}');
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

  // ── Injecta o documento no editor HTML ──
  void _inject() async {
    final ctrl = _wvc;
    if (ctrl == null) return;

    final doc = widget.controller.document;

    if (doc == null) {
      // Documento novo
      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        window._docTitle = 'Sem título';
        if (typeof createPage === 'function' && pages.length === 0) {
          createPage(0); applyScale(); updateMeta();
          setTimeout(() => pages[0]?.editor?.focus(), 300);
        }
      ''');
    } else {
      // Documento existente — escapa o conteúdo para JS
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
