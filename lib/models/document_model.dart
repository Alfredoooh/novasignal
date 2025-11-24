class DocumentModel {
  final String name;
  final String category;
  final bool isPro;
  final String html;
  final String coverImage; // URL da imagem PNG/JPG/WEBP no GitHub

  DocumentModel({
    required this.name,
    required this.category,
    required this.isPro,
    required this.html,
    required this.coverImage,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json['name'] as String,
      category: json['category'] as String,
      isPro: json['pro'] as bool,
      html: json['html'] as String,
      coverImage: json['coverImage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'pro': isPro,
      'html': html,
      'coverImage': coverImage,
    };
  }
}