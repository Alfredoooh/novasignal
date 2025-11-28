import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/document_model.dart';
import '../providers/theme_provider.dart';
import 'document_detail_screen.dart';
import '../widgets/favorites_widgets.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedCategory = 'All';
  bool _isGridView = false;
  String _sortBy = 'name';

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

  List<String> _getCategories() {
    final categories = widget.favoriteDocuments
        .map((doc) => doc.category)
        .toSet()
        .toList();
    categories.sort();
    categories.insert(0, 'All');
    return categories;
  }

  List<DocumentModel> _getFilteredDocuments() {
    var docs = widget.favoriteDocuments.where((doc) {
      final matchesCategory = _selectedCategory == 'All' || 
                              doc.category == _selectedCategory;
      return matchesCategory;
    }).toList();

    switch (_sortBy) {
      case 'name':
        docs.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        docs.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'date':
        break;
    }

    return docs;
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'My Favorite Documents',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total: ${widget.favoriteDocuments.length} documents',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Name', 'Category', 'Type'],
                data: widget.favoriteDocuments.map((doc) => [
                  doc.name,
                  doc.category,
                  doc.isPro ? 'PRO' : 'Free',
                ]).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/favorites_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved: ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToCsv() async {
    try {
      final csv = StringBuffer();
      csv.writeln('Name,Category,Type,Is Favorite');

      for (var doc in widget.favoriteDocuments) {
        csv.writeln('"${doc.name}","${doc.category}","${doc.isPro ? 'PRO' : 'Free'}","Yes"');
      }

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/favorites_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV saved: ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToJson() async {
    try {
      final jsonData = {
        'exported_at': DateTime.now().toIso8601String(),
        'total': widget.favoriteDocuments.length,
        'favorites': widget.favoriteDocuments.map((doc) => {
          'name': doc.name,
          'category': doc.category,
          'isPro': doc.isPro,
          'isFavorite': doc.isFavorite,
          'coverImage': doc.coverImage,
        }).toList(),
      };

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/favorites_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonData),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('JSON saved: ${file.path}'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting JSON: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFavorites() async {
    try {
      final text = StringBuffer();
      text.writeln('📚 My Favorite Documents (${widget.favoriteDocuments.length})');
      text.writeln('');

      for (var doc in widget.favoriteDocuments) {
        text.writeln('• ${doc.name}');
        text.writeln('  Category: ${doc.category}');
        if (doc.isPro) text.writeln('  Type: PRO ⭐');
        text.writeln('');
      }

      await Share.share(
        text.toString(),
        subject: 'My Favorite Documents',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSortOptions() {
    final theme = widget.themeProvider.currentTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sort by',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Name', 'name', 'sort_alpha', theme),
            _buildSortOption('Category', 'category', 'category', theme),
            _buildSortOption('Date Added', 'date', 'calendar', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, String icon, ThemeData theme) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showBulkActions() {
    final theme = widget.themeProvider.currentTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildBulkActionOption(
              'Remove All from Favorites',
              'heart',
              Colors.red,
              theme,
              () {
                _showRemoveAllDialog();
              },
            ),
            _buildBulkActionOption(
              'Export Favorites List',
              'export',
              theme.colorScheme.primary,
              theme,
              () {
                Navigator.pop(context);
                _showExportDialog();
              },
            ),
            _buildBulkActionOption(
              'Share Favorites',
              'share',
              theme.colorScheme.primary,
              theme,
              () {
                Navigator.pop(context);
                _shareFavorites();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionOption(
    String label,
    String icon,
    Color color,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveAllDialog() {
    final theme = widget.themeProvider.currentTheme;
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Remove All Favorites?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will remove all ${widget.favoriteDocuments.length} documents from your favorites. This action cannot be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (var doc in widget.favoriteDocuments) {
                  doc.isFavorite = false;
                  widget.onFavoriteToggle?.call(doc);
                }
              });
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Remove All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final theme = widget.themeProvider.currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/export.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Export Format',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption('PDF Document', 'pdf', theme, _exportToPdf),
            const SizedBox(height: 12),
            _buildExportOption('CSV Spreadsheet', 'csv', theme, _exportToCsv),
            const SizedBox(height: 12),
            _buildExportOption('JSON File', 'json', theme, _exportToJson),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(String label, String format, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/document.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icons/arrow_forward.svg',
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(DocumentModel document) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeProvider.currentTheme;
    final filteredDocs = _getFilteredDocuments();
    final categories = _getCategories();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: theme.cardColor,
              child: Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        IconButton(
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
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/icons/heart_filled.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.red,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Favorites',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.displayLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        if (widget.favoriteDocuments.isNotEmpty) ...[
                          IconButton(
                            icon: SvgPicture.asset(
                              _isGridView ? 'assets/icons/list.svg' : 'assets/icons/grid.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isGridView = !_isGridView;
                              });
                            },
                          ),
                          PopupMenuButton(
                            icon: SvgPicture.asset(
                              'assets/icons/more_vert.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/sort.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.secondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Sort'),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(
                                    Duration.zero,
                                    () => _showSortOptions(),
                                  );
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/settings.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.secondary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Bulk Actions'),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(
                                    Duration.zero,
                                    () => _showBulkActions(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    color: theme.dividerColor,
                    height: 0.5,
                  ),
                ],
              ),
            ),

            // Stats Cards
            if (widget.favoriteDocuments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FavoritesStatCard(
                        label: 'Total',
                        value: widget.favoriteDocuments.length.toString(),
                        icon: 'heart_filled',
                        color: Colors.red,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FavoritesStatCard(
                        label: 'Categories',
                        value: (categories.length - 1).toString(),
                        icon: 'category',
                        color: theme.colorScheme.primary,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FavoritesStatCard(
                        label: 'PRO',
                        value: widget.favoriteDocuments.where((d) => d.isPro).length.toString(),
                        icon: 'star',
                        color: Colors.amber,
                        theme: theme,
                      ),
                    ),
                  ],
                ),
              ),

            // Category Chips
            if (categories.length > 1 && widget.favoriteDocuments.isNotEmpty)
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: CategoryChip(
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

            // Content
            Expanded(
              child: widget.favoriteDocuments.isEmpty
                  ? FavoritesEmptyState(theme: theme)
                  : filteredDocs.isEmpty
                      ? FavoritesEmptyCategoryState(
                          theme: theme,
                          selectedCategory: _selectedCategory,
                          onClearFilters: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                        )
                      : FadeTransition(
                          opacity: _animationController,
                          child: _isGridView
                              ? FavoritesGridView(
                                  documents: filteredDocs,
                                  theme: theme,
                                  onTap: _navigateToDetail,
                                  onFavoriteToggle: (doc) {
                                    setState(() {
                                      doc.isFavorite = !doc.isFavorite;
                                      widget.onFavoriteToggle?.call(doc);
                                    });
                                  },
                                )
                              : FavoritesListView(
                                  documents: filteredDocs,
                                  theme: theme,
                                  onTap: _navigateToDetail,
                                  onFavoriteToggle: (doc) {
                                    setState(() {
                                      doc.isFavorite = !doc.isFavorite;
                                      widget.onFavoriteToggle?.call(doc);
                                    });
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}