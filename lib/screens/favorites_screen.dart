import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import 'document_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<DocumentModel> favoriteDocuments;
  final ThemeProvider themeProvider;
  final Function(DocumentModel)? onFavoriteToggle;

  const FavoritesScreen({
    Key? key,
    required this.favoriteDocuments,
    required this.themeProvider,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return const Color(0xFF3B82F6);
      case 'academic':
        return const Color(0xFF8B5CF6);
      case 'personal':
        return const Color(0xFF10B981);
      case 'legal':
        return const Color(0xFFF59E0B);
      case 'creative':
        return const Color(0xFFEC4899);
      case 'finance':
        return const Color(0xFF14B8A6);
      case 'health':
        return const Color(0xFFEF4444);
      case 'education':
        return const Color(0xFF06B6D4);
      case 'technology':
        return const Color(0xFF8B5CF6);
      case 'marketing':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
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
      case 'finance':
        return 'assets/icons/finance.svg';
      case 'health':
        return 'assets/icons/health.svg';
      case 'education':
        return 'assets/icons/education.svg';
      case 'technology':
        return 'assets/icons/technology.svg';
      case 'marketing':
        return 'assets/icons/marketing.svg';
      default:
        return 'assets/icons/document.svg';
    }
  }

  List<String> _getCategories() {
    final categories = widget.favoriteDocuments
        .map((doc) => doc.category)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<DocumentModel> _getFilteredDocuments() {
    if (_selectedCategory == 'All') {
      return widget.favoriteDocuments;
    }
    return widget.favoriteDocuments
        .where((doc) => doc.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredDocs = _getFilteredDocuments();
    final categories = _getCategories();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/arrow_back.svg',
            width: 19.2,
            height: 19.2,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/heart_filled.svg',
              width: 19.2,
              height: 19.2,
              colorFilter: ColorFilter.mode(
                Colors.red,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: widget.favoriteDocuments.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                if (categories.length > 1) _buildCategoryFilter(theme, categories),
                Expanded(
                  child: FadeTransition(
                    opacity: _animationController,
                    child: filteredDocs.isEmpty
                        ? _buildEmptyCategoryState(theme)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              return _buildFavoriteCard(
                                context,
                                filteredDocs[index],
                                theme,
                                index,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme, List<String> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          final color = category == 'All' 
              ? theme.colorScheme.primary 
              : _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category != 'All')
                    SvgPicture.asset(
                      _getCategoryIconPath(category),
                      width: 12.8,
                      height: 12.8,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white : color,
                        BlendMode.srcIn,
                      ),
                    ),
                  if (category != 'All') const SizedBox(width: 6),
                  Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              backgroundColor: color.withOpacity(0.1),
              selectedColor: color,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? color : color.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    DocumentModel document,
    ThemeData theme,
    int index,
  ) {
    final categoryColor = _getCategoryColor(document.category);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentDetailScreen(
                  document: document,
                  themeProvider: widget.themeProvider,
                  onFavoriteToggle: (doc) {
                    setState(() {
                      widget.onFavoriteToggle?.call(doc);
                    });
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Imagem
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'favorite_${document.id}',
                    child: Image.network(
                      document.coverImage,
                      width: 100,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 120,
                          color: categoryColor.withOpacity(0.1),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/document.svg',
                              width: 32,
                              height: 32,
                              colorFilter: ColorFilter.mode(
                                categoryColor.withOpacity(0.5),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Conteúdo
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                document.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/heart_filled.svg',
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                  Colors.red,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  document.isFavorite = false;
                                  widget.onFavoriteToggle?.call(document);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                _getCategoryIconPath(document.category),
                                width: 9.6,
                                height: 9.6,
                                colorFilter: ColorFilter.mode(
                                  categoryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                document.category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (document.isPro) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.orange.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/star.svg',
                                      width: 9.6,
                                      height: 9.6,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/heart.svg',
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum favorito ainda',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione documentos aos favoritos\npara vê-los aqui',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/filter.svg',
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary.withOpacity(0.5),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum documento nesta categoria',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}