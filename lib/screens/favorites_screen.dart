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
  late AnimationController _searchController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isGridView = false;
  String _sortBy = 'name';
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
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
      final matchesSearch = _searchQuery.isEmpty ||
                           doc.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchController.forward();
        _searchFocusNode.requestFocus();
      } else {
        _searchController.reverse();
        _searchQuery = '';
        _searchTextController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  // EXPORTAÇÃO REAL - PDF
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

  // EXPORTAÇÃO REAL - CSV
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

  // EXPORTAÇÃO REAL - JSON
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

  // PARTILHA REAL
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
              width: 24,
              height: 24,
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
                size: 24,
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
              width: 24,
              height: 24,
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
              width: 24,
              height: 24,
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
              width: 24,
              height: 24,
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
              width: 16,
              height: 16,
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
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        if (!_isSearching) ...[
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/icons/heart_filled.svg',
                            width: 22,
                            height: 22,
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
                        ],
                        if (_isSearching)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 16),
                              child: TextField(
                                controller: _searchTextController,
                                focusNode: _searchFocusNode,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search favorites...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (widget.favoriteDocuments.isNotEmpty) ...[
                          IconButton(
                            icon: SvgPicture.asset(
                              _isSearching ? 'assets/icons/close.svg' : 'assets/icons/search.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: _toggleSearch,
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              _isGridView ? 'assets/icons/list.svg' : 'assets/icons/grid.svg',
                              width: 24,
                              height: 24,
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
                              width: 24,
                              height: 24,
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
                                      width: 20,
                                      height: 20,
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
                                      width: 20,
                                      height: 20,
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

            if (widget.favoriteDocuments.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        widget.favoriteDocuments.length.toString(),
                        'heart_filled',
                        Colors.red,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Categories',
                        (categories.length - 1).toString(),
                        'category',
                        theme.colorScheme.primary,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'PRO',
                        widget.favoriteDocuments.where((d) => d.isPro).length.toString(),
                        'star',
                        Colors.amber,
                        theme,
                      ),
                    ),
                  ],
                ),
              ),

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

            Expanded(
              child: widget.favoriteDocuments.isEmpty
                  ? _buildEmptyState(theme)
                  : filteredDocs.isEmpty
                      ? _buildEmptyCategoryState(theme)
                      : FadeTransition(
                          opacity: _animationController,
                          child: _isGridView
                              ? _buildGridView(filteredDocs, theme)
                              : _buildListView(filteredDocs, theme),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String icon,
    Color color,
    ThemeData theme,
  ) {
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

  Widget _buildGridView(List<DocumentModel> docs, ThemeData theme) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: docs.length,
      itemBuilder: (context, index) {
        return _buildGridCard(docs[index], theme, index);
      },
    );
  }

  Widget _buildGridCard(DocumentModel document, ThemeData theme, int index) {
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
        onTap: () => _navigateToDetail(document),
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
                    child: Image.asset(
                      document.coverImage,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
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
                            SvgPicture.asset(
                              'assets/icons/star.svg',
                              width: 12,
                              height: 12,
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
                      onTap: () {
                        setState(() {
                          document.isFavorite = !document.isFavorite;
                          widget.onFavoriteToggle?.call(document);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          document.isFavorite
                              ? 'assets/icons/heart_filled.svg'
                              : 'assets/icons/heart.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            document.isFavorite ? Colors.red : Colors.grey,
                            BlendMode.srcIn,
                          ),
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
                        SvgPicture.asset(
                          'assets/icons/category.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.secondary,
                            BlendMode.srcIn,
                          ),
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

  Widget _buildListView(List<DocumentModel> docs, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: docs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildListCard(docs[index], theme, index);
      },
    );
  }

  Widget _buildListCard(DocumentModel document, ThemeData theme, int index) {
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
        onTap: () => _navigateToDetail(document),
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
                    child: Image.asset(
                      document.coverImage,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                            SvgPicture.asset(
                              'assets/icons/star.svg',
                              width: 10,
                              height: 10,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
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
                          SvgPicture.asset(
                            'assets/icons/category.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.secondary,
                              BlendMode.srcIn,
                            ),
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
                  onTap: () {
                    setState(() {
                      document.isFavorite = !document.isFavorite;
                      widget.onFavoriteToggle?.call(document);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: document.isFavorite
                          ? Colors.red.withOpacity(0.1)
                          : theme.dividerColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      document.isFavorite
                          ? 'assets/icons/heart_filled.svg'
                          : 'assets/icons/heart.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        document.isFavorite ? Colors.red : theme.colorScheme.secondary,
                        BlendMode.srcIn,
                      ),
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

  Widget _buildEmptyState(ThemeData theme) {
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
              child: SvgPicture.asset(
                'assets/icons/heart.svg',
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
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
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
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

  Widget _buildEmptyCategoryState(ThemeData theme) {
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
              child: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 64,
                height: 64,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary.withOpacity(0.5),
                  BlendMode.srcIn,
                ),
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
              _searchQuery.isNotEmpty
                  ? 'No documents match "$_searchQuery" in ${_selectedCategory == 'All' ? 'any category' : _selectedCategory}'
                  : 'No favorites found in $_selectedCategory',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchQuery = '';
                  _searchTextController.clear();
                });
              },
              icon: SvgPicture.asset(
                'assets/icons/refresh.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor,
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