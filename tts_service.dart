import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─────────────────────────────────────────────────────────
// TTS SERVICE — Voz humana masculina
//
// Pipeline:
//   1. ElevenLabs API → voz "Adam" (natural, masculina, PT)
//   2. Fallback: flutter_tts com melhor voz do sistema
//
// ElevenLabs free tier: 10,000 chars/mês
// Vozes masculinas disponíveis:
//   - Adam      (pNInz6obpgDQGcFmaJgB) — claro, profissional
//   - Josh      (TxGEqnHWrfWFTfGW9XjX) — jovem, natural
//   - Antoni    (ErXwobaYiN019PkySvjV) — suave, articulado
//   - Daniel    (onwK4e9ZLuTAKqWW03F9) — narrador, brit
// ─────────────────────────────────────────────────────────

class TtsService {
  TtsService._();
  static final instance = TtsService._();

  // ── ElevenLabs config ───────────────────────────────────
  // Obtém a chave em: https://elevenlabs.io → Profile → API Key
  // Free tier: 10k chars/mês sem cartão
  static const _elevenLabsKey  = 'SUA_CHAVE_ELEVENLABS_AQUI';
  static const _voiceId        = 'pNInz6obpgDQGcFmaJgB'; // Adam — voz masculina natural
  static const _modelId        = 'eleven_multilingual_v2'; // suporta português
  static const _useElevenLabs  = true; // false → usa só flutter_tts

  // ── Player de áudio ─────────────────────────────────────
  final _player = AudioPlayer();

  // ── flutter_tts (fallback) ──────────────────────────────
  final _tts = FlutterTts();
  bool _ttsReady = false;
  bool _playing  = false;

  // ── Estado ──────────────────────────────────────────────
  bool get isPlaying => _playing;

  // ── Inicializar ─────────────────────────────────────────
  Future<void> init() async {
    // Configurar flutter_tts como fallback
    await _tts.setLanguage('pt-PT');
    await _tts.setSpeechRate(0.45);   // mais devagar = mais natural
    await _tts.setVolume(1.0);
    await _tts.setPitch(0.9);         // ligeiramente grave = masculino

    // Tentar seleccionar a melhor voz masculina disponível
    try {
      final voices = await _tts.getVoices as List?;
      if (voices != null) {
        final maleVoice = voices.firstWhere(
          (v) {
            final name = (v['name'] as String? ?? '').toLowerCase();
            final locale = (v['locale'] as String? ?? '').toLowerCase();
            return (locale.contains('pt') || locale.contains('por')) &&
                   (name.contains('male') || name.contains('masculin'));
          },
          orElse: () => null,
        );
        if (maleVoice != null) {
          await _tts.setVoice({'name': maleVoice['name'], 'locale': maleVoice['locale']});
        }
      }
    } catch (_) {}

    _tts.setCompletionHandler(() {
      _playing = false;
    });
    _tts.setErrorHandler((msg) {
      debugPrint('TTS error: $msg');
      _playing = false;
    });

    // Player events
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playing = false;
      }
    });

    _ttsReady = true;
  }

  // ── Falar texto ─────────────────────────────────────────
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    if (!_ttsReady) await init();

    await stop(); // para qualquer leitura anterior

    // Limpar texto — remover markdown, HTML, excesso de espaços
    final clean = _clean(text);
    if (clean.isEmpty) return;

    _playing = true;

    // Tentar ElevenLabs primeiro
    if (_useElevenLabs && _elevenLabsKey != 'SUA_CHAVE_ELEVENLABS_AQUI') {
      try {
        await _speakElevenLabs(clean);
        return;
      } catch (e) {
        debugPrint('ElevenLabs failed, using fallback: $e');
      }
    }

    // Fallback: flutter_tts (voz do sistema)
    await _speakFallback(clean);
  }

  // ── ElevenLabs TTS ──────────────────────────────────────
  Future<void> _speakElevenLabs(String text) async {
    final url = Uri.parse(
      'https://api.elevenlabs.io/v1/text-to-speech/$_voiceId/stream',
    );

    final response = await http.post(
      url,
      headers: {
        'xi-api-key':   _elevenLabsKey,
        'Content-Type': 'application/json',
        'Accept':       'audio/mpeg',
      },
      body: jsonEncode({
        'text': text,
        'model_id': _modelId,
        'voice_settings': {
          'stability':        0.45,   // 0-1 — mais baixo = mais expressivo
          'similarity_boost': 0.75,   // fidelidade à voz original
          'style':            0.35,   // estilo/variação
          'use_speaker_boost': true,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('ElevenLabs error ${response.statusCode}: ${response.body}');
    }

    // Guardar áudio em cache e tocar
    final tmpDir  = await getTemporaryDirectory();
    final tmpFile = File('${tmpDir.path}/aria_tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await tmpFile.writeAsBytes(response.bodyBytes);

    await _player.setFilePath(tmpFile.path);
    await _player.play();

    // Apagar cache depois de tocar
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        tmpFile.delete().catchError((_) {});
        _playing = false;
      }
    });
  }

  // ── flutter_tts fallback ────────────────────────────────
  Future<void> _speakFallback(String text) async {
    // Dividir em parágrafos para melhor entoação
    final parts = text.split('\n').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) {
      await _tts.speak(text);
      return;
    }
    for (final part in parts) {
      if (!_playing) break;
      await _tts.speak(part);
    }
  }

  // ── Parar ───────────────────────────────────────────────
  Future<void> stop() async {
    _playing = false;
    try { await _player.stop(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
  }

  // ── Pausar / retomar ────────────────────────────────────
  Future<void> pause() async {
    try { await _player.pause(); } catch (_) {}
    try { await _tts.pause(); } catch (_) {}
  }

  Future<void> resume() async {
    try { await _player.play(); } catch (_) {}
  }

  // ── Limpeza de texto ────────────────────────────────────
  String _clean(String text) => text
    .replaceAll(RegExp(r'<[^>]+>'), ' ')              // HTML tags
    .replaceAll(RegExp(r'\*{1,3}([^*]+)\*{1,3}'), r'$1')  // markdown bold/italic
    .replaceAll(RegExp(r'#{1,6}\s*'), '')              // markdown headers
    .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')   // markdown links
    .replaceAll(RegExp(r'`[^`]*`'), '')                // inline code
    .replaceAll(RegExp(r'^\s*[-*•]\s*', multiLine: true), '') // bullets
    .replaceAll(RegExp(r'\s{2,}'), ' ')                // espaços duplos
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')             // linhas em branco a mais
    .trim();

  void dispose() {
    _player.dispose();
    _tts.stop();
  }
}

// ─────────────────────────────────────────────────────────
// WIDGET — botão de leitura em voz alta
// Usa-se em qualquer tela: TtsButton(text: texto)
// ─────────────────────────────────────────────────────────

class TtsButton extends StatefulWidget {
  final String text;
  final Color? color;
  final double size;

  const TtsButton({
    super.key,
    required this.text,
    this.color,
    this.size = 22,
  });

  @override
  State<TtsButton> createState() => _TtsButtonState();
}

class _TtsButtonState extends State<TtsButton> {
  bool _playing = false;

  Future<void> _toggle() async {
    final svc = TtsService.instance;
    if (_playing) {
      await svc.stop();
      setState(() => _playing = false);
    } else {
      setState(() => _playing = true);
      await svc.speak(widget.text);
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  void dispose() {
    if (_playing) TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? Theme.of(context).colorScheme.primary;
    return IconButton(
      tooltip: _playing ? 'Parar leitura' : 'Ouvir em voz alta',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _playing ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
          key: ValueKey(_playing),
          color: c,
          size: widget.size,
        ),
      ),
      onPressed: _toggle,
    );
  }
}
