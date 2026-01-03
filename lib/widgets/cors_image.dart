import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Widget para carregar imagens com suporte CORS na web
class CorsImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final FilterQuality filterQuality;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CorsImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.filterQuality = FilterQuality.medium,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  String _getProxiedImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String cleanUrl = url.trim();
    
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(cleanUrl)}';
    }

    return cleanUrl;
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl = _getProxiedImageUrl(imageUrl);
    final hasValidUrl = proxiedUrl.isNotEmpty && 
                        Uri.tryParse(proxiedUrl)?.hasAbsolutePath == true;

    if (!hasValidUrl) {
      return errorWidget ?? _buildErrorWidget();
    }

    return Image.network(
      proxiedUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
      filterQuality: filterQuality,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erro ao carregar imagem: $imageUrl');
        debugPrint('   URL proxied: $proxiedUrl');
        debugPrint('   Erro: $error');
        return errorWidget ?? _buildErrorWidget();
      },
    );
  }

  Widget _buildPlaceholder(ImageChunkEvent? loadingProgress) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: (width ?? 50) * 0.4,
          height: (height ?? 50) * 0.4,
          child: CircularProgressIndicator(
            value: loadingProgress?.expectedTotalBytes != null
                ? loadingProgress!.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
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
  final FilterQuality filterQuality;

  const TeamLogo({
    Key? key,
    required this.logoUrl,
    this.size = 40,
    this.filterQuality = FilterQuality.medium,
  }) : super(key: key);

  String _getProxiedImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String cleanUrl = url.trim();
    
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(cleanUrl)}';
    }

    return cleanUrl;
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl = _getProxiedImageUrl(logoUrl);
    final hasValidUrl = proxiedUrl.isNotEmpty && 
                        Uri.tryParse(proxiedUrl)?.hasAbsolutePath == true;

    if (!hasValidUrl) {
      return _buildDefaultLogo();
    }

    return Image.network(
      proxiedUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: filterQuality,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erro ao carregar logo: $logoUrl');
        debugPrint('   URL proxied: $proxiedUrl');
        debugPrint('   Erro: $error');
        return _buildDefaultLogo();
      },
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
  final FilterQuality filterQuality;

  const LeagueFlag({
    Key? key,
    required this.flagUrl,
    this.width = 32,
    this.height = 24,
    this.filterQuality = FilterQuality.medium,
  }) : super(key: key);

  String _getProxiedImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    String cleanUrl = url.trim();
    
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    if (kIsWeb) {
      return 'https://corsproxy.io/?${Uri.encodeComponent(cleanUrl)}';
    }

    return cleanUrl;
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl = _getProxiedImageUrl(flagUrl);
    final hasValidUrl = proxiedUrl.isNotEmpty && 
                        Uri.tryParse(proxiedUrl)?.hasAbsolutePath == true;

    if (!hasValidUrl) {
      return _buildDefaultFlag();
    }

    return Image.network(
      proxiedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      filterQuality: filterQuality,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: SizedBox(
              width: height * 0.4,
              height: height * 0.4,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 1.5,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Erro ao carregar flag: $flagUrl');
        debugPrint('   URL proxied: $proxiedUrl');
        debugPrint('   Erro: $error');
        return _buildDefaultFlag();
      },
    );
  }

  Widget _buildDefaultFlag() {
    return Container(
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
    );
  }
}