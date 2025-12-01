import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'chat_tab.dart';
import 'preview_tab.dart';

class DocuGenHomePage extends StatefulWidget {
  const DocuGenHomePage({Key? key}) : super(key: key);

  @override
  State<DocuGenHomePage> createState() => _DocuGenHomePageState();
}

class _DocuGenHomePageState extends State<DocuGenHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'DocuGen AI',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.cube_outline),
            color: const Color(0xFF007AFF),
            iconSize: 28,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Ionicons.settings_outline),
            color: const Color(0xFF007AFF),
            iconSize: 28,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CupertinoSlidingSegmentedControl<int>(
              backgroundColor: const Color(0xFFE5E5EA),
              thumbColor: Colors.white,
              groupValue: _selectedIndex,
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              },
              onValueChanged: (value) {
                setState(() {
                  _selectedIndex = value!;
                });
              },
            ),
          ),
          Expanded(
            child: _selectedIndex == 0 ? const ChatTab() : const PreviewTab(),
          ),
        ],
      ),
    );
  }
}