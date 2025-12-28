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
    final hasImage = noticia['imageUrl'] != null && (noticia['imageUrl'] as String).isNotEmpty;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: Icon(Symbols.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          noticia['subtitle'] ?? 'Notícia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        actions: [
          if (noticia['url'] != null && (noticia['url'] as String).isNotEmpty)
            IconButton(
              icon: Icon(Symbols.open_in_new_rounded, color: cs.onSurface),
              onPressed: () => _abrirUrl(noticia['url']),
              tooltip: 'Abrir no navegador',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                noticia['imageUrl'],
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Symbols.article_rounded,
                    size: 64,
                    color: cs.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
            const SizedBox(height: 16),
          ],
          Text(
            noticia['title'] ?? '',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          if (noticia['description'] != null && (noticia['description'] as String).isNotEmpty) ...[
            Text(
              noticia['description'],
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface,
                height: 1.6,
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _abrirUrl(noticia['url']),
                  borderRadius: BorderRadius.circular(12),
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
                                'Abrir fonte original',
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
    );
  }
}