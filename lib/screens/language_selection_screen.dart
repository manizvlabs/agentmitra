import 'package:flutter/material.dart';
import '../core/services/localization_service.dart';
import '../core/services/auth_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    // Set default selection to current locale
    _selectedLocale = LocalizationService().currentLocale;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(Locale locale) async {
    setState(() {
      _selectedLocale = locale;
    });

    // Update the app's locale
    final localizationService = LocalizationService();
    await localizationService.initialize(locale);

    // Update user preferences if authenticated
    final authService = AuthService();
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      // Update user's language preference
      // This would be implemented with user preferences service
      debugPrint('Updated user language preference to: ${locale.languageCode}');
    }

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${localizationService.getLocaleDisplayName(locale)}'
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back or to next screen
      Navigator.of(context).pop(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    final supportedLocales = localizationService.getSupportedLocalesInfo();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Select Language',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Choose your preferred language',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Select a language to continue using the app',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Language Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: supportedLocales.length,
                      itemBuilder: (context, index) {
                        final localeInfo = supportedLocales[index];
                        final locale = localeInfo['locale'] as Locale;
                        final displayName = localeInfo['displayName'] as String;
                        final flag = localeInfo['flag'] as String;
                        final isSelected = _selectedLocale == locale;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerColor.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: InkWell(
                            onTap: () => _selectLanguage(locale),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Flag emoji
                                  Text(
                                    flag,
                                    style: const TextStyle(fontSize: 32),
                                  ),

                                  const SizedBox(width: 16),

                                  // Language info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getLanguageDescription(locale),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selection indicator
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).dividerColor,
                                        width: 2,
                                      ),
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
                      },
                    ),
                  ),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedLocale != null
                          ? () => _selectLanguage(_selectedLocale!)
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip option (use system default)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Use system default locale
                        final deviceLocale = WidgetsBinding.instance.window.locale;
                        final bestMatch = LocalizationService().getBestMatchingLocale(deviceLocale);
                        _selectLanguage(bestMatch);
                      },
                      child: Text(
                        'Use device language',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageDescription(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English - Official language';
      case 'hi':
        return 'हिंदी - Official language';
      case 'te':
        return 'తెలుగు - Regional language';
      default:
        return 'Available language';
    }
  }
}