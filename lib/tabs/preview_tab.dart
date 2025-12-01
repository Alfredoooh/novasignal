import 'package:flutter/material.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Text(
          'Preview',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}