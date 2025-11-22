import 'package:flutter/cupertino.dart';

class LoadingIndicator extends StatefulWidget {
  final Color backgroundColor;

  const LoadingIndicator({
    Key? key,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(0.33),
                const SizedBox(width: 4),
                _buildDot(0.66),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDot(double delay) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          delay,
          delay + 0.33,
          curve: Curves.easeInOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8 * (0.5 - (animation.value - 0.5).abs()) * 2),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CupertinoColors.systemGrey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}