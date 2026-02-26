import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import 'cv_editor_screen.dart';
import 'nota_screen.dart';
import 'pdf_viewer_screen.dart';

// ──────────────────────────────────────────────────
// SVGs fornecidos pelo utilizador
// ──────────────────────────────────────────────────

// Documento (editar / criar novo)
const _svgDocumento = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18.656.93,6.464,13.122A4.966,4.966,0,0,0,5,16.657V18a1,1,0,0,0,1,1H7.343a4.966,4.966,0,0,0,3.535-1.464L23.07,5.344a3.125,3.125,0,0,0,0-4.414A3.194,3.194,0,0,0,18.656.93Zm3,3L9.464,16.122A3.02,3.02,0,0,1,7.343,17H7v-.343a3.02,3.02,0,0,1,.878-2.121L20.07,2.344a1.148,1.148,0,0,1,1.586,0A1.123,1.123,0,0,1,21.656,3.93Z"/>
<path d="M23,8.979a1,1,0,0,0-1,1V15H18a3,3,0,0,0-3,3v4H5a3,3,0,0,1-3-3V5A3,3,0,0,1,5,2h9.042a1,1,0,0,0,0-2H5A5.006,5.006,0,0,0,0,5V19a5.006,5.006,0,0,0,5,5H16.343a4.968,4.968,0,0,0,3.536-1.464l2.656-2.658A4.968,4.968,0,0,0,24,16.343V9.979A1,1,0,0,0,23,8.979ZM18.465,21.122a2.975,2.975,0,0,1-1.465.8V18a1,1,0,0,1,1-1h3.925a3.016,3.016,0,0,1-.8,1.464Z"/>
</svg>
''';

// Apresentação
const _svgApresentacao = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M23,16h-.28l-.86-2.582c-.682-2.045-2.588-3.418-4.743-3.418H6.883c-.3,0-.595,.028-.883,.079v-3.079c0-1.654,1.346-3,3-3h.172c.413,1.164,1.524,2,2.828,2h3c1.654,0,3-1.346,3-3s-1.346-3-3-3h-3c-1.304,0-2.415,.836-2.828,2h-.172c-2.757,0-5,2.243-5,5v3.914c-.851,.6-1.514,1.466-1.861,2.505l-.859,2.581h-.279c-.553,0-1,.448-1,1s.447,1,1,1h.975c.02,0,.039,0,.058,0H11v4h-3c-.553,0-1,.448-1,1s.447,1,1,1h8c.553,0,1-.448,1-1s-.447-1-1-1h-3v-4h10c.553,0,1-.448,1-1s-.447-1-1-1ZM12,2h3c.552,0,1,.449,1,1s-.448,1-1,1h-3c-.552,0-1-.449-1-1s.448-1,1-1ZM4.036,14.051c.41-1.227,1.554-2.051,2.847-2.051h10.234c1.293,0,2.437,.824,2.847,2.051l.649,1.949H3.387l.649-1.949Z"/>
</svg>
''';

// CV / Currículo
const _svgCV = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m21,12h-9c-1.657,0-3,1.343-3,3v6c0,1.657,1.343,3,3,3h9c1.657,0,3-1.343,3-3v-6c0-1.657-1.343-3-3-3Zm-7.5,8.4c.411,0,.758-.276.866-.653.022-.079.068-.747.835-.747s.811.705.799.804c-.15,1.237-1.222,2.196-2.5,2.196-1.381,0-2.5-1.119-2.5-2.5v-3c0-1.381,1.119-2.5,2.5-2.5,1.281,0,2.354.963,2.5,2.204.011.097.002.796-.804.796s-.809-.674-.833-.755c-.11-.372-.456-.645-.863-.645-.496,0-.9.404-.9.9v3c0,.496.404.9.9.9Zm7.506.025c-.126.647-.583,1.575-1.628,1.575s-1.51-.97-1.618-1.531l-1.072-5.253c-.101-.496.278-.96.784-.96.38,0,.708.268.784.64l1.072,5.253c.013.065.031.117.05.159.02-.047.042-.109.057-.188l1.053-5.222c.075-.373.403-.642.784-.642.505,0,.884.463.784.958l-1.051,5.211Zm-7.006-14.425c0-3.309-2.691-6-6-6S2,2.691,2,6s2.691,6,6,6,6-2.691,6-6Zm-6,4c-2.206,0-4-1.794-4-4s1.794-4,4-4,4,1.794,4,4-1.794,4-4,4Zm-1.042,5.005c.158.529-.144,1.086-.673,1.243-2.523.751-4.285,3.116-4.285,5.752v1c0,.553-.448,1-1,1s-1-.447-1-1v-1c0-3.514,2.35-6.667,5.715-7.668.528-.156,1.086.143,1.244.673Z"/>
</svg>
''';

// Notas
const _svgNota = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m13,20c0,.553-.448,1-1,1h-7c-2.757,0-5-2.243-5-5v-8C0,5.243,2.243,3,5,3h7c.552,0,1,.447,1,1s-.448,1-1,1h-7c-1.654,0-3,1.346-3,3v8c0,1.654,1.346,3,3,3h7c.552,0,1,.447,1,1Zm-5-3c.552,0,1-.447,1-1v-7h2c.552,0,1-.447,1-1s-.448-1-1-1h-6c-.552,0-1,.447-1,1s.448,1,1,1h2v7c0,.553.448,1,1,1Zm10,5c-.551,0-1-.448-1-1V3c0-.552.449-1,1-1s1-.447,1-1-.448-1-1-1c-.768,0-1.469.29-2,.766-.531-.476-1.232-.766-2-.766-.552,0-1,.447-1,1s.448,1,1,1,1,.448,1,1v18c0,.552-.449,1-1,1s-1,.447-1,1,.448,1,1,1c.768,0,1.469-.29,2-.766.531.476,1.232.766,2,.766.552,0,1-.447,1-1s-.448-1-1-1Zm2.25-18.843c-.538-.137-1.08.185-1.218.72-.138.534.184,1.08.719,1.218,1.325.341,2.25,1.535,2.25,2.905v8c0,1.37-.925,2.564-2.25,2.905-.535.138-.856.684-.719,1.218.116.451.522.751.968.751.083,0,.167-.01.25-.031,2.208-.569,3.75-2.561,3.75-4.843v-8c0-2.282-1.542-4.273-3.75-4.843Z"/>
</svg>
''';

// Carregar ficheiro
const _svgCarregar = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M12,24A12,12,0,1,0,0,12,12.013,12.013,0,0,0,12,24ZM12,2A10,10,0,1,1,2,12,10.011,10.011,0,0,1,12,2ZM6.293,10.879a1,1,0,0,0,1.414,0L11,7.587,11.007,18a1,1,0,0,0,2,0L13,7.586l3.293,3.293A1,1,0,1,0,17.731,9.49l-.024-.025L14.122,5.879a3,3,0,0,0-4.243,0h0L6.293,9.465A1,1,0,0,0,6.293,10.879Z"/>
</svg>
''';

const _chevronSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M9,19a1,1,0,0,1-.707-1.707L13.586,12,8.293,6.707A1,1,0,0,1,9.707,5.293l6,6a1,1,0,0,1,0,1.414l-6,6A1,1,0,0,1,9,19Z"/>
</svg>
''';

Widget _svg(String d, Color c, {double s = 22}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ──────────────────────────────────────────────────
class CriarScreen extends StatefulWidget {
  final VoidCallback? onDocCreated;
  const CriarScreen({super.key, this.onDocCreated});
  @override
  State<CriarScreen> createState() => _CriarScreenState();
}

class _CriarScreenState extends State<CriarScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  // ── Carregar ficheiro externo ──────────────────
  Future<void> _carregar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'rtf', 'md'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final ext  = (file.extension ?? '').toLowerCase();
      final name = file.name;
      final bytes = file.bytes;

      if (bytes == null) return;

      setState(() => _loading = true);

      if (ext == 'pdf') {
        // ── Guardar PDF em temp e abrir viewer ──
        final dir    = await getTemporaryDirectory();
        final tmpPath = '${dir.path}/$name';
        await File(tmpPath).writeAsBytes(bytes);

        if (!mounted) return;
        setState(() => _loading = false);

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PdfViewerScreen(path: tmpPath, title: name)),
        );
      } else if (ext == 'txt' || ext == 'md') {
        // ── Texto puro → abrir no editor ──
        final text  = utf8.decode(bytes, allowMalformed: true);
        final html  = '<p>${text.replaceAll('\n\n', '</p><p>').replaceAll('\n', '<br/>')}</p>';
        final docId = 'imported_${DateTime.now().millisecondsSinceEpoch}';

        if (!mounted) return;
        setState(() => _loading = false);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(
              importHtml: html,
              importTitle: name.replaceAll(RegExp(r'\.[^.]+$'), ''),
            ),
          ),
        );
        widget.onDocCreated?.call();
      } else if (ext == 'docx' || ext == 'doc') {
        // ── DOCX → enviar base64 ao editor para mammoth.js processar ──
        final b64 = base64Encode(bytes);
        final docTitle = name.replaceAll(RegExp(r'\.[^.]+$'), '');

        if (!mounted) return;
        setState(() => _loading = false);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditorScreen(
              importDocxBase64: b64,
              importTitle: docTitle,
            ),
          ),
        );
        widget.onDocCreated?.call();
      } else {
        setState(() => _loading = false);
        _showUnsupported();
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('FilePicker error: $e');
    }
  }

  void _showUnsupported() {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkSurface : AppColors.surface;
    final tp       = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final ts       = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Formato não suportado',
            style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Por agora só PDF, DOCX, TXT e MD são suportados.',
            style: GoogleFonts.syne(color: ts, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.syne(color: accColor(isDark), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkBackground    : AppColors.background;
    final textSec  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc      = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                child: Text('ESCOLHE UM TIPO',
                  style: GoogleFonts.syne(
                    color: textSec, fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 1.2)),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _Item(
                      svg: _svgDocumento, acc: acc, isDark: isDark,
                      title: 'Documento',
                      subtitle: 'Texto com formatação rica',
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const EditorScreen()));
                        widget.onDocCreated?.call();
                      },
                    ),
                    _Item(
                      svg: _svgApresentacao, acc: acc, isDark: isDark,
                      title: 'Apresentação',
                      subtitle: 'Em breve',
                      disabled: true,
                    ),
                    _Item(
                      svg: _svgCV, acc: acc, isDark: isDark,
                      title: 'Currículo / CV',
                      subtitle: 'Editor visual',
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CvEditorScreen()));
                        widget.onDocCreated?.call();
                      },
                    ),
                    _Item(
                      svg: _svgNota, acc: acc, isDark: isDark,
                      title: 'Nota',
                      subtitle: 'Anotações rápidas',
                      onTap: () async {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NotaScreen()));
                        widget.onDocCreated?.call();
                      },
                    ),
                    const SizedBox(height: 8),
                    // ── Separador "Importar" ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text('IMPORTAR',
                        style: GoogleFonts.syne(
                          color: textSec, fontSize: 11,
                          fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    ),
                    _Item(
                      svg: _svgCarregar, acc: acc, isDark: isDark,
                      title: 'Carregar ficheiro',
                      subtitle: 'PDF, DOCX, TXT e mais',
                      onTap: _carregar,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Indicador de carregamento ──
          if (_loading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(color: acc, strokeWidth: 2.5),
                    const SizedBox(height: 16),
                    Text('A processar…',
                        style: GoogleFonts.syne(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
class _Item extends StatelessWidget {
  final String svg;
  final Color acc;
  final bool isDark;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  const _Item({
    required this.svg, required this.acc, required this.isDark,
    required this.title, required this.subtitle,
    this.disabled = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;

    final iconColor = disabled ? textSec : acc;
    final iconBg    = disabled
        ? (isDark ? AppColors.darkSurface : const Color(0xFFF5F5F5))
        : acc.withOpacity(.1);

    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
          ),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(13)),
              child: Center(child: _svg(svg, iconColor, s: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                style: GoogleFonts.syne(
                  color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle,
                style: GoogleFonts.syne(color: textSec, fontSize: 13)),
            ])),
            if (!disabled) _svg(_chevronSvg, textSec, s: 18),
          ]),
        ),
      ),
    );
  }
}
