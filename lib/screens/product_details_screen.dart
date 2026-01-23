import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/app_strings.dart';
import '../assets/app_icons.dart';

const Color primaryColor = Color(0xFF2C3E50);

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedColor;
  String? selectedSize;
  int quantity = 1;
  final List<String> availableColors = ['Vermelho', 'Azul', 'Verde', 'Preto', 'Branco'];
  final List<String> availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final translator = GoogleTranslator();

  String? _translatedTitle;
  String? _translatedDescription;
  bool _isTranslating = false;
  double? _priceInAOA;
  bool _isLoadingPrice = false;

  @override
  void initState() {
    super.initState();
    selectedColor = availableColors.first;
    selectedSize = availableSizes[1];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _translateContent();
      _convertPrice();
    });
  }

  Future<void> _convertPrice() async {
    if (!mounted) return;
    setState(() => _isLoadingPrice = true);
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aoaRate = data['rates']['AOA'] ?? 900.0;
        final priceUSD = (widget.product['price'] ?? 0).toDouble();
        if (mounted) {
          setState(() {
            _priceInAOA = priceUSD * aoaRate;
            _isLoadingPrice = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _priceInAOA = (widget.product['price'] ?? 0).toDouble() * 900;
          _isLoadingPrice = false;
        });
      }
    }
  }

  Future<void> _translateContent() async {
    if (!mounted) return;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale;

    if (currentLocale != 'pt') {
      if (mounted) {
        setState(() {
          _translatedTitle = widget.product['title'];
          _translatedDescription = widget.product['description'];
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isTranslating = true);
    }

    try {
      if (widget.product['title'] != null) {
        final titleTranslation = await translator.translate(
          widget.product['title'],
          from: 'en',
          to: 'pt',
        );
        if (mounted) {
          _translatedTitle = titleTranslation.text;
        }
      }

      if (widget.product['description'] != null) {
        final descTranslation = await translator.translate(
          widget.product['description'],
          from: 'en',
          to: 'pt',
        );
        if (mounted) {
          _translatedDescription = descTranslation.text;
        }
      }

      if (mounted) {
        setState(() => _isTranslating = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedTitle = widget.product['title'];
          _translatedDescription = widget.product['description'];
          _isTranslating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getImages() {
    final images = <String>[];
    if (widget.product['thumbnail'] != null) {
      images.add(widget.product['thumbnail']);
    }
    if (widget.product['images'] != null && widget.product['images'] is List) {
      for (var img in widget.product['images']) {
        if (img is String && img.isNotEmpty && img != widget.product['thumbnail']) {
          images.add(img);
        }
      }
    }
    if (images.isEmpty && widget.product['image'] != null) {
      images.add(widget.product['image']);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final isDark = themeProvider.isDark;
    final currentLocale = localeProvider.locale;
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFF0F0F0);
    final cardColor = isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF2C3E50);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);
    final isInCart = cartProvider.cart.any((item) => item['id'] == widget.product['id']);

    final images = _getImages();
    final title = _translatedTitle ?? widget.product['title'] ?? AppStrings.get('product_details', currentLocale);
    final description = _translatedDescription ?? widget.product['description'] ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: primaryColor,
              child: Row(
                children: [
                  _NavigationButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (images.length > 1) ...[
                    _NavigationButton(
                      icon: Icons.chevron_left,
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
                      icon: Icons.chevron_right,
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
                    color: Colors.white,
                    child: images.isEmpty
                        ? Center(
                            child: Icon(Symbols.image, size: 80, color: subtitleColor),
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
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(Symbols.broken_image, size: 80, color: subtitleColor),
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
                  Container(
                    color: cardColor,
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
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                              ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product['rating'] ?? 4.5}',
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.product['reviews']?.length ?? 0} ${AppStrings.get('reviews', currentLocale)})',
                              style: TextStyle(fontSize: 14, color: subtitleColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                                style: const TextStyle(fontSize: 28, color: primaryColor, fontWeight: FontWeight.bold),
                              ),
                        const SizedBox(height: 16),
                        if (widget.product['brand'] != null) ...[
                          Row(
                            children: [
                              Text(
                                '${AppStrings.get('brand', currentLocale)}: ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Text(
                                widget.product['brand'],
                                style: TextStyle(fontSize: 16, color: subtitleColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (widget.product['category'] != null) ...[
                          Row(
                            children: [
                              Text(
                                '${AppStrings.get('category', currentLocale)}: ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              ),
                              Text(
                                widget.product['category'],
                                style: TextStyle(fontSize: 16, color: subtitleColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            Text(
                              '${AppStrings.get('availability', currentLocale)}: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (widget.product['stock'] ?? 0) > 0
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (widget.product['stock'] ?? 0) > 0
                                    ? AppStrings.get('in_stock', currentLocale)
                                    : AppStrings.get('out_of_stock', currentLocale),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: (widget.product['stock'] ?? 0) > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.get('description', currentLocale),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 8),
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
                                style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.5),
                              ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('select_color', currentLocale),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: availableColors.map((color) {
                            final isSelected = selectedColor == color;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(Icons.check_circle, color: Colors.white, size: 16),
                                      ),
                                    Text(
                                      color,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : textColor,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('select_size', currentLocale),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: availableSizes.map((size) {
                            final isSelected = selectedSize == size;
                            return GestureDetector(
                              onTap: () => setState(() => selectedSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0)),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.get('quantity', currentLocale),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (quantity > 1) setState(() => quantity--);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.remove, color: textColor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              quantity.toString(),
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                if (quantity < (widget.product['stock'] ?? 99)) {
                                  setState(() => quantity++);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (widget.product['stock'] ?? 0) > 0
                                    ? () {
                                        if (isInCart) {
                                          cartProvider.removeFromCart(widget.product);
                                        } else {
                                          final productWithDetails =
                                              Map<String, dynamic>.from(widget.product);
                                          productWithDetails['selectedColor'] = selectedColor;
                                          productWithDetails['selectedSize'] = selectedSize;
                                          productWithDetails['quantity'] = quantity;
                                          cartProvider.addToCart(productWithDetails);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppStrings.get('add_to_cart', currentLocale)),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart ? Colors.red : primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  isInCart
                                      ? AppStrings.get('remove_from_cart', currentLocale)
                                      : AppStrings.get('add_to_cart', currentLocale),
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
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

class _NavigationButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationButton({required this.icon, required this.onTap});

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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(_isPressed ? 8 : 20),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 22),
      ),
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