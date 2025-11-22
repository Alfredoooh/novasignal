import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Image', 'Video', 'Styles', 'Top Creators'];

  // Lista de imagens com diferentes aspectos para replicar o design
  final List<ImageItem> _images = [
    ImageItem(
      gradient: [Color(0xFF1E40AF), Color(0xFF7C3AED)],
      aspectRatio: 0.75,
      likes: 256,
      hasRecreateButton: true,
    ),
    ImageItem(
      gradient: [Color(0xFFBAE6FD), Color(0xFFE0F2FE)],
      aspectRatio: 1.3,
      isLight: true,
    ),
    ImageItem(
      gradient: [Color(0xFF0F766E), Color(0xFF115E59)],
      aspectRatio: 0.6,
    ),
    ImageItem(
      gradient: [Color(0xFFDC2626), Color(0xFFEA580C)],
      aspectRatio: 1.0,
    ),
    ImageItem(
      gradient: [Color(0xFFE0F2FE), Color(0xFF93C5FD)],
      aspectRatio: 1.5,
      isLight: true,
    ),
    ImageItem(
      gradient: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      aspectRatio: 1.3,
    ),
    ImageItem(
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
      aspectRatio: 1.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              'Get inspired by the community',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildTabBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMasonryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMasonryGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildImageCard(_images[0], 0),
                const SizedBox(height: 12),
                _buildImageCard(_images[2], 2),
                const SizedBox(height: 12),
                _buildImageCard(_images[4], 4),
                const SizedBox(height: 12),
                _buildImageCard(_images[6], 6),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _buildImageCard(_images[1], 1),
                const SizedBox(height: 12),
                _buildImageCard(_images[3], 3),
                const SizedBox(height: 12),
                _buildImageCard(_images[5], 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(ImageItem item, int index) {
    final width = (MediaQuery.of(context).size.width - 44) / 2;
    final height = width / item.aspectRatio;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: item.gradient,
        ),
      ),
      child: Stack(
        children: [
          if (item.likes != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.likes}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (item.hasRecreateButton)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Recreate',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ImageItem {
  final List<Color> gradient;
  final double aspectRatio;
  final int? likes;
  final bool hasRecreateButton;
  final bool isLight;

  ImageItem({
    required this.gradient,
    required this.aspectRatio,
    this.likes,
    this.hasRecreateButton = false,
    this.isLight = false,
  });
}