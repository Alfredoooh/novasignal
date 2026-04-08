/*import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter/services.dart';
import 'services/document_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/editor_screen.dart';
import 'widgets/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  await DocumentService.instance.load();
  await AppSettings.instance.load();
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  await _initBackgroundService();
  runApp(const WriteApp());
}

Future<void> _initBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onBgStart,
      autoStart: true,
      isForegroundMode: false,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: _onBgStart,
      onBackground: _onIosBg,
    ),
  );
}

@pragma('vm:entry-point')
void _onBgStart(ServiceInstance service) {}

@pragma('vm:entry-point')
Future<bool> _onIosBg(ServiceInstance service) async => true;

class WriteApp extends StatefulWidget {
  const WriteApp({super.key});
  @override
  State<WriteApp> createState() => _WriteAppState();
}

class _WriteAppState extends State<WriteApp> {
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
    final isDark = themeNotifier.isDark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Write',
      debugShowCheckedModeBanner: false,
        restorationScopeId: 'novasignal_root',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF13223),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B1B1B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFA6559),
          surface: Color(0xFF343434),
          onSurface: Color(0xFFFFE8E3),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _authed = AuthService.instance.loggedIn;
  }

  void _onDone() => setState(() => _authed = true);

  @override
  Widget build(BuildContext context) {
    if (_authed) return const EditorScreen(isRoot: true);
    return AuthScreen(onDone: _onDone);
  }
}*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const YouTubeScraperApp());
}

class YouTubeScraperApp extends StatelessWidget {
  const YouTubeScraperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Scraper',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const YouTubeScraperPage(),
    );
  }
}

class YouTubeScraperPage extends StatefulWidget {
  const YouTubeScraperPage({super.key});

  @override
  State<YouTubeScraperPage> createState() => _YouTubeScraperPageState();
}

class _YouTubeScraperPageState extends State<YouTubeScraperPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _status = 'Digite um termo e pressione Enter.';
  bool _isError = false;
  bool _loading = false;

  List<String> _videoIds = [];
  List<String> _watchLinks = [];
  List<String> _embedLinks = [];

  static const Color bg = Color(0xFF0B0F17);
  static const Color card = Color(0xFF121826);
  static const Color card2 = Color(0xFF182033);
  static const Color text = Color(0xFFEFF2FF);
  static const Color muted = Color(0xFF94A3B8);
  static const Color line = Color(0x14FFFFFF);
  static const Color accent = Color(0xFF7C3AED);
  static const Color linkColor = Color(0xFF67E8F9);
  static const Color good = Color(0xFF22C55E);
  static const Color bad = Color(0xFFEF4444);

  String cleanQuery(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String buildSearchUrl(String query) {
    return 'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
  }

  List<String> extractVideoIdsFromHtml(String html) {
    final ids = <String>[];

    final patterns = <RegExp>[
      RegExp(r'(?:watch\?v=|/shorts/|/embed/|/live/)([a-zA-Z0-9_-]{11})'),
      RegExp(r'"videoId":"([a-zA-Z0-9_-]{11})"'),
      RegExp(r'"videoRenderer".*?"videoId":"([a-zA-Z0-9_-]{11})"'),
      RegExp(r'href="\/watch\?v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'(?:v=)([a-zA-Z0-9_-]{11})(?:&|$)'),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(html)) {
        final id = match.group(1);
        if (id != null && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id)) {
          ids.add(id);
        }
      }
    }

    return ids.toSet().toList();
  }

  Future<void> _search() async {
    final query = cleanQuery(_controller.text);

    if (query.isEmpty) {
      setState(() {
        _status = 'Digite um termo de pesquisa primeiro.';
        _isError = true;
        _loading = false;
        _videoIds = [];
        _watchLinks = [];
        _embedLinks = [];
      });
      return;
    }

    final searchUrl = buildSearchUrl(query);

    setState(() {
      _status = 'Lendo o HTML da busca e extraindo links de vídeo...';
      _isError = false;
      _loading = true;
      _videoIds = [];
      _watchLinks = [];
      _embedLinks = [];
    });

    try {
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao buscar a página. HTTP ${response.statusCode}');
      }

      final html = response.body;
      final ids = extractVideoIdsFromHtml(html);

      final watchLinks = ids
          .map((id) => 'https://www.youtube.com/watch?v=$id')
          .toList();

      final embedLinks = ids
          .map((id) => 'https://www.youtube.com/embed/$id')
          .toList();

      setState(() {
        _videoIds = ids;
        _watchLinks = watchLinks;
        _embedLinks = embedLinks;
        _status =
            'Primeira etapa concluída: ${ids.length} vídeos encontrados.\nSegunda etapa concluída: ${embedLinks.length} links embed gerados.';
        _isError = false;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _status =
            'O app não conseguiu ler a resposta do YouTube.\n\nDetalhe: $e';
        _isError = true;
        _loading = false;
      });
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: muted,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.02,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultItem({
    required String badgeText,
    required Color badgeBg,
    required Color badgeBorder,
    required Color badgeTextColor,
    required String title,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: badgeBorder),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: -0.01,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            url,
            style: const TextStyle(
              color: linkColor,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openLink(url),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Abrir link',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<Widget> children,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.01,
          ),
        ),
        const SizedBox(height: 10),
        if (children.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: Border.all(color: line),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emptyTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                ),
                Text(
                  emptySubtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        else
          ...children,
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      _videoIds.length.toString(),
      _watchLinks.length.toString(),
      _embedLinks.length.toString(),
      _isError ? 'ERRO' : (_loading ? '...' : 'OK'),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: bg),
        child: Stack(
          children: [
            Positioned(
              left: -120,
              top: -90,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              right: -120,
              top: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: good.withOpacity(0.10),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YouTube Scraper em duas etapas',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.03,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          width: 860,
                          child: Text(
                            'Primeiro ele tenta ler o HTML da busca do YouTube e extrair todos os IDs de vídeo encontrados. Depois ele pega esses IDs e gera os links watch e embed.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(255, 255, 255, 0.03),
                                Color.fromRGBO(255, 255, 255, 0.02),
                              ],
                            ),
                            border: Border.all(color: line),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.35),
                                blurRadius: 60,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth >= 860;

                                final left = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Pesquisar no YouTube',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) => _search(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: text,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Ex.: programação em flutter, música relaxante, receitas fáceis',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF64748B),
                                        ),
                                        filled: true,
                                        fillColor: card,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 15,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: line),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: line),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: accent.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 170,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _search,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Extrair vídeos',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.03),
                                        border: Border.all(color: line),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        _status,
                                        style: TextStyle(
                                          color: _isError
                                              ? const Color(0xFFFFD1D1)
                                              : muted,
                                          height: 1.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                );

                                final right = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ou cole o HTML bruto aqui',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      height: 220,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: card,
                                        border: Border.all(color: line),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: TextField(
                                        maxLines: null,
                                        expands: true,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: text,
                                          height: 1.5,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText:
                                              'Cole aqui o HTML da página caso a busca direta seja bloqueada...',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF64748B),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (_) {},
                                      ),
                                    ),
                                  ],
                                );

                                return wide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: left),
                                          const SizedBox(width: 14),
                                          Expanded(child: right),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          left,
                                          const SizedBox(height: 14),
                                          right,
                                        ],
                                      );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final wide = constraints.maxWidth >= 860;
                            final statWidgets = [
                              _statCard('IDs encontrados', stats[0]),
                              _statCard('Links de vídeo', stats[1]),
                              _statCard('Links embed', stats[2]),
                              _statCard('Status', stats[3]),
                            ];

                            return wide
                                ? Row(
                                    children: [
                                      Expanded(child: statWidgets[0]),
                                      const SizedBox(width: 12),
                                      Expanded(child: statWidgets[1]),
                                      const SizedBox(width: 12),
                                      Expanded(child: statWidgets[2]),
                                      const SizedBox(width: 12),
                                      Expanded(child: statWidgets[3]),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: statWidgets[0]),
                                          const SizedBox(width: 12),
                                          Expanded(child: statWidgets[1]),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: statWidgets[2]),
                                          const SizedBox(width: 12),
                                          Expanded(child: statWidgets[3]),
                                        ],
                                      ),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Primeira etapa: links de vídeo encontrados',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.01,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_watchLinks.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              border: Border.all(color: line),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nenhum link de vídeo encontrado.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'O YouTube pode ter bloqueado o acesso ao HTML ou a busca não retornou dados legíveis.',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: List.generate(_watchLinks.length, (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _watchLinks.length - 1 ? 0 : 12,
                                ),
                                child: _resultItem(
                                  badgeText: 'Vídeo',
                                  badgeBg: const Color.fromRGBO(34, 197, 94, 0.14),
                                  badgeBorder:
                                      const Color.fromRGBO(34, 197, 94, 0.28),
                                  badgeTextColor: const Color(0xFFC8F7D3),
                                  title: 'ID: ${_videoIds[index]}',
                                  url: _watchLinks[index],
                                ),
                              );
                            }),
                          ),
                        const SizedBox(height: 18),
                        const Text(
                          'Segunda etapa: links embed gerados',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.01,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_embedLinks.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              border: Border.all(color: line),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nenhum embed gerado.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Sem IDs válidos na primeira etapa, não há embed para montar.',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: List.generate(_embedLinks.length, (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == _embedLinks.length - 1 ? 0 : 12,
                                ),
                                child: _resultItem(
                                  badgeText: 'Embed',
                                  badgeBg: const Color.fromRGBO(124, 58, 237, 0.14),
                                  badgeBorder:
                                      const Color.fromRGBO(124, 58, 237, 0.28),
                                  badgeTextColor: const Color(0xFFE5DDFF),
                                  title: 'ID: ${_videoIds[index]}',
                                  url: _embedLinks[index],
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
