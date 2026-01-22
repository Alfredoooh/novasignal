import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'dart:math';

const Color primaryColor = Color(0xFF2C3E50);

String formatPrice(double price) {
  String str = price.toStringAsFixed(2);
  final parts = str.split('.');
  String integerPart = parts[0];
  String formatted = '';
  while (integerPart.length > 3) {
    formatted = ',' + integerPart.substring(integerPart.length - 3) + formatted;
    integerPart = integerPart.substring(0, integerPart.length - 3);
  }
  formatted = integerPart + formatted;
  return formatted + '.' + parts[1];
}

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

    String imageUrl = widget.product['thumbnail'] ?? widget.product['image'] ?? '';
    if (imageUrl.isEmpty && widget.product['images'] is List && (widget.product['images'] as List).isNotEmpty) {
      imageUrl = (widget.product['images'] as List)[0];
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: _hasImageError || _isImageLoading
                      ? _buildImagePlaceholder()
                      : Image.network(
                          imageUrl,
                          height: 160 + widget.imageHeightVariation.toDouble(),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() => _isImageLoading = false);
                                }
                              });
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

                // Favorite Button no topo
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteButton(isDark: widget.isDark),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AOA${formatPrice(productPrice)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            '$discountPercent% off',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF3B30),
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
      color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE5E5EA),
      child: _isImageLoading && !_hasImageError
          ? _SkeletonLoader(isDark: widget.isDark)
          : Center(
              child: Icon(
                Icons.image_not_supported_rounded,
                size: 48,
                color: widget.isDark 
                    ? const Color(0xFF65676B) 
                    : const Color(0xFFA0A0A5),
              ),
            ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isDark;

  const _FavoriteButton({required this.isDark});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isFavorite = false;
  bool _showGif = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isFavorite) {
          setState(() {
            _isFavorite = true;
            _showGif = true;
          });
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() => _showGif = false);
            }
          });
        } else {
          setState(() => _isFavorite = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _showGif
            ? Image.asset(
                'assets/like_animation.gif',
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.red,
                  );
                },
              )
            : Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: _isFavorite ? Colors.red : Colors.grey[700],
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
                (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE5E5EA))
                    .withOpacity(_animation.value),
                (widget.isDark ? const Color(0xFF4A4C4E) : const Color(0xFFD1D1D6))
                    .withOpacity(_animation.value),
                (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE5E5EA))
                    .withOpacity(_animation.value),
              ],
            ),
          ),
        );
      },
    );
  }
}