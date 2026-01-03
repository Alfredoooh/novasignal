import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';

/// Widget para carregar imagens com suporte CORS na web
class CorsImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CorsImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  String _getCorsProxyUrl(String url) {
    if (url.isEmpty) return '';
    
    // Remove espaços em branco
    url = url.trim();
    
    // Se já tiver protocolo, usa direto
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    
    // Na web, usa proxy CORS
    if (kIsWeb) {
      // Opção 1: CORS Anywhere (público, mas pode ter limite de taxa)
      return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
      
      // Opção 2: AllOrigins (alternativa)
      // return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
      
      // Opção 3: Seu próprio proxy (recomendado para produção)
      // return 'https://seu-proxy.com/image?url=${Uri.encodeComponent(url)}';
    }
    
    // Mobile/Desktop: retorna URL direta
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final proxiedUrl = _getCorsProxyUrl(imageUrl);

    return CachedNetworkImage(
      imageUrl: proxiedUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('❌ Erro ao carregar imagem: $url');
        debugPrint('   Erro: $error');
        return errorWidget ?? _buildErrorWidget();
      },
      // Configurações adicionais para web
      httpHeaders: kIsWeb ? {
        'Accept': 'image/*',
      } : null,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.sports_soccer,
        size: (width ?? 50) * 0.5,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Widget simplificado para logos de times
class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final double size;

  const TeamLogo({
    Key? key,
    required this.logoUrl,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CorsImage(
      imageUrl: logoUrl ?? '',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorWidget: _buildDefaultLogo(),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
}

/// Widget para bandeiras de países/ligas
class LeagueFlag extends StatelessWidget {
  final String? flagUrl;
  final double width;
  final double height;

  const LeagueFlag({
    Key? key,
    required this.flagUrl,
    this.width = 32,
    this.height = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CorsImage(
      imageUrl: flagUrl ?? '',
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.flag_outlined,
          size: height * 0.7,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}