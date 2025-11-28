import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/document_model.dart';

// ==================== STAT CARD ====================
class FavoritesStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;
  final ThemeData theme;

  const FavoritesStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/$icon.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== CATEGORY CHIP ====================
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.secondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ==================== GRID VIEW ====================
class FavoritesGridView extends StatelessWidget {
  final List<DocumentModel> documents;
  final ThemeData theme;
  final Function(DocumentModel) onTap;
  final Function(DocumentModel) onFavoriteToggle;

  const FavoritesGridView({
    Key? key,
    required this.documents,
    required this.theme,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return FavoritesGridCard(
          document: documents[index],
          theme: theme,
          index: index,
          onTap: () => onTap(documents[index]),
          onFavoriteToggle: () => onFavoriteToggle(documents[index]),
        );
      },
    );
  }
}

// ==================== GRID CARD ====================
class FavoritesGridCard extends StatelessWidget {
  final DocumentModel document;
  final ThemeData theme;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const FavoritesGridCard({
    Key? key,
    required this.document,
    required this.theme,
    required this.index,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: document.coverImage.endsWith('.svg')
                        ? SvgPicture.asset(
                            document.coverImage,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            document.coverImage,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 160,
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.description,
                                  size: 48,
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
                  ),
                  if (document.isPro)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/star.png',
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          document.isFavorite
                              ? 'assets/icons/heart_filled.png'
                              : 'assets/icons/heart.png',
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/category.png',
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            document.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LIST VIEW ====================
class FavoritesListView extends StatelessWidget {
  final List<DocumentModel> documents;
  final ThemeData theme;
  final Function(DocumentModel) onTap;
  final Function(DocumentModel) onFavoriteToggle;

  const FavoritesListView({
    Key? key,
    required this.documents,
    required this.theme,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return FavoritesListCard(
          document: documents[index],
          theme: theme,
          index: index,
          onTap: () => onTap(documents[index]),
          onFavoriteToggle: () => onFavoriteToggle(documents[index]),
        );
      },
    );
  }
}

// ==================== LIST CARD ====================
class FavoritesListCard extends StatelessWidget {
  final DocumentModel document;
  final ThemeData theme;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const FavoritesListCard({
    Key? key,
    required this.document,
    required this.theme,
    required this.index,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    child: document.coverImage.endsWith('.svg')
                        ? SvgPicture.asset(
                            document.coverImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            document.coverImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.description,
                                  size: 32,
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                ),
                              );
                            },
                          ),
                  ),
                  if (document.isPro)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/star.png',
                              width: 10,
                              height: 10,
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        document.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/category.png',
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              document.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: document.isFavorite
                          ? Colors.red.withOpacity(0.1)
                          : theme.dividerColor,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      document.isFavorite
                          ? 'assets/icons/heart_filled.png'
                          : 'assets/icons/heart.png',
                      width: 20,
                      height: 20,
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

// ==================== EMPTY STATE ====================
class FavoritesEmptyState extends StatelessWidget {
  final ThemeData theme;

  const FavoritesEmptyState({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/heart.png',
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding documents to your favorites by tapping the heart icon on any document.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(
                'assets/icons/search.png',
                width: 20,
                height: 20,
              ),
              label: const Text('Browse Documents'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EMPTY CATEGORY STATE ====================
class FavoritesEmptyCategoryState extends StatelessWidget {
  final ThemeData theme;
  final String selectedCategory;
  final VoidCallback onClearFilters;

  const FavoritesEmptyCategoryState({
    Key? key,
    required this.theme,
    required this.selectedCategory,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/search.png',
                width: 64,
                height: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No favorites found in $selectedCategory',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onClearFilters,
              icon: Image.asset(
                'assets/icons/refresh.png',
                width: 20,
                height: 20,
              ),
              label: const Text('Clear Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}