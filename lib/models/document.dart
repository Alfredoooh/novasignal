import 'dart:convert';

enum DocType { document, presentation, cv, note }

class ADocument {
  final String id;
  String title;
  String htmlContent;
  String plainText;
  int wordCount;
  DateTime createdAt;
  DateTime updatedAt;
  DocType docType;

  ADocument({
    required this.id,
    required this.title,
    this.htmlContent = '',
    this.plainText = '',
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.docType = DocType.document,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'htmlContent': htmlContent,
    'plainText': plainText,
    'wordCount': wordCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'docType': docType.name,
  };

  factory ADocument.fromJson(Map<String, dynamic> j) => ADocument(
    id: j['id'],
    title: j['title'] ?? 'Sem título',
    htmlContent: j['htmlContent'] ?? '',
    plainText: j['plainText'] ?? '',
    wordCount: j['wordCount'] ?? 0,
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
    docType: _parseDocType(j['docType']),
  );

  static DocType _parseDocType(dynamic v) {
    if (v == null) return DocType.document;
    switch (v.toString()) {
      case 'presentation': return DocType.presentation;
      case 'cv':           return DocType.cv;
      case 'note':         return DocType.note;
      default:             return DocType.document;
    }
  }

  ADocument copyWith({
    String? title,
    String? htmlContent,
    String? plainText,
    int? wordCount,
    DateTime? updatedAt,
    DocType? docType,
  }) => ADocument(
    id: id,
    title: title ?? this.title,
    htmlContent: htmlContent ?? this.htmlContent,
    plainText: plainText ?? this.plainText,
    wordCount: wordCount ?? this.wordCount,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    docType: docType ?? this.docType,
  );

  String get preview {
    if (plainText.isEmpty) return '';
    return plainText.length > 80
        ? '${plainText.substring(0, 80).trim()}…'
        : plainText.trim();
  }

  String toJsonString() => jsonEncode(toJson());
  factory ADocument.fromJsonString(String s) =>
      ADocument.fromJson(jsonDecode(s));
}
