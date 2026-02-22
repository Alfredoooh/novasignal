import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DocumentService.instance.load();
    if (mounted) setState(() => _docs = DocumentService.instance.documents.toList());
  }

  Future<void> _openDoc(ADocument doc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditorScreen(document: doc)),
    );
    _load(); // recarrega após voltar
  }

  Future<void> _deleteDoc(ADocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Eliminar documento',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('Tens a certeza que queres eliminar "${doc.title}"?',
          style: const TextStyle(fontFamily: 'Syne', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: AriaTheme.textSub, fontFamily: 'Syne')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: AriaTheme.danger, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DocumentService.instance.delete(doc.id);
      _load();
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return DateFormat('d MMM yyyy', 'pt').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App Bar com nome "Aria" grande ──
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 140,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: const Text(
                'Aria',
                style: TextStyle(
                  fontFamily: 'Syne', fontWeight: FontWeight.w800,
                  fontSize: 28, color: Color(0xFF111111),
                ),
              ),
              background: Container(
                color: Colors.white,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 50),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 28),
                        children: [
                          TextSpan(text: 'A', style: TextStyle(color: Color(0xFF111111))),
                          TextSpan(text: 'ria', style: TextStyle(color: AriaTheme.acc)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFF0F0F0)),
            ),
          ),

          // ── Secção Recentes ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Text(
                'RECENTES',
                style: TextStyle(
                  fontFamily: 'Syne', fontWeight: FontWeight.w800,
                  fontSize: 11, letterSpacing: 1.4,
                  color: AriaTheme.textSub.withOpacity(.6),
                ),
              ),
            ),
          ),

          // ── Lista de documentos ou estado vazio ──
          _docs.isEmpty
              ? SliverFillRemaining(child: _buildEmpty())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _buildDocTile(_docs[i]),
                    childCount: _docs.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AriaTheme.acc.withOpacity(.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.description_outlined, size: 30, color: AriaTheme.acc),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ainda vazio',
            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF111111)),
          ),
          const SizedBox(height: 8),
          Text(
            'Os teus documentos aparecem aqui.\nVai a Criar para começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Syne', fontSize: 13.5,
              color: AriaTheme.textSub, height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTile(ADocument doc) {
    return InkWell(
      onTap: () => _openDoc(doc),
      onLongPress: () => _deleteDoc(doc),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Row(
          children: [
            // Ícone do documento
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AriaTheme.acc.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, size: 22, color: AriaTheme.acc),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: const TextStyle(
                      fontFamily: 'Syne', fontWeight: FontWeight.w700,
                      fontSize: 15, color: Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    doc.preview,
                    style: TextStyle(
                      fontFamily: 'Syne', fontSize: 12.5,
                      color: AriaTheme.textSub,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatDate(doc.updatedAt),
                        style: TextStyle(
                          fontFamily: 'Syne', fontSize: 11,
                          color: AriaTheme.textSub.withOpacity(.6),
                        ),
                      ),
                      if (doc.wordCount > 0) ...[
                        Text(' · ', style: TextStyle(color: AriaTheme.textSub.withOpacity(.4))),
                        Text(
                          '${doc.wordCount} palavras',
                          style: TextStyle(
                            fontFamily: 'Syne', fontSize: 11,
                            color: AriaTheme.textSub.withOpacity(.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}
