import 'package:flutter/material.dart';

/// Presentations Screen
/// Shows available presentations and templates
class PresentationsScreen extends StatelessWidget {
  const PresentationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Presentations', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Presentations - Coming Soon!'),
      ),
    );
  }
}
