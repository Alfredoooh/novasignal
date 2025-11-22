import 'package:flutter/cupertino.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isError = message.role == 'error';

    return Align(
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
              ? primaryColor
              : isError
                  ? const Color(0xFF5F1C1C)
                  : secondaryBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isError
                ? const Color(0xFFFF6B6B)
                : CupertinoColors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}