import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/cart_provider.dart';
import '../utils/app_strings.dart';

class BasketTabScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final cartProvider = CartProvider.of(context);
    final cart = cartProvider?.cart ?? [];
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final dividerColor = isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB);

    if (cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.shopping_basket,
              size: 80,
              color: subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.get('empty_cart', currentLocale),
              style: TextStyle(
                fontSize: 18,
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar produtos por loja/marca
    final Map<String, List<Map<String, dynamic>>> groupedCart = {};
    for (var item in cart) {
      final brand = item['brand'] ?? AppStrings.get('brand', currentLocale);
      if (!groupedCart.containsKey(brand)) {
        groupedCart[brand] = [];
      }
      groupedCart[brand]!.add(item);
    }

    // Calcular total
    double total = 0;
    for (var item in cart) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }

    return Column(
      children: [
        // Header com "All" e "Esvaziar"
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
                  // Esvaziar cesta
                  cartProvider?.cart.clear();
                  if (cartProvider != null) {
                    (cartProvider as ChangeNotifier).notifyListeners();
                  }
                },
                child: Text(
                  AppStrings.get('clear_cart', currentLocale),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF3B30),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de produtos agrupados
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
                    // Header da loja/marca
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.store,
                            size: 18,
                            color: subtitleColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            brand,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navegar para a página da loja
                            },
                            child: Text(
                              AppStrings.get('explore_more', currentLocale),
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

                    // Produtos da loja
                    ...items.map((item) => _CartItem(
                      item: item,
                      isDark: isDark,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      cardColor: cardColor,
                      dividerColor: dividerColor,
                      currentLocale: currentLocale,
                      onQuantityChanged: () {
                        if (cartProvider != null) {
                          (cartProvider as ChangeNotifier).notifyListeners();
                        }
                      },
                      onRemove: () {
                        cartProvider?.removeFromCart(item);
                      },
                    )),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom bar com total e checkout
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              top: BorderSide(
                color: dividerColor.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x40000000) : const Color(0x1A000000),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
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
                          AppStrings.get('total', currentLocale),
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AOA ${total.toStringAsFixed(2)}',
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
                      isDark: isDark,
                      currentLocale: currentLocale,
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
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<_CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<_CartItem> {
  bool _isSelected = false;

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
    final price = (widget.item['price'] ?? 0).toDouble();
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
          // Checkbox
          GestureDetector(
            onTap: () {
              setState(() => _isSelected = !_isSelected);
            },
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: _isSelected ? const Color(0xFF007AFF) : Colors.transparent,
                border: Border.all(
                  color: _isSelected ? const Color(0xFF007AFF) : widget.subtitleColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Imagem do produto
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Symbols.image,
                          size: 32,
                          color: widget.subtitleColor,
                        );
                      },
                    ),
                  )
                : Icon(
                    Symbols.image,
                    size: 32,
                    color: widget.subtitleColor,
                  ),
          ),
          const SizedBox(width: 12),

          // Informações do produto
          Expanded(
            child: SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Cor e tamanho
                  if (selectedColor != null || selectedSize != null)
                    Text(
                      [
                        if (selectedColor != null) selectedColor,
                        if (selectedSize != null) selectedSize,
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.subtitleColor,
                      ),
                    ),

                  // Preço e controles de quantidade
                  Row(
                    children: [
                      Text(
                        'AOA ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
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
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: onDecrement,
            isDark: isDark,
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add,
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
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF4E5052) : const Color(0xFFE0E2E5),
          borderRadius: BorderRadius.circular(_isPressed ? 4 : 6),
        ),
        child: Icon(
          widget.icon,
          size: 16,
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
        // TODO: Implementar checkout
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(_isPressed ? 12 : 24),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          AppStrings.get('checkout', widget.currentLocale),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}