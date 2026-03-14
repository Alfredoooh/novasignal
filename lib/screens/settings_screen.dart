import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme.dart';

// ─── Keys ───────────────────────────────────────────────────────
const _kKeyModel        = 'ai_model';
const _kKeyTemp         = 'ai_temperature';
const _kKeyMaxTokens    = 'ai_max_tokens';
const _kKeyWorkerUrl    = 'worker_url';
const _kKeySystemPrompt = 'system_prompt';
const _kKeyUserId       = 'user_id';

// ─── AppSettings singleton ──────────────────────────────────────
class AppSettings {
  static final instance = AppSettings._();
  AppSettings._();

  String workerUrl    = 'https://dawn-sun-590a.alfredopjonas.workers.dev';
  String model        = 'compound-beta';
  double temperature  = 0.8;
  int    maxTokens    = 8192;
  String systemPrompt = '';
  String userId       = '';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    workerUrl    = p.getString(_kKeyWorkerUrl)    ?? workerUrl;
    model        = p.getString(_kKeyModel)        ?? model;
    temperature  = p.getDouble(_kKeyTemp)         ?? temperature;
    maxTokens    = p.getInt(_kKeyMaxTokens)       ?? maxTokens;
    systemPrompt = p.getString(_kKeySystemPrompt) ?? systemPrompt;
    userId       = p.getString(_kKeyUserId)       ?? _generateUserId();
    if (userId.isEmpty) {
      userId = _generateUserId();
      await p.setString(_kKeyUserId, userId);
    }
  }

  String _generateUserId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'u_$now';
  }

  Future<void> saveLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKeyWorkerUrl,    workerUrl);
    await p.setString(_kKeyModel,        model);
    await p.setDouble(_kKeyTemp,         temperature);
    await p.setInt(_kKeyMaxTokens,       maxTokens);
    await p.setString(_kKeySystemPrompt, systemPrompt);
  }

  // Save to worker KV
  Future<void> saveRemote() async {
    try {
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse('$workerUrl/settings/save'));
      req.headers.set('Content-Type', 'application/json');
      req.write(jsonEncode({
        'user_id': userId,
        'settings': {
          'model': model,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'system_prompt': systemPrompt,
        },
      }));
      await req.close();
    } catch (_) {}
  }

  // Load from worker KV (sync over local)
  Future<void> loadRemote() async {
    try {
      final client = HttpClient();
      final req = await client.postUrl(Uri.parse('$workerUrl/settings/get'));
      req.headers.set('Content-Type', 'application/json');
      req.write(jsonEncode({'user_id': userId}));
      final res = await req.close().timeout(const Duration(seconds: 5));
      final raw = await res.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final s = data['settings'] as Map<String, dynamic>?;
      if (s != null) {
        model        = s['model']        as String? ?? model;
        temperature  = (s['temperature'] as num?)?.toDouble() ?? temperature;
        maxTokens    = (s['max_tokens']  as num?)?.toInt()    ?? maxTokens;
        systemPrompt = s['system_prompt'] as String? ?? systemPrompt;
        await saveLocal();
      }
    } catch (_) {}
  }

  Future<void> save() async {
    await saveLocal();
    await saveRemote();
  }
}

// ─── SVG ────────────────────────────────────────────────────────
const _svgBack = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17.921,1.505a1.5,1.5,0,0,1-.44,1.06L9.809,10.237a2.5,2.5,0,0,0,0,3.536l7.662,7.662a1.5,1.5,0,0,1-2.121,2.121L7.688,15.894a5.506,5.506,0,0,1,0-7.779L15.36.444a1.5,1.5,0,0,1,2.561,1.061Z"/></svg>';

// ─── SettingsScreen ─────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _workerCtrl;
  late TextEditingController _systemCtrl;
  late double _temp;
  late int    _maxTokens;
  late String _model;
  bool _saving = false;

  List<Map<String,String>> _models = [];
  bool _loadingModels = true;

  @override
  void initState() {
    super.initState();
    final s    = AppSettings.instance;
    _workerCtrl = TextEditingController(text: s.workerUrl);
    _systemCtrl = TextEditingController(text: s.systemPrompt);
    _temp       = s.temperature;
    _maxTokens  = s.maxTokens;
    _model      = s.model;
    themeNotifier.addListener(_rebuild);
    _loadModels();
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    _workerCtrl.dispose();
    _systemCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  Future<void> _loadModels() async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(
        Uri.parse('${AppSettings.instance.workerUrl}/models'));
      final res = await req.close().timeout(const Duration(seconds: 10));
      final raw = await res.transform(utf8.decoder).join();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final list = (data['models'] as List? ?? [])
        .map((m) => {'id': m['id'] as String, 'label': m['id'] as String})
        .toList();
      if (mounted) setState(() { _models = list; _loadingModels = false; });
    } catch (_) {
      // fallback
      if (mounted) setState(() {
        _models = [
          {'id': 'compound-beta',      'label': 'compound-beta'},
          {'id': 'compound-beta-mini', 'label': 'compound-beta-mini'},
        ];
        _loadingModels = false;
      });
    }
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    final s      = AppSettings.instance;
    s.workerUrl   = _workerCtrl.text.trim();
    s.systemPrompt = _systemCtrl.text.trim();
    s.temperature  = _temp;
    s.maxTokens    = _maxTokens;
    s.model        = _model;
    await s.save(); // local + remote
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Configurações guardadas'),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = themeNotifier.isDark;
    final bg      = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFFFFFF);
    final surface = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final border  = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
    final textP   = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final textS   = isDark ? const Color(0xFF8E8E8E) : const Color(0xFF6B6B6B);
    final accent  = accColor(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: Column(children: [
        // AppBar
        SizedBox(
          height: kToolbarHeight,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            IconButton(
              icon: SvgPicture.string(_svgBack, width: 20, height: 20,
                colorFilter: ColorFilter.mode(textP, BlendMode.srcIn)),
              onPressed: () => Navigator.pop(context),
            ),
            Text('Configurações',
              style: TextStyle(color: textP, fontSize: 17, fontWeight: FontWeight.w700)),
            const Spacer(),
            if (_saving)
              Padding(padding: const EdgeInsets.only(right: 16),
                child: SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: accent)))
            else
              TextButton(
                onPressed: _saveAll,
                child: Text('Guardar',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
          ]),
        ),

        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [

            _Label('Modelo IA', textS),
            _Card(surface: surface, border: border, child: _loadingModels
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: accent)),
                    const SizedBox(width: 12),
                    Text('A carregar modelos…', style: TextStyle(color: textS, fontSize: 14)),
                  ]))
              : Column(
                  children: _models.asMap().entries.map((e) => _RadioTile(
                    label: e.value['label']!,
                    selected: _model == e.value['id'],
                    isLast: e.key == _models.length - 1,
                    border: border, textP: textP, accent: accent,
                    onTap: () => setState(() => _model = e.value['id']!),
                  )).toList(),
                )),

            const SizedBox(height: 20),
            _Label('Temperatura  (${_temp.toStringAsFixed(1)})', textS),
            _Card(surface: surface, border: border, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                Text('0.0', style: TextStyle(color: textS, fontSize: 12)),
                Expanded(child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent, thumbColor: accent,
                    inactiveTrackColor: border, trackHeight: 3,
                    overlayColor: accent.withOpacity(0.15),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _temp, min: 0.0, max: 2.0, divisions: 20,
                    onChanged: (v) => setState(() =>
                      _temp = double.parse(v.toStringAsFixed(1))),
                  ),
                )),
                Text('2.0', style: TextStyle(color: textS, fontSize: 12)),
              ]),
            )),

            const SizedBox(height: 20),
            _Label('Max tokens  ($_maxTokens)', textS),
            _Card(surface: surface, border: border, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                Text('512', style: TextStyle(color: textS, fontSize: 12)),
                Expanded(child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accent, thumbColor: accent,
                    inactiveTrackColor: border, trackHeight: 3,
                    overlayColor: accent.withOpacity(0.15),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _maxTokens.toDouble(),
                    min: 512, max: 8192, divisions: 30,
                    onChanged: (v) => setState(() => _maxTokens = v.round()),
                  ),
                )),
                Text('8192', style: TextStyle(color: textS, fontSize: 12)),
              ]),
            )),

            const SizedBox(height: 20),
            _Label('URL do Worker', textS),
            _Card(surface: surface, border: border, child: _TF(
              ctrl: _workerCtrl, hint: 'https://...workers.dev',
              textP: textP, textS: textS,
            )),

            const SizedBox(height: 20),
            _Label('Prompt de sistema (vazio = sem instruções)', textS),
            _Card(surface: surface, border: border, child: _TF(
              ctrl: _systemCtrl,
              hint: 'Deixa vazio para que a IA responda livremente…',
              textP: textP, textS: textS, maxLines: 5,
            )),

            const SizedBox(height: 20),
            _Label('Aparência', textS),
            _Card(surface: surface, border: border, child: _SwitchTile(
              label: 'Tema escuro', value: isDark,
              textP: textP, border: border, accent: accent,
              onChanged: (_) => themeNotifier.toggle(),
            )),
          ],
        )),
      ])),
    );
  }
}

class _Label extends StatelessWidget {
  final String t; final Color c;
  const _Label(this.t, this.c);
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(t, style: TextStyle(color: c, fontSize: 12,
      fontWeight: FontWeight.w600, letterSpacing: 0.4)));
}

class _Card extends StatelessWidget {
  final Widget child; final Color surface, border;
  const _Card({required this.child, required this.surface, required this.border});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border, width: 1)),
    clipBehavior: Clip.antiAlias, child: child);
}

class _TF extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint; final Color textP, textS;
  final int maxLines;
  const _TF({required this.ctrl, required this.hint,
    required this.textP, required this.textS, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextField(
    controller: ctrl, maxLines: maxLines,
    style: TextStyle(color: textP, fontSize: 14),
    decoration: InputDecoration(hintText: hint,
      hintStyle: TextStyle(color: textS, fontSize: 14),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true));
}

class _RadioTile extends StatelessWidget {
  final String label; final bool selected, isLast;
  final Color textP, border, accent; final VoidCallback onTap;
  const _RadioTile({required this.label, required this.selected,
    required this.isLast, required this.textP, required this.border,
    required this.accent, required this.onTap});
  @override Widget build(BuildContext context) => Column(children: [
    InkWell(onTap: onTap, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(color: textP,
          fontSize: 15, fontWeight: FontWeight.w500))),
        AnimatedContainer(duration: const Duration(milliseconds: 180),
          width: 20, height: 20,
          decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: selected ? accent : border, width: 2),
            color: selected ? accent : Colors.transparent),
          child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null),
      ]))),
    if (!isLast) Divider(height: 1, color: border),
  ]);
}

class _SwitchTile extends StatelessWidget {
  final String label; final bool value;
  final Color textP, border, accent; final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.label, required this.value,
    required this.textP, required this.border,
    required this.accent, required this.onChanged});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(color: textP,
        fontSize: 15, fontWeight: FontWeight.w500))),
      Switch(value: value, onChanged: onChanged, activeColor: accent),
    ]));
}
