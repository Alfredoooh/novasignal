// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/firebase/firestore_service.dart';
import '../models/order_model.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId;
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  OrderProvider(this._userId) {
    if (_userId != null) {
      _loadOrders();
    }
  }

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _loadOrders() {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return;
    
    _firestoreService.getUserOrders(userId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<bool> createOrder(List<OrderDocumentItem> documents) async {
    // CORRIGIDO: Verificação explícita de null
    final userId = _userId;
    if (userId == null) return false;
    
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final totalPrice = documents.fold<double>(
        0.0,
        (sum, item) => sum + item.price,
      );

      final order = OrderModel(
        id: const Uuid().v4(),
        userId: userId, // CORRIGIDO: Agora é String não-nulo
        documents: documents,
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createOrder(order);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestoreService.updateOrderStatus(orderId, status);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}