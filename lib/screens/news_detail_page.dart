import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> noticia;

  const NewsDetailPage({super.key, required this.noticia});

  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: noticia['imageUrl'] != null && (noticia['imageUrl'] as String).isNotEmpty ? 250 : 200,
            pinned: true,
            stretch: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (noticia['url'] != null && (noticia['url'] as String).isNotEmpty)
                IconButton(
                  icon: Icon(Symbols.open_in_new_rounded, color: cs.onSurface),
                  onPressed: () => _abrirUrl(noticia['url']),
                  tooltip: 'Abrir no navegador',
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                noticia['subtitle'] ?? 'Notícia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 56),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (noticia['imageUrl'] != null && (noticia['imageUrl'] as String).isNotEmpty)
                    Image.network(
                      noticia['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.primaryContainer,
                              cs.surface,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Symbols.article_rounded,
                            size: 80,
                            color: cs.primary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            cs.primaryContainer,
                            cs.surface,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Symbols.article_rounded,
                          size: 80,
                          color: cs.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cs.surface.withOpacity(0.8),
                          cs.surface,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (noticia['date'] != null && (noticia['date'] as String).isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Symbols.schedule_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          noticia['date'],
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    noticia['title'] ?? '',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (noticia['description'] != null && (noticia['description'] as String).isNotEmpty) ...[
                    Text(
                      noticia['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: cs.onSurface,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (noticia['url'] != null && (noticia['url'] as String).isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _abrirUrl(noticia['url']),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.open_in_new_rounded,
                                  color: cs.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ler notícia completa',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        noticia['subtitle'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: cs.onPrimaryContainer.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Symbols.arrow_forward_rounded,
                                  color: cs.primary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}