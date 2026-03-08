import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../services/auth_service.dart';
import '../widgets/theme.dart';
import 'auth_screen.dart';
import 'agenda_screen.dart';
import 'editor_screen_native.dart';

// ─── SVGs ─────────────────────────────────────────────────────────
const _svgChatOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m19,4h-1.101c-.465-2.279-2.485-4-4.899-4H5C2.243,0,0,2.243,0,5v12.854c0,.794.435,1.52,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.19-.36l2.95-1.967c.691,1.935,2.541,3.324,4.711,3.324h5.697l3.964,2.643c.36.24.774.361,1.19.361.348,0,.696-.085,1.015-.256.7-.374,1.134-1.1,1.134-1.894v-12.854c0-2.757-2.243-5-5-5ZM2.23,17.979c-.019.012-.075.048-.152.007-.079-.042-.079-.109-.079-.131V5c0-1.654,1.346-3,3-3h8c1.654,0,3,1.346,3,3v7c0,1.654-1.346,3-3,3h-6c-.327,0-.541.159-.565.175l-4.205,2.804Zm19.77,3.876c0,.021,0,.089-.079.131-.079.041-.133.005-.151-.007l-4.215-2.811c-.164-.109-.357-.168-.555-.168h-6c-1.304,0-2.415-.836-2.828-2h4.828c2.757,0,5-2.243,5-5v-6h1c1.654,0,3,1.346,3,3v12.854Z"/></svg>''';

const _svgChatFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m13-.004H5C2.243-.004,0,2.239,0,4.996v12.854c0,.793.435,1.519,1.134,1.894.318.171.667.255,1.015.255.416,0,.831-.121,1.191-.36l3.963-2.643h5.697c2.757,0,5-2.243,5-5v-7C18,2.239,15.757-.004,13-.004Zm11,9v12.854c0,.793-.435,1.519-1.134,1.894-.318.171-.667.255-1.015.256-.416,0-.831-.121-1.19-.36l-3.964-2.644h-5.697c-1.45,0-2.747-.631-3.661-1.62l.569-.38h5.092c3.859,0,7-3.141,7-7v-7c0-.308-.027-.608-.065-.906,2.311.44,4.065,2.469,4.065,4.906Z"/></svg>''';

const _svgPreviewOutline = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M20.466,1.967L14.78,.221c-2.614-.797-5.406,.664-6.225,3.24l-.188,.539h-3.368C2.243,4,0,6.243,0,9v10c0,2.757,2.243,5,5,5h6c1.596,0,3.004-.766,3.92-1.934,.231,.032,.461,.052,.688,.052,2.167,0,4.144-1.414,4.775-3.564l3.413-10.397c.767-2.613-.727-5.39-3.331-6.189ZM11,22H5c-1.654,0-3-1.346-3-3V9c0-1.654,1.346-3,3-3h6c1.654,0,3,1.346,3,3v10c0,1.654-1.346,3-3,3ZM21.887,7.562l-3.412,10.397c-.358,1.214-1.413,2.022-2.603,2.132,.079-.353,.128-.716,.128-1.092V9c0-2.757-2.243-5-5-5h-.507c.534-1.501,2.163-2.341,3.7-1.867l5.686,1.746c1.562,.479,2.459,2.146,2.008,3.684Z"/></svg>''';

const _svgPreviewFilled = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.799,8.156l-3.413,10.398c-.447,1.519-1.57,2.658-2.952,3.203,.365-.847,.568-1.779,.568-2.758V9c0-3.86-3.141-7-7-7h-1.665C10.566,.381,12.723-.408,14.782,.221l5.686,1.746c2.604,.8,4.098,3.576,3.331,6.189Zm-7.797,.844v10c0,2.757-2.243,5-5,5H5.002C2.245,24,.002,21.757,.002,19V9C.002,6.243,2.245,4,5.002,4h6c2.757,0,5,2.243,5,5Z"/></svg>''';

const _svgAgenda = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M18,12.5c0,.829-.672,1.5-1.5,1.5H7.5c-.828,0-1.5-.671-1.5-1.5s.672-1.5,1.5-1.5h9c.828,0,1.5,.671,1.5,1.5Zm-6.5,3.5H7.5c-.828,0-1.5,.671-1.5,1.5s.672,1.5,1.5,1.5h4c.828,0,1.5-.671,1.5-1.5s-.672-1.5-1.5-1.5ZM24,7.5v11c0,3.033-2.468,5.5-5.5,5.5H5.5c-3.032,0-5.5-2.467-5.5-5.5V7.5C0,4.467,2.468,2,5.5,2h.5v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h6v-.5c0-.829,.672-1.5,1.5-1.5s1.5,.671,1.5,1.5v.5h.5c3.032,0,5.5,2.467,5.5,5.5Zm-3,11V9H3v9.5c0,1.378,1.121,2.5,2.5,2.5h13c1.379,0,2.5-1.122,2.5-2.5Z"/></svg>''';

const _svgUser = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="m12,0C5.383,0,0,5.383,0,12s5.383,12,12,12,12-5.383,12-12S18.617,0,12,0Zm-4,21.164v-.164c0-2.206,1.794-4,4-4s4,1.794,4,4v.164c-1.226.537-2.578.836-4,.836s-2.774-.299-4-.836Zm9.925-1.113c-.456-2.859-2.939-5.051-5.925-5.051s-5.468,2.192-5.925,5.051c-2.47-1.823-4.075-4.753-4.075-8.051C2,6.486,6.486,2,12,2s10,4.486,10,10c0,3.298-1.605,6.228-4.075,8.051Zm-5.925-15.051c-2.206,0-4,1.794-4,4s1.794,4,4,4,4-1.794,4-4-1.794-4-4-4Zm0,6c-1.103,0-2-.897-2-2s.897-2,2-2,2,.897,2,2-.897,2-2,2Z"/></svg>''';

const _svgNewChat = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22,1H2A1,1,0,0,0,1,2V16a3,3,0,0,0,3,3H12v3a1,1,0,0,0,.553.894A.985.985,0,0,0,13,23a1,1,0,0,0,.625-.219l4.457-3.781H21a3,3,0,0,0,3-3V2A1,1,0,0,0,22,1ZM21,16a1,1,0,0,1-1,1H17a1,1,0,0,0-.625.219L14,19.132V18a1,1,0,0,0-1-1H4a1,1,0,0,1-1-1V3H21Z"/><path d="M8,11h3v3a1,1,0,0,0,2,0V11h3a1,1,0,0,0,0-2H13V6a1,1,0,0,0-2,0V9H8a1,1,0,0,0,0,2Z"/></svg>''';

// ─── Worker URL ────────────────────────────────────────────────────
const _kWorker = 'https://dawn-sun-590a.alfredopjonas.workers.dev';

// ─── Chat Models ───────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
  Map<String,dynamic> toJson() => {'text': text, 'isUser': isUser};
  factory ChatMessage.fromJson(Map<String,dynamic> j) =>
    ChatMessage(text: j['text'] as String, isUser: j['isUser'] as bool);
}

class ChatConversation {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  ChatConversation({required this.id, required this.title, required this.messages, required this.createdAt});
}

// ─── Conversations Store ───────────────────────────────────────────
class ConversationStore {
  static final instance = ConversationStore._();
  ConversationStore._();
  final List<ChatConversation> _convs = [];
  List<ChatConversation> get all => List.unmodifiable(_convs);

  ChatConversation newConversation() {
    final c = ChatConversation(
      id: const Uuid().v4(),
      title: 'Nova conversa',
      messages: [],
      createdAt: DateTime.now(),
    );
    _convs.insert(0, c);
    return c;
  }

  void updateTitle(String id, String firstMessage) {
    final c = _convs.firstWhere((c) => c.id == id, orElse: () => _convs.first);
    c.title = firstMessage.length > 30
      ? '${firstMessage.substring(0, 30)}…'
      : firstMessage;
  }
}

// ─── DrawerIcon ────────────────────────────────────────────────────
class _DrawerIcon extends StatelessWidget {
  final Color color;
  const _DrawerIcon({required this.color});
  @override
  Widget build(BuildContext context) => Column(
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

// ─── EditorController ──────────────────────────────────────────────
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

// ─── EditorScreen ──────────────────────────────────────────────────
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
    with SingleTickerProviderStateMixin
    implements EditorController {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  int _tabIndex = 1;
  late ChatConversation _activeConv;

  @override ADocument? get document        => widget.document;
  @override DocType    get docType         => widget.document?.docType ?? widget.docType;
  @override String?    get importHtml       => widget.importHtml;
  @override String?    get importTitle      => widget.importTitle;
  @override String?    get importDocxBase64 => widget.importDocxBase64;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() => _tabIndex = _tabController.index);
    });
    themeNotifier.addListener(_onTheme);
    _activeConv = ConversationStore.instance.newConversation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    themeNotifier.removeListener(_onTheme);
    super.dispose();
  }

  void _onTheme() => setState(() {});

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

  void _switchTab(int idx) {
    _tabController.animateTo(idx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut);
    setState(() => _tabIndex = idx);
  }

  void _newConversation() {
    setState(() => _activeConv = ConversationStore.instance.newConversation());
    _scaffoldKey.currentState?.closeDrawer();
    Future.delayed(const Duration(milliseconds: 300), () => _switchTab(0));
  }

  void _openConversation(ChatConversation conv) {
    setState(() => _activeConv = conv);
    _scaffoldKey.currentState?.closeDrawer();
    Future.delayed(const Duration(milliseconds: 300), () => _switchTab(0));
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = themeNotifier.isDark;
    final bg         = isDark ? AppColors.darkBackground : AppColors.background;
    // Nav bar slightly lighter than body in dark mode
    final navBg      = isDark ? const Color(0xFF1A1A1A) : AppColors.navBg;
    final selected   = isDark ? AppColors.darkNavSelected   : AppColors.navSelected;
    final unselected = isDark ? AppColors.darkNavUnselected : AppColors.navUnselected;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: widget.isRoot
        ? _AppDrawer(
            scaffoldKey: _scaffoldKey,
            activeConvId: _activeConv.id,
            onNewChat: _newConversation,
            onOpenConv: _openConversation,
          )
        : null,
      body: _TabFadeView(
        controller: _tabController,
        children: [
          _ChatScreen(
            key: ValueKey(_activeConv.id),
            conversation: _activeConv,
            scaffoldKey: _scaffoldKey,
            isRoot: widget.isRoot,
            onConvUpdated: () => setState(() {}),
          ),
          buildEditorView(context, this),
        ],
      ),
      bottomNavigationBar: _BottomTabBar(
        index: _tabIndex,
        onTap: _switchTab,
        selectedColor: selected,
        unselectedColor: unselected,
        navBg: navBg,
        isDark: isDark,
      ),
    );
  }
}

// ─── Tab Fade View (opacity only, no slide) ────────────────────────
class _TabFadeView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  const _TabFadeView({required this.controller, required this.children});
  @override
  State<_TabFadeView> createState() => _TabFadeViewState();
}

class _TabFadeViewState extends State<_TabFadeView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (i) {
        final isActive = i == widget.controller.index;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          opacity: isActive ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !isActive,
            child: widget.children[i],
          ),
        );
      }),
    );
  }
}

// ─── Bottom Tab Bar ────────────────────────────────────────────────
class _BottomTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final Color selectedColor, unselectedColor, navBg;
  final bool isDark;
  const _BottomTabBar({
    required this.index, required this.onTap,
    required this.selectedColor, required this.unselectedColor,
    required this.navBg, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(children: [
            Expanded(child: _TabBtn(
              outlineSvg: _svgChatOutline, filledSvg: _svgChatFilled,
              label: 'Chat', selected: index == 0,
              selectedColor: selectedColor, unselectedColor: unselectedColor,
              onTap: () => onTap(0),
            )),
            Expanded(child: _TabBtn(
              outlineSvg: _svgPreviewOutline, filledSvg: _svgPreviewFilled,
              label: 'Preview', selected: index == 1,
              selectedColor: selectedColor, unselectedColor: unselectedColor,
              onTap: () => onTap(1),
            )),
          ]),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String outlineSvg, filledSvg, label;
  final bool selected;
  final Color selectedColor, unselectedColor;
  final VoidCallback onTap;
  const _TabBtn({
    required this.outlineSvg, required this.filledSvg, required this.label,
    required this.selected, required this.selectedColor,
    required this.unselectedColor, required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final color = selected ? selectedColor : unselectedColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.string(
            selected ? filledSvg : outlineSvg,
            key: ValueKey(selected),
            width: 20, height: 20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
          color: color, fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );
  }
}

// ─── Chat Screen ───────────────────────────────────────────────────
class _ChatScreen extends StatefulWidget {
  final ChatConversation conversation;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isRoot;
  final VoidCallback onConvUpdated;
  const _ChatScreen({
    super.key,
    required this.conversation,
    required this.scaffoldKey,
    required this.isRoot,
    required this.onConvUpdated,
  });
  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _busy    = false;
  bool _isDark  = false;

  List<ChatMessage> get _messages => widget.conversation.messages;

  @override
  void initState() {
    super.initState();
    _isDark = themeNotifier.isDark;
    themeNotifier.addListener(_onTheme);
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onTheme);
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTheme() => setState(() => _isDark = themeNotifier.isDark);

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _busy) return;
    final isFirst = _messages.isEmpty;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _ctrl.clear();
      _busy = true;
    });
    if (isFirst) {
      ConversationStore.instance.updateTitle(widget.conversation.id, text);
      widget.onConvUpdated();
    }
    _scrollBottom();
    _callAI(text);
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _callAI(String prompt) async {
    try {
      final history = _messages
        .where((m) => m.isUser)
        .take(6)
        .map((m) => {'role': 'user', 'content': m.text})
        .toList();

      final client = HttpClient();
      final req = await client.postUrl(Uri.parse('$_kWorker/chat'));
      req.headers.set('Content-Type', 'application/json');
      req.write(jsonEncode({
        'prompt': prompt,
        'model': 'compound-beta',
        'history': history,
      }));
      final res  = await req.close();
      final raw  = await res.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data['error'] != null) throw Exception(data['error']);

      final reply = (data['content'] ?? data['answer'] ?? data['text'] ?? '') as String;

      if (mounted) setState(() {
        _messages.add(ChatMessage(text: reply.trim(), isUser: false));
        _busy = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _messages.add(ChatMessage(text: 'Erro: $e', isUser: false));
        _busy = false;
      });
    }
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = _isDark;
    final bg      = isDark ? AppColors.darkBackground : AppColors.background;
    final surface = isDark ? const Color(0xFF2A2A2A)  : const Color(0xFFF0F0F0);
    final textP   = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textS   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    // Input slightly different from body
    final inputBg = isDark ? const Color(0xFF1A1A1A) : AppColors.background;
    final inputBorder = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final sendColor = isDark ? AppColors.darkNavSelected : AppColors.navSelected;

    return Container(
      color: bg,
      child: Column(children: [
        // ── AppBar ── mesmo padding que o editor nativo usa
        SafeArea(
          bottom: false,
          child: Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              if (widget.isRoot)
                IconButton(
                  icon: _DrawerIcon(color: textP),
                  onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
                )
              else
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              Text('Chat IA',
                style: TextStyle(color: textP, fontSize: 20, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // ── Mensagens ──
        Expanded(
          child: _messages.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                SvgPicture.string(_svgChatOutline, width: 44, height: 44,
                  colorFilter: ColorFilter.mode(textS, BlendMode.srcIn)),
                const SizedBox(height: 12),
                Text('Começa uma conversa',
                  style: TextStyle(color: textS, fontSize: 15, fontWeight: FontWeight.w400)),
              ]))
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _messages.length + (_busy ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(children: [
                        SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: textS)),
                        const SizedBox(width: 10),
                        Text('A pensar…', style: TextStyle(color: textS, fontSize: 13)),
                      ]),
                    );
                  }
                  final msg = _messages[i];
                  if (msg.isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12, left: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(msg.text,
                          style: TextStyle(color: textP, fontSize: 15)),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 32),
                      child: Text(msg.text,
                        style: TextStyle(color: textP, fontSize: 15, height: 1.55)),
                    );
                  }
                },
              ),
        ),

        // ── Input — sem divisória, bordas superiores curvas ──
        Container(
          decoration: BoxDecoration(
            color: inputBg,
            border: Border(
              top: BorderSide(color: inputBorder, width: 1),
              left: BorderSide(color: inputBorder, width: 1),
              right: BorderSide(color: inputBorder, width: 1),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            16, 12, 16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: TextStyle(color: textP, fontSize: 15),
                maxLines: 4, minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Pergunta algo…',
                  hintStyle: TextStyle(color: textS),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: sendColor),
                alignment: Alignment.center,
                child: Icon(Icons.arrow_upward_rounded,
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Drawer ────────────────────────────────────────────────────────
class _AppDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String activeConvId;
  final VoidCallback onNewChat;
  final ValueChanged<ChatConversation> onOpenConv;
  const _AppDrawer({
    required this.scaffoldKey,
    required this.activeConvId,
    required this.onNewChat,
    required this.onOpenConv,
  });
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
    final isDark    = themeNotifier.isDark;
    final bg        = isDark ? AppColors.darkDrawerBg : AppColors.background;
    final textP     = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final textS     = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final surfaceBg = isDark ? const Color(0xFF323232) : const Color(0xFFF5F5F5);
    final toggleBg  = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);
    final divider   = isDark ? AppColors.darkDivider : AppColors.divider;
    final activeColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    final convs = ConversationStore.instance.all;

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: bg,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),

          // Nova conversa
          ListTile(
            leading: _svg(_svgNewChat, textS, size: 20),
            title: Text('Nova conversa',
              style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w500)),
            onTap: widget.onNewChat,
          ),

          // Conversas guardadas
          if (convs.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Conversas',
                style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: convs.length,
                itemBuilder: (_, i) {
                  final conv = convs[i];
                  final isActive = conv.id == widget.activeConvId;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onOpenConv(conv),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: isActive
                          ? BoxDecoration(color: activeColor,
                              borderRadius: BorderRadius.circular(8))
                          : null,
                        margin: isActive
                          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 1)
                          : const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
                        child: Text(conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive ? textP : textS,
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            const Spacer(),

          Divider(height: 1, color: divider),

          // Agenda
          ListTile(
            leading: _svg(_svgAgenda, textS, size: 22),
            title: Text('Agenda',
              style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => AgendaPage()));
            },
          ),

          Divider(height: 1, color: divider),

          // Footer: avatar + theme toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(children: [
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
                        style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w700)))
                    : Center(child: _svg(_svgUser, textS, size: 26)),
                ),
              ),
              const SizedBox(width: 12),
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
                        color: textP, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        isDark ? 'Tema claro' : 'Tema escuro',
                        style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40, height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? textP : const Color(0xFFD0D0D0),
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
        ]),
      ),
    );
  }
}
