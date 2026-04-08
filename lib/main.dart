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
import 'package:audioplayers/audioplayers.dart';
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

  String _status = 'Digite um termo e pressione Enter.';
  bool _isError = false;
  bool _loading = false;

  List<String> _videoIds = [];
  List<String> _videoTitles = [];
  List<String> _watchLinks = [];
  List<String> _embedLinks = [];

  final AudioPlayer _audioPlayer = AudioPlayer();

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
        _videoTitles = [];
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
      _videoTitles = [];
    });

    try {
      final response = await http.get(Uri.parse(searchUrl));
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

      final titles = ids
          .map((id) => 'Título do vídeo $id')  // Simulando a coleta do título
          .toList(); // Aqui você pode melhorar pegando o título real da página

      setState(() {
        _videoIds = ids;
        _watchLinks = watchLinks;
        _embedLinks = embedLinks;
        _videoTitles = titles;
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

  void _openAudioPlayer(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioPlayerPage(url: url),
      ),
    );
  }

  Widget _resultItem({
    required String title,
    required String url,
    required int index,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(url),
      onTap: () => _openAudioPlayer(url),
      trailing: IconButton(
        icon: Icon(Icons.download),
        onPressed: () {
          // Implementar download do áudio (por enquanto vazio)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Função de download não implementada")),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Scraper'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Pesquise no YouTube',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _search,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text('Pesquisar'),
          ),
          const SizedBox(height: 16),
          Text(_status),
          const SizedBox(height: 16),
          if (_videoIds.isNotEmpty)
            Column(
              children: List.generate(_videoIds.length, (index) {
                return _resultItem(
                  title: _videoTitles[index],
                  url: _watchLinks[index],
                  index: index,
                );
              }),
            ),
        ],
      ),
    );
  }
}

class AudioPlayerPage extends StatelessWidget {
  final String url;

  const AudioPlayerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player de Áudio"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tocando: $url'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Usando o Audioplayer para tocar o áudio do URL
                final player = AudioPlayer();
                player.setSourceUrl(url);  // Método correto para URL
                player.play();
              },
              child: const Text('Tocar Áudio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Adicionar download, se tiver solução para isso
              },
              child: const Text('Baixar Áudio'),
            ),
          ],
        ),
      ),
    );
  }
}