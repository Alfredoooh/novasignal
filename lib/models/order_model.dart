// models/order_model.dart
class OrderModel {
  final String id;
  final String userId;
  final List<OrderDocumentItem> documents;
  final String status; // 'pending', 'in_progress', 'completed', 'cancelled'
  final double totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.documents,
    this.status = 'pending',
    required this.totalPrice,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'status': status,
      'totalPrice': totalPrice,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      documents: (map['documents'] as List)
          .map((doc) => OrderDocumentItem.fromMap(doc))
          .toList(),
      status: map['status'] ?? 'pending',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}

class OrderDocumentItem {
  final String documentId;
  final String documentTitle;
  final String userDescription; // CAMPO OBRIGATÓRIO
  final DateTime? deadline;
  final String urgency; // 'low', 'medium', 'high'
  final String? additionalInfo;
  final double price;

  OrderDocumentItem({
    required this.documentId,
    required this.documentTitle,
    required this.userDescription,
    this.deadline,
    this.urgency = 'medium',
    this.additionalInfo,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'documentTitle': documentTitle,
      'userDescription': userDescription,
      'deadline': deadline?.toIso8601String(),
      'urgency': urgency,
      'additionalInfo': additionalInfo,
      'price': price,
    };
  }

  factory OrderDocumentItem.fromMap(Map<String, dynamic> map) {
    return OrderDocumentItem(
      documentId: map['documentId'] ?? '',
      documentTitle: map['documentTitle'] ?? '',
      userDescription: map['userDescription'] ?? '',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      urgency: map['urgency'] ?? 'medium',
      additionalInfo: map['additionalInfo'],
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
