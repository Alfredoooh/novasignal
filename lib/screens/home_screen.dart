import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/theme.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ADocument> _docs = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> load() => _load();

  Future<void> _load() async {
    await DocumentService.instance.load();
    if (mounted) setState(() => _docs = DocumentService.instance.documents.toList());
  }

  Future<void> _openDoc(ADocument doc) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(document: doc)));
    _load();
  }

  Future<void> _deleteDoc(ADocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Eliminar documento',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('Eliminar "${doc.title}"?',
          style: const TextStyle(fontFamily: 'Syne', fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: AriaTheme.textSub, fontFamily: 'Syne'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar',
              style: TextStyle(color: AriaTheme.danger, fontFamily: 'Syne', fontWeight: FontWeight.w800))),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 110,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(builder: (ctx, box) {
              final t = ((box.maxHeight - kToolbarHeight) /
                  (110.0 - kToolbarHeight)).clamp(0.0, 1.0);
              return Container(
                color: Colors.white,
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.only(left: 20, bottom: 12 + 4 * t),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 20 + 14 * t,
                      height: 1,
                    ),
                    children: const [
                      TextSpan(text: 'A', style: TextStyle(color: Color(0xFF111111))),
                      TextSpan(text: 'ria', style: TextStyle(color: AriaTheme.acc)),
                    ],
                  ),
                ),
              );
            }),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFF0F0F0)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Text('RECENTES',
                style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                  fontSize: 11, letterSpacing: 1.4, color: AriaTheme.textSub.withOpacity(.5))),
            ),
          ),
          if (_docs.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _buildTile(_docs[i]), childCount: _docs.length)),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: AriaTheme.acc.withOpacity(.08), borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.description_outlined, size: 30, color: AriaTheme.acc),
      ),
      const SizedBox(height: 16),
      const Text('Ainda vazio',
        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF111111))),
      const SizedBox(height: 8),
      Text('Os teus documentos aparecem aqui.\nVai a Criar para começar.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Syne', fontSize: 13.5, color: AriaTheme.textSub, height: 1.6)),
    ]),
  );

  Widget _buildTile(ADocument doc) => InkWell(
    onTap: () => _openDoc(doc),
    onLongPress: () => _deleteDoc(doc),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AriaTheme.acc.withOpacity(.08), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.description_outlined, size: 22, color: AriaTheme.acc),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doc.title,
            style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF111111)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(doc.preview,
            style: TextStyle(fontFamily: 'Syne', fontSize: 12.5, color: AriaTheme.textSub),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Text(_fmt(doc.updatedAt),
              style: TextStyle(fontFamily: 'Syne', fontSize: 11, color: AriaTheme.textSub.withOpacity(.6))),
            if (doc.wordCount > 0) ...[
              Text(' · ', style: TextStyle(color: AriaTheme.textSub.withOpacity(.4), fontSize: 11)),
              Text('${doc.wordCount} palavras',
                style: TextStyle(fontFamily: 'Syne', fontSize: 11, color: AriaTheme.textSub.withOpacity(.6))),
            ],
          ]),
        ])),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
      ]),
    ),
  );
}