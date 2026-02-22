import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';

class EditorScreen extends StatefulWidget {
  /// Documento existente — null se for novo
  final ADocument? document;

  const EditorScreen({super.key, this.document});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final WebViewController _wvc;
  bool _loading = true;
  bool _saving = false;
  String _title = 'Sem título';
  bool _isEditing = false; // editar título inline

  @override
  void initState() {
    super.initState();
    _title = widget.document?.title ?? 'Sem título';
    _initWebView();
  }

  void _initWebView() {
    _wvc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      // Canal de mensagens do HTML → Flutter
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: _onMessage,
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _loading = false);
          _injectDocument();
        },
      ))
      ..loadFlutterAsset('assets/editor/editor.html');
  }

  // Injecta o documento no WebView após carregar o HTML
  void _injectDocument() {
    final doc = widget.document;
    if (doc == null) {
      // Documento novo — cria página vazia
      _wvc.runJavaScript('''
        window._docId = null;
        window._docTitle = 'Sem título';
        if (typeof createPage === 'function' && pages.length === 0) {
          createPage(0); applyScale(); updateMeta();
          setTimeout(() => pages[0]?.editor?.focus(), 300);
        }
      ''');
    } else {
      // Documento existente — carrega conteúdo
      final htmlEscaped = doc.htmlContent
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\n')
          .replaceAll('\r', '');
      final titleEscaped = doc.title.replaceAll("'", r"\'");
      _wvc.runJavaScript('''
        window._docId = '${doc.id}';
        window._docTitle = '$titleEscaped';
        if (typeof createPage === 'function') {
          document.getElementById('doc-pages').innerHTML = '';
          pages = []; activePg = 0;
          createPage(0); applyScale(); updateMeta();
          if (pages[0]) {
            pages[0].editor.innerHTML = '$htmlEscaped';
            updateMeta();
          }
        }
        const el = document.getElementById('doc-title-text');
        if (el) el.textContent = '$titleEscaped';
      ''');
    }
  }

  // Mensagem recebida do HTML (save, etc.)
  void _onMessage(JavaScriptMessage msg) {
    try {
      final data = jsonDecode(msg.message) as Map<String, dynamic>;
      final action = data['action'] as String?;
      if (action == 'save') {
        final innerData = jsonDecode(data['data'] as String) as Map<String, dynamic>;
        _performSave(
          title: innerData['title'] as String? ?? _title,
          html: innerData['html'] as String? ?? '',
          text: innerData['text'] as String? ?? '',
          words: innerData['words'] as int? ?? 0,
          existingId: data['id'] as String?,
        );
      }
    } catch (e) {
      debugPrint('Bridge error: $e');
    }
  }

  // Pede ao WebView o conteúdo e guarda
  Future<void> _requestSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    // Chama a função JS que envia via FlutterBridge
    await _wvc.runJavaScript('window.saveDocument()');
    // _performSave será chamado via _onMessage
    // Timeout de segurança
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && _saving) setState(() => _saving = false);
  }

  Future<void> _performSave({
    required String title,
    required String html,
    required String text,
    required int words,
    String? existingId,
  }) async {
    final now = DateTime.now();
    final id = existingId ?? widget.document?.id ?? const Uuid().v4();

    final doc = ADocument(
      id: id,
      title: title.isEmpty ? 'Sem título' : title,
      htmlContent: html,
      plainText: text,
      wordCount: words,
      createdAt: widget.document?.createdAt ?? now,
      updatedAt: now,
    );

    await DocumentService.instance.save(doc);

    if (mounted) {
      setState(() { _saving = false; _title = doc.title; });
      _showSavedSnack();
    }
  }

  void _showSavedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Guardado',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AriaTheme.acc,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // Edição do título em dialog
  Future<void> _editTitle() async {
    final ctrl = TextEditingController(text: _title == 'Sem título' ? '' : _title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'Nome do documento',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Sem título',
            hintStyle: TextStyle(color: AriaTheme.textSub),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AriaTheme.acc, width: 2),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: AriaTheme.textSub, fontFamily: 'Syne')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('OK', style: TextStyle(color: AriaTheme.acc, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (result != null) {
      final newTitle = result.isEmpty ? 'Sem título' : result;
      setState(() => _title = newTitle);
      await _wvc.runJavaScript("window.setDocTitle('${newTitle.replaceAll("'", "\\'")}')");
    }
  }

  Future<bool> _onWillPop() async {
    // Ao sair pergunta se quer guardar (só se tiver conteúdo)
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Sair do editor',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text('Queres guardar antes de sair?',
          style: TextStyle(fontFamily: 'Syne', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text('Descartar', style: TextStyle(color: AriaTheme.danger, fontFamily: 'Syne')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text('Guardar', style: TextStyle(color: AriaTheme.acc, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _requestSave();
      await Future.delayed(const Duration(milliseconds: 800));
    }
    return result != null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF8E8E93)),
            onPressed: () async {
              if (await _onWillPop()) Navigator.pop(context);
            },
          ),
          titleSpacing: 0,
          title: GestureDetector(
            onTap: _editTitle,
            child: Text(
              _title,
              style: const TextStyle(
                fontFamily: 'Syne', fontWeight: FontWeight.w700,
                fontSize: 16, color: Color(0xFF111111),
              ),
            ),
          ),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AriaTheme.acc),
                ),
              )
            else
              TextButton(
                onPressed: _requestSave,
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    fontFamily: 'Syne', fontWeight: FontWeight.w800,
                    fontSize: 14, color: AriaTheme.acc,
                  ),
                ),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFF0F0F0)),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _wvc),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: AriaTheme.acc, strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}
