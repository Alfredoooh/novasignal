import 'package:flutter/material.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Editor de Documentos',
        style: TextStyle(fontSize: 14.4),
      ),
    );
  }
}