import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';
import 'cv_editor_screen.dart';
import 'nota_screen.dart';
import 'file_browser_screen.dart';

// ── SVG apenas para Carregar e chevron ────────────────────────
const _svgCarregar = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,24A12,12,0,1,0,0,12,12.013,12.013,0,0,0,12,24ZM12,2A10,10,0,1,1,2,12,10.011,10.011,0,0,1,12,2ZM6.293,10.879a1,1,0,0,0,1.414,0L11,7.587,11.007,18a1,1,0,0,0,2,0L13,7.586l3.293,3.293A1,1,0,1,0,17.731,9.49l-.024-.025L14.122,5.879a3,3,0,0,0-4.243,0h0L6.293,9.465A1,1,0,0,0,6.293,10.879Z"/></svg>';
const _svgChevron  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M9,19a1,1,0,0,1-.707-1.707L13.586,12,8.293,6.707A1,1,0,0,1,9.707,5.293l6,6a1,1,0,0,1,0,1.414l-6,6A1,1,0,0,1,9,19Z"/></svg>';

Widget _svg(String d, Color c, {double s = 22}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// ══════════════════════════════════════════════════════════════
// ECRÃ PRINCIPAL
// ══════════════════════════════════════════════════════════════
class CriarScreen extends StatefulWidget {
  final VoidCallback? onDocCreated;
  const CriarScreen({super.key, this.onDocCreated});
  @override
  State<CriarScreen> createState() => _CriarScreenState();
}

class _CriarScreenState extends State<CriarScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isDark  = themeNotifier.isDark;
    final bg      = isDark ? AppColors.darkBackground    : AppColors.background;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    const docColor  = Color(0xFF1D4ED8);
    const presColor = Color(0xFF2563EB);
    const cvColor   = Color(0xFF16A34A);
    const noteColor = Color(0xFFEA580C);
    final loadColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Label secção ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
            child: Text(
              'ESCOLHE UM TIPO',
              style: GoogleFonts.syne(
                color: textSec,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),

          // ── 4 tipos — PNG, sem linhas entre eles ──
          _TypeItem(
            pngAsset: 'assets/icons/ic_documento.png',
            iconColor: docColor,
            isDark: isDark,
            title: 'Documento',
            subtitle: 'Texto com formatação rica',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditorScreen(docType: DocType.document),
                ),
              );
              widget.onDocCreated?.call();
            },
          ),
          _TypeItem(
            pngAsset: 'assets/icons/ic_apresentacao.png',
            iconColor: presColor,
            isDark: isDark,
            title: 'Apresentação',
            subtitle: 'Em breve',
            disabled: true,
          ),
          _TypeItem(
            pngAsset: 'assets/icons/ic_cv.png',
            iconColor: cvColor,
            isDark: isDark,
            title: 'Currículo / CV',
            subtitle: 'Editor visual',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CvEditorScreen()),
              );
              widget.onDocCreated?.call();
            },
          ),
          _TypeItem(
            pngAsset: 'assets/icons/ic_nota.png',
            iconColor: noteColor,
            isDark: isDark,
            title: 'Nota',
            subtitle: 'Anotações rápidas',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotaScreen()),
              );
              widget.onDocCreated?.call();
            },
          ),

          const SizedBox(height: 24),

          // ── Label Importar ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              'IMPORTAR',
              style: GoogleFonts.syne(
                color: textSec,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),

          // ── Carregar — SVG (único) ───────────────
          _CarregarItem(
            isDark: isDark,
            iconColor: loadColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FileBrowserScreen(onDocImported: widget.onDocCreated),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ITEM DE TIPO — ícone PNG
// ══════════════════════════════════════════════════════════════
class _TypeItem extends StatelessWidget {
  final String pngAsset;
  final Color iconColor;
  final bool isDark;
  final String title;
  final String subtitle;
  final bool disabled;
  final VoidCallback? onTap;

  const _TypeItem({
    required this.pngAsset,
    required this.iconColor,
    required this.isDark,
    required this.title,
    required this.subtitle,
    this.disabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    // Dark: fundo com tinte da cor + ícone mais claro
    final iconBg = isDark
        ? Color.lerp(const Color(0xFF2C2C2E), iconColor, 0.28)!
        : iconColor.withOpacity(0.12);
    final iconTint = isDark
        ? Color.lerp(iconColor, Colors.white, 0.38)!
        : iconColor;

    return Opacity(
      opacity: disabled ? 0.38 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          // Sem borda, sem linha — só o ripple
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Ícone PNG
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Image.asset(
                      pngAsset,
                      width: 26,
                      height: 26,
                      color: iconTint,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.insert_drive_file_rounded,
                        color: iconTint,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Título + subtítulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.syne(
                          color: disabled ? textSec : textPri,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.syne(
                          color: textSec,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron SVG (só se activo)
                if (!disabled)
                  _svg(_svgChevron, textSec, s: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CARREGAR — SVG (único item com SVG)
// ══════════════════════════════════════════════════════════════
class _CarregarItem extends StatelessWidget {
  final bool isDark;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CarregarItem({
    required this.isDark,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPri = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconBg  = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _svg(_svgCarregar, iconColor, s: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carregar ficheiro',
                      style: GoogleFonts.syne(
                        color: textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PDF, DOCX, TXT e mais',
                      style: GoogleFonts.syne(
                        color: textSec,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _svg(_svgChevron, textSec, s: 18),
            ],
          ),
        ),
      ),
    );
  }
}
