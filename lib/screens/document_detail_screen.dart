import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui' as ui;
import 'package:palette_generator/palette_generator.dart';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import '../screens/document_viewer_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;
  final ThemeProvider themeProvider;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
    required this.themeProvider,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheetController;
  late Animation<double> _sheetAnimation;
  Color _dominantColor = Colors.blue;
  bool _isLoadingColor = true;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sheetAnimation = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );
    _extractColors();
  }

  Future<void> _extractColors() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.document.coverImage),
        maximumColorCount: 20,
      );

      setState(() {
        _dominantColor = paletteGenerator.dominantColor?.color ??
            paletteGenerator.lightVibrantColor?.color ??
            _getCategoryColor(widget.document.category);
        _isLoadingColor = false;
      });
    } catch (e) {
      setState(() {
        _dominantColor = _getCategoryColor(widget.document.category);
        _isLoadingColor = false;
      });
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Colors.blue;
      case 'academic':
        return Colors.purple;
      case 'personal':
        return Colors.green;
      case 'legal':
        return Colors.orange;
      case 'creative':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryIconPath(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return 'assets/icons/business.svg';
      case 'academic':
        return 'assets/icons/academic.svg';
      case 'personal':
        return 'assets/icons/personal.svg';
      case 'legal':
        return 'assets/icons/legal.svg';
      case 'creative':
        return 'assets/icons/creative.svg';
      default:
        return 'assets/icons/document.svg';
    }
  }

  String _getDocumentDescription(String name) {
    switch (name) {
      case 'Business Proposal':
        return 'Professional template for creating compelling business proposals with executive summaries, problem statements, and budget planning sections.';
      case 'Research Paper':
        return 'Academic template following standard research paper format with abstract, methodology, results, and references sections.';
      case 'Resume/CV':
        return 'Clean and professional resume template to showcase your experience, education, and skills effectively.';
      case 'Contract Agreement':
        return 'Legal template for formal agreements with clear clauses, terms and conditions, and signature sections.';
      case 'Blog Post':
        return 'Modern blog post template with engaging layout, perfect for creative writing and content creation.';
      case 'Meeting Minutes':
        return 'Structured template for recording meeting discussions, decisions, and action items in an organized format.';
      default:
        return 'Professional document template ready to use.';
    }
  }

  void _toggleSheet() {
    if (_sheetController.isCompleted) {
      _sheetController.reverse();
    } else {
      _sheetController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final lightColor = _dominantColor.withOpacity(0.08);
    final mediumColor = _dominantColor.withOpacity(0.12);

    return Scaffold(
      backgroundColor: lightColor,
      body: Stack(
        children: [
          // Imagem de capa em tamanho original
          Positioned.fill(
            child: Image.network(
              widget.document.coverImage,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: mediumColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 3,
                      color: _dominantColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: mediumColor,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/document.svg',
                      width: 80,
                      height: 80,
                      colorFilter: ColorFilter.mode(
                        _dominantColor.withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Overlay escuro
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Botão voltar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/arrow_back.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    _dominantColor,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Badge PRO
          if (widget.document.isPro)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Painel deslizante de detalhes
          GestureDetector(
            onTap: _toggleSheet,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -5) {
                _sheetController.forward();
              } else if (details.primaryDelta! > 5) {
                _sheetController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: _sheetAnimation,
              builder: (context, child) {
                final minHeight = screenHeight * 0.35;
                final maxHeight = screenHeight * 0.85;
                final currentHeight =
                    minHeight + (maxHeight - minHeight) * _sheetAnimation.value;

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: currentHeight,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Handlebar
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Conteúdo scrollável
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  widget.document.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Categoria
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _dominantColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        _getCategoryIconPath(
                                            widget.document.category),
                                        width: 14,
                                        height: 14,
                                        colorFilter: ColorFilter.mode(
                                          _dominantColor,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.document.category,
                                        style: TextStyle(
                                          color: _dominantColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Descrição
                                Text(
                                  'About this template',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _getDocumentDescription(widget.document.name),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                    color: theme.textTheme.bodySmall?.color,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Features
                                Text(
                                  'Key Features',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _FeatureItem(
                                  iconPath: 'assets/icons/edit.svg',
                                  title: 'Ready to Use',
                                  description: 'Pre-formatted and customizable',
                                  theme: theme,
                                  accentColor: _dominantColor,
                                ),
                                _FeatureItem(
                                  iconPath: 'assets/icons/palette.svg',
                                  title: 'Professional Design',
                                  description: 'Clean and modern layout',
                                  theme: theme,
                                  accentColor: _dominantColor,
                                ),
                                _FeatureItem(
                                  iconPath: 'assets/icons/responsive.svg',
                                  title: 'Fully Responsive',
                                  description: 'Works perfectly on all devices',
                                  theme: theme,
                                  accentColor: _dominantColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Barra de botões inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Botão Preview
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DocumentViewerScreen(
                                  document: widget.document,
                                  themeProvider: widget.themeProvider,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _dominantColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: _dominantColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/play.svg',
                                width: 18,
                                height: 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Preview',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botão Edit Template
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            // Ação de editar template
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _dominantColor,
                            side: BorderSide(
                              color: _dominantColor.withOpacity(0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  _dominantColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Edit Template',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final ThemeData theme;
  final Color accentColor;

  const _FeatureItem({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.theme,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(
                  accentColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}