import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'auth_screen.dart';
import 'editor_native.dart';

// ── SVGs ────────────────────────────────────────────────────────
const _svgHamburger = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M3,8H21a1,1,0,0,0,0-2H3A1,1,0,0,0,3,8Zm18,8H3a1,1,0,0,0,0,2H21a1,1,0,0,0,0-2Zm0-5H3a1,1,0,0,0,0,2H21a1,1,0,0,0,0-2Z"/></svg>';
const _svgSun  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,17c-2.76,0-5-2.24-5-5s2.24-5,5-5,5,2.24,5,5-2.24,5-5,5Zm1-13V1c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1Zm0,19v-3c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1ZM5,12c0-.55-.45-1-1-1H1c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1Zm19,0c0-.55-.45-1-1-1h-3c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1ZM6.71,6.71c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm14,14c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm-16,0l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29ZM18.71,6.71l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Z"/></svg>';
const _svgMoon = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m15,12.5c0,3.018,1.5,5.733,3.54,7.646.85.798.462,2.242-.668,2.527-1.381.348-3.09.431-4.63.187C8.396,22.091,4.565,18.053,4.061,13.173,3.378,6.571,8.539,1,15,1c1.279,0,2.861.223,4,.629,1.106.394,1.344,1.867.417,2.588C16.948,6.136,15,9.13,15,12.5Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';
const _svgAccount = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,12A6,6,0,1,0,6,6,6.006,6.006,0,0,0,12,12ZM12,2a4,4,0,1,1-4,4A4,4,0,0,1,12,2ZM12,14a9.01,9.01,0,0,0-9,9,1,1,0,0,0,2,0,7,7,0,0,1,14,0,1,1,0,0,0,2,0A9.01,9.01,0,0,0,12,14Z"/></svg>';

// ── EditorController ─────────────────────────────────────────────
abstract class EditorController {
  ADocument? get document;
  DocType get docType;
  String? get importHtml;
  String? get importTitle;
  String? get importDocxBase64;
  Future<void> handleSaveMessage(Map<String, dynamic> data);
  void handleBack();
  void setSaving(bool v);
}

// ── EditorScreen ─────────────────────────────────────────────────
class EditorScreen extends StatefulWidget {
  final ADocument? document;
  final DocType docType;
  final String? importHtml;
  final String? importTitle;
  final String? importDocxBase64;
  final bool isRoot;

  const EditorScreen({
    super.key,
    this.document,
    this.docType = DocType.document,
    this.importHtml,
    this.importTitle,
    this.importDocxBase64,
    this.isRoot = false,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    implements EditorController {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override ADocument? get document        => widget.document;
  @override DocType    get docType         => widget.document?.docType ?? widget.docType;
  @override String?    get importHtml       => widget.importHtml;
  @override String?    get importTitle      => widget.importTitle;
  @override String?    get importDocxBase64 => widget.importDocxBase64;

  @override
  Future<void> handleSaveMessage(Map<String, dynamic> data) async {
    final innerData = jsonDecode(data['data'] as String) as Map<String, dynamic>;
    final now = DateTime.now();
    final id = (data['id'] as String?)?.isNotEmpty == true
        ? data['id'] as String
        : widget.document?.id ?? const Uuid().v4();
    final docTitle = (innerData['title'] as String?)?.trim();
    final doc = ADocument(
      id: id,
      title: (docTitle == null || docTitle.isEmpty) ? 'Sem título' : docTitle,
      htmlContent: innerData['html'] as String? ?? '',
      plainText:   innerData['text'] as String? ?? '',
      wordCount:   innerData['words'] as int?   ?? 0,
      createdAt:   widget.document?.createdAt ?? now,
      updatedAt:   now,
      docType:     widget.document?.docType ?? widget.docType,
    );
    await DocumentService.instance.save(doc);
    if (AuthService.instance.loggedIn) {
      AuthService.instance.syncDocument(doc.toJson()).ignore();
    }
    if (mounted) setState(() {});
  }

  @override
  void handleBack() {
    if (widget.isRoot) {
      _scaffoldKey.currentState?.openDrawer();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void setSaving(bool v) { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(isDark ? 0xFF242424 : 0xFFFFFFFF),
      drawer: widget.isRoot ? _AppDrawer() : null,
      body: buildEditorView(context, this),
    );
  }
}

// ── Drawer ───────────────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  const _AppDrawer();
  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  static const _bg    = Color(0xFF1C1C1E);
  static const _white = Colors.white;
  static const _grey  = Color(0xFF8E8E93);
  static const _light = Color(0xFFD1D1D6);

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    final auth   = AuthService.instance;
    final acc    = accColor(isDark);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFA6559), Color(0xFFF13223)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('W', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Write',
                    style: GoogleFonts.roboto(color: _white, fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),

            const SizedBox(height: 8),

            // ── Nav items ───────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // Tema toggle
                  _DrawerItem(
                    svg: isDark ? _svgSun : _svgMoon,
                    label: isDark ? 'Modo claro' : 'Modo escuro',
                    onTap: () {
                      _close();
                      themeNotifier.toggle();
                    },
                  ),
                ],
              ),
            ),

            // ── Conta ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(children: [
                auth.loggedIn
                  ? CircleAvatar(
                      radius: 18,
                      backgroundColor: acc.withOpacity(.2),
                      child: Text((auth.user?.name ?? 'U')[0].toUpperCase(),
                        style: TextStyle(color: acc, fontSize: 15, fontWeight: FontWeight.w700)),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white12,
                      child: SvgPicture.string(_svgAccount, width: 18, height: 18,
                        colorFilter: const ColorFilter.mode(_grey, BlendMode.srcIn)),
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: auth.loggedIn
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        Text(auth.user?.name ?? '',
                          style: GoogleFonts.roboto(color: _white, fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                        Text(auth.user?.email ?? auth.user?.phone ?? '',
                          style: GoogleFonts.roboto(color: _grey, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis),
                      ])
                    : GestureDetector(
                        onTap: () {
                          _close();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AuthScreen(onDone: () => Navigator.pop(context))));
                        },
                        child: Text('Entrar / Criar conta',
                          style: GoogleFonts.roboto(color: acc, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                ),
                if (auth.loggedIn)
                  GestureDetector(
                    onTap: () async {
                      _close();
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const EditorScreen(isRoot: true)),
                          (_) => false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Sair', style: GoogleFonts.roboto(
                        color: const Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final String svg, label;
  final VoidCallback onTap;
  const _DrawerItem({required this.svg, required this.label, required this.onTap});
  @override State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF3A3A3C) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          SvgPicture.string(widget.svg, width: 20, height: 20,
            colorFilter: const ColorFilter.mode(Color(0xFFD1D1D6), BlendMode.srcIn)),
          const SizedBox(width: 16),
          Text(widget.label,
            style: GoogleFonts.roboto(color: const Color(0xFFD1D1D6), fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
