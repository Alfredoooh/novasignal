import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import '../screens/document_viewer_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;
  final ThemeProvider themeProvider;
  final bool isSecondaryScreen;
  final VoidCallback? onClose;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
    required this.themeProvider,
    this.isSecondaryScreen = false,
    this.onClose,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> 
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showTitle = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final showTitle = offset > 200;

    if (_showTitle != showTitle) {
      setState(() => _showTitle = showTitle);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      default:
        return 'assets/icons/document.svg';
    }
  }

  void _showFullImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullScreenImage(
          imageUrl: widget.document.coverImage,
          heroTag: 'document_${widget.document.id}',
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Share Template',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _ShareOption(
              iconPath: 'assets/icons/link.svg',
              label: 'Copy Link',
              theme: Theme.of(context),
            ),
            _ShareOption(
              iconPath: 'assets/icons/email.svg',
              label: 'Email',
              theme: Theme.of(context),
            ),
            _ShareOption(
              iconPath: 'assets/icons/share.svg',
              label: 'More Options',
              theme: Theme.of(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool _isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isSecondaryScreen) {
      return _buildSecondaryScreenLayout(theme);
    }

    return _buildMobileLayout(theme);
  }

  Widget _buildSecondaryScreenLayout(ThemeData theme) {
    final categoryColor = _getCategoryColor(widget.document.category);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header fixo
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.document.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : theme.colorScheme.secondary,
                  ),
                  onPressed: () => setState(() => _isFavorite = !_isFavorite),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: theme.colorScheme.secondary),
                  onPressed: _showShareOptions,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.secondary),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          
          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Imagem com blur
                  GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: _buildImageWithBlur(categoryColor),
                  ),
                  _buildContent(theme, categoryColor),
                ],
              ),
            ),
          ),
          
          // Botão fixo no bottom
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
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
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Use Template',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildMobileLayout(ThemeData theme) {
    final categoryColor = _getCategoryColor(widget.document.category);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showTitle 
            ? theme.appBarTheme.backgroundColor 
            : Colors.transparent,
        elevation: _showTitle ? 2 : 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: _showTitle 
                  ? Colors.transparent 
                  : theme.cardColor.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: _showTitle ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.document.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: _showTitle 
                    ? Colors.transparent 
                    : theme.cardColor.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: _showTitle ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : theme.colorScheme.primary,
                ),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: _showTitle 
                    ? Colors.transparent 
                    : theme.cardColor.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: _showTitle ? [] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: _showShareOptions,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Hero Image com blur background
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: Hero(
                      tag: 'document_${widget.document.id}',
                      child: _buildImageWithBlur(categoryColor),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -20, 0),
                    child: _buildContent(theme, categoryColor),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withOpacity(0.0),
                    theme.scaffoldBackgroundColor.withOpacity(0.8),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SafeArea(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
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
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Use Template',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithBlur(Color categoryColor) {
    return Container(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background blurred
          Image.network(
            widget.document.coverImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: categoryColor.withOpacity(0.1));
            },
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          
          // Imagem original centralizada
          Center(
            child: Image.network(
              widget.document.coverImage,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 3,
                    color: categoryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image,
                  size: 64,
                  color: categoryColor.withOpacity(0.5),
                );
              },
            ),
          ),
          
          // PRO Badge
          if (widget.document.isPro)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade400,
                      Colors.orange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                    const Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Indicador de zoom
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Tap to view',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildContent(ThemeData theme, Color categoryColor) {
    final isWide = _isWideScreen(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.document.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: categoryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category,
                  size: 13,
                  color: categoryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.document.category,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick Stats
          if (widget.document.downloads != null || widget.document.rating != null)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.document.downloads != null)
                  _StatChip(
                    icon: Icons.download,
                    label: '${widget.document.downloads} Downloads',
                    theme: theme,
                  ),
                if (widget.document.rating != null)
                  _StatChip(
                    icon: Icons.star,
                    label: '${widget.document.rating} Rating',
                    theme: theme,
                  ),
              ],
            ),

          if (widget.document.downloads != null || widget.document.rating != null)
            const SizedBox(height: 32),

          // Description
          if (widget.document.description != null && widget.document.description!.isNotEmpty) ...[
            _SectionHeader(title: 'Description', theme: theme),
            const SizedBox(height: 12),
            Text(
              widget.document.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Features - Grid em telas largas
          if (widget.document.features != null && widget.document.features!.isNotEmpty) ...[
            _SectionHeader(title: 'Features', theme: theme),
            const SizedBox(height: 16),
            
            if (isWide)
              // Grid 2x2
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: widget.document.features!.length,
                itemBuilder: (context, index) {
                  final feature = widget.document.features![index];
                  return _FeatureItemCompact(
                    iconPath: feature['icon'] ?? 'assets/icons/document.svg',
                    title: feature['title'] ?? '',
                    description: feature['description'] ?? '',
                    theme: theme,
                    categoryColor: categoryColor,
                  );
                },
              )
            else
              // Lista vertical
              ...widget.document.features!.map((feature) {
                return _FeatureItem(
                  iconPath: feature['icon'] ?? 'assets/icons/document.svg',
                  title: feature['title'] ?? '',
                  description: feature['description'] ?? '',
                  theme: theme,
                  categoryColor: categoryColor,
                );
              }).toList(),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Tela cheia da imagem
class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImage({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Stat Chip
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Share Option
class _ShareOption extends StatelessWidget {
  final String iconPath;
  final String label;
  final ThemeData theme;

  const _ShareOption({
    required this.iconPath,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.share, color: theme.colorScheme.primary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label selected'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

// Feature Item (lista vertical)
class _FeatureItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final ThemeData theme;
  final Color categoryColor;

  const _FeatureItem({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.theme,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle,
                  size: 24,
                  color: categoryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
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

// Feature Item Compact (grid)
class _FeatureItemCompact extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final ThemeData theme;
  final Color categoryColor;

  const _FeatureItemCompact({
    required this.iconPath,
    required this.title,
    required this.description,
    required this.theme,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle,
                size: 20,
                color: categoryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}