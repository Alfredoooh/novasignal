import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

const _kPill  = 999.0;
const _kCard  = 18.0;
const _kModal = 20.0;
const _kWorkerUrl = 'https://dawn-sun-590a.alfredopjonas.workers.dev';

Widget buildEditorView(BuildContext context, EditorController controller) =>
    _WebEditorView(controller: controller);

class _WebEditorView extends StatefulWidget {
  final EditorController controller;
  const _WebEditorView({required this.controller});
  @override
  State<_WebEditorView> createState() => _WebEditorViewState();
}

class _WebEditorViewState extends State<_WebEditorView> {
  late final String _viewId;
  late final html.IFrameElement _iframe;
  bool _loading = true;
  static String _ariaToken = '';

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

    ui.platformViewRegistry.registerViewFactory(_viewId, (_) => _iframe);

    html.window.addEventListener('message', _onMessage);

    _iframe.addEventListener('load', (_) async {
      if (mounted) setState(() => _loading = false);
      _sendTheme();
      if (_ariaToken.isNotEmpty) {
        _postToIframe({'action': 'setAriaToken', 'token': _ariaToken});
      }
      _inject();
    });

    themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _onMessage);
    themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _postToIframe(Map<String, dynamic> msg) {
    _iframe.contentWindow?.postMessage(msg, '*');
  }

  void _sendModalResult(Map<String, dynamic> data) {
    _postToIframe({...data, 'action': 'modalResult'});
  }

  void _onThemeChanged() => _sendTheme();

  void _sendTheme() {
    _postToIframe({'action': 'setTheme', 'isDark': themeNotifier.isDark});
  }

  void _inject() {
    final doc      = widget.controller.document;
    final impHtml  = widget.controller.importHtml;
    final impTitle = widget.controller.importTitle;
    final impDocx  = widget.controller.importDocxBase64;

    if (impDocx != null && impDocx.isNotEmpty) {
      _postToIframe({'action': 'load', 'id': null, 'title': impTitle ?? 'Sem título', 'html': ''});
      _postToIframe({'action': 'loadDocx', 'base64': impDocx});
    } else if (impHtml != null && impHtml.isNotEmpty) {
      _postToIframe({'action': 'load', 'id': null, 'title': impTitle ?? 'Sem título', 'html': impHtml});
    } else if (doc == null) {
      _postToIframe({'action': 'load', 'id': null, 'title': 'Sem título', 'html': ''});
    } else {
      _postToIframe({'action': 'load', 'id': doc.id, 'title': doc.title, 'html': doc.htmlContent});
    }
  }

  // ── Receptor de mensagens ──────────────────────────────
  void _onMessage(html.Event e) async {
    if (e is! html.MessageEvent) return;
    final data = e.data;
    if (data is! Map) return;
    final d      = Map<String, dynamic>.from(data as Map);
    final action = d['action'] as String? ?? '';

    switch (action) {
      case 'save':
        widget.controller.setSaving(true);
        await widget.controller.handleSaveMessage(d);
        break;
      case 'back':
        widget.controller.handleBack();
        break;
      case 'editorReady':
        _sendTheme();
        _inject();
        break;
      case 'exportPDF':
        _handleExportPdf(d);
        break;
      case 'exportTXT':
        _handleExportTxt(d);
        break;
      case 'aiRequest':
        await _handleAiRequest(d);
        break;
      case 'modal':
        await _handleModal(d);
        break;
    }
  }

  // ── Export PDF ─────────────────────────────────────────
  void _handleExportPdf(Map<String, dynamic> d) {
    try {
      final b64   = d['base64'] as String? ?? '';
      final title = (d['title'] as String?)?.isNotEmpty == true ? d['title'] as String : 'documento';
      if (b64.isEmpty) { _showSnack('Erro ao gerar PDF.', isError: true); return; }
      final bytes = base64Decode(b64);
      final blob  = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url   = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', '$title.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
      _showSnack('PDF guardado!');
    } catch (_) {
      _showSnack('Erro ao exportar PDF.', isError: true);
    }
  }

  // ── Export TXT ─────────────────────────────────────────
  void _handleExportTxt(Map<String, dynamic> d) {
    try {
      final text  = d['text'] as String? ?? '';
      final title = (d['title'] as String?)?.isNotEmpty == true ? d['title'] as String : 'documento';
      final blob  = html.Blob([text], 'text/plain');
      final url   = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', '$title.txt')
        ..click();
      html.Url.revokeObjectUrl(url);
      _showSnack('TXT guardado!');
    } catch (_) {
      _showSnack('Erro ao exportar TXT.', isError: true);
    }
  }

  // ── IA ─────────────────────────────────────────────────
  Future<void> _handleAiRequest(Map<String, dynamic> d) async {
    final prompt   = d['prompt']   as String? ?? '';
    final aiAction = d['aiAction'] as String? ?? '';
    if (prompt.isEmpty) return;
    try {
      final isSearch = aiAction.contains('Pesquis') || aiAction.contains('internet');
      final endpoint = isSearch ? '$_kWorkerUrl/ask' : '$_kWorkerUrl/generate';
      final headers  = <String, String>{'Content-Type': 'application/json'};
      if (_ariaToken.isNotEmpty) headers['Authorization'] = 'Bearer $_ariaToken';
      final body = isSearch
          ? jsonEncode({'query': prompt, 'mode': 'search'})
          : jsonEncode({'prompt': prompt, 'system': 'És um assistente de escrita profissional. Respondes APENAS com o texto solicitado, sem explicações extras. Em português.'});

      final response = await html.HttpRequest.request(endpoint, method: 'POST', requestHeaders: headers, sendData: body);
      final decoded  = jsonDecode(response.responseText ?? '{}') as Map<String, dynamic>;
      final aiText   = (decoded['answer'] ?? decoded['text']) as String?;

      if (aiText != null && aiText.isNotEmpty) {
        _postToIframe({'action': 'aiResponse', 'text': aiText});
      } else {
        _showSnack('IA não devolveu resposta.', isError: true);
        _postToIframe({'action': 'setProgress', 'value': false});
      }
    } catch (e) {
      debugPrint('AI error (web): $e');
      _showSnack('Erro na IA. Verifica a ligação.', isError: true);
      _postToIframe({'action': 'setProgress', 'value': false});
    }
  }

  // ── Dispatch modal ─────────────────────────────────────
  Future<void> _handleModal(Map<String, dynamic> d) async {
    final type = d['type'] as String? ?? '';
    switch (type) {
      case 'link':        await _showLinkModal(d['text'] as String?); break;
      case 'image':       await _showImageModal(); break;
      case 'imageUpload': await _showImageUploadModal(); break;
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
      case 'qrcode':      await _showQrCodeModal(); break;
      case 'sticker':     await _showStickerModal(); break;
    }
  }

  // ═══════════════════════════════════════════════════════
  // MODAIS
  // ═══════════════════════════════════════════════════════

  Future<void> _showLinkModal(String? selectedText) async {
    final isDark   = themeNotifier.isDark;
    final urlCtrl  = TextEditingController();
    final textCtrl = TextEditingController(text: selectedText ?? '');
    final result   = await _openSheet<Map<String, String>>((_) => _SimpleFormSheet(
      title: 'Inserir Link', isDark: isDark, acc: accColor(isDark),
      fields: [
        _FieldDef(ctrl: urlCtrl,  label: 'URL', hint: 'https://exemplo.com', icon: Icons.link_rounded, keyboard: TextInputType.url),
        _FieldDef(ctrl: textCtrl, label: 'Texto (opcional)', hint: selectedText?.isNotEmpty == true ? selectedText! : 'Texto do link', icon: Icons.text_fields_rounded),
      ],
      confirmLabel: 'Inserir link',
      onConfirm: () { final u = urlCtrl.text.trim(); if (u.isEmpty) return null; return {'type': 'link', 'url': u, 'text': textCtrl.text.trim()}; },
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showImageModal() async {
    final isDark  = themeNotifier.isDark;
    final urlCtrl = TextEditingController();
    final altCtrl = TextEditingController();
    final result  = await _openSheet<Map<String, String>>((_) => _SimpleFormSheet(
      title: 'Inserir Imagem', isDark: isDark, acc: accColor(isDark),
      fields: [
        _FieldDef(ctrl: urlCtrl, label: 'URL da imagem', hint: 'https://exemplo.com/img.jpg', icon: Icons.image_outlined, keyboard: TextInputType.url),
        _FieldDef(ctrl: altCtrl, label: 'Descrição (alt)', hint: 'Descrição da imagem', icon: Icons.description_outlined),
      ],
      confirmLabel: 'Inserir imagem',
      onConfirm: () { final u = urlCtrl.text.trim(); if (u.isEmpty) return null; return {'type': 'image', 'url': u, 'alt': altCtrl.text.trim()}; },
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showImageUploadModal() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return;
    final file   = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    try {
      final bytes = Uint8List.fromList(reader.result as List<int>);
      final b64   = base64Encode(bytes);
      final mime  = file.type.isNotEmpty ? file.type : 'image/jpeg';
      _sendModalResult({'type': 'imageUpload', 'base64': b64, 'mime': mime, 'alt': file.name});
    } catch (_) {
      _showSnack('Erro ao processar imagem.', isError: true);
    }
  }

  Future<void> _showTableModal() async {
    final result = await _openSheet<Map<String, String>>((_) =>
        _TablePickerSheet(isDark: themeNotifier.isDark, acc: accColor(themeNotifier.isDark)));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showStyleModal(String current) async {
    final isDark = themeNotifier.isDark;
    final defs   = [
      {'tag': 'h1', 'label': 'Título'}, {'tag': 'h2', 'label': 'Subtítulo'},
      {'tag': 'h3', 'label': 'Secção'}, {'tag': 'p',  'label': 'Corpo'},
      {'tag': 'blockquote', 'label': 'Citação'},
    ];
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: 'Estilo do texto', isDark: isDark, acc: accColor(isDark),
      items: defs.map((d) => _ListItem(label: d['label']!, selected: current == d['tag'])).toList(),
      onSelect: (i) => {'type': 'style', 'tag': defs[i]['tag']!, 'label': defs[i]['label']!},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showFontModal(String current, List<Map> fonts) async {
    final isDark = themeNotifier.isDark;
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: 'Tipo de letra', isDark: isDark, acc: accColor(isDark),
      items: fonts.map((f) => _ListItem(label: f['label'] as String, selected: current == f['family'], fontFamily: f['family'] as String)).toList(),
      onSelect: (i) => {'type': 'font', 'family': fonts[i]['family'] as String, 'label': fonts[i]['label'] as String},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showSizeModal(int current, List<int> sizes) async {
    final isDark = themeNotifier.isDark;
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: 'Tamanho da letra', isDark: isDark, acc: accColor(isDark),
      items: sizes.map((s) => _ListItem(label: '$s pt', selected: current == s, fontSize: s.toDouble().clamp(12, 22))).toList(),
      onSelect: (i) => {'type': 'size', 'size': sizes[i].toString()},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showColorModal(String current, List<String> presets) async {
    final isDark = themeNotifier.isDark;
    final result = await _openSheet<Map<String, String>>((_) => _ColorPickerSheet(
      title: 'Cor da letra', isDark: isDark, acc: accColor(isDark),
      current: current, presets: presets, resultType: 'color',
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showBgColorModal(String current) async {
    final isDark  = themeNotifier.isDark;
    final presets = ['#ffff00','#b4f0a4','#a8d8ff','#ffc8a0','#e8b4ff','#ffd700','#98f5c8','#87ceeb','#ffb347','#da70d6','#ffffff','#e0e0e0','#bdbdbd','#757575','#000000','transparent'];
    final result  = await _openSheet<Map<String, String>>((_) => _ColorPickerSheet(
      title: 'Cor de fundo do texto', isDark: isDark, acc: accColor(isDark),
      current: current, presets: presets, resultType: 'bgColor',
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showOpcoesModal() async {
    final isDark  = themeNotifier.isDark;
    final actions = [
      {'action': 'exportPDF',   'label': 'Baixar como PDF',        'danger': false},
      {'action': 'exportTXT',   'label': 'Baixar como TXT',        'danger': false},
      {'action': 'stats',       'label': 'Estatísticas',           'danger': false},
      {'action': 'findReplace', 'label': 'Localizar e substituir', 'danger': false},
      {'action': 'print',       'label': 'Imprimir',               'danger': false},
      {'action': 'duplicate',   'label': 'Duplicar página',        'danger': false},
      {'action': 'newPage',     'label': 'Nova página',            'danger': false},
      {'action': 'whitePaper',  'label': 'Papel branco',           'danger': false},
      {'action': 'clearAll',    'label': 'Limpar tudo',            'danger': true },
    ];
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: 'Opções', isDark: isDark, acc: accColor(isDark),
      items: actions.map((a) => _ListItem(label: a['label'] as String, danger: a['danger'] as bool)).toList(),
      onSelect: (i) => {'type': 'opcoes', 'action': actions[i]['action'] as String},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showGeminiModal(String selectedText) async {
    final isDark  = themeNotifier.isDark;
    final actions = [
      'Melhorar escrita','Resumir','Continuar texto','Encurtar texto',
      'Expandir texto','Traduzir para inglês','Traduzir para espanhol',
      'Traduzir para francês','Corrigir gramática','Tom formal','Tom casual',
      'Tom persuasivo','Criar lista com pontos','Explicar conceito',
    ];
    final title  = selectedText.isNotEmpty
        ? '"${selectedText.length > 40 ? '${selectedText.substring(0, 40)}…' : selectedText}"'
        : 'Pedir à IA';
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: title, isDark: isDark, acc: accColor(isDark),
      items: actions.map((a) => _ListItem(label: a)).toList(),
      onSelect: (i) => {'type': 'gemini', 'action': actions[i]},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showInsertModal() async {
    final isDark = themeNotifier.isDark;
    final items  = [
      {'action': 'table',      'icon': '⊞', 'label': 'Tabela'},
      {'action': 'hr',         'icon': '─',  'label': 'Linha horizontal'},
      {'action': 'blockquote', 'icon': '❝', 'label': 'Citação'},
      {'action': 'code',       'icon': '<>', 'label': 'Código'},
      {'action': 'link',       'icon': '🔗', 'label': 'Link'},
      {'action': 'ul',         'icon': '•',  'label': 'Lista com marcas'},
      {'action': 'ol',         'icon': '1.', 'label': 'Lista numerada'},
      {'action': 'pageBreak',  'icon': '⬛', 'label': 'Quebra de página'},
      {'action': 'image',      'icon': '🖼',  'label': 'Imagem'},
    ];
    final result = await _openSheet<Map<String, String>>((_) => _ListPickerSheet(
      title: 'Inserir elemento', isDark: isDark, acc: accColor(isDark),
      items: items.map((it) => _ListItem(label: it['label'] as String, leading: it['icon'] as String)).toList(),
      onSelect: (i) => {'type': 'insert', 'action': items[i]['action'] as String},
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showLayoutModal() async {
    final isDark = themeNotifier.isDark;
    final result = await _openSheet<Map<String, String>>((_) => _LayoutSheet(isDark: isDark, acc: accColor(isDark)));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showRenameModal(String current) async {
    final isDark = themeNotifier.isDark;
    final ctrl   = TextEditingController(text: current);
    final result = await _openSheet<Map<String, String>>((_) => _SimpleFormSheet(
      title: 'Renomear documento', isDark: isDark, acc: accColor(isDark),
      fields: [_FieldDef(ctrl: ctrl, label: 'Nome', hint: 'Nome do documento', icon: Icons.drive_file_rename_outline_rounded)],
      confirmLabel: 'Guardar',
      onConfirm: () { final v = ctrl.text.trim(); if (v.isEmpty) return null; return {'type': 'rename', 'title': v}; },
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showStatsModal(Map<String, dynamic> d) async {
    final isDark = themeNotifier.isDark;
    final items  = [
      'Palavras: ${d['words']}', 'Caracteres (com espaços): ${d['chars']}',
      'Caracteres (sem espaços): ${d['charsNoSp']}', 'Frases: ${d['sentences']}',
      'Páginas: ${d['pages']}', 'Tempo de leitura: ~${d['readMin']} min',
    ];
    await _openSheet<void>((_) => _ListPickerSheet(
      title: 'Estatísticas', isDark: isDark, acc: accColor(isDark),
      items: items.map((s) => _ListItem(label: s, tappable: false)).toList(),
      onSelect: (_) => null,
    ));
  }

  Future<void> _showFindReplaceModal() async {
    final isDark      = themeNotifier.isDark;
    final findCtrl    = TextEditingController();
    final replaceCtrl = TextEditingController();
    final result      = await _openSheet<Map<String, String>>((_) =>
        _FindReplaceSheet(isDark: isDark, acc: accColor(isDark), findCtrl: findCtrl, replaceCtrl: replaceCtrl));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showQrCodeModal() async {
    final isDark = themeNotifier.isDark;
    final ctrl   = TextEditingController();
    final result = await _openSheet<Map<String, String>>((_) => _SimpleFormSheet(
      title: 'Criar QR Code', isDark: isDark, acc: accColor(isDark),
      fields: [_FieldDef(ctrl: ctrl, label: 'Conteúdo', hint: 'URL, texto, email…', icon: Icons.qr_code_rounded)],
      confirmLabel: 'Inserir QR Code',
      onConfirm: () { final v = ctrl.text.trim(); if (v.isEmpty) return null; return {'type': 'qrcode', 'content': v}; },
    ));
    if (result != null) _sendModalResult(result);
  }

  Future<void> _showStickerModal() async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final bg     = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp     = isDark ? Colors.white : Colors.black;
    final div    = isDark ? AppColors.darkDivider : AppColors.divider;
    final packs  = {
      'Emoções': ['⭐','🌟','💡','🔥','✅','❌','📌','💎','🎯','🚀','💪','🌈','❤️','🎉','📊','📈','💰','🏆','✨','🌙','☀️','⚡','🎨','📝','🔑','💬','📣','🌍','🎵','🎁'],
      'Negócios': ['📊','📈','📉','💹','💼','📋','📁','🗂️','📌','📍','✅','☑️','🔔','📧','📞','💻','🖥️','📱','🖨️','🖇️'],
      'Sinais': ['⚠️','🚫','✅','❌','ℹ️','❓','❗','💯','🔒','🔓','🔴','🟡','🟢','🔵','⬛','⬜'],
      'Natureza': ['🌱','🌿','🍃','🌸','🌺','🌻','🌴','🌊','⛰️','🌋','🌅','☁️','⛅','🌙','⭐','🌟','💫','🌈','☀️'],
    };
    String currentPack = packs.keys.first;
    await showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: Colors.transparent, barrierColor: Colors.black54,
      builder: (_) => StatefulBuilder(builder: (ctx, ss) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0), child: Center(child: Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
          Padding(padding: const EdgeInsets.fromLTRB(20,14,20,10), child: Text('Stickers & Ícones', style: GoogleFonts.roboto(color:tp,fontSize:17,fontWeight:FontWeight.w800))),
          Container(height:0.5,color:div),
          SizedBox(height:44, child: ListView(
            padding: const EdgeInsets.fromLTRB(12,8,12,0), scrollDirection: Axis.horizontal,
            children: packs.keys.map((pack) {
              final sel = pack == currentPack;
              return GestureDetector(
                onTap: () => ss(() => currentPack = pack),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds:150), margin: const EdgeInsets.only(right:8),
                  padding: const EdgeInsets.symmetric(horizontal:14,vertical:5),
                  decoration: BoxDecoration(color: sel ? acc : Colors.transparent, borderRadius: BorderRadius.circular(999), border: Border.all(color: sel ? acc : div)),
                  child: Text(pack, style: GoogleFonts.roboto(color: sel ? Colors.white : tp, fontSize:12, fontWeight:FontWeight.w700)),
                ),
              );
            }).toList(),
          )),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:6,crossAxisSpacing:8,mainAxisSpacing:8),
            itemCount: packs[currentPack]!.length,
            itemBuilder: (_, i) {
              final icon = packs[currentPack]![i];
              return GestureDetector(
                onTap: () { Navigator.pop(ctx); _sendModalResult({'type':'sticker','icon':icon,'color':'#e0185e'}); },
                child: Container(alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize:28))),
              );
            },
          )),
        ]),
      )),
    );
  }

  Future<T?> _openSheet<T>(Widget Function(BuildContext) builder) =>
      showModalBottomSheet<T>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, barrierColor: Colors.black54, builder: builder);

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final color = isError ? const Color(0xFFDC2626) : accColor(themeNotifier.isDark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16,0,16,16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg     = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE8E8E8);
    return Stack(children: [
      HtmlElementView(viewType: _viewId),
      if (_loading) Container(color: bg, child: Center(child: CircularProgressIndicator(color: isDark ? AppColors.accDark : AppColors.acc, strokeWidth: 2))),
    ]);
  }
}

// ═══════════════════════════════════════════════════════
// SHEETS
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
  final Map<String, String>? Function() onConfirm;
  const _SimpleFormSheet({required this.title, required this.confirmLabel, required this.isDark, required this.acc, required this.fields, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    return Padding(
      padding: EdgeInsets.fromLTRB(0,0,0,MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(0,12,0,0), child: Center(child: Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,16), child: Text(title, style: GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w800))),
          Container(height:0.5,color:div),
          Padding(padding: const EdgeInsets.fromLTRB(20,16,20,0), child: Column(children: fields.map((f) => Padding(
            padding: const EdgeInsets.only(bottom:12),
            child: TextField(controller:f.ctrl, keyboardType:f.keyboard, style:GoogleFonts.roboto(color:tp,fontSize:14),
              decoration: InputDecoration(labelText:f.label, hintText:f.hint,
                labelStyle:GoogleFonts.roboto(color:ts,fontSize:13), hintStyle:GoogleFonts.roboto(color:ts.withOpacity(.6),fontSize:13),
                prefixIcon:f.icon!=null?Icon(f.icon,size:18,color:ts):null,
                contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:14),
                enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(_kCard),borderSide:BorderSide(color:div)),
                focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(_kCard),borderSide:BorderSide(color:acc,width:1.5)),
                filled:true, fillColor:isDark?AppColors.darkBackground:const Color(0xFFF9FAFB)),
            ),
          )).toList())),
          Padding(padding: const EdgeInsets.fromLTRB(20,8,20,24), child: GestureDetector(
            onTap: () { final r = onConfirm(); if (r != null) Navigator.pop(context, r); },
            child: Container(width:double.infinity, padding:const EdgeInsets.symmetric(vertical:16),
              decoration:BoxDecoration(color:acc,borderRadius:BorderRadius.circular(_kPill)),
              child:Text(confirmLabel,textAlign:TextAlign.center,style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w800,fontSize:15))),
          )),
        ]),
      ),
    );
  }
}

class _TablePickerSheet extends StatefulWidget {
  final bool isDark; final Color acc;
  final int initialRows, initialCols;
  const _TablePickerSheet({required this.isDark, required this.acc, this.initialRows = 3, this.initialCols = 3});
  @override State<_TablePickerSheet> createState() => _TablePickerSheetState();
}
class _TablePickerSheetState extends State<_TablePickerSheet> {
  int _hoverRow = 3, _hoverCol = 3;
  @override void initState() { super.initState(); _hoverRow = widget.initialRows; _hoverCol = widget.initialCols; }
  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    const maxR = 8, maxC = 8;
    return Container(
      decoration: BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(_kModal))),
      child: Column(mainAxisSize:MainAxisSize.min,children:[
        Padding(padding:const EdgeInsets.fromLTRB(0,12,0,0),child:Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
        Padding(padding:const EdgeInsets.fromLTRB(20,16,20,6),child:Row(children:[
          Expanded(child:Text('Inserir Tabela',style:GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w800))),
          Text('${_hoverRow}×$_hoverCol',style:GoogleFonts.roboto(color:acc,fontSize:16,fontWeight:FontWeight.w800)),
        ])),
        Padding(padding:const EdgeInsets.only(bottom:12),child:Text('Toca para selecionar o tamanho',style:GoogleFonts.roboto(color:ts,fontSize:12))),
        Container(height:0.5,color:div),
        Padding(padding:const EdgeInsets.all(20),child:Column(children:List.generate(maxR,(r)=>Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(maxC,(c){
          final isActive = r<_hoverRow && c<_hoverCol;
          return GestureDetector(
            onTap: ()=>setState(()=>(_hoverRow=r+1,_hoverCol=c+1)),
            child:AnimatedContainer(duration:const Duration(milliseconds:80),width:36,height:36,margin:const EdgeInsets.all(2),
              decoration:BoxDecoration(color:isActive?acc.withOpacity(.15):Colors.transparent,border:Border.all(color:isActive?acc:div,width:isActive?1.5:1),borderRadius:BorderRadius.circular(6))),
          );
        }))))),
        Padding(padding:const EdgeInsets.fromLTRB(20,0,20,24),child:GestureDetector(
          onTap:()=>Navigator.pop(context,<String,String>{'type':'table','rows':'$_hoverRow','cols':'$_hoverCol'}),
          child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:16),
            decoration:BoxDecoration(color:acc,borderRadius:BorderRadius.circular(_kPill)),
            child:Text('Inserir tabela $_hoverRow×$_hoverCol',textAlign:TextAlign.center,style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w800,fontSize:15))),
        )),
      ]),
    );
  }
}

class _ListItem {
  final String label;
  final bool selected, danger, tappable;
  final String? leading, fontFamily;
  final double? fontSize;
  const _ListItem({required this.label, this.selected=false, this.danger=false, this.tappable=true, this.leading, this.fontFamily, this.fontSize});
}

class _ListPickerSheet extends StatelessWidget {
  final String title; final bool isDark; final Color acc;
  final List<_ListItem> items; final Map<String,String>? Function(int) onSelect;
  const _ListPickerSheet({required this.title, required this.isDark, required this.acc, required this.items, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(_kModal))),
      child: Column(mainAxisSize:MainAxisSize.min,children:[
        Padding(padding:const EdgeInsets.fromLTRB(0,12,0,0),child:Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
        Padding(padding:const EdgeInsets.fromLTRB(20,14,20,10),child:Text(title,style:GoogleFonts.roboto(color:tp,fontSize:17,fontWeight:FontWeight.w800),maxLines:2,overflow:TextOverflow.ellipsis)),
        Container(height:0.5,color:div),
        Flexible(child:ListView.separated(
          shrinkWrap:true, padding:const EdgeInsets.only(bottom:24), itemCount:items.length,
          separatorBuilder:(_,__)=>Container(height:0.5,margin:const EdgeInsets.symmetric(horizontal:20),color:div),
          itemBuilder:(ctx,i){
            final item = items[i];
            return GestureDetector(
              onTap: item.tappable ? ()=>Navigator.pop(ctx,onSelect(i)) : null,
              child:Container(color:Colors.transparent,padding:const EdgeInsets.symmetric(horizontal:20,vertical:14),
                child:Row(children:[
                  if(item.leading!=null)...[
                    Container(width:32,height:32,decoration:BoxDecoration(color:isDark?const Color(0xFF2A2A2A):const Color(0xFFF0F0F0),borderRadius:BorderRadius.circular(8)),alignment:Alignment.center,child:Text(item.leading!,style:const TextStyle(fontSize:14))),
                    const SizedBox(width:14),
                  ],
                  Expanded(child:Text(item.label,style:item.fontFamily!=null
                    ?TextStyle(color:item.danger?const Color(0xFFDC2626):tp,fontSize:item.fontSize??15,fontWeight:item.selected?FontWeight.w700:FontWeight.w400,fontFamily:item.fontFamily)
                    :GoogleFonts.roboto(color:item.danger?const Color(0xFFDC2626):tp,fontSize:item.fontSize??15,fontWeight:item.selected?FontWeight.w700:FontWeight.w400))),
                  if(item.selected) Icon(Icons.check_rounded,color:acc,size:18),
                ]),
              ),
            );
          },
        )),
      ]),
    );
  }
}

class _ColorPickerSheet extends StatefulWidget {
  final String title, current, resultType; final bool isDark; final Color acc; final List<String> presets;
  const _ColorPickerSheet({required this.title, required this.isDark, required this.acc, required this.current, required this.presets, required this.resultType});
  @override State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}
class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late String _selected;
  @override void initState() { super.initState(); _selected = widget.current; }
  Color _parseHex(String hex) {
    if (hex=='transparent') return Colors.transparent;
    try { return Color(int.parse(hex.replaceAll('#',''),radix:16)+0xFF000000); } catch(_) { return Colors.black; }
  }
  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    return Container(
      decoration: BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(_kModal))),
      child: Column(mainAxisSize:MainAxisSize.min,children:[
        Padding(padding:const EdgeInsets.fromLTRB(0,12,0,0),child:Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
        Padding(padding:const EdgeInsets.fromLTRB(20,14,20,14),child:Text(widget.title,style:GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w800))),
        Container(height:0.5,color:div),
        Padding(padding:const EdgeInsets.all(20),child:GridView.builder(
          shrinkWrap:true, physics:const NeverScrollableScrollPhysics(),
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,crossAxisSpacing:12,mainAxisSpacing:12),
          itemCount:widget.presets.length,
          itemBuilder:(ctx,i){
            final c=widget.presets[i]; final isSel=c==_selected; final isTr=c=='transparent';
            return GestureDetector(onTap:()=>setState(()=>_selected=c),
              child:AnimatedContainer(duration:const Duration(milliseconds:100),decoration:BoxDecoration(shape:BoxShape.circle,
                color:isTr?null:_parseHex(c),border:Border.all(color:isSel?acc:(widget.isDark?Colors.white24:Colors.black12),width:isSel?2.5:1),
                gradient:isTr?const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Colors.white,Colors.white,Color(0xFFCC0000),Color(0xFFCC0000)],stops:[0,0.45,0.45,1]):null)));
          },
        )),
        Padding(padding:const EdgeInsets.fromLTRB(20,0,20,24),child:GestureDetector(
          onTap:()=>Navigator.pop(context,<String,String>{'type':widget.resultType,'color':_selected}),
          child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:16),
            decoration:BoxDecoration(color:acc,borderRadius:BorderRadius.circular(_kPill)),
            child:Text('Aplicar',textAlign:TextAlign.center,style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w800,fontSize:15))),
        )),
      ]),
    );
  }
}

class _LayoutSheet extends StatefulWidget {
  final bool isDark; final Color acc;
  const _LayoutSheet({required this.isDark, required this.acc});
  @override State<_LayoutSheet> createState() => _LayoutSheetState();
}
class _LayoutSheetState extends State<_LayoutSheet> {
  String _format='A4', _margin='Normais', _spacing='Simples';
  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    Widget section(String t) => Padding(padding:const EdgeInsets.only(bottom:10,top:16),child:Text(t.toUpperCase(),style:GoogleFonts.roboto(color:ts,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.2)));
    Widget chips(List<String> opts,String cur,ValueChanged<String> onTap)=>Wrap(spacing:8,children:opts.map((o){final sel=o==cur;return GestureDetector(onTap:()=>setState(()=>onTap(o)),child:AnimatedContainer(duration:const Duration(milliseconds:100),padding:const EdgeInsets.symmetric(horizontal:18,vertical:8),decoration:BoxDecoration(color:sel?acc.withOpacity(.12):Colors.transparent,border:Border.all(color:sel?acc:div,width:sel?1.5:1),borderRadius:BorderRadius.circular(_kPill)),child:Text(o,style:GoogleFonts.roboto(color:sel?acc:tp,fontSize:13,fontWeight:FontWeight.w700))));}).toList());
    return Container(
      decoration:BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(_kModal))),
      child:SafeArea(child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        Padding(padding:const EdgeInsets.fromLTRB(0,12,0,0),child:Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
        Padding(padding:const EdgeInsets.fromLTRB(20,14,20,10),child:Text('Layout da página',style:GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w800))),
        Container(height:0.5,color:div),
        Padding(padding:const EdgeInsets.symmetric(horizontal:20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          section('Tamanho do papel'), chips(['A4','A5','Letter','Legal'],_format,(v)=>_format=v),
          section('Margens'), chips(['Estreitas','Normais','Largas'],_margin,(v)=>_margin=v),
          section('Espaçamento de linha'), chips(['Simples','1,5 linhas','Duplo'],_spacing,(v)=>_spacing=v),
          const SizedBox(height:20),
          GestureDetector(
            onTap:(){final sm={'Simples':'1.4','1,5 linhas':'1.65','Duplo':'2.0'};Navigator.pop(context,<String,String>{'type':'layout','format':_format,'margin':_margin,'spacing':sm[_spacing]??'1.4'});},
            child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:16),decoration:BoxDecoration(color:acc,borderRadius:BorderRadius.circular(_kPill)),child:Text('Aplicar',textAlign:TextAlign.center,style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w800,fontSize:15))),
          ),
          const SizedBox(height:8),
        ])),
      ]))),
    );
  }
}

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
    Widget tf(TextEditingController c,String label,String hint)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label.toUpperCase(),style:GoogleFonts.roboto(color:ts,fontSize:10,fontWeight:FontWeight.w800,letterSpacing:1.1)),const SizedBox(height:6),
      TextField(controller:c,style:GoogleFonts.roboto(color:tp,fontSize:14),decoration:InputDecoration(hintText:hint,hintStyle:GoogleFonts.roboto(color:ts.withOpacity(.6),fontSize:13),contentPadding:const EdgeInsets.symmetric(horizontal:16,vertical:14),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(_kCard),borderSide:BorderSide(color:div)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(_kCard),borderSide:BorderSide(color:acc,width:1.5)),filled:true,fillColor:isDark?AppColors.darkBackground:const Color(0xFFF9FAFB))),
    ]);
    return Padding(
      padding:EdgeInsets.fromLTRB(0,0,0,MediaQuery.of(context).viewInsets.bottom),
      child:Container(decoration:BoxDecoration(color:bg,borderRadius:const BorderRadius.vertical(top:Radius.circular(_kModal))),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          Padding(padding:const EdgeInsets.fromLTRB(0,12,0,0),child:Center(child:Container(width:40,height:4,decoration:BoxDecoration(color:div,borderRadius:BorderRadius.circular(_kPill))))),
          Padding(padding:const EdgeInsets.fromLTRB(20,14,20,12),child:Text('Localizar e substituir',style:GoogleFonts.roboto(color:tp,fontSize:18,fontWeight:FontWeight.w800))),
          Container(height:0.5,color:div),
          Padding(padding:const EdgeInsets.fromLTRB(20,16,20,0),child:Column(children:[tf(findCtrl,'Localizar','Texto a encontrar'),const SizedBox(height:12),tf(replaceCtrl,'Substituir por','Novo texto (vazio para apagar)'),const SizedBox(height:16)])),
          Padding(padding:const EdgeInsets.fromLTRB(20,0,20,24),child:Row(children:[
            Expanded(child:GestureDetector(onTap:()=>Navigator.pop(context,<String,String>{'type':'findReplace','action':'count','find':findCtrl.text.trim()}),child:Container(padding:const EdgeInsets.symmetric(vertical:15),decoration:BoxDecoration(border:Border.all(color:div),borderRadius:BorderRadius.circular(_kPill)),child:Text('Contar',textAlign:TextAlign.center,style:GoogleFonts.roboto(color:tp,fontWeight:FontWeight.w700,fontSize:14))))),
            const SizedBox(width:10),
            Expanded(child:GestureDetector(onTap:()=>Navigator.pop(context,<String,String>{'type':'findReplace','action':'replace','find':findCtrl.text.trim(),'replaceWith':replaceCtrl.text}),child:Container(padding:const EdgeInsets.symmetric(vertical:15),decoration:BoxDecoration(color:acc,borderRadius:BorderRadius.circular(_kPill)),child:Text('Substituir tudo',textAlign:TextAlign.center,style:GoogleFonts.roboto(color:Colors.white,fontWeight:FontWeight.w800,fontSize:14))))),
          ])),
        ]),
      ),
    );
  }
}
