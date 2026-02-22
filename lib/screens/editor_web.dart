import 'dart:html' as html;
import 'dart:convert';
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'editor_screen.dart';

// Registo único do iframe element factory
bool _registered = false;

Widget buildEditorView(BuildContext context, EditorController controller) {
  return _WebEditorView(controller: controller);
}

class _WebEditorView extends StatefulWidget {
  final EditorController controller;
  const _WebEditorView({required this.controller});
  @override
  State<_WebEditorView> createState() => _WebEditorViewState();
}

class _WebEditorViewState extends State<_WebEditorView> {
  late final String _viewId;
  late final html.IFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewId = 'aria-editor-${DateTime.now().millisecondsSinceEpoch}';

    _iframe = html.IFrameElement()
      ..src = 'assets/assets/editor/editor.html'
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'clipboard-read; clipboard-write'
      ..setAttribute('allowfullscreen', 'true');

    if (!_registered) {
      ui.platformViewRegistry.registerViewFactory(
        _viewId,
        (_) => _iframe,
      );
      _registered = true;
    } else {
      // Para cada instância com id único, regista sempre
      ui.platformViewRegistry.registerViewFactory(_viewId, (_) => _iframe);
    }

    // Escuta mensagens do iframe
    html.window.addEventListener('message', _onMessage);

    // Quando o iframe carrega, injecta o documento
    _iframe.addEventListener('load', (_) => _inject());
  }

  void _inject() {
    final doc = widget.controller.document;
    final msg = doc == null
        ? {'action': 'load', 'id': null, 'title': 'Sem título', 'html': ''}
        : {
            'action': 'load',
            'id': doc.id,
            'title': doc.title,
            'html': doc.htmlContent
          };
    _iframe.contentWindow?.postMessage(msg, '*');
  }

  void _onMessage(html.Event e) {
    if (e is! html.MessageEvent) return;
    final data = e.data;
    if (data is! Map) return;
    final action = data['action'];
    if (action == 'save') {
      widget.controller
          .handleSaveMessage(Map<String, dynamic>.from(data));
    } else if (action == 'back') {
      widget.controller.handleBack();
    } else if (action == 'editorReady') {
      _inject();
    }
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _onMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}