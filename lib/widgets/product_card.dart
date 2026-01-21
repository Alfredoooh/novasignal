import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:math';

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

  @override
  Widget build(BuildContext context) {
    final random = Random(widget.product['id']);
    final hasDiscount = random.nextBool();
    final discountPercent = hasDiscount ? (10 + random.nextInt(40)) : 0;
    final originalPrice = hasDiscount ? (widget.product['price'] / (1 - discountPercent / 100)) : widget.product['price'];
    final soldCount = 100 + random.nextInt(9900);
    final stock = widget.product['stock'] ?? (10 + random.nextInt(90));
    final hasLowStock = stock <= 5;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: ColorFiltered(
                    colorFilter: widget.isDark 
                        ? const ColorFilter.mode(Color(0xFFB0B3B8), BlendMode.modulate)
                        : const ColorFilter.mode(Colors.transparent, BlendMode.color),
                    child: Image.network(
                      widget.product['thumbnail'] ?? widget.product['image'] ?? '',
                      height: 160 + widget.imageHeightVariation.toDouble(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: widget.isDark ? const Color(0xFF5E6266) : const Color(0xFFB0B3B8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          (widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF)).withOpacity(0.9),
                          (widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF)).withOpacity(0.6),
                          (widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF)).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '-$discountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (hasLowStock)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            stock == 1 ? 'Último!' : '$stock restam',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteButton(isDark: widget.isDark),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['title'],
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'AOA${widget.product['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          'AOA${originalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 13,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.product['rating'] ?? 4.5}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 2,
                        height: 2,
                        decoration: BoxDecoration(
                          color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$soldCount vendidos',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 11,
                          color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Envio grátis',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
                          ),
                        ),
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

class _FavoriteButton extends StatefulWidget {
  final bool isDark;

  const _FavoriteButton({required this.isDark});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isFavorite = !_isFavorite);
        _controller.forward().then((_) => _controller.reverse());
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
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
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: _isFavorite ? Colors.red : Colors.grey[700],
              ),
            ),
          );
        },
      ),
    );
  }
}