class DocumentModel {
  final String id;
  final String title;
  final List<String> pages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String paperSize;
  final double fontSize;
  final String fontFamily;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final String textAlign;

  DocumentModel({
    required this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
    this.paperSize = 'A4',
    this.fontSize = 12.0,
    this.fontFamily = 'Roboto',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.textAlign = 'left',
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      pages: (json['pages'] as List).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      paperSize: json['paperSize'] as String? ?? 'A4',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 12.0,
      fontFamily: json['fontFamily'] as String? ?? 'Roboto',
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      textAlign: json['textAlign'] as String? ?? 'left',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pages': pages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paperSize': paperSize,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'textAlign': textAlign,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    List<String>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paperSize,
    double? fontSize,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    String? textAlign,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paperSize: paperSize ?? this.paperSize,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      textAlign: textAlign ?? this.textAlign,
    );
  }
}