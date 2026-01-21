import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_strings.dart';
import '../assets/app_icons.dart';

const Color primaryColor = Color(0xFF2C3E50);

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedColor;
  String? selectedSize;
  int quantity = 1;
  final List<String> availableColors = ['Vermelho', 'Azul', 'Verde', 'Preto', 'Branco'];
  final List<String> availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    selectedColor = availableColors.first;
    selectedSize = availableSizes[1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final locale = LocaleProvider.of(context);
    final cartProvider = CartProvider.of(context);
    final isDark = theme?.isDark ?? false;
    final currentLocale = locale?.locale ?? 'pt';
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    final isInCart = cartProvider?.cart.any((item) => item['id'] == widget.product['id']) ?? false;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.string(
                        AppIcons.arrowLeft,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppStrings.get('product_details', currentLocale),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    color: isDark ? const Color(0xFFF5F5F5) : Colors.white,
                    height: 300,
                    child: Image.network(
                      widget.product['thumbnail'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? const Color(0xFFF5F5F5) : const Color(0xFFF0F2F5),
                          child: const Icon(Icons.error, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  Container(
                    color: cardColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['title'],
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product['rating'] ?? 4.5}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.product['reviews']?.length ?? 0} ${AppStrings.get('reviews', currentLocale)})',
                              style: TextStyle(fontSize: 13, color: subtitleColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${widget.product['price']}',
                          style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        if (widget.product['brand'] != null) ...[
                          Row(
                            children: [
                              Text(
                                '${AppStrings.get('brand', currentLocale)}: ',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                              ),
                              Text(
                                widget.product['brand'],
                                style: TextStyle(fontSize: 15, color: subtitleColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (widget.product['category'] != null) ...[
                          Row(
                            children: [
                              Text(
                                '${AppStrings.get('category', currentLocale)}: ',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                              ),
                              Text(
                                widget.product['category'],
                                style: TextStyle(fontSize: 15, color: subtitleColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Text(
                              '${AppStrings.get('availability', currentLocale)}: ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (widget.product['stock'] ?? 0) > 0 ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (widget.product['stock'] ?? 0) > 0 ? AppStrings.get('in_stock', currentLocale) : AppStrings.get('out_of_stock', currentLocale),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: (widget.product['stock'] ?? 0) > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.get('description', currentLocale),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product['description'],
                          style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.4),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('select_color', currentLocale),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableColors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  color,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : textColor,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('select_size', currentLocale),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: availableSizes.map((size) {
                            final isSelected = selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => selectedSize = size),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryColor : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('quantity', currentLocale),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.remove, color: textColor, size: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              quantity.toString(),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                if (quantity < (widget.product['stock'] ?? 99)) setState(() => quantity++);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: (widget.product['stock'] ?? 0) > 0
                                ? () {
                                    if (isInCart) {
                                      cartProvider?.removeFromCart(widget.product);
                                    } else {
                                      final productWithDetails = Map<String, dynamic>.from(widget.product);
                                      productWithDetails['selectedColor'] = selectedColor;
                                      productWithDetails['selectedSize'] = selectedSize;
                                      productWithDetails['quantity'] = quantity;
                                      cartProvider?.addToCart(productWithDetails);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(AppStrings.get('add_to_cart', currentLocale)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isInCart ? Colors.red : primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  isInCart ? AppStrings.get('remove_from_cart', currentLocale) : AppStrings.get('add_to_cart', currentLocale),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}