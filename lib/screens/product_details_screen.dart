import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'dart:math';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Define cor padrão se houver cores disponíveis
    if (widget.product['colors'] != null && (widget.product['colors'] as List).isNotEmpty) {
      _selectedColor = widget.product['colors'][0]['name'];
    }
    if (widget.product['sizes'] != null && (widget.product['sizes'] as List).isNotEmpty) {
      _selectedSize = widget.product['sizes'][0];
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
    final isDark = themeProvider?.isDark ?? false;
    final bgColor = isDark ? const Color(0xFF18191A) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21);
    final subtitleColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF65676B);
    
    final images = _getImages();
    final colors = widget.product['colors'] as List?;
    final sizes = widget.product['sizes'] as List?;
    final originalPrice = (widget.product['price'] ?? 0) * 1.3;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // AppBar customizado
          SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _NavigationButton(
                    isDark: isDark,
                    svgPath: _backIconSvg,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _NavigationButton(
                    isDark: isDark,
                    svgPath: _previousIconSvg,
                    onTap: () {
                      // Navegar para produto anterior
                    },
                  ),
                  const SizedBox(width: 8),
                  _NavigationButton(
                    isDark: isDark,
                    svgPath: _nextIconSvg,
                    onTap: () {
                      // Navegar para próximo produto
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
                  // Galeria de imagens
                  SizedBox(
                    height: 400,
                    child: Stack(
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
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5),
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 80,
                                    color: isDark ? const Color(0xFF5E6266) : const Color(0xFFB0B3B8),
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
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Item ${_currentImageIndex + 1}/${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                        // Título
                        Text(
                          widget.product['title'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Avaliação
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '4.7',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              ' | 10,000+ sold',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Bundle deals container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Bundle deals',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.card_giftcard,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'AOA${widget.product['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'AOA${originalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'New shopper only',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          'Tax excluded, add at checkout if applicable',
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                          ),
                        ),
                        
                        // Cores
                        if (colors != null && colors.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Band Color: ${_selectedColor ?? ''}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: colors.map((color) {
                              final colorName = color['name'] as String;
                              final colorHex = color['hex'] as String;
                              final isSelected = _selectedColor == colorName;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedColor = colorName);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: _parseColor(colorHex),
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: _parseColor(colorHex),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF5E6266) : const Color(0xFFE4E6EB),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        
                        // Tamanhos
                        if (sizes != null && sizes.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Band Width: ${_selectedSize ?? ''}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: sizes.map((size) {
                              final sizeStr = size as String;
                              final isSelected = _selectedSize == sizeStr;
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _selectedSize = sizeStr);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (isDark ? const Color(0xFF3E4042) : const Color(0xFFF0F2F5))
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.red
                                          : (isDark ? const Color(0xFF5E6266) : const Color(0xFFE4E6EB)),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    sizeStr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? Colors.red : textColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // AliExpress commitment
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242526) : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Choice',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'AliExpress commitment',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Free shipping
                        _InfoRow(
                          icon: Icons.local_shipping_outlined,
                          title: 'Free shipping',
                          subtitle: 'Delivery: Mar. 28',
                          isDark: isDark,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Return policy
                        _InfoRow(
                          icon: Icons.sync_outlined,
                          title: 'Return&refund policy',
                          subtitle: null,
                          isDark: isDark,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        
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

class _NavigationButton extends StatelessWidget {
  final bool isDark;
  final String svgPath;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.isDark,
    required this.svgPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFF0F2F5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.string(
            svgPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              isDark ? const Color(0xFFE4E6EB) : const Color(0xFF1C1E21),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Color textColor;
  final Color subtitleColor;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE4E6EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: isDark ? const Color(0xFF65676B) : const Color(0xFFB0B3B8),
          ),
        ],
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

  const _AddToCartBar({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    required this.isDark,
    required this.textColor,
  });

  @override
  State<_AddToCartBar> createState() => _AddToCartBarState();
}

class _AddToCartBarState extends State<_AddToCartBar> {
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
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              final cartProvider = CartProvider.of(context);
              final productToAdd = Map<String, dynamic>.from(widget.product);
              productToAdd['selectedColor'] = widget.selectedColor;
              productToAdd['selectedSize'] = widget.selectedSize;
              productToAdd['quantity'] = 1;
              cartProvider?.addToCart(productToAdd);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to cart'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(_isPressed ? 6 : 100),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Add to my picks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _backIconSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="m24,13v8c0,.552-.447,1-1,1s-1-.448-1-1v-8c0-1.654-1.346-3-3-3H2.367c.032.039.059.08.095.116l5.137,5.18c.389.392.387,1.025-.006,1.414-.195.193-.449.29-.704.29-.258,0-.515-.099-.71-.296L1.045,11.527c-.673-.673-1.045-1.572-1.045-2.527s.372-1.854,1.048-2.529L6.179,1.296c.39-.393,1.022-.394,1.414-.006.393.389.395,1.022.006,1.414L2.465,7.881c-.037.037-.065.079-.098.119h16.633c2.757,0,5,2.243,5,5Z"/>
</svg>
''';

const _previousIconSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="m24,13v8c0,.552-.447,1-1,1s-1-.448-1-1v-8c0-1.654-1.346-3-3-3H2.367c.032.039.059.08.095.116l5.137,5.18c.389.392.387,1.025-.006,1.414-.195.193-.449.29-.704.29-.258,0-.515-.099-.71-.296L1.045,11.527c-.673-.673-1.045-1.572-1.045-2.527s.372-1.854,1.048-2.529L6.179,1.296c.39-.393,1.022-.394,1.414-.006.393.389.395,1.022.006,1.414L2.465,7.881c-.037.037-.065.079-.098.119h16.633c2.757,0,5,2.243,5,5Z"/>
</svg>
''';

const _nextIconSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="m24,9c0,.956-.372,1.854-1.048,2.53l-5.131,5.174c-.195.197-.453.296-.71.296-.254,0-.509-.097-.704-.29-.392-.389-.395-1.021-.006-1.414l5.134-5.177c.037-.037.065-.079.098-.119H5c-1.654,0-3,1.346-3,3v8c0,.553-.448,1-1,1s-1-.447-1-1v-8c0-2.757,2.243-5,5-5h16.633c-.032-.039-.059-.08-.095-.116l-5.137-5.18c-.389-.392-.386-1.025.006-1.414.393-.388,1.026-.386,1.414.006l5.134,5.177c.673.673,1.045,1.571,1.045,2.527Z"/>
</svg>
''';