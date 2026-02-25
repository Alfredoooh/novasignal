import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Worker URL ───────────────────────────────────────────────────────────────
const kWorkerUrl = 'https://dawn-sun-590a.alfredopjonas.workers.dev';

// ════════════════════════════════════════════════════════════════
// MODEL
// ════════════════════════════════════════════════════════════════
class AriaUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String plan;
  final String createdAt;

  const AriaUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.plan = 'free',
    required this.createdAt,
  });

  factory AriaUser.fromJson(Map<String, dynamic> j) => AriaUser(
        id:        j['id']        as String? ?? '',
        name:      j['name']      as String? ?? 'Utilizador',
        email:     j['email']     as String? ?? '',
        phone:     j['phone']     as String?,
        plan:      j['plan']      as String? ?? 'free',
        createdAt: j['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'email': email,
        'phone': phone, 'plan': plan, 'createdAt': createdAt,
      };
  String toJsonString() => jsonEncode(toJson());
}

// ════════════════════════════════════════════════════════════════
// RESULT
// ════════════════════════════════════════════════════════════════
class AuthResult {
  final bool ok;
  final AriaUser? user;
  final String? error;
  const AuthResult._({required this.ok, this.user, this.error});
  factory AuthResult.success(AriaUser u) => AuthResult._(ok: true,  user: u);
  factory AuthResult.fail(String msg)    => AuthResult._(ok: false, error: msg);
}

// ════════════════════════════════════════════════════════════════
// AUTH SERVICE — Singleton
// ════════════════════════════════════════════════════════════════
class AuthService extends ChangeNotifier {
  static final AuthService _i = AuthService._();
  static AuthService get instance => _i;
  AuthService._();

  AriaUser? _user;
  String    _token  = '';
  bool      _loading = false;

  AriaUser? get user     => _user;
  String    get token    => _token;
  bool      get loggedIn => _user != null && _token.isNotEmpty;
  bool      get loading  => _loading;

  static const _kToken = 'aria_token';
  static const _kUser  = 'aria_user';

  // ── Init: restaura sessão guardada ───────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken) ?? '';
    final raw = prefs.getString(_kUser);
    if (raw != null) {
      try { _user = AriaUser.fromJson(jsonDecode(raw)); } catch (_) {}
    }
    if (_token.isNotEmpty) {
      try {
        final res = await _get('/auth/me');
        if (res['ok'] == true) {
          _user = AriaUser.fromJson(res['user'] as Map<String, dynamic>);
          await _save();
        } else {
          await _clear();
        }
      } catch (_) { /* sem rede — mantém cache */ }
    }
    notifyListeners();
  }

  // ── Registo ──────────────────────────────────────────────────
  Future<AuthResult> registerEmail({
    required String name, required String email, required String password,
  }) => _run(() => _post('/auth/register', {
        'name': name.trim(), 'email': email.trim().toLowerCase(), 'password': password,
      }));

  Future<AuthResult> registerPhone({
    required String name, required String phone, required String password,
  }) => _run(() => _post('/auth/register', {
        'name': name.trim(),
        'email': 'phone_${phone.replaceAll(RegExp(r'\D'), '')}@aria.internal',
        'phone': phone.trim(), 'password': password,
      }));

  // ── Login ────────────────────────────────────────────────────
  Future<AuthResult> loginEmail({
    required String email, required String password,
  }) => _run(() => _post('/auth/login', {
        'email': email.trim().toLowerCase(), 'password': password,
      }));

  Future<AuthResult> loginPhone({
    required String phone, required String password,
  }) => _run(() => _post('/auth/login', {
        'email': 'phone_${phone.replaceAll(RegExp(r'\D'), '')}@aria.internal',
        'password': password,
      }));

  // ── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    try { await _post('/auth/logout', {}); } catch (_) {}
    await _clear();
    notifyListeners();
  }

  // ── Sync docs ────────────────────────────────────────────────
  Future<bool> syncDocument(Map<String, dynamic> doc) async {
    if (!loggedIn) return false;
    try {
      final res = await _post('/user/documents', {'document': doc});
      return res['ok'] == true;
    } catch (_) { return false; }
  }

  Future<List<Map<String, dynamic>>?> fetchDocuments() async {
    if (!loggedIn) return null;
    try {
      final res = await _get('/user/documents');
      if (res['ok'] == true && res['documents'] is List) {
        return (res['documents'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteDocument(String id) async {
    if (!loggedIn) return false;
    try {
      final res = await _delete('/user/documents/$id');
      return res['ok'] == true;
    } catch (_) { return false; }
  }

  // ── Sync histórico ───────────────────────────────────────────
  Future<bool> syncActivity(Map<String, dynamic> event) async {
    if (!loggedIn) return false;
    try {
      final res = await _post('/user/history', {'event': event});
      return res['ok'] == true;
    } catch (_) { return false; }
  }

  Future<List<Map<String, dynamic>>?> fetchHistory({int limit = 100}) async {
    if (!loggedIn) return null;
    try {
      final res = await _get('/user/history?limit=$limit');
      if (res['ok'] == true && res['history'] is List) {
        return (res['history'] as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return null;
  }

  // ── Privados ─────────────────────────────────────────────────
  Future<AuthResult> _run(Future<Map<String, dynamic>> Function() call) async {
    _loading = true; notifyListeners();
    try {
      final res = await call();
      if (res['ok'] == true && res['token'] != null) {
        _token = res['token'] as String;
        _user  = AriaUser.fromJson(res['user'] as Map<String, dynamic>);
        await _save();
        notifyListeners();
        return AuthResult.success(_user!);
      }
      return AuthResult.fail(res['error'] as String? ?? 'Erro desconhecido');
    } catch (e) {
      return AuthResult.fail('Sem ligação à internet.');
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _token);
    if (_user != null) await prefs.setString(_kUser, _user!.toJsonString());
  }

  Future<void> _clear() async {
    _token = ''; _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken); await prefs.remove(_kUser);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final c = HttpClient();
    final req = await c.postUrl(Uri.parse('$kWorkerUrl$path'));
    req.headers.set('Content-Type', 'application/json');
    if (_token.isNotEmpty) req.headers.set('Authorization', 'Bearer $_token');
    req.write(jsonEncode(body));
    final resp = await req.close();
    return jsonDecode(await resp.transform(utf8.decoder).join());
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final c = HttpClient();
    final req = await c.getUrl(Uri.parse('$kWorkerUrl$path'));
    if (_token.isNotEmpty) req.headers.set('Authorization', 'Bearer $_token');
    final resp = await req.close();
    return jsonDecode(await resp.transform(utf8.decoder).join());
  }

  Future<Map<String, dynamic>> _delete(String path) async {
    final c = HttpClient();
    final req = await c.deleteUrl(Uri.parse('$kWorkerUrl$path'));
    if (_token.isNotEmpty) req.headers.set('Authorization', 'Bearer $_token');
    final resp = await req.close();
    return jsonDecode(await resp.transform(utf8.decoder).join());
  }
}
