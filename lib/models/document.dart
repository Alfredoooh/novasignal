import 'dart:convert';

class ADocument {
  final String id;
  String title;
  String htmlContent;
  String plainText;
  int wordCount;
  DateTime createdAt;
  DateTime updatedAt;

  ADocument({
    required this.id,
    required this.title,
    this.htmlContent = '',
    this.plainText = '',
    this.wordCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'htmlContent': htmlContent,
    'plainText': plainText,
    'wordCount': wordCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ADocument.fromJson(Map<String, dynamic> j) => ADocument(
    id: j['id'],
    title: j['title'] ?? 'Sem título',
    htmlContent: j['htmlContent'] ?? '',
    plainText: j['plainText'] ?? '',
    wordCount: j['wordCount'] ?? 0,
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
  );

  ADocument copyWith({
    String? title,
    String? htmlContent,
    String? plainText,
    int? wordCount,
    DateTime? updatedAt,
  }) => ADocument(
    id: id,
    title: title ?? this.title,
    htmlContent: htmlContent ?? this.htmlContent,
    plainText: plainText ?? this.plainText,
    wordCount: wordCount ?? this.wordCount,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  // Prévia: primeiros ~80 chars do texto
  String get preview {
    if (plainText.isEmpty) return 'Documento vazio';
    return plainText.length > 80
        ? '${plainText.substring(0, 80).trim()}…'
        : plainText.trim();
  }

  String toJsonString() => jsonEncode(toJson());
  factory ADocument.fromJsonString(String s) =>
      ADocument.fromJson(jsonDecode(s));
}
