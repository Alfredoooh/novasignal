import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import 'file_browser_screen.dart';

const _svgDocumento = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19.949,5.536,16.465,2.05A6.958,6.958,0,0,0,11.515,0H7A5.006,5.006,0,0,0,2,5V19a5.006,5.006,0,0,0,5,5H17a5.006,5.006,0,0,0,5-5V10.485A6.951,6.951,0,0,0,19.949,5.536ZM18.535,6.95A4.983,4.983,0,0,1,19.316,8H15a1,1,0,0,1-1-1V2.684a5.01,5.01,0,0,1,1.051.78ZM20,19a3,3,0,0,1-3,3H7a3,3,0,0,1-3-3V5A3,3,0,0,1,7,2h4.515c.164,0,.323.032.485.047V7a3,3,0,0,0,3,3h4.953c.015.162.047.32.047.485Z"/></svg>';
const _svgApresentacao = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23,16h-.28l-.86-2.582c-.682-2.045-2.588-3.418-4.743-3.418H6.883c-.3,0-.595,.028-.883,.079v-3.079c0-1.654,1.346-3,3-3h.172c.413,1.164,1.524,2,2.828,2h3c1.654,0,3-1.346,3-3s-1.346-3-3-3h-3c-1.304,0-2.415,.836-2.828,2h-.172c-2.757,0-5,2.243-5,5v3.914c-.851,.6-1.514,1.466-1.861,2.505l-.859,2.581h-.279c-.553,0-1,.448-1,1s.447,1,1,1h.975c.02,0,.039,0,.058,0H11v4h-3c-.553,0-1,.448-1,1s.447,1,1,1h8c.553,0,1-.448,1-1s-.447-1-1-1h-3v-4h10c.553,0,1-.448,1-1s-.447-1-1-1ZM12,2h3c.552,0,1,.449,1,1s-.448,1-1,1h-3c-.552,0-1-.449-1-1s.448-1,1-1ZM4.036,14.051c.41-1.227,1.554-2.051,2.847-2.051h10.234c1.293,0,2.437,.824,2.847,2.051l.649,1.949H3.387l.649-1.949Z"/></svg>';
const _svgCV = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m21,12h-9c-1.657,0-3,1.343-3,3v6c0,1.657,1.343,3,3,3h9c1.657,0,3-1.343,3-3v-6c0-1.657-1.343-3-3-3Zm-7.5,8.4c.411,0,.758-.276.866-.653.022-.079.068-.747.835-.747s.811.705.799.804c-.15,1.237-1.222,2.196-2.5,2.196-1.381,0-2.5-1.119-2.5-2.5v-3c0-1.381,1.119-2.5,2.5-2.5,1.281,0,2.354.963,2.5,2.204.011.097.002.796-.804.796s-.809-.674-.833-.755c-.11-.372-.456-.645-.863-.645-.496,0-.9.404-.9.9v3c0,.496.404.9.9.9Zm7.506.025c-.126.647-.583,1.575-1.628,1.575s-1.51-.97-1.618-1.531l-1.072-5.253c-.101-.496.278-.96.784-.96.38,0,.708.268.784.64l1.072,5.253c.013.065.031.117.05.159.02-.047.042-.109.057-.188l1.053-5.222c.075-.373.403-.642.784-.642.505,0,.884.463.784.958l-1.051,5.211Zm-7.006-14.425c0-3.309-2.691-6-6-6S2,2.691,2,6s2.691,6,6,6,6-2.691,6-6Zm-6,4c-2.206,0-4-1.794-4-4s1.794-4,4-4,4,1.794,4,4-1.794,4-4,4Zm-1.042,5.005c.158.529-.144,1.086-.673,1.243-2.523.751-4.285,3.116-4.285,5.752v1c0,.553-.448,1-1,1s-1-.447-1-1v-1c0-3.514,2.35-6.667,5.715-7.668.528-.156,1.086.143,1.244.673Z"/></svg>';
const _svgNota = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m13,20c0,.553-.448,1-1,1h-7c-2.757,0-5-2.243-5-5v-8C0,5.243,2.243,3,5,3h7c.552,0,1,.447,1,1s-.448,1-1,1h-7c-1.654,0-3,1.346-3,3v8c0,1.654,1.346,3,3,3h7c.552,0,1,.447,1,1Zm-5-3c.552,0,1-.447,1-1v-7h2c.552,0,1-.447,1-1s-.448-1-1-1h-6c-.552,0-1,.447-1,1s.448,1,1,1h2v7c0,.553.448,1,1,1Zm10,5c-.551,0-1-.448-1-1V3c0-.552.449-1,1-1s1-.447,1-1-.448-1-1-1c-.768,0-1.469.29-2,.766-.531-.476-1.232-.766-2-.766-.552,0-1,.447-1,1s.448,1,1,1,1,.448,1,1v18c0,.552-.449,1-1,1s-1,.447-1,1,.448,1,1,1c.768,0,1.469-.29,2-.766.531.476,1.232.766,2,.766.552,0,1-.447,1-1s-.448-1-1-1Z"/></svg>';
const _svgCarregar = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,24A12,12,0,1,0,0,12,12.013,12.013,0,0,0,12,24ZM12,2A10,10,0,1,1,2,12,10.011,10.011,0,0,1,12,2ZM6.293,10.879a1,1,0,0,0,1.414,0L11,7.587,11.007,18a1,1,0,0,0,2,0L13,7.586l3.293,3.293A1,1,0,1,0,17.731,9.49l-.024-.025L14.122,5.879a3,3,0,0,0-4.243,0h0L6.293,9.465A1,1,0,0,0,6.293,10.879Z"/></svg>';
const _chevronSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M9,19a1,1,0,0,1-.707-1.707L13.586,12,8.293,6.707A1,1,0,0,1,9.707,5.293l6,6a1,1,0,0,1,0,1.414l-6,6A1,1,0,0,1,9,19Z"/></svg>';

Widget _svg(String d, Color c, {double s = 22}) => SvgPicture.string(d,
    width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

class CriarScreen extends StatefulWidget {
  final VoidCallback? onDocCreated;
  const CriarScreen({super.key, this.onDocCreated});
  @override
  State<CriarScreen> createState() => _CriarScreenState();
}

class _CriarScreenState extends State<CriarScreen> {
  @override
  void initState() { super.initState(); themeNotifier.addListener(_onTheme); }
  @override
  void dispose() { themeNotifier.removeListener(_onTheme); super.dispose(); }
  void _onTheme() => setState(() {});

  void _carregar() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FileBrowserScreen(onDocImported: widget.onDocCreated),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = themeNotifier.isDark;
    final bg       = isDark ? AppColors.darkBackground    : AppColors.background;
    final textSec  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor = isDark ? AppColors.darkDivider       : AppColors.divider;

    // per-type colors (no pink)
    final docColor  = const Color(0xFF1D4ED8);
    final presColor = const Color(0xFF2563EB);
    final cvColor   = const Color(0xFF16A34A);
    final noteColor = const Color(0xFFEA580C);
    final loadColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 0.5, color: divColor),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Text('ESCOLHE UM TIPO', style: GoogleFonts.roboto(
              color: textSec, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
        ),
        Expanded(child: ListView(padding: EdgeInsets.zero, children: [
          _Item(
            svg: _svgDocumento, iconColor: docColor, isDark: isDark,
            title: 'Documento', subtitle: 'Texto com formatação rica',
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EditorScreen(docType: DocType.document)));
              widget.onDocCreated?.call();
            },
          ),
          _Item(
            svg: _svgApresentacao, iconColor: presColor, isDark: isDark,
            title: 'Apresentação', subtitle: 'Em breve', disabled: true,
          ),
          _Item(
            svg: _svgCV, iconColor: cvColor, isDark: isDark,
            title: 'Currículo / CV', subtitle: 'Em breve', disabled: true,
          ),
          _Item(
            svg: _svgNota, iconColor: noteColor, isDark: isDark,
            title: 'Nota', subtitle: 'Em breve', disabled: true,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('IMPORTAR', style: GoogleFonts.roboto(
                color: textSec, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ),
          _Item(
            svg: _svgCarregar, iconColor: loadColor, isDark: isDark,
            title: 'Carregar ficheiro', subtitle: 'PDF, DOCX, TXT e mais',
            onTap: _carregar,
          ),
        ])),
      ]),
    );
  }
}

class _Item extends StatelessWidget {
  final String svg;
  final Color iconColor;
  final bool isDark;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  const _Item({
    required this.svg,
    required this.iconColor,
    required this.isDark,
    required this.title,
    required this.subtitle,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;

    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
              color: bg,
              border: Border(bottom: BorderSide(color: divColor, width: 0.5))),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Center(child: _svg(svg, iconColor, s: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.roboto(
                  color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text(subtitle, style: GoogleFonts.roboto(color: textSec, fontSize: 13)),
            ])),
            if (!disabled) _svg(_chevronSvg, textSec, s: 18),
          ]),
        ),
      ),
    );
  }
}
