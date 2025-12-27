import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'news_detail_page.dart';

class NewsExpandedContent extends StatelessWidget {
  final List<Map<String, dynamic>> noticias;

  const NewsExpandedContent({
    super.key,
    required this.noticias,
  });

  void _openNewsDetail(BuildContext context, Map<String, dynamic> noticia) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(noticia: noticia),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (noticias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.article_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notícia disponível',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final noticia = noticias[index];
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    _buildNewsItem(context, noticia),
                  ],
                );
              },
              childCount: noticias.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildNewsItem(BuildContext context, Map<String, dynamic> noticia) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => _openNewsDetail(context, noticia),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Symbols.article_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noticia['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noticia['subtitle'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (noticia['date'] != null && (noticia['date'] as String).isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        noticia['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}