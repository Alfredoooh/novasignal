import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'editor_screen.dart';

// Chamado por editor_screen.dart via importação condicional
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
  late final WebViewController _wvc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _wvc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('FlutterBridge', onMessageReceived: _onMsg)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) {
        setState(() => _loading = false);
        _inject();
      }))
      ..loadFlutterAsset('assets/editor/editor.html');
  }

  void _inject() {
    final doc = widget.controller.document;
    if (doc == null) {
      _wvc.runJavaScript('''
        window._docId = null; window._docTitle = 'Sem título';
        if (typeof createPage === 'function' && pages.length === 0) {
          createPage(0); applyScale(); updateMeta();
          setTimeout(() => pages[0]?.editor?.focus(), 300);
        }
      ''');
    } else {
      final he = doc.htmlContent
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\n')
          .replaceAll('\r', '');
      final te = doc.title.replaceAll("'", r"\'");
      _wvc.runJavaScript('''
        window._docId = '${doc.id}'; window._docTitle = '$te';
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

  void _onMsg(JavaScriptMessage msg) {
    try {
      final d = jsonDecode(msg.message) as Map<String, dynamic>;
      if (d['action'] == 'save') widget.controller.handleSaveMessage(d);
      if (d['action'] == 'back') widget.controller.handleBack();
    } catch (e) {
      debugPrint('bridge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebViewWidget(controller: _wvc),
      if (_loading)
        const Center(
            child: CircularProgressIndicator(
                color: Color(0xFFE0185E), strokeWidth: 2)),
    ]);
  }
}