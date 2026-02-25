import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document.dart';
import 'auth_service.dart';

// ════════════════════════════════════════════════════════════════
// DOCUMENT SERVICE — local + sync com conta Aria Worker
// ════════════════════════════════════════════════════════════════
class DocumentService {
  static const _kDocsKey = 'aria_documents';

  static DocumentService? _instance;
  static DocumentService get instance => _instance ??= DocumentService._();
  DocumentService._();

  List<ADocument> _docs = [];
  List<ADocument> get documents => List.unmodifiable(_docs);

  // ── Carrega documentos (local + merge da conta se logado) ────
  Future<void> load() async {
    // 1. Carrega do SharedPreferences (local)
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kDocsKey) ?? [];
    _docs = raw.map((s) {
      try { return ADocument.fromJsonString(s); } catch (_) { return null; }
    }).whereType<ADocument>().toList();
    _docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // 2. Se o utilizador está autenticado, faz merge com a nuvem
    if (AuthService.instance.loggedIn) {
      await _mergeFromCloud();
    }
  }

  // ── Merge cloud → local ───────────────────────────────────────
  Future<void> _mergeFromCloud() async {
    try {
      final cloudDocs = await AuthService.instance.fetchDocuments();
      if (cloudDocs == null || cloudDocs.isEmpty) return;

      bool changed = false;
      for (final json in cloudDocs) {
        try {
          final cloudDoc = ADocument.fromJson(json);
          final idx = _docs.indexWhere((d) => d.id == cloudDoc.id);
          if (idx < 0) {
            // Documento novo da nuvem
            _docs.insert(0, cloudDoc);
            changed = true;
          } else {
            // Mantém o mais recente
            if (cloudDoc.updatedAt.isAfter(_docs[idx].updatedAt)) {
              _docs[idx] = cloudDoc;
              changed = true;
            }
          }
        } catch (_) {}
      }

      if (changed) {
        _docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        await _persist();
      }
    } catch (_) { /* sem rede — continua com cache local */ }
  }

  // ── Guardar (local + sync para a conta) ──────────────────────
  Future<ADocument> save(ADocument doc) async {
    // Actualiza local
    final idx = _docs.indexWhere((d) => d.id == doc.id);
    final isNew = idx < 0;
    if (isNew) {
      _docs.insert(0, doc);
    } else {
      _docs[idx] = doc;
    }
    _docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persist();

    // Sync para a conta (não bloqueia UI)
    _syncDoc(doc, isNew: isNew);

    return doc;
  }

  // ── Apagar (local + cloud) ────────────────────────────────────
  Future<void> delete(String id) async {
    _docs.removeWhere((d) => d.id == id);
    await _persist();

    // Regista actividade de eliminação + apaga da nuvem
    _logActivity(action: 'delete_document', docId: id);
    AuthService.instance.deleteDocument(id);
  }

  // ── Buscar por ID ─────────────────────────────────────────────
  ADocument? find(String id) {
    try { return _docs.firstWhere((d) => d.id == id); } catch (_) { return null; }
  }

  // ── Sync individual de documento ─────────────────────────────
  Future<void> _syncDoc(ADocument doc, {bool isNew = false}) async {
    final auth = AuthService.instance;
    if (!auth.loggedIn) return;

    // Registar evento de histórico
    await _logActivity(
      action: isNew ? 'create_document' : 'update_document',
      docId: doc.id,
      meta: {
        'title':    doc.title,
        'docType':  doc.docType.name,
        'wordCount': doc.wordCount,
      },
    );

    // Sync o documento completo em JSON para a conta
    await auth.syncDocument(doc.toJsonWithHistory());
  }

  // ── Registar evento de histórico na conta ────────────────────
  Future<void> _logActivity({
    required String action,
    String? docId,
    Map<String, dynamic>? meta,
  }) async {
    await AuthService.instance.syncActivity({
      'action':    action,
      'docId':     docId,
      'timestamp': DateTime.now().toIso8601String(),
      'userId':    AuthService.instance.user?.id,
      if (meta != null) ...meta,
    });
  }

  // ── Regista acção manual (abrir doc, pesquisa IA, etc.) ───────
  Future<void> logActivity(String action, {
    String? docId, Map<String, dynamic>? meta,
  }) => _logActivity(action: action, docId: docId, meta: meta);

  // ── Persistir local ───────────────────────────────────────────
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kDocsKey,
      _docs.map((d) => d.toJsonString()).toList(),
    );
  }
}
