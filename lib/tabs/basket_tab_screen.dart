import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/cart_provider.dart';
import '../utils/app_strings.dart';

const Color primaryColor = Color(0xFF2C3E50);

class BasketTabScreen extends StatelessWidget {
  final Color bgColor;
  final bool isDark;
  final String currentLocale;

  const BasketTabScreen({
    Key? key,
    required this.bgColor,
    required this.isDark,
    required this.currentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = CartProvider.of(context);
    final cart = cartProvider?.cart ?? [];
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 100, color: textColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('empty_cart', currentLocale),
              style: TextStyle(fontSize: 24, color: textColor),
            ),
          ],
        ),
      );
    }

    double totalPrice = 0;
    for (var item in cart) {
      totalPrice += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final product = cart[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product['thumbnail'] ?? product['image'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: const Icon(Icons.error),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    product['title'],
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${product['price']}',
                        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                      if (product['selectedColor'] != null)
                        Text(
                          'Cor: ${product['selectedColor']}',
                          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                        ),
                      if (product['selectedSize'] != null)
                        Text(
                          'Tamanho: ${product['selectedSize']}',
                          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                        ),
                      if (product['quantity'] != null)
                        Text(
                          'Qtd: ${product['quantity']}',
                          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      cartProvider?.removeFromCart(product);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('total', currentLocale),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.get('checkout', currentLocale)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppStrings.get('checkout', currentLocale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}