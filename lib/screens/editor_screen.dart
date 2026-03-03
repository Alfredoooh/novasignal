import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'auth_screen.dart';
import 'editor_screen_native.dart';

// ─────────────────────────────────────────────
// SVGs
// ─────────────────────────────────────────────
const String _agendaOutlineSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18,12.5c0,.829-.672,1.5-1.5,1.5H7.5c-.828,0-1.5-.671-1.5-1.5s.672-1.5,1.5-1.5h9c.828,0,1.5,.671,1.5,1.5Zm-6.5,3.5H7.5c-.828,0-1.5,.671-1.5,1.5s.672,1.5,1.5,1.5h4c.828,0,1.5-.671,1.5-1.5s-.672-1.5-1.5-1.5ZM24,7.5v11c0,3.033-2.468,5.5-5.5,5.5H5.5c-3.032,0-5.5-2.467-5.5-5.5V7.5C0,4.467,2.468,2,5.5,2h.5v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h6v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h.5c3.032,0,5.5,2.467,5.5,5.5Zm-3,11V9H3v9.5c0,1.378,1.121,2.5,2.5,2.5h13c1.379,0,2.5-1.122,2.5-2.5Z"/>
</svg>
''';

const String _utilizadorSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm-4,21.164v-.164c0-2.206,1.794-4,4-4s4,1.794,4,4v.164c-1.226.537-2.578.836-4,.836s-2.774-.299-4-.836Zm9.925-1.113c-.456-2.859-2.939-5.051-5.925-5.051s-5.468,2.192-5.925,5.051c-2.47-1.823-4.075-4.753-4.075-8.051C2,6.486,6.486,2,12,2s10,4.486,10,10c0,3.298-1.605,6.228-4.075,8.051Zm-5.925-15.051c-2.206,0-4,1.794-4,4s1.794,4,4,4,4-1.794,4-4-1.794-4-4-4Zm0,6c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2Z"/>
</svg>
''';

const String _chatSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="m19,4h-1.101c-.465-2.279-2.485-4-4.899-4H5C2.243,0,0,2.243,0,5v12.854c0,.794.435,1.52,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.19-.36l2.95-1.967c.691,1.935,2.541,3.324,4.711,3.324h5.697l3.964,2.643c.36.24.774.361,1.19.361.348,0,.696-.085,1.015-.256.7-.374,1.134-1.1,1.134-1.894v-12.854c0-2.757-2.243-5-5-5Z"/>
</svg>
''';

const String _previewSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M21,0H3A3,3,0,0,0,0,3V21a3,3,0,0,0,3,3H21a3,3,0,0,0,3-3V3A3,3,0,0,0,21,0ZM2,3A1,1,0,0,1,3,2H21a1,1,0,0,1,1,1V7H2ZM22,21a1,1,0,0,1-1,1H3a1,1,0,0,1-1-1V9H22ZM7,4A1,1,0,1,1,6,3,1,1,0,0,1,7,4ZM4,4A1,1,0,1,1,3,3,1,1,0,0,1,4,4Z"/>
</svg>
''';

// ─────────────────────────────────────────────
// ÍCONE DRAWER — idêntico ao reference
// ─────────────────────────────────────────────
class _DrawerIcon extends StatelessWidget {
  final Color color;
  const _DrawerIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 22, height: 2,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 5),
        Container(width: 14, height: 2,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// EDITOR CONTROLLER
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
// EDITOR SCREEN
// ─────────────────────────────────────────────
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
  int _tabIndex = 1; // 0=Chat, 1=Preview(editor)

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
    final bg         = isDark ? AppColors.darkBackground : AppColors.background;
    final navBg      = isDark ? AppColors.darkNavBg      : AppColors.navBg;
    final selected   = isDark ? AppColors.darkNavSelected   : AppColors.navSelected;
    final unselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;
    final divider    = isDark ? AppColors.darkDivider    : AppColors.divider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      extendBodyBehindAppBar: false,
      drawer: widget.isRoot ? _AppDrawer(isDark: isDark) : null,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _ChatPlaceholder(isDark: isDark),
          buildEditorView(context, this),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, thickness: 1, color: divider),
          Container(
            color: navBg,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: Row(children: [
                  Expanded(child: _TabBtn(
                    svg: _chatSvg, label: 'Chat',
                    selected: _tabIndex == 0,
                    selectedColor: selected, unselectedColor: unselected,
                    onTap: () => setState(() => _tabIndex = 0),
                  )),
                  Expanded(child: _TabBtn(
                    svg: _previewSvg, label: 'Preview',
                    selected: _tabIndex == 1,
                    selectedColor: selected, unselectedColor: unselected,
                    onTap: () => setState(() => _tabIndex = 1),
                  )),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB BUTTON
// ─────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String svg, label;
  final bool selected;
  final Color selectedColor, unselectedColor;
  final VoidCallback onTap;
  const _TabBtn({required this.svg, required this.label, required this.selected,
    required this.selectedColor, required this.unselectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.string(svg, width: 20, height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          color: color, fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// CHAT PLACEHOLDER
// ─────────────────────────────────────────────
class _ChatPlaceholder extends StatelessWidget {
  final bool isDark;
  const _ChatPlaceholder({required this.isDark});
  @override
  Widget build(BuildContext context) {
    final text = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      SvgPicture.string(_chatSvg, width: 48, height: 48,
        colorFilter: ColorFilter.mode(text, BlendMode.srcIn)),
      const SizedBox(height: 16),
      Text('Chat IA em breve',
        style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w500)),
    ]));
  }
}

// ─────────────────────────────────────────────
// DRAWER — idêntico ao reference
// ─────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  final bool isDark;
  const _AppDrawer({required this.isDark});
  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> {
  @override
  void initState() { super.initState(); themeNotifier.addListener(_rebuild); }
  @override
  void dispose() { themeNotifier.removeListener(_rebuild); super.dispose(); }
  void _rebuild() => setState(() {});

  Widget _svg(String data, Color color, {double size = 22}) =>
    SvgPicture.string(data, width: size, height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn));

  @override
  Widget build(BuildContext context) {
    final isDark      = themeNotifier.isDark;
    final bg          = isDark ? AppColors.darkDrawerBg : AppColors.background;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSec     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceBg   = isDark ? const Color(0xFF323232) : const Color(0xFFF5F5F5);
    final toggleBg    = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    final divider     = isDark ? AppColors.darkDivider : AppColors.divider;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Agenda
            ListTile(
              leading: _svg(_agendaOutlineSvg, textSec, size: 22),
              title: Text('Agenda',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AgendaPage()));
              },
            ),
            const Spacer(),
            Divider(height: 1, color: divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(children: [
                // Avatar utilizador
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (!AuthService.instance.loggedIn) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AuthScreen(onDone: () => Navigator.pop(context))));
                    }
                  },
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: surfaceBg, shape: BoxShape.circle),
                    child: AuthService.instance.loggedIn
                      ? Center(child: Text(
                          (AuthService.instance.user?.name ?? 'U')[0].toUpperCase(),
                          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700)))
                      : Center(child: _svg(_utilizadorSvg, textSec, size: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                // Toggle tema
                Expanded(
                  child: GestureDetector(
                    onTap: themeNotifier.toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: toggleBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(children: [
                        Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: textPrimary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(
                          isDark ? 'Tema claro' : 'Tema escuro',
                          style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 40, height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark ? textPrimary : const Color(0xFFD0D0D0),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(3),
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkDrawerBg : AppColors.background,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
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
