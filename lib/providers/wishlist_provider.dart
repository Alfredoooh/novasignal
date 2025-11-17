// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';
import '../services/firebase/firestore_service.dart';
import '../models/wishlist_item_model.dart';
import '../models/document_model.dart';

class WishlistProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId;
  
  List<WishlistItemModel> _items = [];
  bool _isLoading = false;

  WishlistProvider(this._userId) {
    if (_userId != null) {
      _loadWishlist();
    }
  }

  List<WishlistItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;

  void _loadWishlist() {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return;
    
    _firestoreService.getWishlist(userId).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  Future<void> addToWishlist(DocumentModel document) async {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return;
    
    final item = WishlistItemModel.fromDocument(document);
    await _firestoreService.addToWishlist(userId, item);
  }

  Future<void> removeFromWishlist(String documentId) async {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return;
    
    await _firestoreService.removeFromWishlist(userId, documentId);
  }

  Future<bool> isInWishlist(String documentId) async {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return false;
    
    return await _firestoreService.isInWishlist(userId, documentId);
  }

  void clearWishlist() {
    _items = [];
    notifyListeners();
  }
}