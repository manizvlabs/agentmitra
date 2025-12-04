import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Settings functionality requires backend API integration'),
      ),
    );
  }
}
