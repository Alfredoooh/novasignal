import 'package:flutter/cupertino.dart';
import '../models/message.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final Color primaryColor;
  final Color secondaryBackground;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.primaryColor,
    required this.secondaryBackground,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == 'user';
    final isError = widget.message.role == 'error';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? widget.primaryColor
                  : isError
                      ? const Color(0xFF5F1C1C)
                      : widget.secondaryBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUser ? widget.primaryColor : widget.secondaryBackground).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message.content,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFFF6B6B)
                    : CupertinoColors.white,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}