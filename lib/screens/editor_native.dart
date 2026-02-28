import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

// ── Design tokens ─────────────────────────────────────
const _kPill  = 999.0;
const _kCard  = 18.0;
const _kModal = 20.0;

// ── Aria Worker ───────────────────────────────────────
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
  static   static String _ariaToken = '';

  InAppWebViewController? _wvc;
  bool _loading = true;
  String _selectedModel = 'google/gemini-2.0-flash-001'; // Gemini 2.0
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

  Future<void> _injectModalResult(Map<String, dynamic> data) async {
    final js = jsonEncode(data);
    await _wvc?.evaluateJavascript(
      source: 'if(typeof window._modalResult==="function") window._modalResult($js);',
    );
  }

  // ═════════════════════════════════════════════════════
  // MODAIS NATIVOS FLUTTER
  // ═════════════════════════════════════════════════════

  Future<void> _showLinkModal(String? selectedText) async {
    final isDark = themeNotifier.isDark;
    final urlCtrl  = TextEditingController();
    final textCtrl = TextEditingController(text: selectedText ?? '');
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Inserir Link', isDark: isDark, acc: acc,
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

  Future<void> _showImageModal() async {
    final isDark = themeNotifier.isDark;
    final urlCtrl = TextEditingController();
    final altCtrl = TextEditingController();
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Inserir Imagem', isDark: isDark, acc: acc,
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

  Future<void> _showTableModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _TablePickerSheet(isDark: isDark, acc: acc),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showStyleModal(String current) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final defs = [
      {'tag':'h1','label':'Título'},
      {'tag':'h2','label':'Subtítulo'},
      {'tag':'h3','label':'Secção'},
      {'tag':'p', 'label':'Corpo'},
      {'tag':'blockquote','label':'Citação'},
    ];
    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: 'Estilo do texto', isDark: isDark, acc: acc,
        items: defs.map((d) => _ListItem(
          label: d['label']!, selected: current == d['tag'],
        )).toList(),
        onSelect: (i) => {'type':'style','tag':defs[i]['tag']!,'label':defs[i]['label']!},
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showFontModal(String current, List<Map> fonts) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: 'Tipo de letra', isDark: isDark, acc: acc,
        items: fonts.map((f) => _ListItem(
          label: f['label'] as String, selected: current == f['family'],
          fontFamily: f['family'] as String,
        )).toList(),
        onSelect: (i) => {'type':'font','family':fonts[i]['family'] as String,'label':fonts[i]['label'] as String},
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showSizeModal(int current, List<int> sizes) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: 'Tamanho da letra', isDark: isDark, acc: acc,
        items: sizes.map((s) => _ListItem(
          label: '$s pt', selected: current == s, fontSize: s.toDouble().clamp(12,22),
        )).toList(),
        onSelect: (i) => {'type':'size','size':sizes[i].toString()},
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showColorModal(String current, List<String> presets) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _ColorPickerSheet(title: 'Cor da letra', isDark: isDark, acc: acc, current: current, presets: presets, resultType: 'color'),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showBgColorModal(String current) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final presets = ['#ffff00','#b4f0a4','#a8d8ff','#ffc8a0','#e8b4ff',
      '#ffd700','#98f5c8','#87ceeb','#ffb347','#da70d6',
      '#ffffff','#e0e0e0','#bdbdbd','#757575','#000000','transparent'];
    final result = await _openSheet<Map<String,String>>((_) =>
      _ColorPickerSheet(title: 'Cor de fundo do texto', isDark: isDark, acc: acc, current: current, presets: presets, resultType: 'bgColor'),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showOpcoesModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final actions = [
      {'action':'exportPDF',   'label':'Guardar como PDF'},
      {'action':'exportTXT',   'label':'Guardar como TXT'},
      {'action':'sharePDF',    'label':'Partilhar PDF'},
      {'action':'stats',       'label':'Estatísticas'},
      {'action':'findReplace', 'label':'Localizar e substituir'},
      {'action':'duplicate',   'label':'Duplicar página'},
      {'action':'newPage',     'label':'Nova página'},
      {'action':'whitePaper',  'label':'Papel branco'},
      {'action':'clearAll',    'label':'Limpar tudo', 'danger': true},
    ];
    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: 'Opções', isDark: isDark, acc: acc,
        items: actions.map((a) => _ListItem(
          label: a['label'] as String,
          danger: (a['danger'] as bool?) ?? false,
        )).toList(),
        onSelect: (i) => {'type':'opcoes','action':actions[i]['action'] as String},
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  // ── Gemini / IA ───────────────────────────────────────
  Future<void> _showGeminiModal(String selectedText) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final actions = [
      'Escrever algo',           // abre modal de escrita livre
      'Melhorar escrita',
      'Resumir',
      'Continuar texto',
      'Encurtar texto',
      'Expandir texto',
      'Traduzir para inglês',
      'Traduzir para espanhol',
      'Traduzir para francês',
      'Corrigir gramática',
      'Tom formal',
      'Tom casual',
      'Tom persuasivo',
      'Criar lista com pontos',
      'Explicar conceito',
      'Pesquisar na internet',
    ];
    final title = selectedText.isNotEmpty
        ? '"${selectedText.length > 40 ? "${selectedText.substring(0,40)}…" : selectedText}"'
        : 'Pedir à IA';

    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: title, isDark: isDark, acc: acc,
        items: actions.map((a) => _ListItem(
          label: a,
          selected: false,
          // Destaca "Escrever algo"
          isAccent: a == 'Escrever algo',
        )).toList(),
        onSelect: (i) => {'type':'gemini','action':actions[i]},
      ),
    );

    if (result != null) {
      if (result['action'] == 'Escrever algo') {
        await _showAiWriteModal(selectedText: selectedText);
      } else {
        await _injectModalResult(result);
      }
    }
  }

  // ── Tela de IA — full screen (abre com selectedText opcional) ──
  Future<void> _showAiWriteModal({String selectedText = ''}) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.6),
        pageBuilder: (_, __, ___) => _AiScreen(
          isDark: themeNotifier.isDark,
          acc: accColor(themeNotifier.isDark),
          initialModel: _selectedModel,
          selectedText: selectedText,
          onModelChanged: (m) { if (mounted) setState(() => _selectedModel = m); },
          onInsertToEditor: _insertAiContent,
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04), end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Insere conteúdo da IA directamente no paper
  Future<void> _insertAiContent(String content, bool isHtml) async {
    await _wvc?.evaluateJavascript(
      source: 'if(typeof window.setProgress==="function") window.setProgress(true);',
    );
    final js = jsonEncode({'text': content, 'type': isHtml ? 'html' : 'text'});
    await _wvc?.evaluateJavascript(
      source: 'if(typeof window._aiResponse==="function") window._aiResponse($js);',
    );
  }

  // ── Insert ────────────────────────────────────────────
  Future<void> _showInsertModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final items = [
      {'action':'table',      'label':'Tabela'},
      {'action':'hr',         'label':'Linha horizontal'},
      {'action':'blockquote', 'label':'Citação'},
      {'action':'code',       'label':'Bloco de código'},
      {'action':'link',       'label':'Link'},
      {'action':'ul',         'label':'Lista com marcas'},
      {'action':'ol',         'label':'Lista numerada'},
      {'action':'pageBreak',  'label':'Quebra de página'},
      {'action':'image',      'label':'Imagem por URL'},
      {'action':'imageUpload','label':'Imagem da galeria'},
      {'action':'qrcode',     'label':'QR Code'},
      {'action':'signature',  'label':'Assinatura'},
    ];
    final result = await _openSheet<Map<String,String>>((_) =>
      _ListPickerSheet(
        title: 'Inserir elemento', isDark: isDark, acc: acc,
        items: items.map((it) => _ListItem(label: it['label'] as String)).toList(),
        onSelect: (i) => {'type':'insert','action':items[i]['action'] as String},
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showLayoutModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _LayoutSheet(isDark: isDark, acc: acc),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showRenameModal(String current) async {
    final isDark = themeNotifier.isDark;
    final ctrl = TextEditingController(text: current);
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Renomear documento', isDark: isDark, acc: acc,
        fields: [_FieldDef(ctrl: ctrl, label: 'Nome', hint: 'Nome do documento', icon: Icons.drive_file_rename_outline_rounded)],
        confirmLabel: 'Guardar',
        onConfirm: () {
          final v = ctrl.text.trim();
          if (v.isEmpty) return null;
          return {'type':'rename','title':v};
        },
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showStatsModal(Map<String,dynamic> d) async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final items = [
      'Palavras: ${d['words']}',
      'Caracteres (com espaços): ${d['chars']}',
      'Caracteres (sem espaços): ${d['charsNoSp']}',
      'Frases: ${d['sentences']}',
      'Páginas: ${d['pages']}',
      'Tempo de leitura: ~${d['readMin']} min',
    ];
    await _openSheet<void>((_) =>
      _ListPickerSheet(
        title: 'Estatísticas', isDark: isDark, acc: acc,
        items: items.map((s) => _ListItem(label: s, tappable: false)).toList(),
        onSelect: (_) => null,
      ),
    );
  }

  Future<void> _showFindReplaceModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final findCtrl    = TextEditingController();
    final replaceCtrl = TextEditingController();
    final result = await _openSheet<Map<String,String>>((_) =>
      _FindReplaceSheet(isDark: isDark, acc: acc, findCtrl: findCtrl, replaceCtrl: replaceCtrl),
    );
    if (result != null) await _injectModalResult(result);
  }

  Future<void> _showImageUploadModal() async {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    final picker = ImagePicker();
    final result = await _openSheet<Map<String,String>>((_) => _ListPickerSheet(
      title: 'Inserir imagem', isDark: isDark, acc: acc,
      items: const [
        _ListItem(label: 'Câmera'),
        _ListItem(label: 'Galeria'),
      ],
      onSelect: (i) => {'src': i == 0 ? 'camera' : 'gallery'},
    ));
    if (result == null) return;
    final src = result['src'] ?? 'gallery';
    XFile? file;
    try {
      file = await picker.pickImage(
        source: src == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (e) {
      _showSnack('Não foi possível aceder à imagem.', isError: true);
      return;
    }
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = file.mimeType ?? 'image/jpeg';
      await _injectModalResult({'type':'imageUpload','base64':b64,'mime':mime,'alt':file.name});
    } catch (e) {
      _showSnack('Erro ao processar imagem.', isError: true);
    }
  }

  Future<void> _showQrCodeModal() async {
    final isDark = themeNotifier.isDark;
    final ctrl = TextEditingController();
    final acc = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _SimpleFormSheet(
        title: 'Criar QR Code', isDark: isDark, acc: acc,
        fields: [
          _FieldDef(ctrl: ctrl, label: 'Conteúdo do QR Code', hint: 'URL, texto, email, telefone…', icon: Icons.qr_code_rounded),
        ],
        confirmLabel: 'Inserir QR Code',
        onConfirm: () {
          final v = ctrl.text.trim();
          if (v.isEmpty) return null;
          return {'type':'qrcode','content':v};
        },
      ),
    );
    if (result != null) await _injectModalResult(result);
  }

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
  // IA — Aria Worker
  // ═════════════════════════════════════════════════════
   // ── Escrita livre — sem orientações, faz exactamente o que o utilizador pede ──
  Future<void> _handleAiWrite(String userPrompt, {String? model}) async {
    await _wvc?.evaluateJavascript(
      source: 'if(typeof window.setProgress==="function") window.setProgress(true);',
    );
    try {
      final headers = <String,String>{'Content-Type':'application/json'};
      if (_ariaToken.isNotEmpty) headers['Authorization'] = 'Bearer \$_ariaToken';

      final body = jsonEncode({
        'prompt': userPrompt,
        'model': model ?? _selectedModel,
        'max_tokens': 8192,
        'temperature': 1.0,
        // Sem system prompt — a IA faz exactamente o que o utilizador pedir
      });

      final client   = HttpClient();
      final request  = await client.postUrl(Uri.parse('${_NativeEditorViewState._kWorkerUrl}/generate'));
      headers.forEach((k,v) => request.headers.set(k,v));
      request.write(body);
      final response     = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded      = jsonDecode(responseBody) as Map<String,dynamic>;
      final aiText       = (decoded['answer'] ?? decoded['text']) as String?;

      if (aiText != null && aiText.isNotEmpty) {
        final js = jsonEncode({'text': aiText});
        await _wvc?.evaluateJavascript(
          source: 'if(typeof window._aiResponse==="function") window._aiResponse(\$js);',
        );
      } else {
        _showSnack('IA não devolveu resposta.', isError: true);
        await _wvc?.evaluateJavascript(source: 'if(typeof window.setProgress==="function") window.setProgress(false);');
      }
    } catch (e) {
      debugPrint('AI write error: \$e');
      _showSnack('Erro na IA. Verifica a ligação.', isError: true);
      await _wvc?.evaluateJavascript(source: 'if(typeof window.setProgress==="function") window.setProgress(false);');
    }
  }

  Future<void> _handleAiRequest(Map<String,dynamic> data) async {
    final prompt   = data['prompt']   as String? ?? '';
    final aiAction = data['aiAction'] as String? ?? '';
    if (prompt.isEmpty) return;

    try {
      final isSearch  = aiAction.contains('Pesquis') || aiAction.contains('internet');
      final endpoint  = '${_NativeEditorViewState._kWorkerUrl}/chat';
      final headers   = <String,String>{'Content-Type':'application/json'};
      if (_ariaToken.isNotEmpty) headers['Authorization'] = 'Bearer $_ariaToken';

      final body = isSearch
          ? jsonEncode({'query': prompt, 'mode': 'search'})
          : jsonEncode({
              'prompt': prompt,
              'system': 'És um assistente de escrita profissional. Respondes APENAS com o texto solicitado, sem explicações extras. Em português.',
            });

      final client   = HttpClient();
      final request  = await client.postUrl(Uri.parse(endpoint));
      headers.forEach((k,v) => request.headers.set(k,v));
      request.write(body);
      final response     = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded      = jsonDecode(responseBody) as Map<String,dynamic>;
      final aiText       = (decoded['answer'] ?? decoded['text']) as String?;

      if (aiText != null && aiText.isNotEmpty) {
        final js = jsonEncode({'text': aiText});
        await _wvc?.evaluateJavascript(
          source: 'if(typeof window._aiResponse==="function") window._aiResponse($js);',
        );
      } else {
        _showSnack('IA não devolveu resposta.', isError: true);
        await _wvc?.evaluateJavascript(source: 'if(typeof window.setProgress==="function") window.setProgress(false);');
      }
    } catch (e) {
      debugPrint('AI request error: $e');
      _showSnack('Erro na IA. Verifica a ligação.', isError: true);
      await _wvc?.evaluateJavascript(source: 'if(typeof window.setProgress==="function") window.setProgress(false);');
    }
  }

  void setAriaToken(String token) {
    _ariaToken = token;
    _wvc?.evaluateJavascript(
      source: 'if(typeof window.setAriaToken==="function") window.setAriaToken("${token.replaceAll('"', '\\"')}");',
    );
  }

  // ═════════════════════════════════════════════════════
  // PDF EXPORT
  // ═════════════════════════════════════════════════════
  Future<void> _handleExportPdf(Map<String,dynamic> data) async {
    try {
      final base64Str = data['base64'] as String? ?? '';
      final title     = (data['title'] as String?)?.isNotEmpty == true
          ? data['title'] as String : 'documento';
      if (base64Str.isEmpty) {
        _showSnack('Erro ao gerar PDF.', isError: true); return;
      }
      final bytes    = base64Decode(base64Str);
      final dir      = await getTemporaryDirectory();
      final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
      final file     = File('${dir.path}/$safeName.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/pdf')], subject: title);
    } catch (e) {
      debugPrint('PDF export error: $e');
      _showSnack('Erro ao exportar PDF.', isError: true);
    }
  }

  // ═════════════════════════════════════════════════════
  // INJECT DOCUMENT
  // ═════════════════════════════════════════════════════
  Future<void> _injectHtmlBase64(
    InAppWebViewController ctrl,
    String html, String title, String? id, bool isNew,
  ) async {
    final b64  = base64Encode(utf8.encode(html));
    final te   = _escapeJs(title);
    final idJs = id != null ? '"$id"' : 'null';
    await ctrl.evaluateJavascript(source: '''
      (function() {
        const b64 = "$b64";
        const html = typeof atob !== "undefined"
          ? decodeURIComponent(Array.from(atob(b64)).map(c=>'%'+c.charCodeAt(0).toString(16).padStart(2,'0')).join(''))
          : "";
        if (typeof window.loadContent === "function") {
          window.loadContent(html, "$te", $idJs, ${isNew ? 'true' : 'false'});
        }
      })();
    ''');
  }

  void _inject() async {
    final ctrl = _wvc; if (ctrl == null) return;
    final doc      = widget.controller.document;
    final impHtml  = widget.controller.importHtml;
    final impTitle = widget.controller.importTitle;
    final impDocx  = widget.controller.importDocxBase64;

    if (impDocx != null && impDocx.isNotEmpty) {
      final te = _escapeJs(impTitle ?? 'Sem título');
      await ctrl.evaluateJavascript(source: '''
        window._docId = null;
        if (typeof window.loadContent === "function") window.loadContent("", "$te", null, true);
        if (typeof window.loadDocxBase64 === "function") window.loadDocxBase64("$impDocx");
      ''');
    } else if (impHtml != null && impHtml.isNotEmpty) {
      await _injectHtmlBase64(ctrl, impHtml, impTitle ?? 'Sem título', null, false);
    } else if (doc == null) {
      await ctrl.evaluateJavascript(source: 'if (typeof window.loadContent === "function") window.loadContent("", "", null, true);');
    } else {
      final isEmpty = doc.htmlContent.trim().isEmpty;
      await _injectHtmlBase64(ctrl, doc.htmlContent, doc.title, doc.id, isEmpty);
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
  // BUILD
  // ═════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg     = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8);

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
                final d   = jsonDecode(msg) as Map<String,dynamic>;

                switch (d['action']) {
                  case 'save':
                    widget.controller.setSaving(true);
                    await widget.controller.handleSaveMessage(d);
                    break;
                  case 'back':
                    widget.controller.handleBack();
                    break;
                  case 'exportPDF':
                    await _handleExportPdf(d);
                    break;
                  case 'exportPDF_html':
                    final html  = d['html'] as String? ?? '';
                    final title = (d['title'] as String? ?? 'documento').replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
                    if (html.isNotEmpty) {
                      final dir  = await getTemporaryDirectory();
                      final file = File('${dir.path}/$title.html');
                      await file.writeAsString(html);
                      await Share.shareXFiles([XFile(file.path)], subject: title);
                    }
                    break;
                  case 'aiRequest':
                    await _handleAiRequest(d);
                    break;
                  case 'modal':
                    final type = d['type'] as String? ?? '';
                    switch (type) {
                      case 'link':        await _showLinkModal(d['text'] as String?); break;
                      case 'image':       await _showImageModal(); break;
                      case 'table':       await _showTableModal(); break;
                      case 'style':       await _showStyleModal(d['current'] as String? ?? 'p'); break;
                      case 'font':
                        final fonts = (d['fonts'] as List?)?.cast<Map>() ?? [];
                        await _showFontModal(d['current'] as String? ?? '', fonts);
                        break;
                      case 'size':
                        final sizes = (d['sizes'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [];
                        await _showSizeModal(d['current'] as int? ?? 14, sizes);
                        break;
                      case 'color':
                        final presets = (d['presets'] as List?)?.cast<String>() ?? [];
                        await _showColorModal(d['current'] as String? ?? '#111111', presets);
                        break;
                      case 'bgColor':     await _showBgColorModal(d['current'] as String? ?? '#ffff00'); break;
                      case 'opcoes':      await _showOpcoesModal(); break;
                      case 'gemini':      await _showGeminiModal(d['selectedText'] as String? ?? ''); break;
                      case 'insert':      await _showInsertModal(); break;
                      case 'layout':      await _showLayoutModal(); break;
                      case 'rename':      await _showRenameModal(d['current'] as String? ?? ''); break;
                      case 'stats':       await _showStatsModal(d); break;
                      case 'findReplace': await _showFindReplaceModal(); break;
                      case 'imageUpload': await _showImageUploadModal(); break;
                      case 'qrcode':      await _showQrCodeModal(); break;
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
          if (_ariaToken.isNotEmpty) {
            final safeToken = _ariaToken.replaceAll('"', '\\"');
            await ctrl.evaluateJavascript(
              source: 'if(typeof window.setAriaToken==="function") window.setAriaToken("$safeToken");',
            );
          }
          _inject();
        },

        onConsoleMessage: (ctrl, msg) => debugPrint('[WebView] ${msg.message}'),
      ),

      // ── Loader — branco + spinner fino ──────────────────
      if (_loading)
        const ColoredBox(
          color: Colors.white,
          child: Center(
            child: SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFBBBBBB),
              ),
            ),
          ),
        ),

      // ── FAB IA — gradient circular, sem sombra ──────────
      if (!_loading)
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => _showAiWriteModal(),
            child: Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF13223), Color(0xFFFA6559)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment: Alignment.center,
              child: Text('IA',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// MODELS DISPONÍVEIS
// ═══════════════════════════════════════════════════════

class _AiModel {
  final String id, label, iconUrl;
  const _AiModel({required this.id, required this.label, required this.iconUrl});
}

const _kModels = [
  _AiModel(
    id: 'google/gemini-2.0-flash-001',
    label: 'Gemini 2.0',
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/googlegemini.svg',
  ),
  _AiModel(
    id: 'google/gemini-2.5-pro-exp-03-25:free',
    label: 'Gemini 2.5 Pro',
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/googlegemini.svg',
  ),
  _AiModel(
    id: 'openai/gpt-4o-mini',
    label: 'GPT-4o Mini',
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/openai.svg',
  ),
  _AiModel(
    id: 'anthropic/claude-3.5-sonnet',
    label: 'Claude 3.5',
    iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/anthropic.svg',
  ),
];

// ═══════════════════════════════════════════════════════
// CHAT — modelo de mensagem
// ═══════════════════════════════════════════════════════

enum _MsgRole { user, ai }

class _Msg {
  final _MsgRole role;
  final String   text;
  final bool     isHtml;
  final bool     searched;
  _Msg(this.role, this.text, {this.isHtml = false, this.searched = false});
}

// ═══════════════════════════════════════════════════════
// MODAL DE IA — chat com input na barra inferior
// ═══════════════════════════════════════════════════════

class _AiScreen extends StatefulWidget {
  final bool   isDark;
  final Color  acc;
  final String initialModel;
  final String selectedText;
  final ValueChanged<String>         onModelChanged;
  final void Function(String, bool)  onInsertToEditor;

  const _AiScreen({
    required this.isDark,
    required this.acc,
    required this.initialModel,
    required this.selectedText,
    required this.onModelChanged,
    required this.onInsertToEditor,
  });

  @override
  State<_AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<_AiScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _msgs       = <_Msg>[];
  bool  _busy       = false;
  bool  _showQuick  = false;
  late  String _model;

  static const _kQuick = [
    'Corrigir gramática',
    'Tornar mais formal',
    'Tornar mais curto',
    'Resumir em tópicos',
    'Traduzir para inglês',
    'Criar documento HTML com tabelas',
    'Gerar relatório profissional em HTML',
  ];

  @override
  void initState() {
    super.initState();
    _model = widget.initialModel;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  });

  Future<void> _send() async {
    final prompt = _inputCtrl.text.trim();
    if (prompt.isEmpty || _busy) return;

    setState(() {
      _msgs.add(_Msg(_MsgRole.user, prompt));
      _busy = true;
      _showQuick = false;
    });
    _inputCtrl.clear();
    _scrollBottom();

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_NativeEditorViewState._ariaToken.isNotEmpty)
          'Authorization': 'Bearer ${_NativeEditorViewState._ariaToken}',
      };

      final history = _msgs
          .where((m) => m.role == _MsgRole.user)
          .take(4)
          .map((m) => {'role': 'user', 'content': m.text})
          .toList();

      final body = jsonEncode({
        'prompt'       : prompt,
        'model'        : _model,
        'history'      : history,
        'selectedText' : widget.selectedText,
      });

      final client  = HttpClient();
      final req     = await client.postUrl(Uri.parse('${_NativeEditorViewState._kWorkerUrl}/chat'));
      headers.forEach((k, v) => req.headers.set(k, v));
      req.write(body);
      final res     = await req.close();
      final raw     = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      if (decoded['error'] != null) throw Exception(decoded['error']);

      final content  = (decoded['content'] ?? decoded['answer'] ?? decoded['text'] ?? '') as String;
      final type     = (decoded['type'] ?? 'text') as String;
      final searched = (decoded['searched'] ?? false) as bool;

      setState(() {
        _msgs.add(_Msg(_MsgRole.ai, content, isHtml: type == 'html', searched: searched));
        _busy = false;
      });
      _scrollBottom();
    } catch (e) {
      setState(() {
        _msgs.add(_Msg(_MsgRole.ai, 'Erro: $e'));
        _busy = false;
      });
    }
  }

  // ── Cores ──────────────────────────────────────────────
  Color get _bg  => widget.isDark ? const Color(0xFF1B1B1B) : const Color(0xFFF1F0F0);
  Color get _tp  => widget.isDark ? const Color(0xFFFFE8E3) : Colors.black;
  Color get _ts  => widget.isDark ? const Color(0xFF9E8E8A) : const Color(0xFF6B6B6B);
  Color get _div => widget.isDark ? const Color(0xFF3A3030) : const Color(0xFFE0E0E0);
  Color get _cardBg => widget.isDark ? const Color(0xFF2C2C2C) : Colors.white;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final bot    = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(child: Column(children: [

        // ── AppBar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(children: [
            // Botão fechar
            IconButton(
              icon: Icon(Icons.close_rounded, color: _ts, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text('Aria', style: GoogleFonts.roboto(color: _tp, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            if (_busy) SizedBox(width: 13, height: 13,
              child: CircularProgressIndicator(strokeWidth: 2, color: widget.acc)),
            const Spacer(),
            // Botão "+" — atalhos rápidos
            GestureDetector(
              onTap: () => setState(() => _showQuick = !_showQuick),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _showQuick ? widget.acc.withOpacity(.15) : _div.withOpacity(.4),
                  border: Border.all(color: _showQuick ? widget.acc : _div, width: 1.2),
                ),
                alignment: Alignment.center,
                child: AnimatedRotation(
                  turns: _showQuick ? 0.125 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.add_rounded,
                    color: _showQuick ? widget.acc : _ts, size: 18),
                ),
              ),
            ),
          ]),
        ),

        // ── Texto seleccionado (se houver) ──────────────────
        if (widget.selectedText.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.acc.withOpacity(.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.acc.withOpacity(.2)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.format_quote_rounded, color: widget.acc, size: 14),
              const SizedBox(width: 6),
              Expanded(child: Text(
                widget.selectedText.length > 120
                  ? '${widget.selectedText.substring(0, 120)}…'
                  : widget.selectedText,
                style: GoogleFonts.roboto(color: _ts, fontSize: 12.5, height: 1.4),
                maxLines: 3, overflow: TextOverflow.ellipsis,
              )),
            ]),
          ),

        // ── Atalhos rápidos ──────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut,
          child: _showQuick ? Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
            child: Wrap(spacing: 6, runSpacing: 6, children: _kQuick.map((q) =>
              GestureDetector(
                onTap: () { _inputCtrl.text = q; setState(() => _showQuick = false); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _div),
                    borderRadius: BorderRadius.circular(99),
                    color: _tp.withOpacity(.04),
                  ),
                  child: Text(q, style: GoogleFonts.roboto(color: _ts, fontSize: 11.5, fontWeight: FontWeight.w500)),
                ),
              )).toList()),
          ) : const SizedBox.shrink(),
        ),

        // ── Selector de modelo ───────────────────────────────
        SizedBox(height: 36,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
            scrollDirection: Axis.horizontal,
            itemCount: _kModels.length,
            itemBuilder: (_, i) {
              final m   = _kModels[i];
              final sel = m.id == _model;
              return GestureDetector(
                onTap: () { setState(() => _model = m.id); widget.onModelChanged(m.id); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 130),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel ? widget.acc.withOpacity(.10) : Colors.transparent,
                    border: Border.all(color: sel ? widget.acc : _div, width: sel ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SvgPicture.network(m.iconUrl, width: 13, height: 13,
                      colorFilter: ColorFilter.mode(sel ? widget.acc : _ts, BlendMode.srcIn),
                      placeholderBuilder: (_) => SizedBox(width: 13, height: 13,
                        child: CircularProgressIndicator(strokeWidth: 1, color: _ts))),
                    const SizedBox(width: 5),
                    Text(m.label, style: GoogleFonts.roboto(
                      color: sel ? widget.acc : _ts, fontSize: 11,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),

        Container(height: 0.5, color: _div),

        // ── Área de conversa ─────────────────────────────────
        Expanded(
          child: _msgs.isEmpty
            ? Center(child: Text('Pergunta ou pede qualquer coisa…',
                style: GoogleFonts.roboto(color: _ts.withOpacity(.5), fontSize: 13)))
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                itemCount: _msgs.length,
                itemBuilder: (_, i) => _buildMsg(_msgs[i]),
              ),
        ),

        // ── Input bar ────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: _bg,
            border: Border(top: BorderSide(color: _div, width: 0.5)),
          ),
          padding: EdgeInsets.fromLTRB(12, 8, 12, (insets > 0 ? insets : bot) + 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 40, maxHeight: 110),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: _div),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: null,
                  style: GoogleFonts.roboto(color: _tp, fontSize: 14, height: 1.45),
                  decoration: InputDecoration(
                    hintText: 'Escreve o teu pedido…',
                    hintStyle: GoogleFonts.roboto(color: _ts.withOpacity(.5), fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botão enviar
            GestureDetector(
              onTap: _busy ? null : _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _busy
                    ? LinearGradient(colors: [_div, _div])
                    : const LinearGradient(
                        colors: [Color(0xFFF13223), Color(0xFFFA6559)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                ),
                alignment: Alignment.center,
                child: _busy
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ])),
    );
  }

  // ── Render de mensagem ───────────────────────────────────
  Widget _buildMsg(_Msg msg) {
    if (msg.role == _MsgRole.user) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF13223), Color(0xFFFA6559)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4)),
          ),
          child: Text(msg.text,
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 14, height: 1.5)),
        ),
      );
    }

    // ── Resposta da IA ──────────────────────────────────────
    return Container(
      margin: const EdgeInsets.only(bottom: 14, right: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Badge "pesquisado"
        if (msg.searched) Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.travel_explore_rounded, color: widget.acc, size: 12),
            const SizedBox(width: 4),
            Text('Pesquisado na web',
              style: GoogleFonts.roboto(color: widget.acc, fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ),

        // Card da resposta
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
            border: Border.all(color: _div.withOpacity(.5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Preview HTML
            if (msg.isHtml)
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3), topRight: Radius.circular(18)),
                ),
                clipBehavior: Clip.antiAlias,
                child: _HtmlSnippet(html: msg.text),
              ),

            if (msg.isHtml) Divider(height: 0.5, thickness: 0.5, color: _div.withOpacity(.4)),

            // Texto da resposta (só para texto, para HTML mostra só preview)
            if (!msg.isHtml)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Text(msg.text,
                  style: GoogleFonts.roboto(color: _tp, fontSize: 14, height: 1.6)),
              ),

            // Botão "Passar para o projeto"
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: GestureDetector(
                onTap: () {
                  widget.onInsertToEditor(msg.text, msg.isHtml);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF13223), Color(0xFFFA6559)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.file_present_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text('Passar para o projeto',
                      style: GoogleFonts.roboto(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Preview de HTML no chat ──────────────────────────────
class _HtmlSnippet extends StatelessWidget {
  final String html;
  const _HtmlSnippet({required this.html});

  @override
  Widget build(BuildContext context) {
    String clean(String s) => s
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    final lines = RegExp(
      r'<(h[123]|p|li|blockquote)[^>]*>([\s\S]*?)<\/\1>',
      caseSensitive: false,
    ).allMatches(html).map((m) => (
      tag: m.group(1)!.toLowerCase(),
      text: clean(m.group(2) ?? ''),
    )).where((l) => l.text.isNotEmpty).take(10).toList();

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: lines.map((l) {
          final isH = l.tag.startsWith('h');
          return Padding(
            padding: EdgeInsets.only(bottom: isH ? 5 : 2),
            child: Text(l.text,
              maxLines: isH ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black87,
                fontSize: l.tag == 'h1' ? 14 : l.tag == 'h2' ? 12.5 : 11,
                fontWeight: isH ? FontWeight.w700 : FontWeight.w400,
                height: 1.4,
              )),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SHEETS / MODAIS NATIVOS
// ═══════════════════════════════════════════════════════

class _FieldDef {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData? icon;
  final TextInputType keyboard;
  const _FieldDef({required this.ctrl, required this.label, required this.hint, this.icon, this.keyboard = TextInputType.text});
}

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
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
            child: Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,16),
            child: Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
          Container(height: 0.5, color: div),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,16,20,0),
            child: Column(children: fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _tf(f, tp, ts, div, acc, isDark),
            )).toList()),
          ),
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

// ── Table picker ──────────────────────────────────────
class _TablePickerSheet extends StatefulWidget {
  final bool isDark; final Color acc;
  const _TablePickerSheet({required this.isDark, required this.acc});
  @override State<_TablePickerSheet> createState() => _TablePickerSheetState();
}

class _TablePickerSheetState extends State<_TablePickerSheet> {
  int _r = 3, _c = 3;

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    const maxR = 8, maxC = 8;

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
          child: Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
        Padding(padding: const EdgeInsets.fromLTRB(20,16,20,6),
          child: Row(children: [
            Expanded(child: Text('Inserir Tabela', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
            Text('${_r}×${_c}', style: GoogleFonts.roboto(color: acc, fontSize: 16, fontWeight: FontWeight.w800)),
          ])),
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Text('Toca para selecionar', style: GoogleFonts.roboto(color: ts, fontSize: 12))),
        Container(height: 0.5, color: div),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: List.generate(maxR, (r) =>
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(maxC, (c) {
                final active = r < _r && c < _c;
                return GestureDetector(
                  onTap: () => setState(() { _r = r+1; _c = c+1; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: 36, height: 36, margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: active ? acc.withOpacity(.15) : Colors.transparent,
                      border: Border.all(color: active ? acc : div, width: active ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }),
            ),
          )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20,0,20,24),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, <String,String>{'type':'table','rows':'$_r','cols':'$_c'}),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Inserir tabela $_r×$_c', textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── List item ─────────────────────────────────────────
class _ListItem {
  final String label;
  final bool selected, danger, tappable, isAccent;
  final String? fontFamily;
  final double? fontSize;
  const _ListItem({
    required this.label,
    this.selected  = false,
    this.danger    = false,
    this.tappable  = true,
    this.isAccent  = false,
    this.fontFamily,
    this.fontSize,
  });
}

// ── List picker sheet ─────────────────────────────────
class _ListPickerSheet extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color acc;
  final List<_ListItem> items;
  final Map<String,String>? Function(int) onSelect;

  const _ListPickerSheet({
    required this.title, required this.isDark, required this.acc,
    required this.items, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
          child: Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
        Padding(padding: const EdgeInsets.fromLTRB(20,14,20,10),
          child: Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis)),
        Container(height: 0.5, color: div),
        Flexible(child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 20), color: div),
          itemBuilder: (ctx, i) {
            final item = items[i];
            final textColor = item.danger ? const Color(0xFFDC2626)
                : item.isAccent ? acc
                : tp;
            return GestureDetector(
              onTap: item.tappable ? () {
                final r = onSelect(i);
                Navigator.pop(ctx, r);
              } : null,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(children: [
                  Expanded(child: Text(item.label,
                    style: item.fontFamily != null
                      ? TextStyle(color: textColor, fontSize: item.fontSize ?? 15,
                          fontWeight: item.selected ? FontWeight.w700 : FontWeight.w400, fontFamily: item.fontFamily)
                      : GoogleFonts.roboto(color: textColor, fontSize: item.fontSize ?? 15,
                          fontWeight: (item.selected || item.isAccent) ? FontWeight.w700 : FontWeight.w400),
                  )),
                  if (item.selected)
                    Icon(Icons.check_rounded, color: acc, size: 18)
                  else if (item.isAccent)
                    Icon(Icons.arrow_forward_ios_rounded, color: acc, size: 14),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}

// ── Color picker ──────────────────────────────────────
class _ColorPickerSheet extends StatefulWidget {
  final String title, current, resultType;
  final bool isDark;
  final Color acc;
  final List<String> presets;
  const _ColorPickerSheet({required this.title, required this.isDark, required this.acc, required this.current, required this.presets, required this.resultType});
  @override State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late String _selected;
  @override void initState() { super.initState(); _selected = widget.current; }

  Color _parseHex(String hex) {
    if (hex == 'transparent') return Colors.transparent;
    try { return Color(int.parse(hex.replaceAll('#',''), radix: 16) + 0xFF000000); }
    catch (_) { return Colors.black; }
  }

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
          child: Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
        Padding(padding: const EdgeInsets.fromLTRB(20,14,20,14),
          child: Text(widget.title, style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
        Container(height: 0.5, color: div),
        Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: widget.presets.length,
            itemBuilder: (ctx, i) {
              final c = widget.presets[i];
              final isSelected = c == _selected;
              final isTransparent = c == 'transparent';
              return GestureDetector(
                onTap: () => setState(() => _selected = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTransparent ? null : _parseHex(c),
                    border: Border.all(
                      color: isSelected ? acc : (widget.isDark ? Colors.white24 : Colors.black12),
                      width: isSelected ? 2.5 : 1,
                    ),
                    gradient: isTransparent ? const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white, Color(0xFFCC0000), Color(0xFFCC0000)],
                      stops: [0, 0.45, 0.45, 1],
                    ) : null,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20,0,20,24),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, <String,String>{'type': widget.resultType, 'color': _selected}),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Aplicar', textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Layout sheet ──────────────────────────────────────
class _LayoutSheet extends StatefulWidget {
  final bool isDark; final Color acc;
  const _LayoutSheet({required this.isDark, required this.acc});
  @override State<_LayoutSheet> createState() => _LayoutSheetState();
}

class _LayoutSheetState extends State<_LayoutSheet> {
  String _format = 'A4', _margin = 'Normais', _spacing = 'Simples';

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;

    Widget section(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 16),
      child: Text(t.toUpperCase(), style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)));

    Widget chips(List<String> opts, String current, ValueChanged<String> onTap) =>
      Wrap(spacing: 8, children: opts.map((o) {
        final sel = o == current;
        return GestureDetector(
          onTap: () => setState(() => onTap(o)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? acc.withOpacity(.12) : Colors.transparent,
              border: Border.all(color: sel ? acc : div, width: sel ? 1.5 : 1),
              borderRadius: BorderRadius.circular(_kPill),
            ),
            child: Text(o, style: GoogleFonts.roboto(color: sel ? acc : tp, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        );
      }).toList());

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
          child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
        Padding(padding: const EdgeInsets.fromLTRB(20,14,20,10),
          child: Text('Layout da página', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
        Container(height: 0.5, color: div),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          section('Tamanho do papel'),
          chips(['A4','A5','Letter','Legal'], _format, (v) => _format = v),
          section('Margens'),
          chips(['Estreitas','Normais','Largas'], _margin, (v) => _margin = v),
          section('Espaçamento de linha'),
          chips(['Simples','1,5 linhas','Duplo'], _spacing, (v) => _spacing = v),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              final spacingMap = {'Simples':'1.4','1,5 linhas':'1.65','Duplo':'2.0'};
              Navigator.pop(context, <String,String>{
                'type':'layout', 'format': _format, 'margin': _margin,
                'spacing': spacingMap[_spacing] ?? '1.4',
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Aplicar', textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ])),
      ]))),
    );
  }
}

// ── Find & Replace ────────────────────────────────────
class _FindReplaceSheet extends StatelessWidget {
  final bool isDark; final Color acc;
  final TextEditingController findCtrl, replaceCtrl;
  const _FindReplaceSheet({required this.isDark, required this.acc, required this.findCtrl, required this.replaceCtrl});

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0),
            child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill))))),
          Padding(padding: const EdgeInsets.fromLTRB(20,14,20,12),
            child: Text('Localizar e substituir', style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800))),
          Container(height: 0.5, color: div),
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0), child: Column(children: [
            _tf(findCtrl, 'Localizar', 'Texto a encontrar', tp, ts, div, acc, isDark),
            const SizedBox(height: 12),
            _tf(replaceCtrl, 'Substituir por', 'Novo texto (vazio para apagar)', tp, ts, div, acc, isDark),
            const SizedBox(height: 16),
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(20,0,20,24), child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, <String,String>{'type':'findReplace','action':'count','find':findCtrl.text.trim()}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(border: Border.all(color: div), borderRadius: BorderRadius.circular(_kPill)),
                child: Text('Contar', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: tp, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, <String,String>{
                'type':'findReplace','action':'replace',
                'find':findCtrl.text.trim(),'replaceWith':replaceCtrl.text,
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                child: Text('Substituir tudo', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            )),
          ])),
        ]),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label, String hint, Color tp, Color ts, Color div, Color acc, bool dark) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      const SizedBox(height: 6),
      TextField(
        controller: c,
        style: GoogleFonts.roboto(color: tp, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(color: ts.withOpacity(.6), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_kCard), borderSide: BorderSide(color: div)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_kCard), borderSide: BorderSide(color: acc, width: 1.5)),
          filled: true,
          fillColor: dark ? AppColors.darkBackground : const Color(0xFFF9FAFB),
        ),
      ),
    ]);
}
