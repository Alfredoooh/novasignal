class CartProvider extends InheritedWidget {
  final List<Map<String, dynamic>> cart;
  final Function(Map<String, dynamic>) addToCart;
  final Function(Map<String, dynamic>) removeFromCart;
  final Function(Map<String, dynamic>, int)? updateQuantity; // Adicionar isto

  const CartProvider({
    Key? key,
    required this.cart,
    required this.addToCart,
    required this.removeFromCart,
    this.updateQuantity,
    required Widget child,
  }) : super(key: key, child: child);

  static CartProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartProvider>();
  }

  @override
  bool updateShouldNotify(CartProvider oldWidget) => cart != oldWidget.cart;
}