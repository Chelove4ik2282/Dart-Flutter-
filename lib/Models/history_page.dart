import 'package:flutter/material.dart';

class HomeHistoryPage extends StatelessWidget {
  const HomeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game History')),
      body: const Center(
        child: Text('History will be shown here'),
      ),
    );
  }
}
