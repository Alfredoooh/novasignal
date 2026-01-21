import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

const Color primaryColor = Color(0xFF2C3E50);

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final bool isInCart;
  final int imageHeightVariation;
  final VoidCallback onTap;
  final VoidCallback onCartAction;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isDark,
    required this.isInCart,
    required this.imageHeightVariation,
    required this.onTap,
    required this.onCartAction,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;
  bool _isImageLoading = true;
  bool _hasImageError = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    // Dados reais da API
    final hasDiscount = widget.product['discountPercentage'] != null && 
                        widget.product['discountPercentage'] > 0;
    final discountPercent = hasDiscount ? widget.product['discountPercentage'].toInt() : 0;
    final productPrice = widget.product['price'] ?? 0.0;
    final stock = widget.product['stock'] ?? 0;
    final hasLowStock = stock > 0 && stock <= 5;
    final rating = widget.product['rating'] ?? 0.0;
    
    // Calcular preço original se houver desconto
    final originalPrice = hasDiscount 
        ? (productPrice / (1 - discountPercent / 100)) 
        : productPrice;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.isDark 
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
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _hasImageError || _isImageLoading
                      ? _buildImagePlaceholder()
                      : Image.network(
                          widget.product['thumbnail'] ?? widget.product['image'] ?? '',
                          height: 160 + widget.imageHeightVariation.toDouble(),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              _isImageLoading = false;
                              return child;
                            }
                            return _buildImagePlaceholder();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _hasImageError = true);
                              }
                            });
                            return _buildImagePlaceholder();
                          },
                        ),
                ),
                
                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                
                // Low Stock Badge
                if (hasLowStock)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stock == 1 ? 'Último!' : 'Apenas $stock',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.product['title'] ?? 'Produto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating (se existir na API)
                    if (rating > 0) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ] else
                      const SizedBox(height: 4),
                    
                    const Spacer(),
                    
                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount)
                                Text(
                                  '\$${originalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.isDark 
                                        ? const Color(0xFF65676B) 
                                        : const Color(0xFF8E8E93),
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              Text(
                                '\$${productPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: hasDiscount ? const Color(0xFFFF3B30) : (
                                    widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21)
                                  ),
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Like Button
                        GestureDetector(
                          onTap: () {
                            setState(() => _isFavorite = !_isFavorite);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isFavorite 
                                  ? const Color(0xFFFF3B30).withOpacity(0.1)
                                  : (widget.isDark 
                                      ? const Color(0xFF3E4042) 
                                      : const Color(0xFFF2F2F7)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: _isFavorite 
                                  ? const Color(0xFFFF3B30)
                                  : (widget.isDark 
                                      ? const Color(0xFFB0B3B8) 
                                      : const Color(0xFF8E8E93)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160 + widget.imageHeightVariation.toDouble(),
      width: double.infinity,
      color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7),
      child: _isImageLoading && !_hasImageError
          ? _SkeletonLoader(isDark: widget.isDark)
          : Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 48,
                color: widget.isDark 
                    ? const Color(0xFF65676B) 
                    : const Color(0xFFB0B3B8),
              ),
            ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  final bool isDark;

  const _SkeletonLoader({required this.isDark});

  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader> 
    with SingleTickerProviderStateMixin {
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7))
                    .withOpacity(_animation.value),
                (widget.isDark ? const Color(0xFF4A4C4E) : const Color(0xFFE5E5EA))
                    .withOpacity(_animation.value),
                (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7))
                    .withOpacity(_animation.value),
              ],
            ),
          ),
        );
      },
    );
  }
}