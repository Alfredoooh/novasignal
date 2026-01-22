import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../screens/product_details_screen.dart';

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
            return _buildSkeletonView();
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState();
          } else {
            List<dynamic> products = snapshot.data!;
            if (selectedCategory != 'Todos') {
              products = List.from(products)..shuffle();
              products = products.take(10).toList();
            }

            if (selectedCategory == 'Todos') {
              return _buildAllProductsView(products);
            } else {
              return _buildGridView(products);
            }
          }
        },
      ),
    );
  }

  Widget _buildErrorState() {
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/error_state.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.error_outline_rounded,
                size: 100,
                color: subtitleColor.withOpacity(0.5),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao carregar produtos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifique sua conexão',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllProductsView(List<dynamic> products) {
    final lowPriceProducts = products.where((p) => (p['price'] ?? 0) < 30).toList();
    final midPriceProducts = products.where((p) => (p['price'] ?? 0) >= 30 && (p['price'] ?? 0) < 100).toList();
    final allProducts = List.from(products);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (lowPriceProducts.isNotEmpty) ...[
          _buildSectionTitle('Ofertas Relâmpago', Icons.flash_on_rounded),
          _buildHorizontalProductList(lowPriceProducts),
          const SizedBox(height: 16),
        ],
        if (midPriceProducts.isNotEmpty) ...[
          _buildSectionTitle('Escolha do Editor', Icons.local_fire_department_rounded),
          _buildHorizontalProductList(midPriceProducts),
          const SizedBox(height: 16),
        ],
        _buildSectionTitle('Todos os Produtos', Icons.shopping_bag_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            itemCount: allProducts.length,
            itemBuilder: (context, index) {
              final product = allProducts[index];
              final cartProvider = Provider.of<CartProvider>(context);
              final isInCart = cartProvider.cart.any((item) => item['id'] == product['id']);
              return ProductCard(
                product: product,
                isDark: isDark,
                isInCart: isInCart,
                imageHeightVariation: index % 5 * 30,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsScreen(product: product),
                    ),
                  );
                },
                onCartAction: () {
                  if (isInCart) {
                    cartProvider.removeFromCart(product);
                  } else {
                    cartProvider.addToCart(product);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF007AFF),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductList(List<dynamic> products) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final cartProvider = Provider.of<CartProvider>(context);
          final isInCart = cartProvider.cart.any((item) => item['id'] == product['id']);
          return Container(
            width: 160,
            margin: EdgeInsets.only(right: index == products.length - 1 ? 0 : 8),
            child: ProductCard(
              product: product,
              isDark: isDark,
              isInCart: isInCart,
              imageHeightVariation: 0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(product: product),
                  ),
                );
              },
              onCartAction: () {
                if (isInCart) {
                  cartProvider.removeFromCart(product);
                } else {
                  cartProvider.addToCart(product);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(List<dynamic> products) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final cartProvider = Provider.of<CartProvider>(context);
        final isInCart = cartProvider.cart.any((item) => item['id'] == product['id']);
        return ProductCard(
          product: product,
          isDark: isDark,
          isInCart: isInCart,
          imageHeightVariation: index % 5 * 30,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
          onCartAction: () {
            if (isInCart) {
              cartProvider.removeFromCart(product);
            } else {
              cartProvider.addToCart(product);
            }
          },
        );
      },
    );
  }

  Widget _buildSkeletonView() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      itemCount: 10,
      itemBuilder: (context, index) => _buildSkeletonProductCard(),
    );
  }

  Widget _buildSkeletonProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(
            width: double.infinity,
            height: 160,
            borderRadius: 16,
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 14, borderRadius: 4, isDark: isDark),
                const SizedBox(height: 8),
                _ShimmerBox(width: 120, height: 14, borderRadius: 4, isDark: isDark),
                const SizedBox(height: 12),
                _ShimmerBox(width: 80, height: 20, borderRadius: 4, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDark;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isDark,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7))
                .withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}