import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';

class InicioTabScreen extends StatelessWidget {
  final Color bgColor;
  final bool isDark;
  final Future<List<dynamic>> productsFuture;
  final String selectedCategory;
  final List<String> categories;

  const InicioTabScreen({
    Key? key,
    required this.bgColor,
    required this.isDark,
    required this.productsFuture,
    required this.selectedCategory,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: FutureBuilder<List<dynamic>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: 10,
              itemBuilder: (context, index) => StaggeredGridTile.fit(
                crossAxisCellCount: 1,
                child: _buildSkeletonProductCard(isDark),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<dynamic> products = snapshot.data!;
            if (selectedCategory != 'Todos') {
              products = List.from(products)..shuffle();
              products = products.take(10).toList();
            }
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final cartProvider = CartProvider.of(context);
                final isInCart = cartProvider?.cart.any((item) => item['id'] == product['id']) ?? false;
                return ProductCard(
                  product: product,
                  isDark: isDark,
                  isInCart: isInCart,
                  imageHeightVariation: index % 5 * 30,
                  onTap: () {
                    Navigator.of(context).pushNamed('/product_details', arguments: product);
                  },
                  onCartAction: () {
                    if (isInCart) {
                      cartProvider?.removeFromCart(product);
                    } else {
                      cartProvider?.addToCart(product);
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildSkeletonProductCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmer(double.infinity, 120, isDark),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(100, 12, isDark),
                const SizedBox(height: 4),
                _buildShimmer(60, 10, isDark),
                const SizedBox(height: 4),
                _buildShimmer(80, 12, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(double width, double height, bool isDark, {bool isCircle = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.zero,
            ),
          ),
        );
      },
    );
  }
}