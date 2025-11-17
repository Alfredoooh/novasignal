// lib/models/wishlist_item_model.dart
import 'document_model.dart'; // CORRIGIDO: Import adicionado

class WishlistItemModel {
  final String documentId;
  final String documentTitle;
  final String documentCategory;
  final String thumbnailUrl;
  final double price;
  final DateTime addedAt;

  WishlistItemModel({
    required this.documentId,
    required this.documentTitle,
    required this.documentCategory,
    required this.thumbnailUrl,
    required this.price,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'documentCategory': documentCategory,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      documentCategory: map['documentCategory'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      addedAt: DateTime.parse(map['addedAt']),
    );
  }

  // CORRIGIDO: Agora com import correto do DocumentModel
  factory WishlistItemModel.fromDocument(DocumentModel doc) {
    return WishlistItemModel(
      documentId: doc.id,
      documentTitle: doc.title,
      documentCategory: doc.category,
      thumbnailUrl: doc.thumbnailUrl,
      price: doc.price,
      addedAt: DateTime.now(),
    );
  }
}