import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../assets/app_icons.dart';

const Color primaryColor = Color(0xFF2C3E50);

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isDark;
  final String homeLabel;
  final String storeLabel;
  final String basketLabel;

  const BottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isDark,
    required this.homeLabel,
    required this.storeLabel,
    required this.basketLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF3E4042) : const Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children: [
          _buildBottomItem(0, AppIcons.homeOutline, AppIcons.homeFilled, homeLabel, isDark),
          _buildBottomItem(1, AppIcons.storeOutline, AppIcons.storeFilled, storeLabel, isDark),
          _buildBottomItem(2, AppIcons.basketOutline, AppIcons.basketFilled, basketLabel, isDark),
        ],
      ),
    );
  }

  Widget _buildBottomItem(int index, String outlineIcon, String filledIcon, String label, bool isDark) {
    final isSelected = selectedIndex == index;
    final selectedColor = isDark ? const Color(0xFFFFFFFF) : primaryColor;
    final inactiveColor = isDark ? const Color(0xFFB0B3B8) : const Color(0xFF7F8C8D);

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        child: Container(
          color: isDark ? const Color(0xFF242526) : const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulseIcon(
                icon: isSelected ? filledIcon : outlineIcon,
                color: isSelected ? selectedColor : inactiveColor,
                isSelected: isSelected,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? selectedColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  final String icon;
  final Color color;
  final bool isSelected;

  const _PulseIcon({
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected && widget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.string(widget.icon, color: widget.color),
          ),
        );
      },
    );
  }
}