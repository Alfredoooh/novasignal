class DocumentModel {
  final String id;
  final String name;
  final String category;
  final bool isPro;
  final String coverImage;
  final String html;
  final String? description;
  final List<Map<String, String>>? features;
  final String? downloads;
  final String? rating;

  DocumentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.isPro,
    required this.coverImage,
    required this.html,
    this.description,
    this.features,
    this.downloads,
    this.rating,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    try {
      List<Map<String, String>>? featuresList;
      if (json['features'] != null) {
        featuresList = (json['features'] as List)
            .map((f) => Map<String, String>.from(f))
            .toList();
      }

      return DocumentModel(
        id: json['id']?.toString() ?? 'Untitled',
        name: json['name']?.toString() ?? 'Untitled',
        category: json['category']?.toString() ?? 'General',
        isPro: json['isPro'] as bool? ?? json['pro'] as bool? ?? false,
        coverImage: json['coverImage']?.toString() ?? '',
        html: json['html']?.toString() ?? '',
        description: json['description']?.toString(),
        features: featuresList,
        downloads: json['downloads']?.toString(),
        rating: json['rating']?.toString(),
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
      'description': description,
      'features': features,
      'downloads': downloads,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, name: $name, category: $category, isPro: $isPro)';
  }
}