import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

// SVGs inline usados neste ecrã
const _docIconSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1ZM13,17H8a1,1,0,0,1,0-2h5a1,1,0,0,1,0,2Zm3-4H8a1,1,0,0,1,0-2h8a1,1,0,0,1,0,2Z"/>
</svg>
''';

const _emptyDocSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,2H9.828A3.977,3.977,0,0,0,7,3.172L2.172,8A3.977,3.977,0,0,0,1,10.828V20a3,3,0,0,0,3,3H18a3,3,0,0,0,3-3V5A3,3,0,0,0,18,2ZM7,5.414V8H4.414ZM19,20a1,1,0,0,1-1,1H4a1,1,0,0,1-1-1V10H8A1,1,0,0,0,9,9V3h9a1,1,0,0,1,1,1Z"/>
</svg>
''';

const _chevronSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M9,19a1,1,0,0,1-.707-1.707L13.586,12,8.293,6.707A1,1,0,0,1,9.707,5.293l6,6a1,1,0,0,1,0,1.414l-6,6A1,1,0,0,1,9,19Z"/>
</svg>
''';

Widget _svg(String d, Color c, {double s = 20}) => SvgPicture.string(
    d, width: s, height: s, colorFilter: ColorFilter.mode(c, BlendMode.srcIn));

// HomeScreenState é público para GlobalKey no MainShell
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<ADocument> _docs = [];

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_onTheme);
    _load();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

  Future<void> load() => _load();

  Future<void> _load() async {
    await DocumentService.instance.load();
    if (mounted) setState(() => _docs = DocumentService.instance.documents.toList());
  }

  Future<void> _openDoc(ADocument doc) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditorScreen(document: doc)));
    _load();
  }

  Future<void> _deleteDoc(ADocument doc) async {
    final isDark       = themeNotifier.isDark;
    final bg           = isDark ? AppColors.darkSurface    : AppColors.surface;
    final textPrimary  = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec      = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Eliminar documento',
            style: GoogleFonts.syne(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Eliminar "${doc.title}"?',
            style: GoogleFonts.syne(color: textSec, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: GoogleFonts.syne(color: textSec)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
                style: GoogleFonts.syne(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) { await DocumentService.instance.delete(doc.id); _load(); }
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
    final bg          = isDark ? AppColors.darkBackground   : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary  : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor    = isDark ? AppColors.darkDivider      : AppColors.divider;
    final acc         = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── Large title colapsável — sem duplicação
          SliverAppBar(
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            expandedHeight: 100,
            automaticallyImplyLeading: false,
            // Sem `title:` aqui — só flexibleSpace para evitar duplicação
            flexibleSpace: LayoutBuilder(builder: (ctx, box) {
              final t = ((box.maxHeight - kToolbarHeight) /
                  (100.0 - kToolbarHeight)).clamp(0.0, 1.0);
              return Container(
                color: bg,
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(left: 20, bottom: 12 + 4 * t),
                child: Text(
                  'Início',
                  style: GoogleFonts.syne(
                    color: textPrimary,
                    fontSize: 20 + 12 * t,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              );
            }),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 0.5, color: divColor),
            ),
          ),

          // ── Label RECENTES
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text('RECENTES',
                style: GoogleFonts.syne(
                  color: textSec, fontSize: 11,
                  fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            ),
          ),

          // ── Lista ou estado vazio
          if (_docs.isEmpty)
            SliverFillRemaining(child: _buildEmpty(textPrimary, textSec, acc))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildTile(_docs[i], textPrimary, textSec, divColor, acc),
              childCount: _docs.length,
            )),
        ],
      ),
    );
  }

  Widget _buildEmpty(Color tp, Color ts, Color acc) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: acc.withOpacity(.1), shape: BoxShape.circle),
        child: Center(child: _svg(_emptyDocSvg, acc, s: 36)),
      ),
      const SizedBox(height: 18),
      Text('Ainda vazio',
          style: GoogleFonts.syne(color: tp, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('Os teus documentos aparecem aqui.',
          style: GoogleFonts.syne(color: ts, fontSize: 14)),
    ]),
  );

  Widget _buildTile(ADocument doc, Color tp, Color ts, Color div, Color acc) =>
      InkWell(
        onTap: () => _openDoc(doc),
        onLongPress: () => _deleteDoc(doc),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: div, width: 0.5))),
          child: Row(children: [
            // Ícone do documento
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: acc.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: _svg(_docIconSvg, acc, s: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.title,
                style: GoogleFonts.syne(color: tp, fontWeight: FontWeight.w700, fontSize: 15),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(doc.preview,
                style: GoogleFonts.syne(color: ts, fontSize: 13),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Text(_fmt(doc.updatedAt),
                  style: GoogleFonts.syne(color: ts, fontSize: 11)),
                if (doc.wordCount > 0) ...[
                  Text(' · ', style: GoogleFonts.syne(color: ts, fontSize: 11)),
                  Text('${doc.wordCount} palavras',
                    style: GoogleFonts.syne(color: ts, fontSize: 11)),
                ],
              ]),
            ])),
            _svg(_chevronSvg, ts, s: 18),
          ]),
        ),
      );
}
