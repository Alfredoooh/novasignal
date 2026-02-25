import 'dart:convert';

enum DocType { document, presentation, cv, note }

// ════════════════════════════════════════════════════════════════
// ADocument — modelo de documento com suporte a sync na nuvem
// ════════════════════════════════════════════════════════════════
class ADocument {
  final String id;
  String title;
  String htmlContent;
  String plainText;
  int wordCount;
  DateTime createdAt;
  DateTime updatedAt;
  DocType docType;

  // Campos adicionais para histórico e sync
  int editCount;          // número de vezes editado
  String? lastSyncedAt;   // última vez sincronizado com a nuvem
  List<_HistoryEntry> history; // histórico de edições

  ADocument({
    required this.id,
    required this.title,
    this.htmlContent = '',
    this.plainText = '',
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.docType = DocType.document,
    this.editCount = 0,
    this.lastSyncedAt,
    List<_HistoryEntry>? history,
  }) : history = history ?? [];

  // ── Serialização ─────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'id':           id,
        'title':        title,
        'htmlContent':  htmlContent,
        'plainText':    plainText,
        'wordCount':    wordCount,
        'createdAt':    createdAt.toIso8601String(),
        'updatedAt':    updatedAt.toIso8601String(),
        'docType':      docType.name,
        'editCount':    editCount,
        'lastSyncedAt': lastSyncedAt,
      };

  // JSON completo para a conta na nuvem (inclui histórico)
  Map<String, dynamic> toJsonWithHistory() => {
        ...toJson(),
        'lastSyncedAt': DateTime.now().toIso8601String(),
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory ADocument.fromJson(Map<String, dynamic> j) {
    final histList = j['history'];
    List<_HistoryEntry> hist = [];
    if (histList is List) {
      hist = histList
          .whereType<Map<String, dynamic>>()
          .map((h) => _HistoryEntry.fromJson(h))
          .toList();
    }
    return ADocument(
      id:           j['id']           as String,
      title:        j['title']        as String? ?? 'Sem título',
      htmlContent:  j['htmlContent']  as String? ?? '',
      plainText:    j['plainText']    as String? ?? '',
      wordCount:    j['wordCount']    as int?    ?? 0,
      createdAt:    DateTime.parse(j['createdAt'] as String),
      updatedAt:    DateTime.parse(j['updatedAt'] as String),
      docType:      _parseDocType(j['docType']),
      editCount:    j['editCount']    as int?    ?? 0,
      lastSyncedAt: j['lastSyncedAt'] as String?,
      history:      hist,
    );
  }

  static DocType _parseDocType(dynamic v) {
    switch (v?.toString()) {
      case 'presentation': return DocType.presentation;
      case 'cv':           return DocType.cv;
      case 'note':         return DocType.note;
      default:             return DocType.document;
    }
  }

  // ── Registar edição no histórico ─────────────────────────────
  ADocument withEdit({String? note}) {
    final newHistory = List<_HistoryEntry>.from(history)
      ..insert(0, _HistoryEntry(
        timestamp: DateTime.now().toIso8601String(),
        wordCount: wordCount,
        note: note ?? 'Editado',
      ))
      ..take(50).toList(); // máx. 50 entradas
    return copyWith(
      updatedAt: DateTime.now(),
      editCount: editCount + 1,
      history: newHistory,
    );
  }

  // ── CopyWith ─────────────────────────────────────────────────
  ADocument copyWith({
    String? title,
    String? htmlContent,
    String? plainText,
    int? wordCount,
    DateTime? updatedAt,
    DocType? docType,
    int? editCount,
    String? lastSyncedAt,
    List<_HistoryEntry>? history,
  }) => ADocument(
        id:           id,
        title:        title        ?? this.title,
        htmlContent:  htmlContent  ?? this.htmlContent,
        plainText:    plainText    ?? this.plainText,
        wordCount:    wordCount    ?? this.wordCount,
        createdAt:    createdAt,
        updatedAt:    updatedAt    ?? this.updatedAt,
        docType:      docType      ?? this.docType,
        editCount:    editCount    ?? this.editCount,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        history:      history      ?? this.history,
      );

  String get preview {
    if (plainText.isEmpty) return '';
    return plainText.length > 80
        ? '${plainText.substring(0, 80).trim()}…'
        : plainText.trim();
  }

  String toJsonString()               => jsonEncode(toJson());
  factory ADocument.fromJsonString(String s) => ADocument.fromJson(jsonDecode(s));
}

// ════════════════════════════════════════════════════════════════
// HistoryEntry — entrada no histórico de um documento
// ════════════════════════════════════════════════════════════════
class _HistoryEntry {
  final String timestamp;
  final int wordCount;
  final String note;

  const _HistoryEntry({
    required this.timestamp,
    required this.wordCount,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'wordCount': wordCount,
        'note':      note,
      };

  factory _HistoryEntry.fromJson(Map<String, dynamic> j) => _HistoryEntry(
        timestamp: j['timestamp'] as String? ?? '',
        wordCount: j['wordCount'] as int?    ?? 0,
        note:      j['note']      as String? ?? '',
      );
}