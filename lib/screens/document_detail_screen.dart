import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import '../screens/document_viewer_screen.dart';
import 'package:palette_generator/palette_generator.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentModel document;
  final ThemeProvider themeProvider;
  final bool isSecondaryScreen;
  final VoidCallback? onClose;
  final Function(DocumentModel)? onFavoriteToggle;

  const DocumentDetailScreen({
    Key? key,
    required this.document,
    required this.themeProvider,
    this.isSecondaryScreen = false,
    this.onClose,
    this.onFavoriteToggle,
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
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Color? _dominantColor;

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
    _extractDominantColor();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  Future<void> _extractDominantColor() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.document.coverImage),
        size: const Size(200, 200),
        maximumColorCount: 20,
      );

      if (mounted) {
        setState(() {
          _dominantColor = paletteGenerator.dominantColor?.color
              ?.withOpacity(0.7) ?? _getCategoryColor(widget.document.category);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dominantColor = _getCategoryColor(widget.document.category);
        });
      }
    }
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
      case 'sports':
        return const Color(0xFF22C55E);
      case 'travel':
        return const Color(0xFF3B82F6);
      case 'food':
        return const Color(0xFFF59E0B);
      case 'real estate':
        return const Color(0xFF06B6D4);
      case 'automotive':
        return const Color(0xFF6366F1);
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
      case 'sports':
        return 'assets/icons/sports.svg';
      case 'travel':
        return 'assets/icons/travel.svg';
      case 'food':
        return 'assets/icons/food.svg';
      case 'real estate':
        return 'assets/icons/real_estate.svg';
      case 'automotive':
        return 'assets/icons/automotive.svg';
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

  Future<void> _downloadPDF() async {
    if (widget.document.pdfUrl == null || widget.document.pdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/alert.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              const Text('PDF não disponível'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${widget.document.name}.pdf';

      await dio.download(
        widget.document.pdfUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() => _isDownloading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/check.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Download concluído!')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Abrir',
              textColor: Colors.white,
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isDownloading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/alert.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao baixar: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _toggleFavorite() {
    setState(() {
      widget.document.isFavorite = !widget.document.isFavorite;
    });
    
    widget.onFavoriteToggle?.call(widget.document);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SvgPicture.asset(
              widget.document.isFavorite 
                  ? 'assets/icons/heart_filled.svg' 
                  : 'assets/icons/heart.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.document.isFavorite 
                  ? 'Adicionado aos favoritos' 
                  : 'Removido dos favoritos',
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
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
    final categoryColor = _dominantColor ?? _getCategoryColor(widget.document.category);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
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
                  icon: SvgPicture.asset(
                    widget.document.isFavorite 
                        ? 'assets/icons/heart_filled.svg' 
                        : 'assets/icons/heart.svg',
                    width: 19.2,
                    height: 19.2,
                    colorFilter: ColorFilter.mode(
                      widget.document.isFavorite ? Colors.red : theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: _toggleFavorite,
                ),
                if (_isDownloading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 2.5,
                        color: categoryColor,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/download.svg',
                      width: 19.2,
                      height: 19.2,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: _downloadPDF,
                  ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/close.svg',
                    width: 19.2,
                    height: 19.2,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: _buildImageWithBlur(categoryColor),
                  ),
                  _buildContent(theme, categoryColor),
                ],
              ),
            ),
          ),

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
                    SvgPicture.asset(
                      'assets/icons/play.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
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
    final categoryColor = _dominantColor ?? _getCategoryColor(widget.document.category);

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
                width: 19.2,
                height: 19.2,
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
                  widget.document.isFavorite 
                      ? 'assets/icons/heart_filled.svg' 
                      : 'assets/icons/heart.svg',
                  width: 19.2,
                  height: 19.2,
                  colorFilter: ColorFilter.mode(
                    widget.document.isFavorite ? Colors.red : theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: _toggleFavorite,
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
              child: _isDownloading
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: _downloadProgress,
                          strokeWidth: 2.5,
                          color: categoryColor,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/download.svg',
                        width: 19.2,
                        height: 19.2,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: _downloadPDF,
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
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => _showFullImage(context),
                    child: Hero(
                      tag: 'document_${widget.document.id}',
                      child: _buildImageWithBlur(categoryColor),
                    ),
                  ),
                ),

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
                          width: 16,
                          height: 16,
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

  Widget _buildImageWithBlur(Color categoryColor) {
    return Container(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
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
              ],
            ),
          ),

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
                return SvgPicture.asset(
                  'assets/icons/document.svg',
                  width: 51.2,
                  height: 51.2,
                  colorFilter: ColorFilter.mode(
                    categoryColor.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                );
              },
            ),
          ),

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
                      width: 11.2,
                      height: 11.2,
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
                  SvgPicture.asset(
                    'assets/icons/zoom_in.svg',
                    width: 12.8,
                    height: 12.8,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
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
          Text(
            widget.document.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

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
                SvgPicture.asset(
                  _getCategoryIconPath(widget.document.category),
                  width: 10.4,
                  height: 10.4,
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

          const SizedBox(height: 32),

          if (widget.document.downloads != null || widget.document.rating != null)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.document.downloads != null)
                  _StatChip(
                    iconPath: 'assets/icons/download.svg',
                    label: '${widget.document.downloads} Downloads',
                    theme: theme,
                  ),
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

          if (widget.document.features != null && widget.document.features!.isNotEmpty) ...[
            _SectionHeader(title: 'Features', theme: theme),
            const SizedBox(height: 16),

            if (isWide)
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
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300 || details.primaryVelocity! < -300) {
            Navigator.pop(context);
          }
        },
        child: Stack(
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
                      child: SvgPicture.asset(
                        'assets/icons/close.svg',
                        width: 19.2,
                        height: 19.2,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/swipe.svg',
                        width: 12.8,
                        height: 12.8,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Swipe to close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
    );
  }
}

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
            width: 10.4,
            height: 10.4,
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
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 19.2,
                  height: 19.2,
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
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      height: 1.5,
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
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 19.2,
                height: 19.2,
                colorFilter: ColorFilter.mode(
                  categoryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}