import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../screens/product_details_screen.dart';

class LojaTabScreen extends StatefulWidget {
  final Color bgColor;
  final bool isDark;
  final String currentLocale;

  const LojaTabScreen({
    Key? key,
    required this.bgColor,
    required this.isDark,
    required this.currentLocale,
  }) : super(key: key);

  @override
  State<LojaTabScreen> createState() => _LojaTabScreenState();
}

class _LojaTabScreenState extends State<LojaTabScreen> {
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _storeProducts = [];
  String? _selectedStore;
  bool _isLoadingStores = true;
  bool _isLoadingProducts = false;
  bool _hasStoresError = false;
  bool _hasProductsError = false;
  String _selectedCategory = 'Todos';
  List<String> _categories = ['Todos'];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoadingStores = true;
      _hasStoresError = false;
    });
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        final storesMap = <String, Map<String, dynamic>>{};
        for (var product in products) {
          final brand = product['brand'] ?? 'Sem Marca';
          if (!storesMap.containsKey(brand)) {
            storesMap[brand] = {
              'name': brand,
              'id': brand.toLowerCase().replaceAll(' ', '_'),
              'logo': product['thumbnail'] ?? product['images']?[0] ?? product['image'],
              'category': product['category'] ?? 'Geral',
              'productCount': 1,
            };
          } else {
            storesMap[brand]!['productCount'] = (storesMap[brand]!['productCount'] ?? 0) + 1;
          }
        }

        if (mounted) {
          setState(() {
            _stores = storesMap.values.toList()..sort((a, b) => 
              (b['productCount'] as int).compareTo(a['productCount'] as int));
            _isLoadingStores = false;
            _hasStoresError = false;

            if (_stores.isNotEmpty) {
              _selectedStore = _stores[0]['name'];
              _loadStoreProducts(_stores[0]['name']);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStores = false;
          _hasStoresError = true;
        });
      }
    }
  }

  Future<void> _loadStoreProducts(String storeName) async {
    setState(() {
      _isLoadingProducts = true;
      _hasProductsError = false;
    });
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;

        final filteredProducts = products
            .where((p) => (p['brand'] ?? 'Sem Marca') == storeName)
            .map((p) => p as Map<String, dynamic>)
            .toList();

        final categoriesSet = <String>{'Todos'};
        for (var product in filteredProducts) {
          if (product['category'] != null) {
            categoriesSet.add(product['category']);
          }
        }

        if (mounted) {
          setState(() {
            _storeProducts = filteredProducts;
            _categories = categoriesSet.toList();
            _selectedCategory = 'Todos';
            _isLoadingProducts = false;
            _hasProductsError = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
          _hasProductsError = true;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    var filtered = _storeProducts;

    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((p) => p['category'] == _selectedCategory).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);

    if (_isLoadingStores) {
      return Container(
        color: widget.bgColor,
        child: _buildLoadingFullScreen(),
      );
    }

    if (_hasStoresError || _stores.isEmpty) {
      return Container(
        color: widget.bgColor,
        child: _buildEmptyStoresFullScreen(textColor, subtitleColor),
      );
    }

    return Container(
      color: widget.bgColor,
      child: Row(
        children: [
          // Sidebar de Lojas
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFF8F9FA),
              border: Border(
                right: BorderSide(
                  color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _stores.length,
              itemBuilder: (context, index) {
                final store = _stores[index];
                final isSelected = _selectedStore == store['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedStore = store['name']);
                    _loadStoreProducts(store['name']);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? (widget.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF2C3E50))
                                  : (widget.isDark ? const Color(0xFF4A4C4E) : const Color(0xFFE4E6EB)),
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              store['logo'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.store_rounded,
                                  size: 28,
                                  color: subtitleColor,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store['name'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected 
                                ? (widget.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF2C3E50))
                                : textColor,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${store['productCount']} items',
                          style: TextStyle(
                            fontSize: 9,
                            color: subtitleColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Área Principal
          Expanded(
            child: Column(
              children: [
                // Categorias Horizontais
                if (_selectedStore != null)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
                      border: Border(
                        bottom: BorderSide(
                          color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = category);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (widget.isDark ? const Color(0xFFFFFFFF) : const Color(0xFF2C3E50))
                                    : (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? (widget.isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF))
                                        : (widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50)),
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Grid de Produtos
                Expanded(
                  child: _isLoadingProducts
                      ? _buildLoadingGrid()
                      : _hasProductsError
                          ? _buildErrorProducts(textColor, subtitleColor)
                          : _getFilteredProducts().isEmpty
                              ? _buildEmptyProducts(textColor, subtitleColor)
                              : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _getFilteredProducts().length,
                              itemBuilder: (context, index) {
                                final product = _getFilteredProducts()[index];
                                final cartProvider = Provider.of<CartProvider>(context);
                                final isInCart = cartProvider.cart.any((item) => item['id'] == product['id']);

                                return ProductCard(
                                  product: product,
                                  isDark: widget.isDark,
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
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingFullScreen() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
      ),
    );
  }

  Widget _buildEmptyStoresFullScreen(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_cart.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.store_mall_directory_outlined,
                size: 100,
                color: subtitleColor.withOpacity(0.5),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhuma loja disponível',
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

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(width: double.infinity, height: 120, borderRadius: 12, isDark: widget.isDark),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: double.infinity, height: 13, borderRadius: 4, isDark: widget.isDark),
                    const SizedBox(height: 4),
                    _ShimmerBox(width: 60, height: 11, borderRadius: 4, isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _ShimmerBox(width: 100, height: 16, borderRadius: 4, isDark: widget.isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorProducts(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/error_state.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error_outline_rounded, size: 100, color: subtitleColor.withOpacity(0.5));
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Erro ao carregar produtos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.1),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifique sua conexão',
            style: TextStyle(fontSize: 14, color: subtitleColor, letterSpacing: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_products.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.inventory_2_outlined, size: 100, color: subtitleColor.withOpacity(0.5));
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.1),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros',
            style: TextStyle(fontSize: 14, color: subtitleColor, letterSpacing: 0.1),
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