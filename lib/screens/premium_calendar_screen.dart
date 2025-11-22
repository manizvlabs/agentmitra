import 'package:flutter/material.dart';

/// Premium Calendar Screen
/// Shows premium payment calendar and reminders
class PremiumCalendarScreen extends StatelessWidget {
  const PremiumCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Premium Calendar', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Premium Calendar - Coming Soon!'),
      ),
    );
  }
}
