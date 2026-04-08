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
          .map((id) => 'Título do vídeo $id')
          .toList();

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
        icon: const Icon(Icons.download),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Função de download não implementada")),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
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

class AudioPlayerPage extends StatefulWidget {
  final String url;

  const AudioPlayerPage({super.key, required this.url});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
    } else {
      await _player.play(UrlSource(widget.url)); // ✅ correção aplicada aqui
      setState(() => _playing = true);
    }
  }

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
            Text('Tocando: ${widget.url}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _togglePlay,
              child: Text(_playing ? 'Pausar' : 'Tocar Áudio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Função de download não implementada")),
                );
              },
              child: const Text('Baixar Áudio'),
            ),
          ],
        ),
      ),
    );
  }
}