import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              icon: SvgPicture.asset(
                'assets/icons/arrow_back.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
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
                icon: SvgPicture.asset(
                  _isFavorite 
                      ? 'assets/icons/heart_filled.svg'
                      : 'assets/icons/heart.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    _isFavorite ? Colors.red : theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
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
                icon: SvgPicture.asset(
                  'assets/icons/share.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
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
                // Hero Image com AspectRatio correto
                SliverToBoxAdapter(
                  child: Hero(
                    tag: 'document_${widget.document.id}',
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                                stops: const [0.7, 1.0],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.darken,
                            child: Image.network(
                              widget.document.coverImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: categoryColor.withOpacity(0.1),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 3,
                                      color: categoryColor,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: categoryColor.withOpacity(0.1),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/icons/document.svg',
                                      width: 64,
                                      height: 64,
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
                                  SvgPicture.asset(
                                    'assets/icons/star.svg',
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
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
                      ],
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.document.name,
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Category Badge
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
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
                                  SvgPicture.asset(
                                    _getCategoryIconPath(widget.document.category),
                                    width: 13,
                                    height: 13,
                                    colorFilter: ColorFilter.mode(
                                      categoryColor,
                                      BlendMode.srcIn,
                                    ),
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
                          ),

                          const SizedBox(height: 32),

                          // Quick Stats - DA API
                          if (widget.document.downloads != null || widget.document.rating != null)
                            Row(
                              children: [
                                if (widget.document.downloads != null)
                                  _StatChip(
                                    iconPath: 'assets/icons/download.svg',
                                    label: '${widget.document.downloads} Downloads',
                                    theme: theme,
                                  ),
                                if (widget.document.downloads != null && widget.document.rating != null)
                                  const SizedBox(width: 12),
                                if (widget.document.rating != null)
                                  _StatChip(
                                    iconPath: 'assets/icons/star.svg',
                                    label: '${widget.document.rating} Rating',
                                    theme: theme,
                                  ),
                              ],
                            ),

                          if (widget.document.downloads != null || widget.document.rating != null)
                            const SizedBox(height: 32),

                          // Description - DA API
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

                          // Features - DA API
                          if (widget.document.features != null && widget.document.features!.isNotEmpty) ...[
                            _SectionHeader(title: 'Features', theme: theme),
                            const SizedBox(height: 16),
                            ...widget.document.features!.asMap().entries.map((entry) {
                              final feature = entry.value;
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (entry.key * 100)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _FeatureItem(
                                  iconPath: feature['icon'] ?? 'assets/icons/document.svg',
                                  title: feature['title'] ?? '',
                                  description: feature['description'] ?? '',
                                  theme: theme,
                                  categoryColor: categoryColor,
                                ),
                              );
                            }).toList(),
                          ],

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/play.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
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
}

// Section Header Widget
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

// Stat Chip Widget
class _StatChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final ThemeData theme;

  const _StatChip({
    required this.iconPath,
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
          SvgPicture.asset(
            iconPath,
            width: 13,
            height: 13,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
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

// Share Option Widget
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
      leading: SvgPicture.asset(
        iconPath,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
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

// Enhanced Feature Item Widget
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                child: SvgPicture.asset(
                  iconPath,
                  width: 19,
                  height: 19,
                  colorFilter: ColorFilter.mode(
                    categoryColor,
                    BlendMode.srcIn,
                  ),
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