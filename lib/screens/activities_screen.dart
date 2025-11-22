import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/view_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_widget.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String _selectedTab = 'Year';
  int _currentYear = 2024;

  final Map<int, List<double>> _yearlyData = {
    2024: [3200, 3800, 5100, 6800, 8200, 9500, 6180, 0, 0, 0, 0, 0],
    2023: [2800, 3200, 4100, 5200, 6100, 7200, 8100, 8900, 9200, 9800, 10200, 10500],
  };

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onAddPressed: _handleAdd,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            _buildTabs(),
            _buildYearSelector(),
            _buildChart(),
            _buildBarsChart(),
            _buildSummary(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 15),
      child: Text(
        'Activities',
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
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
          _buildTab('Week'),
          _buildTab('Month'),
          _buildTab('Year'),
          _buildTab('All Time'),
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

  Widget _buildYearSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _currentYear = _currentYear == 2024 ? 2023 : 2024;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _currentYear.toString(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF375F),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Ionicons.chevron_down_outline,
                      size: 16,
                      color: Color(0xFFFF375F),
                    ),
                  ],
                ),
                Text(
                  'vs. ${_currentYear - 1}',
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
              _handleShare();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SHARE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ChartWidget(
        data: _yearlyData[_currentYear]!,
        months: _months,
      ),
    );
  }

  Widget _buildBarsChart() {
    final data = _yearlyData[_currentYear]!;
    final maxValue = data.where((v) => v > 0).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (index) {
          final value = data[index];
          final height = value > 0 ? (value / maxValue) * 100 : 2.0;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      height: height,
                      decoration: BoxDecoration(
                        color: value > 0
                            ? const Color(0xFFFF375F)
                            : Colors.white.withOpacity(0.24),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _months[index],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '1 JAN–25 JUL',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              _buildViewToggles(),
            ],
          ),
          const SizedBox(height: 15),
          Consumer<ViewProvider>(
            builder: (context, viewProvider, child) {
              if (viewProvider.currentView == ViewType.grid) {
                return _buildGridView();
              } else {
                return _buildListView();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggles() {
    return Consumer<ViewProvider>(
      builder: (context, viewProvider, child) {
        return Row(
          children: [
            _buildViewButton(
              icon: Ionicons.grid_outline,
              isActive: viewProvider.currentView == ViewType.grid,
              onTap: () {
                HapticFeedback.lightImpact();
                viewProvider.setView(ViewType.grid);
              },
            ),
            const SizedBox(width: 8),
            _buildViewButton(
              icon: Ionicons.reorder_three_outline,
              isActive: viewProvider.currentView == ViewType.list,
              onTap: () {
                HapticFeedback.lightImpact();
                viewProvider.setView(ViewType.list);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Documentos',
          value: '43 250',
          unit: 'docs',
          change: '+5 742',
          isHighlight: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
        StatCard(
          label: 'Duração',
          value: '160h 34m',
          change: '+31h 7m',
          onTap: () => HapticFeedback.lightImpact(),
        ),
        StatCard(
          label: 'Caracteres',
          value: '803,52k',
          change: '+113,62k',
          onTap: () => HapticFeedback.lightImpact(),
        ),
        StatCard(
          label: 'Páginas',
          value: '2 235',
          unit: 'pgs',
          change: '+178',
          onTap: () => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        StatCard(
          label: 'Documentos',
          value: '43 250',
          unit: 'docs',
          change: '+5 742',
          isHighlight: true,
          isList: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 10),
        StatCard(
          label: 'Duração',
          value: '160h 34m',
          change: '+31h 7m',
          isList: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 10),
        StatCard(
          label: 'Caracteres',
          value: '803,52k',
          change: '+113,62k',
          isList: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
        const SizedBox(height: 10),
        StatCard(
          label: 'Páginas',
          value: '2 235',
          unit: 'pgs',
          change: '+178',
          isList: true,
          onTap: () => HapticFeedback.lightImpact(),
        ),
      ],
    );
  }

  void _handleAdd() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Criar novo documento')),
    );
  }

  void _handleShare() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhar')),
    );
  }
}
