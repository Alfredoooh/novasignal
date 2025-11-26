import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/settings_modal.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../screens/document_detail_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  final DocumentService _documentService = DocumentService();
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';

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
      // No desktop, abre settings na tela secundária (direita)
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
      // No mobile, mostra modal
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
    final theme = Theme.of(context);
    final isDesktop = _isDesktop(context);

    if (isDesktop) {
      return _buildDesktopLayout(theme);
    }
    return _buildMobileLayout(theme);
  }

  // Layout Desktop: AppBar + Grid de Templates (Tela Esquerda)
  Widget _buildDesktopLayout(ThemeData theme) {
    return Column(
      children: [
        // AppBar com Categorias
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Título
                Text(
                  'Templates',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40),
                
                // Categorias
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            label: category,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            theme: theme,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Botão Settings
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showSettingsModal(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'R',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Grid de Templates
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Templates',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSettingsModal(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categorias horizontais
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: category,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      theme: theme,
                    ),
                  );
                },
              ),
            ),

            // Conteúdo
            Expanded(
              child: _buildContent(theme),
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
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
                icon: const Icon(Icons.refresh),
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
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: theme.dividerColor,
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

    // Grid responsivo
    final isDesktop = _isDesktop(context);
    return MasonryGridView.count(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      crossAxisCount: isDesktop ? 3 : 2,
      mainAxisSpacing: isDesktop ? 16 : 12,
      crossAxisSpacing: isDesktop ? 16 : 12,
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        return _ImageCard(
          document: filteredDocs[index],
          theme: theme,
          index: index,
          onTap: () {
            if (isDesktop) {
              // Desktop: Abre DocumentDetailScreen na tela secundária (direita)
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
              // Mobile: Navegação normal em tela cheia
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
    );
  }
}

// Chip de Categoria
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
  final VoidCallback onTap;

  const _ImageCard({
    required this.document,
    required this.theme,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final heightFactor = 0.7 + (random.nextDouble() * 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1 / heightFactor,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    document.coverImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: theme.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.cardColor,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: theme.colorScheme.primary.withOpacity(0.3),
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
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
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
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
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

// Tela secundária vazia (placeholder)
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
            Icon(
              Icons.touch_app_outlined,
              size: 64,
              color: theme.colorScheme.secondary.withOpacity(0.3),
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

// Tela de Settings para desktop (tela secundária)
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
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  icon: Icon(Icons.close, color: theme.colorScheme.secondary),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          
          // Conteúdo
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
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.secondary,
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