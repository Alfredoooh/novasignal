import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

const _docIconSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/></svg>';
const _emptyDocSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1Z"/></svg>';
const _trashSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M21,4H17.9A5.009,5.009,0,0,0,13,0H11A5.009,5.009,0,0,0,6.1,4H3A1,1,0,0,0,3,6H4V19a5.006,5.006,0,0,0,5,5h6a5.006,5.006,0,0,0,5-5V6h1a1,1,0,0,0,0-2ZM11,2h2a3.006,3.006,0,0,1,2.829,2H8.171A3.006,3.006,0,0,1,11,2Zm7,17a3,3,0,0,1-3,3H9a3,3,0,0,1-3-3V6H18ZM11,17a1,1,0,0,1-2,0V11a1,1,0,0,1,2,0Zm4,0a1,1,0,0,1-2,0V11a1,1,0,0,1,2,0Z"/></svg>';

Widget _svg(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ADocument> _docs = [];
  final PageController _pageCtrl = PageController(viewportFraction: 0.78);

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _load();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() {});
  Future<void> load() => _load();

  Future<void> _load() async {
    await DocumentService.instance.load();
    if (mounted) {
      setState(() => _docs = DocumentService.instance.documents.toList());
    }
  }

  Future<void> _openDoc(ADocument doc) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditorScreen(document: doc)));
    _load();
  }

  Future<void> _deleteDoc(ADocument doc) async {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkSurface      : AppColors.surface;
    final textPrimary = isDark ? AppColors.darkTextPrimary  : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar documento',
            style: GoogleFonts.syne(
                color: textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        content: Text('Eliminar "${doc.title}"?',
            style: GoogleFonts.syne(color: textSec, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.syne(color: textSec)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.syne(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DocumentService.instance.delete(doc.id);
      _load();
    }
  }

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Agora mesmo';
    if (d.inMinutes < 60) return 'Há ${d.inMinutes} min';
    if (d.inHours < 24) return 'Há ${d.inHours}h';
    if (d.inDays == 1) return 'Ontem';
    if (d.inDays < 7) return 'Há ${d.inDays} dias';
    return DateFormat('d MMM yyyy', 'pt').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkBackground    : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider       : AppColors.divider;
    final acc         = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 0.5, color: divColor),

          // ── Label RECENTES
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Text('RECENTES',
                style: GoogleFonts.syne(
                    color: textSec,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
          ),

          // ── Carrossel horizontal (papel-preview) ou estado vazio
          if (_docs.isEmpty)
            Expanded(child: _buildEmpty(textPrimary, textSec, acc))
          else ...[
            // Carrossel de papel
            SizedBox(
              height: 230,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _docs.length,
                clipBehavior: Clip.none,
                itemBuilder: (ctx, i) => _buildPaperCard(
                    _docs[i], textPrimary, textSec, divColor, acc, isDark),
              ),
            ),

            const SizedBox(height: 28),

            // ── Label LISTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text('TODOS',
                  style: GoogleFonts.syne(
                      color: textSec,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2)),
            ),

            // ── Lista compacta
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _docs.length,
                itemBuilder: (ctx, i) => _buildListTile(
                    _docs[i], textPrimary, textSec, divColor, acc),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Cartão de papel no carrossel ──────────────────────────────────────────
  Widget _buildPaperCard(ADocument doc, Color tp, Color ts, Color div,
      Color acc, bool isDark) {
    // Papel sempre branco (mesmo em dark mode – é um "papel")
    const paperBg = Color(0xFFFFFFFF);
    const paperBorder = Color(0xFFE0E0E0);
    final lineColor = const Color(0xFFDDDDDD);
    final titleColor = const Color(0xFF1A1A1A);
    final textColor = const Color(0xFF555555);
    final dateColor = const Color(0xFF999999);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _openDoc(doc),
        onLongPress: () => _deleteDoc(doc),
        child: Container(
          decoration: BoxDecoration(
            color: paperBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: paperBorder, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do papel – faixa cinza clara com ícone e título
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border(
                      bottom: BorderSide(color: paperBorder, width: 0.5)),
                ),
                child: Row(
                  children: [
                    SvgPicture.string(_docIconSvg,
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(acc, BlendMode.srcIn)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.title,
                        style: GoogleFonts.syne(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _fmt(doc.updatedAt),
                      style: GoogleFonts.syne(
                          color: dateColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              // Corpo do papel – linhas simuladas com preview do texto
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview do conteúdo em linhas
                      Expanded(
                        child: _PaperLines(
                          text: doc.preview.isEmpty
                              ? 'Documento vazio'
                              : doc.preview,
                          lineColor: lineColor,
                          textColor: textColor,
                        ),
                      ),
                      // Rodapé info
                      if (doc.wordCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${doc.wordCount} palavras',
                            style: GoogleFonts.syne(
                                color: dateColor,
                                fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tile da lista compacta ─────────────────────────────────────────────────
  Widget _buildListTile(
      ADocument doc, Color tp, Color ts, Color div, Color acc) =>
      InkWell(
        onTap: () => _openDoc(doc),
        onLongPress: () => _deleteDoc(doc),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: div, width: 0.5))),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: acc.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(child: _svg(_docIconSvg, acc, s: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title,
                        style: GoogleFonts.syne(
                            color: tp,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(_fmt(doc.updatedAt),
                        style: GoogleFonts.syne(
                            color: ts, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _deleteDoc(doc),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _svg(_trashSvg, ts, s: 16),
                ),
              ),
            ],
          ),
        ),
      );

  // ── Estado vazio ──────────────────────────────────────────────────────────
  Widget _buildEmpty(Color tp, Color ts, Color acc) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: acc.withOpacity(.1), shape: BoxShape.circle),
              child: Center(child: _svg(_emptyDocSvg, acc, s: 36)),
            ),
            const SizedBox(height: 18),
            Text('Ainda vazio',
                style: GoogleFonts.syne(
                    color: tp,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Os teus documentos aparecem aqui.',
                style: GoogleFonts.syne(color: ts, fontSize: 14)),
          ],
        ),
      );
}

// ─── Widget que renderiza o preview do papel em "linhas" ──────────────────────
class _PaperLines extends StatelessWidget {
  final String text;
  final Color lineColor;
  final Color textColor;

  const _PaperLines({
    required this.text,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const lineHeight = 16.0;
        final maxLines = (constraints.maxHeight / lineHeight).floor();
        final words = text.split(' ');
        final lines = <String>[];
        var current = '';

        for (final w in words) {
          final test = current.isEmpty ? w : '$current $w';
          // Aproximação: ~28 chars por linha nesta largura
          if (test.length > 28 && current.isNotEmpty) {
            lines.add(current);
            current = w;
          } else {
            current = test;
          }
          if (lines.length >= maxLines) break;
        }
        if (current.isNotEmpty && lines.length < maxLines) lines.add(current);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(maxLines, (i) {
            final hasText = i < lines.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Stack(
                children: [
                  // Linha base decorativa
                  Container(
                    height: lineHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: lineColor, width: 0.6),
                      ),
                    ),
                  ),
                  // Texto real (se houver)
                  if (hasText)
                    Text(
                      lines[i],
                      style: GoogleFonts.syne(
                        color: textColor,
                        fontSize: 10,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
