import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animated_check/animated_check.dart';
import '../providers/cart_provider.dart';
import '../utils/app_strings.dart';
import 'dart:math';

const Color primaryColor = Color(0xFF2C3E50);

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
  final Set<String> selectedItems = {};
  bool selectAll = false;

  void _toggleSelectAll(List<Map<String, dynamic>> cart) {
    setState(() {
      if (selectAll) {
        selectedItems.clear();
        selectAll = false;
      } else {
        selectedItems.clear();
        for (var item in cart) {
          selectedItems.add('${item['id']}');
        }
        selectAll = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = CartProvider.of(context);
    final cart = cartProvider?.cart ?? [];
    final textColor = widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.get('empty_cart', widget.currentLocale),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione produtos ao carrinho',
              style: TextStyle(
                fontSize: 15,
                color: widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B),
              ),
            ),
          ],
        ),
      );
    }

    final groupedByStore = <String, List<Map<String, dynamic>>>{};
    for (var item in cart) {
      final store = item['brand'] ?? 'Loja Desconhecida';
      groupedByStore.putIfAbsent(store, () => []).add(item);
    }

    double totalPrice = 0;
    int selectedCount = 0;
    for (var item in cart) {
      final itemId = '${item['id']}';
      if (selectedItems.contains(itemId)) {
        totalPrice += (item['price'] ?? 0) * (item['quantity'] ?? 1);
        selectedCount++;
      }
    }

    return Column(
      children: [
        // Select All checkbox
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _AnimatedCheckbox(
                isSelected: selectAll,
                isDark: widget.isDark,
                onTap: () => _toggleSelectAll(cart),
              ),
              const SizedBox(width: 12),
              Text(
                'All',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: groupedByStore.length,
            itemBuilder: (context, index) {
              final store = groupedByStore.keys.elementAt(index);
              final items = groupedByStore[store]!;
              return _StoreSection(
                storeName: store,
                items: items,
                isDark: widget.isDark,
                textColor: textColor,
                selectedItems: selectedItems,
                onItemToggle: (itemId) {
                  setState(() {
                    if (selectedItems.contains(itemId)) {
                      selectedItems.remove(itemId);
                      selectAll = false;
                    } else {
                      selectedItems.add(itemId);
                      if (selectedItems.length == cart.length) {
                        selectAll = true;
                      }
                    }
                  });
                },
                onRemove: (item) => cartProvider?.removeFromCart(item),
              );
            },
          ),
        ),
        _CheckoutBar(
          totalPrice: totalPrice,
          isDark: widget.isDark,
          textColor: textColor,
          currentLocale: widget.currentLocale,
          itemCount: selectedCount,
        ),
      ],
    );
  }
}

class _StoreSection extends StatelessWidget {
  final String storeName;
  final List<Map<String, dynamic>> items;
  final bool isDark;
  final Color textColor;
  final Set<String> selectedItems;
  final Function(String) onItemToggle;
  final Function(Map<String, dynamic>) onRemove;

  const _StoreSection({
    required this.storeName,
    required this.items,
    required this.isDark,
    required this.textColor,
    required this.selectedItems,
    required this.onItemToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
                width: 1,
              ),
            ),
          ),
          child: Text(
            storeName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        ...items.map((item) => _CartItemCard(
              product: item,
              isDark: isDark,
              textColor: textColor,
              isSelected: selectedItems.contains('${item['id']}'),
              onToggle: () => onItemToggle('${item['id']}'),
              onRemove: () => onRemove(item),
            )),
      ],
    );
  }
}

class _CartItemCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.product,
    required this.isDark,
    required this.textColor,
    required this.isSelected,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard> {
  @override
  Widget build(BuildContext context) {
    final subtitleColor = widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final stock = widget.product['stock'] ?? 100;
    final hasLowStock = stock <= 5 && stock > 0;
    final originalPrice = (widget.product['price'] ?? 0) * 1.3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(
            color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedCheckbox(
            isSelected: widget.isSelected,
            isDark: widget.isDark,
            onTap: widget.onToggle,
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product['thumbnail'] ?? widget.product['image'] ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: widget.isDark ? const Color(0xFF5E6266) : const Color(0xFFB0B3B8),
                        ),
                      );
                    },
                  ),
                ),
                if (hasLowStock)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        stock == 1 ? 'Only 1 left' : 'Only $stock left',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product['title'],
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (widget.product['selectedColor'] != null || widget.product['selectedSize'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      [
                        if (widget.product['selectedColor'] != null) widget.product['selectedColor'],
                        if (widget.product['selectedSize'] != null) widget.product['selectedSize'],
                      ].join(' / '),
                      style: TextStyle(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'AOA${widget.product['price'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AOA${originalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New shoppers save AOA${(originalPrice - widget.product['price']).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Free shipping',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    _QuantitySelector(
                      quantity: widget.product['quantity'] ?? 1,
                      isDark: widget.isDark,
                      product: widget.product,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheckbox extends StatefulWidget {
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedCheckbox({
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<_AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.red : Colors.transparent,
          border: Border.all(
            color: widget.isSelected
                ? Colors.red
                : (widget.isDark ? const Color(0xFF5E6266) : const Color(0xFFB0B3B8)),
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: widget.isSelected
            ? AnimatedCheck(
                progress: _controller,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final bool isDark;
  final Map<String, dynamic> product;

  const _QuantitySelector({
    required this.quantity,
    required this.isDark,
    required this.product,
  });

  void _updateQuantity(BuildContext context, int delta) {
    final newQuantity = quantity + delta;
    final stock = product['stock'] ?? 100;

    if (newQuantity >= 1 && newQuantity <= stock) {
      final cartProvider = CartProvider.of(context);
      product['quantity'] = newQuantity;
      cartProvider?.removeFromCart(product);
      cartProvider?.addToCart(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = product['stock'] ?? 100;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? const Color(0xFF5E6266) : const Color(0xFFE4E6EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove,
            isDark: isDark,
            onPressed: () => _updateQuantity(context, -1),
            enabled: quantity > 1,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
            isDark: isDark,
            onPressed: () => _updateQuantity(context, 1),
            enabled: quantity < stock,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;
  final bool enabled;

  const _QuantityButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.enabled
              ? (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5))
              : (widget.isDark ? const Color(0xFF2A2B2C) : const Color(0xFFE4E6EB)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: 18,
          color: widget.enabled 
              ? (widget.isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21))
              : (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFCCD0D5)),
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatefulWidget {
  final double totalPrice;
  final bool isDark;
  final Color textColor;
  final String currentLocale;
  final int itemCount;

  const _CheckoutBar({
    required this.totalPrice,
    required this.isDark,
    required this.textColor,
    required this.currentLocale,
    required this.itemCount,
  });

  @override
  State<_CheckoutBar> createState() => _CheckoutBarState();
}

class _CheckoutBarState extends State<_CheckoutBar> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isDark ? const Color(0x40000000) : const Color(0x10000000),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B),
                    ),
                  ),
                  Text(
                    'AOA${widget.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.textColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  if (widget.itemCount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.get('checkout', widget.currentLocale)),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.itemCount > 0
                        ? Colors.red
                        : (widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB)),
                    borderRadius: BorderRadius.circular(_isPressed ? 6 : 20),
                  ),
                  child: Text(
                    'Checkout (${widget.itemCount})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: widget.itemCount > 0
                          ? Colors.white
                          : (widget.isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}