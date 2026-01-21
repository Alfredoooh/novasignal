import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_strings.dart';

class BasketTabScreen extends StatefulWidget {
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
  State<BasketTabScreen> createState() => _BasketTabScreenState();
}

class _BasketTabScreenState extends State<BasketTabScreen> {
  double? _aoaRate;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  Future<void> _fetchExchangeRate() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _aoaRate = data['rates']['AOA'] ?? 900.0;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aoaRate = 900.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;
    final textColor = widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final cardColor = widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final dividerColor = widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB);

    if (cart.isEmpty) {
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
                  Symbols.shopping_basket,
                  size: 100,
                  color: subtitleColor.withOpacity(0.5),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('empty_cart', widget.currentLocale),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione produtos ao carrinho',
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

    final Map<String, List<Map<String, dynamic>>> groupedCart = {};
    for (var item in cart) {
      final brand = item['brand'] ?? 'Loja Geral';
      if (!groupedCart.containsKey(brand)) {
        groupedCart[brand] = [];
      }
      groupedCart[brand]!.add(item);
    }

    double total = 0;
    for (var item in cart) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    final totalAOA = total * (_aoaRate ?? 900);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              bottom: BorderSide(
                color: dividerColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'All',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  cartProvider.cart.clear();
                  cartProvider.notifyListeners();
                },
                child: const Text(
                  'Esvaziar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF3B30),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: groupedCart.length,
            itemBuilder: (context, groupIndex) {
              final brand = groupedCart.keys.elementAt(groupIndex);
              final items = groupedCart[brand]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: dividerColor.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            brand,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Explorar mais',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ...items.map((item) => _CartItem(
                      item: item,
                      isDark: widget.isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      cardColor: cardColor,
                      dividerColor: dividerColor,
                      currentLocale: widget.currentLocale,
                      aoaRate: _aoaRate ?? 900,
                      onQuantityChanged: () {
                        cartProvider.notifyListeners();
                      },
                      onRemove: () {
                        cartProvider.removeFromCart(item);
                      },
                    )),
                  ],
                ),
              );
            },
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              top: BorderSide(
                color: dividerColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.get('total', widget.currentLocale),
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AOA ${totalAOA.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CheckoutButton(
                      isDark: widget.isDark,
                      currentLocale: widget.currentLocale,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color dividerColor;
  final String currentLocale;
  final double aoaRate;
  final VoidCallback onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItem({
    required this.item,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.dividerColor,
    required this.currentLocale,
    required this.aoaRate,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<_CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<_CartItem> with SingleTickerProviderStateMixin {
  bool _isSelected = false;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  String _getImageUrl() {
    if (widget.item['thumbnail'] != null) return widget.item['thumbnail'];
    if (widget.item['image'] != null) return widget.item['image'];
    if (widget.item['images'] != null && (widget.item['images'] as List).isNotEmpty) {
      return widget.item['images'][0];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final title = widget.item['title'] ?? 'Produto';
    final priceUSD = (widget.item['price'] ?? 0).toDouble();
    final priceAOA = priceUSD * widget.aoaRate;
    final quantity = widget.item['quantity'] ?? 1;
    final selectedColor = widget.item['selectedColor'];
    final selectedSize = widget.item['selectedSize'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.dividerColor.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _isSelected = !_isSelected);
              if (_isSelected) {
                _checkController.forward();
              } else {
                _checkController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _checkController,
              builder: (context, child) {
                return Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: _isSelected 
                        ? const Color(0xFF007AFF) 
                        : Colors.transparent,
                    border: Border.all(
                      color: _isSelected 
                          ? const Color(0xFF007AFF) 
                          : widget.subtitleColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _isSelected
                      ? Transform.scale(
                          scale: _checkAnimation.value,
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported_rounded,
                          size: 32,
                          color: widget.subtitleColor,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.image_not_supported_rounded,
                    size: 32,
                    color: widget.subtitleColor,
                  ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (selectedColor != null || selectedSize != null)
                    Text(
                      [
                        if (selectedColor != null) selectedColor,
                        if (selectedSize != null) selectedSize,
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.subtitleColor,
                        letterSpacing: 0.1,
                      ),
                    ),

                  Row(
                    children: [
                      Text(
                        'AOA ${priceAOA.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      _QuantityControl(
                        quantity: quantity,
                        isDark: widget.isDark,
                        textColor: widget.textColor,
                        onDecrement: () {
                          if (quantity > 1) {
                            widget.item['quantity'] = quantity - 1;
                            widget.onQuantityChanged();
                          } else {
                            widget.onRemove();
                          }
                        },
                        onIncrement: () {
                          widget.item['quantity'] = quantity + 1;
                          widget.onQuantityChanged();
                        },
                      ),
                    ],
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

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final bool isDark;
  final Color textColor;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.isDark,
    required this.textColor,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3E4042) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            isDark: isDark,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.1,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isDark ? const Color(0xFF4E5052) : const Color(0xFFE0E2E5))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          widget.icon,
          size: 18,
          color: widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
        ),
      ),
    );
  }
}

class _CheckoutButton extends StatefulWidget {
  final bool isDark;
  final String currentLocale;

  const _CheckoutButton({
    required this.isDark,
    required this.currentLocale,
  });

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(_isPressed ? 12 : 24),
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.get('checkout', widget.currentLocale),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}