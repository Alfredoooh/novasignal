import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LojaTabScreen extends StatefulWidget {
  final Color bgColor;
  final bool isDark;
  final String currentLocale;

  const LojaTabScreen({
    Key? key,
    required this.bgColor,
    required this.isDark,
    required this.currentLocale,
    Widget _buildEmptyState(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_store.png',
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
            'Tente novamente mais tarde',
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
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoadingStores = true);
    try {
      // Carregar produtos para extrair lojas únicas
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;
        
        // Extrair lojas únicas com base na marca
        final storesMap = <String, Map<String, dynamic>>{};
        for (var product in products) {
          final brand = product['brand'] ?? 'Sem Marca';
          if (!storesMap.containsKey(brand)) {
            storesMap[brand] = {
              'name': brand,
              'id': brand.toLowerCase().replaceAll(' ', '_'),
              'logo': product['thumbnail'] ?? product['image'],
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
            
            // Selecionar primeira loja automaticamente
            if (_stores.isNotEmpty) {
              _selectedStore = _stores[0]['name'];
              _loadStoreProducts(_stores[0]['name']);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStores = false);
      }
    }
  }

  Future<void> _loadStoreProducts(String storeName) async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;
        
        final filteredProducts = products
            .where((p) => (p['brand'] ?? 'Sem Marca') == storeName)
            .map((p) => p as Map<String, dynamic>)
            .toList();
        
        if (mounted) {
          setState(() {
            _storeProducts = filteredProducts;
            _isLoadingProducts = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  List<String> _getCategories() {
    final categories = <String>{'Todos'};
    for (var product in _storeProducts) {
      if (product['category'] != null) {
        categories.add(product['category']);
      }
    }
    return categories.toList();
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    var filtered = _storeProducts;
    
    if (_selectedCategory != 'Todos') {
      filtered = filtered.where((p) => p['category'] == _selectedCategory).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        (p['title'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (p['description'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final cardColor = widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);

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
            child: _isLoadingStores
                ? _buildLoadingSidebar()
                : ListView.builder(
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
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF007AFF).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF007AFF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isDark 
                                      ? const Color(0xFF3E4042) 
                                      : const Color(0xFFFFFFFF),
                                  border: Border.all(
                                    color: widget.isDark 
                                        ? const Color(0xFF4A4C4E) 
                                        : const Color(0xFFE4E6EB),
                                    width: 2,
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
                                  color: isSelected ? const Color(0xFF007AFF) : textColor,
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

          // Área Principal de Produtos
          Expanded(
            child: Column(
              children: [
                // Header da Loja
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(
                      bottom: BorderSide(
                        color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedStore != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.store_rounded,
                              size: 28,
                              color: const Color(0xFF007AFF),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedStore!,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    '${_storeProducts.length} produtos disponíveis',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleColor,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Barra de Pesquisa
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.isDark 
                                ? const Color(0xFF3E4042) 
                                : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              letterSpacing: 0.1,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Pesquisar produtos...',
                              hintStyle: TextStyle(
                                color: subtitleColor,
                                fontSize: 15,
                                letterSpacing: 0.1,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: subtitleColor,
                                size: 22,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: subtitleColor,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Filtro de Categorias
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _getCategories().length,
                            itemBuilder: (context, index) {
                              final category = _getCategories()[index];
                              final isSelected = _selectedCategory == category;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedCategory = category);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? const Color(0xFF007AFF)
                                        : (widget.isDark 
                                            ? const Color(0xFF3E4042) 
                                            : const Color(0xFFF2F2F7)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected ? Colors.white : textColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Grid de Produtos
                Expanded(
                  child: _isLoadingProducts
                      ? _buildLoadingGrid()
                      : _getFilteredProducts().isEmpty
                          ? _buildEmptyState(textColor, subtitleColor)
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _getFilteredProducts().length,
                              itemBuilder: (context, index) {
                                final product = _getFilteredProducts()[index];
                                return _ProductCard(
                                  product: product,
                                  isDark: widget.isDark,
                                  textColor: textColor,
                                  subtitleColor: subtitleColor,
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

  Widget _buildLoadingSidebar() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _ShimmerBox(
                width: 56,
                height: 56,
                borderRadius: 28,
                isDark: widget.isDark,
              ),
              const SizedBox(height: 6),
              _ShimmerBox(
                width: 60,
                height: 10,
                borderRadius: 4,
                isDark: widget.isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                width: double.infinity,
                height: 160,
                borderRadius: 16,
                isDark: widget.isDark,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: double.infinity, height: 14, borderRadius: 4, isDark: widget.isDark),
                    const SizedBox(height: 8),
                    _ShimmerBox(width: 100, height: 12, borderRadius: 4, isDark: widget.isDark),
                    const SizedBox(height: 12),
                    _ShimmerBox(width: 80, height: 20, borderRadius: 4, isDark: widget.isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtitleColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: subtitleColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros',
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
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final price = product['price'] ?? 0.0;
    final hasDiscount = product['discountPercentage'] != null && product['discountPercentage'] > 0;
    final discount = hasDiscount ? product['discountPercentage'].toInt() : 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product['thumbnail'] ?? product['image'] ?? '',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7),
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        size: 48,
                        color: subtitleColor,
                      ),
                    );
                  },
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-$discount%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Produto',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.3,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: hasDiscount ? const Color(0xFFFF3B30) : textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
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
    )..repeat();
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