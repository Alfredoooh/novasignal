class DocumentModel {
  final String id;
  final String name;
  final String category;
  final bool isPro;
  final String coverImage;
  final String html;

  DocumentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.isPro,
    required this.coverImage,
    required this.html,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    try {
      return DocumentModel(
        id: json['id']?.toString() ?? 'Untitled',
        name: json['name']?.toString() ?? 'Untitled',
        category: json['category']?.toString() ?? 'General',
        // AQUI ESTÁ A CORREÇÃO: aceita tanto "pro" quanto "isPro"
        isPro: json['isPro'] as bool? ?? json['pro'] as bool? ?? false,
        coverImage: json['coverImage']?.toString() ?? '',
        html: json['html']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Erro ao criar DocumentModel: $e');
      print('📄 JSON problemático: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isPro': isPro,
      'coverImage': coverImage,
      'html': html,
    };
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, name: $name, category: $category, isPro: $isPro)';
  }
}