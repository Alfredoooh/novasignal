import 'package:flutter/foundation.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  int get itemCount => _cart.length;

  double get totalAmount {
    return _cart.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1) as int;
      return sum + (price * quantity);
    });
  }

  void addToCart(Map<String, dynamic> product) {
    // Verificar se o produto já existe no carrinho
    final existingIndex = _cart.indexWhere((item) => item['id'] == product['id']);
    
    if (existingIndex >= 0) {
      // Se existe, incrementar quantidade
      _cart[existingIndex]['quantity'] = (_cart[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      // Se não existe, adicionar novo item com quantidade 1
      _cart.add({
        ...product,
        'quantity': 1,
      });
    }
    
    notifyListeners();
  }

  void removeFromCart(Map<String, dynamic> product) {
    _cart.removeWhere((item) => item['id'] == product['id']);
    notifyListeners();
  }

  void updateQuantity(Map<String, dynamic> product, int quantity) {
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    
    if (index >= 0) {
      if (quantity > 0) {
        _cart[index]['quantity'] = quantity;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  bool isInCart(dynamic productId) {
    return _cart.any((item) => item['id'] == productId);
  }

  int getQuantity(dynamic productId) {
    final item = _cart.firstWhere(
      (item) => item['id'] == productId,
      orElse: () => {'quantity': 0},
    );
    return item['quantity'] ?? 0;
  }
}