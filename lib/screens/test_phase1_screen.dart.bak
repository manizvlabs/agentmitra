import 'package:flutter/material.dart';
import '../core/services/localization_service.dart';
import '../core/widgets/error_pages/error_pages.dart';
import '../core/widgets/loading/loading_widgets.dart';

/// Test Screen for Phase 1 Components
/// Tests error pages, loading widgets, and localization
class TestPhase1Screen extends StatefulWidget {
  const TestPhase1Screen({super.key});

  @override
  State<TestPhase1Screen> createState() => _TestPhase1ScreenState();
}

class _TestPhase1ScreenState extends State<TestPhase1Screen> {
  final LocalizationService _localizationService = LocalizationService();
  AppLanguage _currentLanguage = AppLanguage.english;

  @override
  void initState() {
    super.initState();
    _initializeLocalization();
  }

  Future<void> _initializeLocalization() async {
    await _localizationService.initialize();
    setState(() {
      _currentLanguage = _localizationService.currentLanguage;
    });
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    await _localizationService.setLanguage(language);
    setState(() {
      _currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 1 Components Test'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language Selector
            _buildLanguageSelector(),
            const SizedBox(height: 24),

            // Current Language Display
            _buildCurrentLanguageDisplay(),
            const SizedBox(height: 24),

            // Localization Test
            _buildLocalizationTest(),
            const SizedBox(height: 24),

            // Error Pages Section
            _buildErrorPagesSection(),
            const SizedBox(height: 24),

            // Loading Widgets Section
            _buildLoadingWidgetsSection(),
            const SizedBox(height: 24),

            // Empty State Widgets Section
            _buildEmptyStateWidgetsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language Selector',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLanguageButton('English', AppLanguage.english),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLanguageButton('हिंदी', AppLanguage.hindi),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLanguageButton('తెలుగు', AppLanguage.telugu),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String label, AppLanguage language) {
    final isSelected = _currentLanguage == language;
    return ElevatedButton(
      onPressed: () => _changeLanguage(language),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
      ),
      child: Text(label),
    );
  }

  Widget _buildCurrentLanguageDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Language: ${_currentLanguage.name} (${_currentLanguage.code})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Locale: ${_currentLanguage.locale}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizationTest() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localization Test',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildLocalizedText('appName'),
            _buildLocalizedText('tagline'),
            _buildLocalizedText('home'),
            _buildLocalizedText('retry'),
            _buildLocalizedText('network_error'),
            _buildLocalizedText('network_error_message'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizedText(String key) {
    final text = _localizationService.getString(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$key:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Pages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildErrorPageButton(
                  'Network Error',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NetworkErrorPage(
                        onRetry: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Retry clicked')),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _buildErrorPageButton(
                  'Trial Expired',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrialExpiredPage()),
                  ),
                ),
                _buildErrorPageButton(
                  'Unauthorized',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UnauthorizedPage()),
                  ),
                ),
                _buildErrorPageButton(
                  'Not Found',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotFoundPage()),
                  ),
                ),
                _buildErrorPageButton(
                  'Server Error',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServerErrorPage(
                        onRetry: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Retry clicked')),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPageButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }

  Widget _buildLoadingWidgetsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loading Widgets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const LoadingCard(height: 100),
            const SizedBox(height: 16),
            const LoadingListItem(showAvatar: true, showSubtitle: true),
            const SizedBox(height: 8),
            const LoadingListItem(showAvatar: false, showSubtitle: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: SkeletonText(width: 100, height: 16)),
                const SizedBox(width: 16),
                Expanded(child: SkeletonText(width: 150, height: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SkeletonCircle(size: 48),
                const SizedBox(width: 16),
                Expanded(child: SkeletonCard(height: 80)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidgetsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empty State Widgets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: EmptyStateCard(
                icon: Icons.inbox_outlined,
                title: 'No Data Available',
                message: 'There are no items to display',
                actionLabel: 'Refresh',
                onAction: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Refresh clicked')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: EmptyStateWithRetry(
                icon: Icons.error_outline,
                title: 'Failed to Load',
                message: 'Something went wrong',
                onRetry: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Retry clicked')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

