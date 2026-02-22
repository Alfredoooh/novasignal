import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/document.dart';

class DocumentService {
  static const _kDocsKey = 'aria_documents';
  static DocumentService? _instance;
  static DocumentService get instance => _instance ??= DocumentService._();
  DocumentService._();

  List<ADocument> _docs = [];
  List<ADocument> get documents => List.unmodifiable(_docs);

  // Carrega todos os documentos guardados
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kDocsKey) ?? [];
    _docs = raw.map((s) {
      try { return ADocument.fromJsonString(s); }
      catch (_) { return null; }
    }).whereType<ADocument>().toList();
    _docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kDocsKey,
      _docs.map((d) => d.toJsonString()).toList(),
    );
  }

  Future<ADocument> save(ADocument doc) async {
    final idx = _docs.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) {
      _docs[idx] = doc;
    } else {
      _docs.insert(0, doc);
    }
    _docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persist();
    return doc;
  }

  Future<void> delete(String id) async {
    _docs.removeWhere((d) => d.id == id);
    await _persist();
  }

  ADocument? find(String id) {
    try { return _docs.firstWhere((d) => d.id == id); }
    catch (_) { return null; }
  }
}
