import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class NewsPage extends StatefulWidget {
  final List<Map<String, dynamic>> noticias;

  const NewsPage({super.key, required this.noticias});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeNewsPage() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeNewsPage();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              // Header com Handle e Título
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 10) {
                    _closeNewsPage();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Column(
                    children: [
                      // Handle Deslizante
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Título e Botão de Fechar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.article_rounded,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Atualidades',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _closeNewsPage,
                              icon: const Icon(Symbols.close_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(
                          thickness: 1,
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Conteúdo
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: widget.noticias.isEmpty
                        ? _buildEmptyState()
                        : _buildNewsList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Symbols.news_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sem conteúdo ainda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'As últimas notícias e atualizações aparecerão aqui em breve',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.info_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Volte mais tarde para conferir as novidades',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildNewsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: widget.noticias.length,
      itemBuilder: (context, index) {
        final noticia = widget.noticias[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildNewsCard(
            noticia['title'] ?? '',
            noticia['subtitle'] ?? '',
            noticia['description'] ?? '',
            noticia['icon'] ?? Symbols.article_rounded,
            noticia['color'] ?? Colors.blue,
            noticia['date'] ?? '',
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color color,
    String date,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Ação ao clicar na notícia
            _showNewsDetail(title, subtitle, description, icon, color, date);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com ícone e data
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 24,
                    ),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNewsDetail(
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color color,
    String date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: color, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (date.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Symbols.close_rounded),
                      label: const Text('Fechar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: color,
                      ),
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