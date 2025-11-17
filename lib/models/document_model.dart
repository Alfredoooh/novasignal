// models/document_model.dart
class DocumentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String thumbnailUrl;
  final double price;
  final bool isFree;
  final List<String> tags;
  final String? fileUrl;
  final int downloads;
  final double rating;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.price,
    this.isFree = false,
    required this.tags,
    this.fileUrl,
    this.downloads = 0,
    this.rating = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'isFree': isFree,
      'tags': tags,
      'fileUrl': fileUrl,
      'downloads': downloads,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      isFree: map['isFree'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      fileUrl: map['fileUrl'],
      downloads: map['downloads'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}