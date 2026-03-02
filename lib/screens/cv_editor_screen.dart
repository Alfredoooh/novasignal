import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/theme.dart';
import '../services/notification_service.dart';

const _kPill  = 999.0;
const _kCard  = 18.0;
const _kModal = 20.0;

class CvEditorScreen extends StatefulWidget {
  final String? docId;
  final String? docTitle;
  const CvEditorScreen({super.key, this.docId, this.docTitle});
  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen> {
  InAppWebViewController? _wvc;
  late TextEditingController _titleCtrl;
  bool _changed = false;

  static const _kFonts = [
    {'family':'Roboto',           'label':'Roboto'},
    {'family':'Inter',            'label':'Inter'},
    {'family':'Poppins',          'label':'Poppins'},
    {'family':'Montserrat',       'label':'Montserrat'},
    {'family':'Lato',             'label':'Lato'},
    {'family':'DM Sans',          'label':'DM Sans'},
    {'family':'Playfair Display', 'label':'Playfair Display'},
    {'family':'Merriweather',     'label':'Merriweather'},
    {'family':'Georgia',          'label':'Georgia'},
    {'family':'Space Mono',       'label':'Space Mono'},
  ];
  static const _kSizes = [8,10,11,12,13,14,16,18,20,24,28,32,40,48,64];
  static const _kColorPresets = [
    '#111111','#ffffff','#FA6559','#ff9f0a','#ffd60a',
    '#30d158','#0a84ff','#5856d6','#bf5af2','#e0185e',
    '#636366','#8e8e93','#c7c7cc','#aeaeb2',
  ];
  static const _kBgPresets = [
    '#ffff00','#b4f0a4','#a8d8ff','#ffc8a0','#e8b4ff',
    '#ffd700','#98f5c8','#87ceeb','#ffb347','#da70d6',
    '#ffffff','#e0e0e0','#bdbdbd','#757575','#000000',
  ];

  // ── Elementos disponíveis ──────────────────────────────
  static const _kElements = [
    // Texto
    {'type':'text',     'label':'Texto',      'icon':Icons.text_fields_rounded},
    {'type':'textbox',  'label':'Caixa',       'icon':Icons.crop_square_rounded},
    {'type':'heading',  'label':'Título',      'icon':Icons.title_rounded},
    {'type':'sticky',   'label':'Post-it',     'icon':Icons.sticky_note_2_rounded},
    // Formas
    {'type':'rect',     'label':'Retângulo',   'icon':Icons.rectangle_outlined},
    {'type':'circle',   'label':'Círculo',     'icon':Icons.circle_outlined},
    {'type':'triangle', 'label':'Triângulo',   'icon':Icons.change_history_rounded},
    {'type':'rhombus',  'label':'Losango',     'icon':Icons.diamond_outlined},
    {'type':'star',     'label':'Estrela',     'icon':Icons.star_outline_rounded},
    {'type':'hexagon',  'label':'Hexágono',    'icon':Icons.hexagon_outlined},
    {'type':'line',     'label':'Linha',       'icon':Icons.horizontal_rule_rounded},
    {'type':'arrow',    'label':'Seta',        'icon':Icons.arrow_right_alt_rounded},
    // CV
    {'type':'divider',  'label':'Divisor',     'icon':Icons.horizontal_rule_rounded},
    {'type':'progress', 'label':'Barra',       'icon':Icons.bar_chart_rounded},
    {'type':'skilldots','label':'Habilidade',  'icon':Icons.more_horiz_rounded},
    {'type':'tag',      'label':'Etiqueta',    'icon':Icons.label_outline_rounded},
    {'type':'exp',      'label':'Experiência', 'icon':Icons.work_outline_rounded},
    {'type':'edu',      'label':'Educação',    'icon':Icons.school_outlined},
    {'type':'timeline', 'label':'Timeline',    'icon':Icons.timeline_rounded},
    {'type':'contact',  'label':'Contacto',    'icon':Icons.call_outlined},
  ];

  // ── Templates ──────────────────────────────────────────
  static const _kTemplates = [
    {'name':'minimal',   'label':'Minimal',      'desc':'Clássico e limpo'},
    {'name':'bold',      'label':'Bold Sidebar',  'desc':'Sidebar escura com acento'},
    {'name':'corporate', 'label':'Corporate',     'desc':'Header azul profissional'},
    {'name':'creative',  'label':'Creative',      'desc':'Gradiente roxo criativo'},
    {'name':'elegant',   'label':'Elegant Gold',  'desc':'Elegante com acento dourado'},
    {'name':'tech',      'label':'Tech Dark',     'desc':'Tema escuro para devs'},
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.docTitle ?? 'Currículo');
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() {
    setState(() {});
    _wvc?.evaluateJavascript(source: 'if(window.setTheme)window.setTheme(${themeNotifier.isDark});');
  }

  Future<void> _js(String code) async {
    await _wvc?.evaluateJavascript(source: code);
  }
  Future<void> _injectResult(Map<String,dynamic> data) async {
    final js = jsonEncode(data);
    await _js('if(typeof window._cvModalResult==="function")window._cvModalResult($js);');
  }

  // ════════════════════════════════════════════════════════
  // BRIDGE HANDLER
  // ════════════════════════════════════════════════════════
  Future<void> _handleBridge(Map<String,dynamic> d) async {
    final action = d['action'] as String? ?? '';
    switch (action) {

      case 'autosave':
      case 'changed':
        if (!_changed && mounted) setState(() => _changed = true);
        break;

      case 'insertImage':
        await _pickImage();
        break;

      case 'exportPDF':
        await _handlePdf(d);
        break;

      case 'modal':
        final type = d['type'] as String? ?? '';
        switch (type) {
          case 'font':
            await _showFontModal(d['current'] as String? ?? 'Roboto');
            break;
          case 'size':
            await _showSizeModal((d['current'] as num?)?.toInt() ?? 16);
            break;
          case 'color':
            await _showColorModal(d['current'] as String? ?? '#111111');
            break;
          case 'bgColor':
            await _showBgColorModal(d['current'] as String? ?? '#ffff00');
            break;
        }
        break;

      case 'openElements':
        await _showElementsSheet();
        break;

      case 'openTemplates':
        await _showTemplatesSheet();
        break;

      case 'openTools':
        await _showToolsSheet(
          tool:  d['tool']  as String? ?? 'pen',
          size:  (d['brushSize'] as num?)?.toInt() ?? 4,
          color: d['color'] as String? ?? '#FA6559',
        );
        break;

      case 'openProperties':
        final data = d['data'] as Map<String,dynamic>? ?? {};
        await _showPropertiesSheet(data);
        break;
    }
  }

  // ════════════════════════════════════════════════════════
  // MODAIS NATIVOS
  // ════════════════════════════════════════════════════════

  // ── Galeria / câmara ────────────────────────────────────
  Future<void> _pickImage() async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final src = await _openSheet<String>((_) => _SimpleListSheet(
      title: 'Inserir imagem', isDark: isDark, acc: acc,
      items: const ['Câmara', 'Galeria'],
      onSelect: (i) => i == 0 ? 'camera' : 'gallery',
    ));
    if (src == null) return;
    XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: src == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
    } catch (_) { _showSnack('Não foi possível aceder à imagem.', isError: true); return; }
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final b64   = base64Encode(bytes);
      final mime  = file.mimeType ?? (file.path.endsWith('.png') ? 'image/png' : 'image/jpeg');
      await _js('if(window.insertImageBase64)window.insertImageBase64("$b64","$mime");');
    } catch (_) { _showSnack('Erro ao processar imagem.', isError: true); }
  }

  // ── PDF (base64 recebido do HTML) ────────────────────────
  Future<void> _handlePdf(Map<String,dynamic> data) async {
    final b64 = data['base64'] as String? ?? '';
    if (b64.isEmpty) { _showSnack('Nada para exportar.', isError: true); return; }
    try {
      final title = _titleCtrl.text.trim().isEmpty ? 'curriculo' : _titleCtrl.text.trim();
      final safe  = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
      final bytes = base64Decode(b64);
      await NotificationService().saveAndNotify(bytes, '$safe.pdf', 'application/pdf');
      _showSnack('PDF guardado em Transferências ✓');
    } catch (e) { _showSnack('Erro ao guardar PDF.', isError: true); }
  }

  // ── Fonte ─────────────────────────────────────────────────
  Future<void> _showFontModal(String current) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _FontSheet(isDark: isDark, acc: acc, current: current, fonts: _kFonts),
    );
    if (result != null) await _injectResult(result);
  }

  // ── Tamanho ───────────────────────────────────────────────
  Future<void> _showSizeModal(int current) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,dynamic>>((_) => _SimpleListSheet(
      title: 'Tamanho', isDark: isDark, acc: acc,
      items: _kSizes.map((s) => '$s pt').toList(),
      selectedIndex: _kSizes.indexOf(current),
      onSelect: (i) => <String,dynamic>{'type':'size','size':'${_kSizes[i]}'},
    ));
    if (result != null) await _injectResult(result);
  }

  // ── Cor do texto ──────────────────────────────────────────
  Future<void> _showColorModal(String current) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _ColorSheet(title: 'Cor do texto', resultType: 'color',
        isDark: isDark, acc: acc, current: current, presets: _kColorPresets),
    );
    if (result != null) await _injectResult(result);
  }

  // ── Cor de fundo ──────────────────────────────────────────
  Future<void> _showBgColorModal(String current) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,String>>((_) =>
      _ColorSheet(title: 'Cor de fundo', resultType: 'bgColor',
        isDark: isDark, acc: acc, current: current, presets: _kBgPresets),
    );
    if (result != null) await _injectResult(result);
  }

  // ── Elementos ─────────────────────────────────────────────
  Future<void> _showElementsSheet() async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final type = await _openSheet<String>((_) =>
      _ElementsSheet(isDark: isDark, acc: acc, elements: _kElements),
    );
    if (type != null) {
      await _js('if(window.insertElement)window.insertElement("$type");');
    }
  }

  // ── Templates ─────────────────────────────────────────────
  Future<void> _showTemplatesSheet() async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final name = await _openSheet<String>((_) =>
      _TemplatesSheet(isDark: isDark, acc: acc, templates: _kTemplates),
    );
    if (name != null) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Aplicar template?',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w800)),
          content: const Text('Isto substitui o conteúdo actual.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Aplicar')),
          ],
        ),
      );
      if (ok == true) {
        await _js('if(window.applyTemplate)window.applyTemplate("$name");');
      }
    }
  }

  // ── Ferramentas de desenho ────────────────────────────────
  Future<void> _showToolsSheet({
    required String tool, required int size, required String color
  }) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,dynamic>>((_) =>
      _ToolsSheet(isDark: isDark, acc: acc,
        initialTool: tool, initialSize: size, initialColor: color),
    );
    if (result == null) {
      await _js('if(window.exitDrawMode)window.exitDrawMode();');
    } else {
      final t = result['tool'] as String;
      final s = result['size'] as int;
      final c = result['color'] as String;
      if (t == 'clear') {
        await _js('if(window.clearDrawing)window.clearDrawing();');
        await _js('if(window.exitDrawMode)window.exitDrawMode();');
      } else {
        await _js('if(window.setDrawConfig)window.setDrawConfig("$t",$s,"$c");');
      }
    }
  }

  // ── Propriedades do elemento ──────────────────────────────
  Future<void> _showPropertiesSheet(Map<String,dynamic> data) async {
    final isDark = themeNotifier.isDark;
    final acc    = accColor(isDark);
    final result = await _openSheet<Map<String,dynamic>>((_) =>
      _PropertiesSheet(isDark: isDark, acc: acc, data: data),
    );
    if (result != null) {
      final js = jsonEncode(result);
      await _js('if(window.applyProperties)window.applyProperties($js);');
    }
  }

  // ── Sheet helper ──────────────────────────────────────────
  Future<T?> _openSheet<T>(Widget Function(BuildContext) builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: builder,
    );

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: isError ? const Color(0xFFDC2626) : accColor(themeNotifier.isDark),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  // ════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final bg  = isDark ? AppColors.darkBackground    : AppColors.background;
    final tp  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final acc = accColor(isDark);
    final div = isDark ? AppColors.darkDivider       : AppColors.divider;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0, scrolledUnderElevation: 0,
        shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: acc, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _titleCtrl,
          style: GoogleFonts.roboto(color: tp, fontSize: 17, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            border: InputBorder.none, isDense: true,
            hintText: 'Título do CV',
            hintStyle: GoogleFonts.roboto(color: ts, fontSize: 17),
          ),
          onChanged: (_) { if (!_changed) setState(() => _changed = true); },
        ),
        actions: [
          if (_changed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () async {
                  await _js("if(window.showToast)window.showToast('Guardado ✓')");
                  setState(() => _changed = false);
                },
                style: TextButton.styleFrom(
                  backgroundColor: acc.withOpacity(.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Text('Guardar',
                  style: GoogleFonts.roboto(color: acc, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(.5),
          child: Container(color: div, height: .5),
        ),
      ),
      body: InAppWebView(
        initialFile: 'assets/cv/cv_editor.html',
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
          allowFileAccessFromFileURLs: true,
          allowUniversalAccessFromFileURLs: true,
          supportZoom: false,
          disallowOverScroll: true,
          textZoom: 100,
        ),
        onWebViewCreated: (ctrl) {
          _wvc = ctrl;
          ctrl.addJavaScriptHandler(
            handlerName: 'CvBridge',
            callback: (args) async {
              try {
                final raw = args.isNotEmpty ? args[0] : null;
                if (raw == null) return;
                final d = jsonDecode(raw is String ? raw : jsonEncode(raw)) as Map<String,dynamic>;
                await _handleBridge(d);
              } catch (e) { debugPrint('CvBridge error: $e'); }
            },
          );
        },
        onLoadStop: (ctrl, _) async {
          await ctrl.evaluateJavascript(
            source: 'if(window.setTheme)window.setTheme(${themeNotifier.isDark});',
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Lista simples
// ════════════════════════════════════════════════════════
class _SimpleListSheet<T> extends StatelessWidget {
  final String title;
  final bool   isDark;
  final Color  acc;
  final List<String> items;
  final int    selectedIndex;
  final T Function(int) onSelect;
  const _SimpleListSheet({
    required this.title, required this.isDark, required this.acc,
    required this.items, required this.onSelect, this.selectedIndex = -1,
  });
  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(div: div),
        _Title(title: title, tp: tp),
        Container(height: .5, color: div),
        Flexible(child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          separatorBuilder: (_, __) => Container(height: .5, color: div),
          itemBuilder: (ctx, i) {
            final sel = i == selectedIndex;
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              title: Text(items[i], style: GoogleFonts.roboto(
                color: sel ? acc : tp, fontWeight: sel ? FontWeight.w800 : FontWeight.w500, fontSize: 15)),
              trailing: sel ? Icon(Icons.check_rounded, color: acc, size: 20) : null,
              onTap: () => Navigator.pop(context, onSelect(i)),
            );
          },
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Fontes
// ════════════════════════════════════════════════════════
class _FontSheet extends StatelessWidget {
  final bool   isDark;
  final Color  acc;
  final String current;
  final List<Map<String,String>> fonts;
  const _FontSheet({required this.isDark, required this.acc, required this.current, required this.fonts});
  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(div: div),
        _Title(title: 'Tipo de letra', tp: tp),
        Container(height: .5, color: div),
        Flexible(child: ListView.separated(
          shrinkWrap: true,
          itemCount: fonts.length,
          separatorBuilder: (_, __) => Container(height: .5, color: div),
          itemBuilder: (ctx, i) {
            final f   = fonts[i];
            final sel = current == f['family'];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: Text(f['label']!, style: TextStyle(
                fontFamily: f['family'], color: sel ? acc : tp,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400, fontSize: 16)),
              trailing: sel ? Icon(Icons.check_rounded, color: acc, size: 20) : null,
              onTap: () => Navigator.pop(context,
                <String,String>{'type':'font','family':f['family']!,'label':f['label']!}),
            );
          },
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Cor
// ════════════════════════════════════════════════════════
class _ColorSheet extends StatefulWidget {
  final String title, resultType, current;
  final bool   isDark;
  final Color  acc;
  final List<String> presets;
  const _ColorSheet({required this.title, required this.resultType, required this.current,
    required this.isDark, required this.acc, required this.presets});
  @override State<_ColorSheet> createState() => _ColorSheetState();
}
class _ColorSheetState extends State<_ColorSheet> {
  late String _sel;
  @override void initState() { super.initState(); _sel = widget.current; }
  Color _parse(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#','0xFF'))); } catch (_) { return Colors.grey; }
  }
  Color _contrast(String hex) {
    final c = _parse(hex);
    return (0.299*c.red + 0.587*c.green + 0.114*c.blue)/255 > .6 ? Colors.black : Colors.white;
  }
  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final acc = widget.acc;
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(div: div),
        _Title(title: widget.title, tp: tp),
        Container(height: .5, color: div),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Wrap(spacing: 12, runSpacing: 12, children: widget.presets.map((hex) {
            final selected = _sel == hex;
            final color    = _parse(hex);
            return GestureDetector(
              onTap: () => setState(() => _sel = hex),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? acc : (hex=='#ffffff'||hex=='#ffff00' ? div : Colors.transparent),
                    width: selected ? 3 : 1,
                  ),
                  boxShadow: selected ? [BoxShadow(color: acc.withOpacity(.35), blurRadius: 8)] : null,
                ),
                child: selected ? Icon(Icons.check_rounded, color: _contrast(hex), size: 18) : null,
              ),
            );
          }).toList()),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context, <String,String>{'type':widget.resultType,'color':_sel}),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
              child: Text('Aplicar', textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Elementos
// ════════════════════════════════════════════════════════
class _ElementsSheet extends StatelessWidget {
  final bool   isDark;
  final Color  acc;
  final List<Map<String,dynamic>> elements;
  const _ElementsSheet({required this.isDark, required this.acc, required this.elements});
  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    final pill = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F2F5);
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(div: div),
        _Title(title: 'Inserir elemento', tp: tp),
        Flexible(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Wrap(spacing: 10, runSpacing: 10,
            children: elements.map((e) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, e['type'] as String),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: pill, borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    Icon(e['icon'] as IconData, color: tp, size: 22),
                    const SizedBox(height: 7),
                    Text(e['label'] as String,
                      style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  ]),
                ),
              );
            }).toList(),
          ),
        )),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Templates
// ════════════════════════════════════════════════════════
class _TemplatesSheet extends StatelessWidget {
  final bool   isDark;
  final Color  acc;
  final List<Map<String,String>> templates;
  const _TemplatesSheet({required this.isDark, required this.acc, required this.templates});
  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = isDark ? Colors.white : Colors.black;
    final ts  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = isDark ? AppColors.darkDivider : AppColors.divider;
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(div: div),
        _Title(title: 'Templates de CV', tp: tp),
        Container(height: .5, color: div),
        Flexible(child: ListView.separated(
          shrinkWrap: true,
          itemCount: templates.length,
          separatorBuilder: (_, __) => Container(height: .5, color: div),
          itemBuilder: (ctx, i) {
            final t = templates[i];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: acc.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined, color: acc, size: 22),
              ),
              title: Text(t['label']!, style: GoogleFonts.roboto(
                color: tp, fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: Text(t['desc']!, style: GoogleFonts.roboto(
                color: ts, fontSize: 12)),
              trailing: Icon(Icons.chevron_right_rounded, color: ts),
              onTap: () => Navigator.pop(context, t['name']),
            );
          },
        )),
        const SizedBox(height: 8),
      ])),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Ferramentas de Desenho
// ════════════════════════════════════════════════════════
class _ToolsSheet extends StatefulWidget {
  final bool   isDark;
  final Color  acc;
  final String initialTool, initialColor;
  final int    initialSize;
  const _ToolsSheet({required this.isDark, required this.acc,
    required this.initialTool, required this.initialSize, required this.initialColor});
  @override State<_ToolsSheet> createState() => _ToolsSheetState();
}
class _ToolsSheetState extends State<_ToolsSheet> {
  late String _tool;
  late int    _size;
  late String _color;

  static const _kTools = [
    {'id':'pen',    'label':'Caneta',    'icon':Icons.edit_outlined},
    {'id':'brush',  'label':'Pincel',    'icon':Icons.brush_outlined},
    {'id':'marker', 'label':'Marcador',  'icon':Icons.highlight_outlined},
    {'id':'eraser', 'label':'Borracha',  'icon':Icons.auto_fix_high_outlined},
  ];
  static const _kColors = [
    '#FA6559','#0a84ff','#30d158','#ffd60a','#ff9f0a','#bf5af2','#1a1a1a','#ffffff',
  ];

  @override void initState() {
    super.initState();
    _tool  = widget.initialTool;
    _size  = widget.initialSize;
    _color = widget.initialColor;
  }

  Color _parse(String hex) {
    try { return Color(int.parse(hex.replaceFirst('#','0xFF'))); } catch (_) { return Colors.grey; }
  }

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final pill = widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F2F5);
    final acc = widget.acc;

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
      child: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Handle(div: div),
          _Title(title: 'Ferramentas de desenho', tp: tp),

          // Ferramenta
          Text('Ferramenta', style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
          const SizedBox(height: 10),
          Row(children: _kTools.map((t) {
            final sel = _tool == t['id'];
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _tool = t['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? acc.withOpacity(.15) : pill,
                    borderRadius: BorderRadius.circular(12),
                    border: sel ? Border.all(color: acc, width: 1.5) : null,
                  ),
                  child: Column(children: [
                    Icon(t['icon'] as IconData, color: sel ? acc : tp, size: 22),
                    const SizedBox(height: 5),
                    Text(t['label'] as String,
                      style: GoogleFonts.roboto(color: sel ? acc : ts, fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ));
          }).toList()),
          const SizedBox(height: 20),

          // Espessura
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Espessura', style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
            Text('${_size}px', style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: acc, thumbColor: acc, inactiveTrackColor: div),
            child: Slider(value: _size.toDouble(), min: 1, max: 40,
              onChanged: (v) => setState(() => _size = v.round())),
          ),
          const SizedBox(height: 16),

          // Cores
          Text('Cor', style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kColors.map((hex) {
              final sel = _color == hex;
              final c   = _parse(hex);
              return GestureDetector(
                onTap: () => setState(() => _color = hex),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(
                      color: sel ? acc : (hex=='#ffffff' ? div : Colors.transparent),
                      width: sel ? 3 : 1,
                    ),
                    boxShadow: sel ? [BoxShadow(color: acc.withOpacity(.4), blurRadius: 6)] : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Botões
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(context, {'tool':'clear','size':_size,'color':_color}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(.12),
                  borderRadius: BorderRadius.circular(_kPill),
                ),
                child: Text('Limpar', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: const Color(0xFFFF3B30), fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: GestureDetector(
              onTap: () => Navigator.pop(context, {'tool':_tool,'size':_size,'color':_color}),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                child: Text('Usar ferramenta', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            )),
          ]),
        ]),
      )),
    );
  }
}

// ════════════════════════════════════════════════════════
// SHEET: Propriedades do elemento
// ════════════════════════════════════════════════════════
class _PropertiesSheet extends StatefulWidget {
  final bool   isDark;
  final Color  acc;
  final Map<String,dynamic> data;
  const _PropertiesSheet({required this.isDark, required this.acc, required this.data});
  @override State<_PropertiesSheet> createState() => _PropertiesSheetState();
}
class _PropertiesSheetState extends State<_PropertiesSheet> {
  late int _x, _y, _w, _h, _opacity, _rotation, _borderRadius;
  final _xCtrl = TextEditingController();
  final _yCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _hCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _x            = (widget.data['x']            as num?)?.toInt() ?? 0;
    _y            = (widget.data['y']            as num?)?.toInt() ?? 0;
    _w            = (widget.data['w']            as num?)?.toInt() ?? 100;
    _h            = (widget.data['h']            as num?)?.toInt() ?? 100;
    _opacity      = (widget.data['opacity']      as num?)?.toInt() ?? 100;
    _rotation     = (widget.data['rotation']     as num?)?.toInt() ?? 0;
    _borderRadius = (widget.data['borderRadius'] as num?)?.toInt() ?? 0;
    _xCtrl.text = '$_x'; _yCtrl.text = '$_y';
    _wCtrl.text = '$_w'; _hCtrl.text = '$_h';
  }

  @override
  void dispose() {
    _xCtrl.dispose(); _yCtrl.dispose(); _wCtrl.dispose(); _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg  = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final tp  = widget.isDark ? Colors.white : Colors.black;
    final ts  = widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final div = widget.isDark ? AppColors.darkDivider : AppColors.divider;
    final pill = widget.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F2F5);
    final acc = widget.acc;

    Widget numField(String label, TextEditingController ctrl, void Function(int) onChanged) {
      return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .08)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.roboto(color: tp, fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true, fillColor: pill,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: acc, width: 1.5)),
          ),
          onChanged: (v) { final n = int.tryParse(v); if (n != null) setState(() => onChanged(n)); },
        ),
      ]));
    }

    Widget sliderRow(String label, int value, int min, int max, String suffix, void Function(int) onChanged) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
          Text('$value$suffix', style: GoogleFonts.roboto(color: acc, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: acc, thumbColor: acc, inactiveTrackColor: div),
          child: Slider(value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
            onChanged: (v) => setState(() => onChanged(v.round()))),
        ),
        const SizedBox(height: 8),
      ]);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(_kModal))),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Handle(div: div),
            _Title(title: 'Propriedades', tp: tp),

            Text('Posição', style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
            const SizedBox(height: 8),
            Row(children: [
              numField('X', _xCtrl, (v) => _x = v),
              const SizedBox(width: 12),
              numField('Y', _yCtrl, (v) => _y = v),
            ]),
            const SizedBox(height: 16),

            Text('Tamanho', style: GoogleFonts.roboto(color: ts, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .08)),
            const SizedBox(height: 8),
            Row(children: [
              numField('Largura', _wCtrl, (v) => _w = v),
              const SizedBox(width: 12),
              numField('Altura', _hCtrl, (v) => _h = v),
            ]),
            const SizedBox(height: 20),

            sliderRow('Opacidade', _opacity, 10, 100, '%', (v) => _opacity = v),
            sliderRow('Rotação', _rotation, 0, 360, '°', (v) => _rotation = v),
            sliderRow('Raio bordo', _borderRadius, 0, 100, 'px', (v) => _borderRadius = v),

            GestureDetector(
              onTap: () => Navigator.pop(context, {
                'x': _x, 'y': _y, 'w': _w, 'h': _h,
                'opacity': _opacity, 'rotation': _rotation, 'borderRadius': _borderRadius,
              }),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: acc, borderRadius: BorderRadius.circular(_kPill)),
                child: Text('Aplicar', textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ])),
        )),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════
class _Handle extends StatelessWidget {
  final Color div;
  const _Handle({required this.div});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
    child: Center(child: Container(width: 40, height: 4,
      decoration: BoxDecoration(color: div, borderRadius: BorderRadius.circular(_kPill)))),
  );
}
class _Title extends StatelessWidget {
  final String title;
  final Color  tp;
  const _Title({required this.title, required this.tp});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
    child: Text(title, style: GoogleFonts.roboto(color: tp, fontSize: 18, fontWeight: FontWeight.w800)),
  );
}
