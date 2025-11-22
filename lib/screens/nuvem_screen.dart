import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import '../widgets/custom_app_bar.dart';

class NuvemScreen extends StatefulWidget {
  const NuvemScreen({super.key});

  @override
  State<NuvemScreen> createState() => _NuvemScreenState();
}

class _NuvemScreenState extends State<NuvemScreen> {
  String _selectedTab = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onAddPressed: () {
          HapticFeedback.mediumImpact();
          _handleUpload();
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 15),
              child: Text(
                'Nuvem',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            _buildTabs(),
            const SizedBox(height: 10),
            _buildStorageInfo(),
            const SizedBox(height: 20),
            _buildFilesList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 20, bottom: 15),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTab('Todos'),
          _buildTab('Documentos'),
          _buildTab('Imagens'),
          _buildTab('Vídeos'),
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    final isActive = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedTab = label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.24),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Armazenamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '4.2 GB / 15 GB',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.28,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFF375F),
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arquivos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 15),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _buildFileItem(
                title: 'Arquivo ${index + 1}.pdf',
                subtitle: '${(index + 1) * 1.2} MB • ${index + 1} dias atrás',
                icon: _getIconForType(index % 4),
                color: _getColorForType(index % 4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showFileOptions();
              },
              child: const Icon(
                Ionicons.ellipsis_horizontal,
                size: 20,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(int type) {
    switch (type) {
      case 0:
        return Ionicons.document_text_outline;
      case 1:
        return Ionicons.image_outline;
      case 2:
        return Ionicons.videocam_outline;
      case 3:
        return Ionicons.folder_outline;
      default:
        return Ionicons.document_outline;
    }
  }

  Color _getColorForType(int type) {
    switch (type) {
      case 0:
        return const Color(0xFFFF375F);
      case 1:
        return const Color(0xFF007AFF);
      case 2:
        return const Color(0xFF34C759);
      case 3:
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  void _handleUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fazer upload de arquivo')),
    );
  }

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Ionicons.share_outline),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.download_outline),
              title: const Text('Baixar'),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.trash_outline, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.mediumImpact();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}