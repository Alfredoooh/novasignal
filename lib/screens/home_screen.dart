import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/settings_modal.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../screens/document_detail_screen.dart';
import '../screens/favorites_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;
  final Function(Widget)? onSecondaryScreenChanged;

  const HomeScreen({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
    this.onSecondaryScreenChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DocumentService _documentService = DocumentService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  late AnimationController _fadeController;
  late AnimationController _categoryController;

  final List<String> _categories = [
    'All',
    'Business',
    'Academic',
    'Personal',
    'Legal',
    'Creative',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _categoryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await _documentService.fetchDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showSettingsModal(BuildContext context) {
    if (_isDesktop(context)) {
      widget.onSecondaryScreenChanged?.call(
        SettingsScreen(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
          onClose: () {
            widget.onSecondaryScreenChanged?.call(const _EmptySecondaryScreen());
          },
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SettingsModal(
          themeProvider: widget.themeProvider,
          languageProvider: widget.languageProvider,
        ),
      );
    }
  }

  void _navigateToFavorites() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          themeProvider: widget.themeProvider,
          documents: _documents.where((doc) => doc.isFavorite).toList(),
        ),
      ),
    );
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  List<DocumentModel> get _filteredDocuments {
    if (_selectedCategory == 'All') {
      return _documents;
    }
    return _documents
        .where((doc) => doc.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeProvider.currentTheme;
    final isDesktop = _isDesktop(context);

    if (isDesktop) {
      return _buildDesktopLayout(theme);
    }
    return _buildMobileLayout(theme);
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              children: [
                Text(
                  'Templates',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _CategoryChip(
                            label: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                              _categoryController.forward(from: 0);
                            },
                            theme: theme,
                            isDesktop: true,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/settings.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => _showSettingsModal(context),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: _buildContent(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: _buildDrawer(theme),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/menu_two.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Templates',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryChip(
                      label: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _categoryController.forward(from: 0);
                      },
                      theme: theme,
                      isDesktop: false,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/close.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: 'assets/icons/heart.svg',
              label: 'Favorites',
              theme: theme,
              onTap: _navigateToFavorites,
            ),
            _DrawerItem(
              icon: 'assets/icons/settings.svg',
              label: 'Settings',
              theme: theme,
              onTap: () {
                Navigator.pop(context);
                _showSettingsModal(context);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Version 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/alert.svg',
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDocuments,
                icon: SvgPicture.asset(
                  'assets/icons/refresh.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredDocs = _filteredDocuments;

    if (filteredDocs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/document.svg',
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  theme.dividerColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No documents available',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new templates',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isDesktop = _isDesktop(context);
    final isWideDesktop = MediaQuery.of(context).size.width >= 1400;
    
    return SlideTransition(
      position: _categoryController.drive(
        Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.elasticOut)),
      ),
      child: FadeTransition(
        opacity: _categoryController.drive(
          Tween<double>(begin: 0.0, end: 1.0),
        ),
        child: MasonryGridView.count(
          controller: _scrollController,
          padding: EdgeInsets.all(isDesktop ? 32 : 20),
          crossAxisCount: isWideDesktop ? 4 : (isDesktop ? 3 : 2),
          mainAxisSpacing: isDesktop ? 20 : 16,
          crossAxisSpacing: isDesktop ? 20 : 16,
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            return _ImageCard(
              document: filteredDocs[index],
              theme: theme,
              index: index,
              isDesktop: isDesktop,
              animationController: _categoryController,
              onTap: () {
                if (isDesktop) {
                  widget.onSecondaryScreenChanged?.call(
                    DocumentDetailScreen(
                      document: filteredDocs[index],
                      themeProvider: widget.themeProvider,
                      isSecondaryScreen: true,
                      onClose: () {
                        widget.onSecondaryScreenChanged?.call(const _EmptySecondaryScreen());
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentDetailScreen(
                        document: filteredDocs[index],
                        themeProvider: widget.themeProvider,
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDesktop;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 20,
            vertical: isDesktop ? 12 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.cardColor,
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 24),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.textTheme.bodyLarge?.color,
              fontSize: isDesktop ? 15 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final DocumentModel document;
  final ThemeData theme;
  final int index;
  final bool isDesktop;
  final AnimationController animationController;
  final VoidCallback onTap;

  const _ImageCard({
    required this.document,
    required this.theme,
    required this.index,
    required this.isDesktop,
    required this.animationController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = isDesktop ? 12.0 : 20.0;
    final delay = (index * 50).clamp(0, 300);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final animationValue = Curves.elasticOut.transform(
          math.max(0, (animationController.value * 1000 - delay) / 1000),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: Hero(
        tag: 'document_${document.id}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Stack(
                  children: [
                    Image.network(
                      document.coverImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return AspectRatio(
                          aspectRatio: 0.75,
                          child: Container(
                            color: theme.cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2.5,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return AspectRatio(
                          aspectRatio: 0.75,
                          child: Container(
                            color: theme.cardColor,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/document.svg',
                                width: 48,
                                height: 48,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary.withOpacity(0.3),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (document.isPro)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (document.isPro)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
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
                              const SizedBox(width: 4),
                              const Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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
          ),
        ),
      ),
    );
  }
}

class _EmptySecondaryScreen extends StatelessWidget {
  const _EmptySecondaryScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/document.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary.withOpacity(0.3),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a template',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;
  final VoidCallback onClose;

  const SettingsScreen({
    Key? key,
    required this.themeProvider,
    required this.languageProvider,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = themeProvider.currentTheme;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/close.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APPEARANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    context: context,
                    label: 'Theme',
                    value: themeProvider.isDarkMode ? 'Dark' : 'Light',
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    context: context,
                    label: 'Language',
                    value: languageProvider.languageName,
                    onTap: () {},
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border.all(
              color: theme.dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/arrow_forward.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}