import 'package:flutter/material.dart';
import '../core/services/localization_service.dart';

/// Language Selection Screen
/// Allows users to select their preferred language
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LocalizationService _localizationService = LocalizationService();
  AppLanguage _selectedLanguage = AppLanguage.english;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    await _localizationService.initialize();
    setState(() {
      _selectedLanguage = _localizationService.currentLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Language Settings', // TODO: Use localization
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveLanguage,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildLanguageList(),
            const SizedBox(height: 32),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.language,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose Your Language',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred language for the best experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _localizationService.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = _localizationService.supportedLanguages[index];
          return _buildLanguageOption(language);
        },
      ),
    );
  }

  Widget _buildLanguageOption(AppLanguage language) {
    final isSelected = _selectedLanguage == language;
    final languageInfo = _localizationService.getLanguageInfo(language);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.red.shade200 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.red.shade100.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = language;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Language Flag/Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getLanguageColor(language).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getLanguageIcon(language),
                  color: _getLanguageColor(language),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Language Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageInfo['name'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red.shade700 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Native name: ${languageInfo['name']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Code: ${languageInfo['code']} (${languageInfo['countryCode']})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.red : Colors.grey.shade200,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Language Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Changing the language will update all text in the app. Some content may take a moment to update. Your preference will be saved automatically.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLanguageColor(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return Colors.blue;
      case AppLanguage.hindi:
        return Colors.orange;
      case AppLanguage.telugu:
        return Colors.green;
    }
  }

  IconData _getLanguageIcon(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return Icons.language;
      case AppLanguage.hindi:
        return Icons.translate;
      case AppLanguage.telugu:
        return Icons.text_fields;
    }
  }

  void _saveLanguage() async {
    try {
      await _localizationService.setLanguage(_selectedLanguage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${_selectedLanguage.name}'),
          backgroundColor: Colors.green,
        ),
      );

      // Show restart dialog for better UX
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Language Changed'),
          content: const Text(
            'The app needs to restart to apply the language changes. Would you like to restart now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // In a real app, you might want to restart the app
                // For now, just go back
                Navigator.of(context).pop();
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change language'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
