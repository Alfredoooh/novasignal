import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_strings.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with TickerProviderStateMixin {
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  final PageController _pageController = PageController();
  late AnimationController _iconController;
  final translator = GoogleTranslator();

  String? _translatedTitle;
  String? _translatedDescription;
  bool _isTranslating = false;
  double? _priceInAOA;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.product['colors'] != null && (widget.product['colors'] as List).isNotEmpty) {
      _selectedColor = widget.product['colors'][0]['name'];
    }
    if (widget.product['sizes'] != null && (widget.product['sizes'] as List).isNotEmpty) {
      _selectedSize = widget.product['sizes'][0];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateContent();
      _convertPrice();
    });
  }

  Future<void> _convertPrice() async {
    setState(() => _isLoadingPrice = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aoaRate = data['rates']['AOA'] ?? 900.0;
        final priceUSD = (widget.product['price'] ?? 0).toDouble();
        setState(() {
          _priceInAOA = priceUSD * aoaRate;
          _isLoadingPrice = false;
        });
      }
    } catch (e) {
      setState(() {
        _priceInAOA = (widget.product['price'] ?? 0).toDouble() * 900;
        _isLoadingPrice = false;
      });
    }
  }

  Future<void> _translateContent() async {
    final locale = LocaleProvider.of(context);
    final currentLocale = locale?.locale ?? 'pt';

    if (currentLocale != 'pt') {
      setState(() {
        _translatedTitle = widget.product['title'];
        _translatedDescription = widget.product['description'];
      });
      return;
    }

    setState(() => _isTranslating = true);

    try {
      if (widget.product['title'] != null) {
        final titleTranslation = await translator.translate(
          widget.product['title'],
          from: 'en',
          to: 'pt',
        );
        _translatedTitle = titleTranslation.text;
      }

      if (widget.product['description'] != null) {
        final descTranslation = await translator.translate(
          widget.product['description'],
          from: 'en',
          to: 'pt',
        );
        _translatedDescription = descTranslation.text;
      }

      if (mounted) {
        setState(() => _isTranslating = false);
      }
    } catch (e) {
      setState(() {
        _translatedTitle = widget.product['title'];
        _translatedDescription = widget.product['description'];
        _isTranslating = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  List<String> _getImages() {
    final images = <String>[];
    if (widget.product['thumbnail'] != null) {
      images.add(widget.product['thumbnail']);
    }
    if (widget.product['images'] != null) {
      images.addAll(List<String>.from(widget.product['images']));
    }
    if (images.isEmpty && widget.product['image'] != null) {
      images.add(widget.product['image']);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final localeProvider = LocaleProvider.of(context);
    final isDark = themeProvider?.isDark ?? false;
    final currentLocale = localeProvider?.locale ?? 'pt';
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);

    final images = _getImages();
    final colors = widget.product['colors'] as List?;
    final sizes = widget.product['sizes'] as List?;

    final title = _translatedTitle ?? widget.product['title'] ?? AppStrings.get('product_details', currentLocale);
    final description = _translatedDescription ?? widget.product['description'] ?? '';
    final rating = widget.product['rating'] ?? 4.5;
    final brand = widget.product['brand'];
    final category = widget.product['category'];
    final stock = widget.product['stock'] ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF2C3E50),
              child: Row(
                children: [
                  _NavigationButton(
                    svgPath: _backIconSvg,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _NavigationButton(
                    svgPath: _leftArrowSvg,
                    onTap: () {
                      if (_currentImageIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _NavigationButton(
                    svgPath: _rightArrowSvg,
                    onTap: () {
                      if (_currentImageIndex < images.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 350,
                    color: isDark ? const Color(0xFF242526) : const Color(0xFFF0F2F5),
                    child: images.isEmpty
                        ? Center(
                            child: Icon(
                              Symbols.image,
                              size: 80,
                              color: subtitleColor,
                            ),
                          )
                        : Stack(
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() => _currentImageIndex = index);
                                },
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    images[index],
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Symbols.broken_image,
                                          size: 80,
                                          color: subtitleColor,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              if (images.length > 1)
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      images.length,
                                      (index) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == index
                                              ? textColor
                                              : subtitleColor.withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isTranslating
                            ? Shimmer(
                                child: Container(
                                  height: 26,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: subtitleColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                title,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                  height: 1.3,
                                ),
                              ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '$rating',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.product['reviews']?.length ?? 0} avaliações',
                              style: TextStyle(fontSize: 13, color: subtitleColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _isLoadingPrice
                            ? Shimmer(
                                child: Container(
                                  height: 32,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: subtitleColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                'AOA ${_priceInAOA?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                        const SizedBox(height: 24),

                        if (brand != null) ...[
                          _InfoRow('Marca', brand, textColor, subtitleColor),
                          const SizedBox(height: 12),
                        ],
                        if (category != null) ...[
                          _InfoRow('Categoria', category, textColor, subtitleColor),
                          const SizedBox(height: 12),
                        ],
                        _InfoRow('Disponibilidade', stock > 0 ? 'Em estoque ($stock)' : 'Esgotado', textColor, stock > 0 ? Colors.green : Colors.red),
                        const SizedBox(height: 24),

                        Text(
                          'Descrição do Produto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _isTranslating
                            ? Column(
                                children: List.generate(
                                  3,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Shimmer(
                                      child: Container(
                                        height: 16,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: subtitleColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),

                        if (colors != null && colors.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Cor: ${_selectedColor ?? ''}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: colors.map((color) {
                              final colorName = color['name'] as String;
                              final colorHex = color['hex'] as String;
                              final isSelected = _selectedColor == colorName;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedColor = colorName);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _parseColor(colorHex),
                                    border: Border.all(
                                      color: isSelected ? textColor : subtitleColor,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        if (sizes != null && sizes.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Tamanho: ${_selectedSize ?? ''}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: sizes.map((size) {
                              final sizeStr = size as String;
                              final isSelected = _selectedSize == sizeStr;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedSize = sizeStr);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? textColor : Colors.transparent,
                                    border: Border.all(
                                      color: textColor,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    sizeStr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? bgColor : textColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(
        product: widget.product,
        selectedColor: _selectedColor,
        selectedSize: _selectedSize,
        isDark: isDark,
        textColor: textColor,
        bgColor: bgColor,
        iconController: _iconController,
        currentLocale: currentLocale,
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return Colors.grey;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color valueColor;

  const _InfoRow(this.label, this.value, this.textColor, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({Key? key, required this.child}) : super(key: key);

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: widget.child,
        );
      },
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final String svgPath;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.svgPath,
    required this.onTap,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(_isPressed ? 8 : 18),
        ),
        child: Center(
          child: SvgPicture.string(
            widget.svgPath,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddToCartBar extends StatefulWidget {
  final Map<String, dynamic> product;
  final String? selectedColor;
  final String? selectedSize;
  final bool isDark;
  final Color textColor;
  final Color bgColor;
  final AnimationController iconController;
  final String currentLocale;

  const _AddToCartBar({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.isDark,
    required this.textColor,
    required this.bgColor,
    required this.iconController,
    required this.currentLocale,
  });

  @override
  State<_AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<_AddToCartBar> {
  bool _isPressed = false;

  bool _isInCart() {
    final cartProvider = CartProvider.of(context);
    return cartProvider?.cart.any((item) => item['id'] == widget.product['id']) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isInCart = _isInCart();

    return Container(
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              final cartProvider = CartProvider.of(context);

              if (isInCart) {
                cartProvider?.cart.removeWhere((item) => item['id'] == widget.product['id']);
                cartProvider?.removeFromCart(widget.product);
                widget.iconController.reverse();
              } else {
                final productToAdd = Map<String, dynamic>.from(widget.product);
                productToAdd['selectedColor'] = widget.selectedColor;
                productToAdd['selectedSize'] = widget.selectedSize;
                productToAdd['quantity'] = 1;
                cartProvider?.addToCart(productToAdd);
                widget.iconController.forward();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Adicionado ao carrinho'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: widget.isDark ? const Color(0xFF242526) : const Color(0xFF1C1E21),
                  ),
                );
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: isInCart ? const Color(0xFFFF3B30) : const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(_isPressed ? 12 : 26),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimateIcon(
                    onTap: () {},
                    iconType: IconType.continueAnimation,
                    animateIcon: AnimateIcons.add,
                    controller: widget.iconController,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInCart ? 'Remover do Carrinho' : 'Adicionar ao Carrinho',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _backIconSvg = '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.68473 7.33186C8.07526 6.94134 8.07526 6.30817 7.68473 5.91765C7.29421 5.52712 6.66105 5.52712 6.27052 5.91765L1.60492 10.5832C0.823873 11.3643 0.823872 12.6306 1.60492 13.4117L6.27336 18.0801C6.66388 18.4706 7.29705 18.4706 7.68757 18.0801C8.0781 17.6896 8.0781 17.0564 7.68757 16.6659L4.02154 12.9998L22 12.9998C22.5523 12.9998 23 12.5521 23 11.9998C23 11.4476 22.5523 10.9998 22 10.9998L4.01675 10.9998L7.68473 7.33186Z" fill="#0F0F0F"/></svg>''';

const _leftArrowSvg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>''';

const _rightArrowSvg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" id="Layer_1" data-name="Layer 1" viewBox="0 0 24 24">
  <path d="m24,9c0,.956-.372,1.854-1.048,2.53l-5.131,5.174c-.195.197-.453.296-.71.296-.254,0-.509-.097-.704-.29-.392-.389-.395-1.021-.006-1.414l5.134-5.177c.037-.037.065-.079.098-.119H5c-1.654,0-3,1.346-3,3v8c0,.553-.448,1-1,1s-1-.447-1-1v-8c0-2.757,2.243-5,5-5h16.633c-.032-.039-.059-.08-.095-.116l-5.137-5.18c-.389-.392-.386-1.025.006-1.414.393-.388,1.026-.386,1.414.006l5.134,5.177c.673.673,1.045,1.571,1.045,2.527Z"/>
</svg>
''';