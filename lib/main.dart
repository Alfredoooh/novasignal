import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const DocuGenApp());
}

class DocuGenApp extends StatelessWidget {
  const DocuGenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuGen AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DocuGenHomePage(),
    );
  }
}