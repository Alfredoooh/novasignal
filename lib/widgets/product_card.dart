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
  bool _imageLoaded = false;

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

    String imageUrl = '';
    
    // DummyJSON retorna 'thumbnail' e 'images'
    if (widget.product['thumbnail'] != null && widget.product['thumbnail'].toString().isNotEmpty) {
      imageUrl = widget.product['thumbnail'].toString();
    } else if (widget.product['images'] != null && widget.product['images'] is List) {
      final images = widget.product['images'] as List;
      if (images.isNotEmpty && images[0] != null) {
        imageUrl = images[0].toString();
      }
    } else if (widget.product['image'] != null && widget.product['image'].toString().isNotEmpty) {
      imageUrl = widget.product['image'].toString();
    }
    
    // Garantir que é uma URL válida
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '';
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120 + widget.imageHeightVariation.toDouble(),
                width: double.infinity,
                color: const Color(0xFFFFFFFF),
                child: imageUrl.isEmpty
                    ? _buildImagePlaceholder()
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            _imageLoaded = true;
                            return child;
                          }
                          if (frame != null) {
                            if (!_imageLoaded) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() => _imageLoaded = true);
                                }
                              });
                            }
                            return child;
                          }
                          return _buildImagePlaceholder();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Low Stock Badge
                              if (hasLowStock)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF9500),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        stock == 1 ? 'Último!' : 'Apenas $stock',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Favorite Button
                        _FavoriteButton(isDark: widget.isDark),
                      ],
                    ),
                    // Title
                    Text(
                      widget.product['title'] ?? 'Produto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                        height: 1.3,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Rating (se existir na API)
                    if (rating > 0) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ] else
                      const SizedBox(height: 2),

                    const Spacer(),

                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AOA${formatPrice(productPrice)}',
                          style: TextStyle(
                            fontSize: 16,
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
                              fontSize: 11,
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
      height: 120 + widget.imageHeightVariation.toDouble(),
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      child: _SkeletonLoader(isDark: widget.isDark),
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
      child: _showGif
          ? Image.asset(
              'assets/like_animation.gif',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.favorite,
                  size: 20,
                  color: Colors.red,
                );
              },
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: _isFavorite ? Colors.red : (widget.isDark ? const Color(0xFFB0B3B8) : Colors.grey[700]),
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
                const Color(0xFFE5E5EA).withOpacity(_animation.value),
                const Color(0xFFD1D1D6).withOpacity(_animation.value),
                const Color(0xFFE5E5EA).withOpacity(_animation.value),
              ],
            ),
          ),
        );
      },
    );
  }
}