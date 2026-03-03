import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'home_screen.dart';
import 'criar_screen.dart';
import 'templates_screen.dart';
import 'activity_screen.dart';
import 'agenda_screen.dart';
import 'auth_screen.dart';

import 'editor_native.dart';

// ─────────────────────────────────────────────────────────────
// SVGs drawer
// ─────────────────────────────────────────────────────────────
const _svgHome = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.121,9.069,15.536,1.483a5.008,5.008,0,0,0-7.072,0L.879,9.069A2.978,2.978,0,0,0,0,11.19v9.817a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V11.19A2.978,2.978,0,0,0,23.121,9.069ZM15,22.007H9V18.073a3,3,0,0,1,6,0Zm7-1a1,1,0,0,1-1,1H17V18.073a5,5,0,0,0-10,0v3.934H3a1,1,0,0,1-1-1V11.19a1.008,1.008,0,0,1,.293-.707L9.878,2.9a3.008,3.008,0,0,1,4.244,0l7.585,7.586A1.008,1.008,0,0,1,22,11.19Z"/></svg>';
const _svgCriar = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m15,13c0,.553-.447,1-1,1s-1-.447-1-1v-2h-2c-.553,0-1-.447-1-1s.447-1,1-1h2v-2c0-.553.447-1,1-1s1,.447,1,1v2h2c.553,0,1,.447,1,1s-.447,1-1,1h-2v2Zm9-8v8.373c0,1.053-.427,2.084-1.172,2.828l-2.627,2.627c-.744.745-1.775,1.172-2.828,1.172h-8.373c-2.757,0-5-2.243-5-5V5C4,2.243,6.243,0,9,0h10c2.757,0,5,2.243,5,5Zm-15,13h8v-3c0-1.105.895-2,2-2h3V5c0-1.654-1.346-3-3-3h-10c-1.654,0-3,1.346-3,3v10c0,1.654,1.346,3,3,3Zm8,4H5c-1.654,0-3-1.346-3-3V7c0-.553-.447-1-1-1s-1,.447-1,1v12c0,2.757,2.243,5,5,5h12c.553,0,1-.447,1-1s-.447-1-1-1Z"/></svg>';
const _svgTemplates = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m9,0h-4C2.243,0,0,2.243,0,5v2c0,1.103.897,2,2,2h7c1.103,0,2-.897,2-2V2c0-1.103-.897-2-2-2ZM2,7v-2c0-1.654,1.346-3,3-3h4l.002,5H2Zm20,8h-7c-1.103,0-2,.897-2,2v5c0,1.103.897,2,2,2h4c2.757,0,5-2.243,5-5v-2c0-1.103-.897-2-2-2Zm0,4c0,1.654-1.346,3-3,3h-4v-5h7v2ZM19,0h-4c-1.103,0-2,.897-2,2v9c0,1.103.897,2,2,2h7c1.103,0,2-.897,2-2v-6c0-2.757-2.243-5-5-5Zm-4,11V2h4c1.654,0,3,1.346,3,3l.002,6h-7.002Zm-6,0H2c-1.103,0-2,.897-2,2v6c0,2.757,2.243,5,5,5h4c1.103,0,2-.897,2-2v-9c0-1.103-.897-2-2-2Zm-4,11c-1.654,0-3-1.346-3-3v-6h7l.002,9h-4.002Z"/></svg>';
const _svgActivity = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,24C5.383,24,0,18.617,0,12S5.383,0,12,0s12,5.383,12,12-5.383,12-12,12Zm0-22C6.486,2,2,6.486,2,12s4.486,10,10,10,10-4.486,10-10S17.514,2,12,2Zm5,10c0-.553-.447-1-1-1h-3V6c0-.553-.448-1-1-1s-1,.447-1,1v6c0,.553,.448,1,1,1h4c.553,0,1-.447,1-1Z"/></svg>';
const _svgAgenda = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M19,2H18V1a1,1,0,0,0-2,0V2H8V1A1,1,0,0,0,6,1V2H5A5.006,5.006,0,0,0,0,7V19a5.006,5.006,0,0,0,5,5H19a5.006,5.006,0,0,0,5-5V7A5.006,5.006,0,0,0,19,2ZM2,7A3,3,0,0,1,5,4H19a3,3,0,0,1,3,3V8H2ZM19,22H5a3,3,0,0,1-3-3V10H22v9A3,3,0,0,1,19,22Z"/><circle cx="12" cy="15" r="1.5"/><circle cx="7" cy="15" r="1.5"/><circle cx="17" cy="15" r="1.5"/></svg>';
const _svgBell = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20.52,15.21l-1.8-1.81V8.94a6.86,6.86,0,0,0-5.82-6.88,6.74,6.74,0,0,0-7.62,6.69v4.65L3.48,15.21A1.65,1.65,0,0,0,4.65,18H8v.34A3.84,3.84,0,0,0,12,22a3.84,3.84,0,0,0,4-3.66V18h3.35a1.65,1.65,0,0,0,1.17-2.79ZM14,18.34A1.88,1.88,0,0,1,12,20a1.88,1.88,0,0,1-2-1.66V18h4ZM5,16l1.4-1.41A2,2,0,0,0,7,13.18V8.75A4.74,4.74,0,0,1,12.34,4,4.86,4.86,0,0,1,17,8.94v4.24a2,2,0,0,0,.58,1.41L19,16Z"/></svg>';
const _svgSettings = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,8a4,4,0,1,0,4,4A4,4,0,0,0,12,8Zm0,6a2,2,0,1,1,2-2A2,2,0,0,1,12,14ZM21.294,13.9l-.444-.256a9.1,9.1,0,0,0,0-3.29l.444-.256a3,3,0,1,0-3-5.2l-.445.257A8.977,8.977,0,0,0,15,3.513V3a3,3,0,0,0-6,0v.513A8.977,8.977,0,0,0,6.152,5.159L5.705,4.9a3,3,0,0,0-3,5.2l.444.256a9.1,9.1,0,0,0,0,3.29L2.705,13.9a3,3,0,0,0,3,5.2l.445-.257A8.977,8.977,0,0,0,9,20.487V21a3,3,0,0,0,6,0v-.513a8.977,8.977,0,0,0,2.848-1.646l.445.257a3,3,0,0,0,3-5.2Zm-2.548-3.776a7.048,7.048,0,0,1,0,3.75,1,1,0,0,0,.464,1.133l1.084.626a1,1,0,0,1-1,1.733l-1.086-.628a1,1,0,0,0-1.215.165,6.984,6.984,0,0,1-3.243,1.875,1,1,0,0,0-.751.969V21a1,1,0,0,1-2,0V19.748a1,1,0,0,0-.751-.969A6.984,6.984,0,0,1,7.006,16.9a1,1,0,0,0-1.215-.165l-1.084.627a1,1,0,1,1-1-1.732l1.084-.626a1,1,0,0,0,.464-1.133,7.048,7.048,0,0,1,0-3.75A1,1,0,0,0,4.79,8.992L3.706,8.366a1,1,0,0,1,1-1.733l1.086.628A1,1,0,0,0,7.006,7.1a6.984,6.984,0,0,1,3.243-1.875A1,1,0,0,0,11,4.252V3a1,1,0,0,1,2,0V4.252a1,1,0,0,0,.751.969A6.984,6.984,0,0,1,16.994,7.1a1,1,0,0,0,1.215.165l1.084-.627a1,1,0,1,1,1,1.732l-1.084.626A1,1,0,0,0,18.746,10.124Z"/></svg>';
const _svgAccount = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,12A6,6,0,1,0,6,6,6.006,6.006,0,0,0,12,12ZM12,2a4,4,0,1,1-4,4A4,4,0,0,1,12,2ZM12,14a9.01,9.01,0,0,0-9,9,1,1,0,0,0,2,0,7,7,0,0,1,14,0,1,1,0,0,0,2,0A9.01,9.01,0,0,0,12,14Z"/></svg>';
const _svgHamburger = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M3,8H21a1,1,0,0,0,0-2H3A1,1,0,0,0,3,8Zm18,8H3a1,1,0,0,0,0,2H21a1,1,0,0,0,0-2Zm0-5H3a1,1,0,0,0,0,2H21a1,1,0,0,0,0-2Z"/></svg>';
const _svgSun  = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12,17c-2.76,0-5-2.24-5-5s2.24-5,5-5,5,2.24,5,5-2.24,5-5,5Zm1-13V1c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1Zm0,19v-3c0-.55-.45-1-1-1s-1,.45-1,1v3c0,.55,.45,1,1,1s1-.45,1-1ZM5,12c0-.55-.45-1-1-1H1c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1Zm19,0c0-.55-.45-1-1-1h-3c-.55,0-1,.45-1,1s.45,1,1,1h3c.55,0,1-.45,1-1ZM6.71,6.71c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm14,14c.39-.39,.39-1.02,0-1.41l-2-2c-.39-.39-1.02-.39-1.41,0s-.39,1.02,0,1.41l2,2c.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Zm-16,0l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29ZM18.71,6.71l2-2c.39-.39,.39-1.02,0-1.41s-1.02-.39-1.41,0l-2,2c-.39,.39-.39,1.02,0,1.41,.2,.2,.45,.29,.71,.29s.51-.1,.71-.29Z"/></svg>';
const _svgMoon = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m15,12.5c0,3.018,1.5,5.733,3.54,7.646.85.798.462,2.242-.668,2.527-1.381.348-3.09.431-4.63.187C8.396,22.091,4.565,18.053,4.061,13.173,3.378,6.571,8.539,1,15,1c1.279,0,2.861.223,4,.629,1.106.394,1.344,1.867.417,2.588C16.948,6.136,15,9.13,15,12.5Z" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>';

// ─────────────────────────────────────────────────────────────
// EditorController interface
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// EditorScreen
// ─────────────────────────────────────────────────────────────
class EditorScreen extends StatefulWidget {
  final ADocument? document;
  final DocType docType;
  final String? importHtml;
  final String? importTitle;
  final String? importDocxBase64;
  /// Quando true: mostra drawer (hamburger) em vez de botão voltar
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
  bool _saving = false;
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
      plainText: innerData['text'] as String? ?? '',
      wordCount: innerData['words'] as int? ?? 0,
      createdAt: widget.document?.createdAt ?? now,
      updatedAt: now,
      docType: widget.document?.docType ?? widget.docType,
    );

    await DocumentService.instance.save(doc);
    if (mounted) {
      setState(() => _saving = false);
      _snack('Guardado');
    }
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
  void setSaving(bool v) { if (mounted) setState(() => _saving = v); }

  void _snack(String msg) {
    final isDark = themeNotifier.isDark;
    final acc = accColor(isDark);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: Colors.white)),
      backgroundColor: acc,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(isDark ? 0xFF242424 : 0xFFFFFFFF),
      drawer: widget.isRoot ? _AppDrawer(scaffoldKey: _scaffoldKey) : null,
      body: buildEditorView(context, this),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Drawer
// ─────────────────────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const _AppDrawer({required this.scaffoldKey});

  static const _bg     = Color(0xFF1C1C1E);
  static const _bgSel  = Color(0xFF2C2C2E);
  static const _white  = Colors.white;
  static const _grey   = Color(0xFF8E8E93);
  static const _accent = Color(0xFFFA6559);

  void _close(BuildContext ctx) => Navigator.of(ctx).pop();

  void _go(BuildContext ctx, Widget screen) {
    _close(ctx);
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    final isDark = themeNotifier.isDark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: _bg,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 8),
              child: Row(
                children: [
                  // App logo
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFA6559), Color(0xFFf13223)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('N',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('NovaSignal',
                      style: GoogleFonts.roboto(
                        color: _white, fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  // Bell
                  _IconBtn(svg: _svgBell, color: _grey, onTap: () => _close(context)),
                  const SizedBox(width: 4),
                  // Folder / documents
                  _IconBtn(
                    svg: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M10,4H4C1.8,4,0,5.8,0,8v12c0,2.2,1.8,4,4,4h16c2.2,0,4-1.8,4-4V10c0-2.2-1.8-4-4-4h-6.6L10,4z M4,6h5.2l2,2H20c1.1,0,2,0.9,2,2v10c0,1.1-0.9,2-2,2H4c-1.1,0-2-0.9-2-2V8C2,6.9,2.9,6,4,6z"/></svg>',
                    color: _grey,
                    onTap: () => _close(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Nav items ────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _NavItem(
                    svg: _svgHome,
                    label: 'Início',
                    onTap: () => _go(context, const HomeScreen()),
                  ),
                  _NavItem(
                    svg: _svgCriar,
                    label: 'Criar',
                    onTap: () => _go(context, CriarScreen(onDocCreated: () {})),
                  ),
                  _NavItem(
                    svg: _svgTemplates,
                    label: 'Templates',
                    onTap: () => _go(context, const TemplatesScreen()),
                  ),
                  _NavItem(
                    svg: _svgActivity,
                    label: 'Atividade',
                    onTap: () => _go(context, const ActivityScreen()),
                  ),
                  _NavItem(
                    svg: _svgAgenda,
                    label: 'Agenda',
                    onTap: () => _go(context, const AgendaScreen()),
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.08), thickness: 1),
                  const SizedBox(height: 8),

                  // Tema
                  _NavItem(
                    svg: isDark ? _svgSun : _svgMoon,
                    label: isDark ? 'Modo claro' : 'Modo escuro',
                    onTap: () {
                      _close(context);
                      themeNotifier.toggle();
                    },
                  ),
                ],
              ),
            ),

            // ── Bottom: conta + settings ─────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  // Avatar
                  auth.loggedIn
                    ? CircleAvatar(
                        radius: 18,
                        backgroundColor: _accent.withOpacity(.2),
                        child: Text(
                          (auth.user?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      )
                    : CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white12,
                        child: SvgPicture.string(_svgAccount, width: 18, height: 18,
                          colorFilter: const ColorFilter.mode(_grey, BlendMode.srcIn)),
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (auth.loggedIn) ...[
                          Text(auth.user?.name ?? '',
                            style: GoogleFonts.roboto(color: _white, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(auth.user?.email ?? auth.user?.phone ?? '',
                            style: GoogleFonts.roboto(color: _grey, fontSize: 11.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else
                          GestureDetector(
                            onTap: () {
                              _close(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AuthScreen(onDone: () => Navigator.pop(context))));
                            },
                            child: Text('Entrar / Criar conta',
                              style: GoogleFonts.roboto(color: _accent, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                  // Settings
                  _IconBtn(
                    svg: _svgSettings,
                    color: _grey,
                    onTap: () {
                      _close(context);
                      if (auth.loggedIn) {
                        _showAccountSheet(context, auth);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => AuthScreen(onDone: () => Navigator.pop(context))));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSheet(BuildContext context, AuthService auth) {
    final isDark = themeNotifier.isDark;
    final acc  = accColor(isDark);
    final bg   = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final tp   = isDark ? Colors.white : const Color(0xFF111111);
    final ts   = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B6B6B);

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: ts.withOpacity(.3), borderRadius: BorderRadius.circular(2))),
            CircleAvatar(radius: 30, backgroundColor: acc.withOpacity(.15),
                child: Text((auth.user?.name ?? 'U')[0].toUpperCase(),
                    style: TextStyle(color: acc, fontSize: 26, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            Text(auth.user?.name ?? '', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w700, color: tp)),
            const SizedBox(height: 4),
            Text(auth.user?.phone ?? auth.user?.email ?? '',
                style: GoogleFonts.roboto(fontSize: 13.5, color: ts)),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const EditorScreen(isRoot: true)),
                      (_) => false,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Terminar sessão', style: GoogleFonts.roboto(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Drawer item
// ─────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final String svg;
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.svg, required this.label, required this.onTap});
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF3A3A3C) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.string(widget.svg, width: 20, height: 20,
              colorFilter: const ColorFilter.mode(Color(0xFFD1D1D6), BlendMode.srcIn)),
            const SizedBox(width: 16),
            Text(widget.label,
              style: GoogleFonts.roboto(
                color: const Color(0xFFD1D1D6),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Icon button helper
// ─────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final String svg;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.svg, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 38, height: 38,
        child: Center(
          child: SvgPicture.string(svg, width: 20, height: 20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
      ),
    );
  }
}
