// services/firebase/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/document_model.dart';
import '../../models/wishlist_item_model.dart';
import '../../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ DOCUMENTOS ============
  
  // Buscar todos os documentos
  Stream<List<DocumentModel>> getDocuments() {
    return _firestore
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.data()))
            .toList());
  }

  // Buscar documentos por categoria
  Stream<List<DocumentModel>> getDocumentsByCategory(String category) {
    return _firestore
        .collection('documents')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromMap(doc.data()))
            .toList());
  }

  // Buscar documento por ID
  Future<DocumentModel?> getDocumentById(String id) async {
    final doc = await _firestore.collection('documents').doc(id).get();
    if (doc.exists) {
      return DocumentModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Buscar documentos (search)
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final snapshot = await _firestore
        .collection('documents')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    return snapshot.docs
        .map((doc) => DocumentModel.fromMap(doc.data()))
        .toList();
  }

  // ============ WISHLIST ============
  
  // Adicionar item à wishlist
  Future<void> addToWishlist(String userId, WishlistItemModel item) async {
    await _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('items')
        .doc(item.documentId)
        .set(item.toMap());
  }

  // Remover item da wishlist
  Future<void> removeFromWishlist(String userId, String documentId) async {
    await _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('items')
        .doc(documentId)
        .delete();
  }

  // Buscar wishlist do usuário
  Stream<List<WishlistItemModel>> getWishlist(String userId) {
    return _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WishlistItemModel.fromMap(doc.data()))
            .toList());
  }

  // Verificar se documento está na wishlist
  Future<bool> isInWishlist(String userId, String documentId) async {
    final doc = await _firestore
        .collection('wishlists')
        .doc(userId)
        .collection('items')
        .doc(documentId)
        .get();
    return doc.exists;
  }

  // ============ PEDIDOS ============
  
  // Criar pedido
  Future<String> createOrder(OrderModel order) async {
    final docRef = await _firestore.collection('orders').add(order.toMap());
    return docRef.id;
  }

  // Buscar pedidos do usuário
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Buscar pedido por ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromMap({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  // Atualizar status do pedido
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}