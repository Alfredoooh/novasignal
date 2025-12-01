import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const DocuGenApp());
}

class DocuGenApp extends StatelessWidget {
  const DocuGenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        title: 'DocuGen AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const DocuGenHomePage(),
      ),
    );
  }
}