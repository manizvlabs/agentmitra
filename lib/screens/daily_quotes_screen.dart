import 'package:flutter/material.dart';
import '../core/widgets/offline_indicator.dart';
import '../core/services/whatsapp_business_service.dart';
import '../core/services/feature_flag_service.dart';

/// Daily Motivational Quotes Screen for Agent App
/// Allows agents to create, edit, and share motivational quotes with clients
class DailyQuotesScreen extends StatefulWidget {
  const DailyQuotesScreen({super.key});

  @override
  State<DailyQuotesScreen> createState() => _DailyQuotesScreenState();
}

class _DailyQuotesScreenState extends State<DailyQuotesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final FeatureFlagService _featureFlagService = FeatureFlagService();
  late bool _whatsappEnabled;

  // Form state
  final _quoteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Initialize feature flags
    _initializeFeatureFlags();
  }

  Future<void> _initializeFeatureFlags() async {
    await _featureFlagService.initialize();
    _whatsappEnabled = await _featureFlagService.isFeatureEnabled('whatsapp_integration_enabled') ?? true;
    setState(() {}); // Trigger rebuild with feature flags
  }

  @override
  void dispose() {
    _animationController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quote Creation & Management Section
                  _buildQuoteCreationSection(),

                  const SizedBox(height: 24),

                  // Template Library Section
                  _buildTemplateLibrary(),

                  const SizedBox(height: 24),

                  // Send & Track Section
                  _buildSendAndTrackSection(),

                  const SizedBox(height: 24),

                  // Offline indicator
                  const OfflineIndicator(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Daily Motivational Quotes',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // TODO: Implement search
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Implement more options menu
          },
        ),
      ],
    );
  }

  Widget _buildQuoteCreationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Create/Edit Quote',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Quote Text',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quoteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your motivational quote here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Background Template',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildTemplateSelector(),
          const SizedBox(height: 16),
          const Text(
            'Agent Branding',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildBrandingOptions(),
        ],
      ),
    );
  }

  Widget _buildTemplateSelector() {
    final templates = [
      {'name': 'Classic White', 'color': Colors.white},
      {'name': 'Ocean Blue', 'color': Colors.blue.shade100},
      {'name': 'Sunset Orange', 'color': Colors.orange.shade100},
      {'name': 'Forest Green', 'color': Colors.green.shade100},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: template['color'] as Color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                template['name'] as String,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandingOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildBrandingOption(
            icon: Icons.business,
            label: 'Show Logo',
            isSelected: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBrandingOption(
            icon: Icons.phone,
            label: 'Show Contact',
            isSelected: false,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingOption({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.purple : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.purple : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.purple : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateLibrary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Template Library',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pre-designed quote templates with customizable backgrounds and branding integration.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildTemplateGrid(),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid() {
    final templates = [
      {'name': 'Motivation', 'icon': Icons.bolt, 'color': Colors.orange},
      {'name': 'Success', 'icon': Icons.star, 'color': Colors.yellow},
      {'name': 'Growth', 'icon': Icons.trending_up, 'color': Colors.green},
      {'name': 'Wisdom', 'icon': Icons.lightbulb, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (template['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (template['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                template['icon'] as IconData,
                size: 32,
                color: template['color'] as Color,
              ),
              const SizedBox(height: 8),
              Text(
                template['name'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSendAndTrackSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Send & Track',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSendOptions(),
          const SizedBox(height: 16),
          _buildTrackingInfo(),
        ],
      ),
    );
  }

  Widget _buildSendOptions() {
    final sendOptions = <Widget>[];

    // Send to All Clients - only show if WhatsApp is enabled
    if (_whatsappEnabled) {
      sendOptions.add(_buildSendOption(
        icon: Icons.group,
        title: 'Send to All Clients',
        subtitle: 'Broadcast to entire client database',
        onTap: () async {
          if (_quoteController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a quote first')),
            );
            return;
          }

          final success = await WhatsAppBusinessService.shareContent(
            content: '"${_quoteController.text}"\n\n- B.Sridhar\nYour LIC Agent',
            subject: 'Daily Motivational Quote',
          );

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quote shared successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to share quote')),
            );
          }
        },
      ));
    }

    // Send to Specific Groups
    sendOptions.add(const SizedBox(height: 12));
    sendOptions.add(_buildSendOption(
      icon: Icons.filter_list,
      title: 'Send to Specific Groups',
      subtitle: 'Target by age, profession, or custom segments',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group selection coming soon!')),
        );
      },
    ));

    // Send to Individual Clients - only show if WhatsApp is enabled
    sendOptions.add(const SizedBox(height: 12));
    if (_whatsappEnabled) {
      sendOptions.add(_buildSendOption(
        icon: Icons.person,
        title: 'Send to Individual Clients',
        subtitle: 'Select specific clients from your database',
        onTap: () async {
          if (_quoteController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a quote first')),
            );
            return;
          }

          // Show client selection dialog (placeholder for now)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Client'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Text('A')),
                    title: const Text('Amit Kumar'),
                    subtitle: const Text('+91 9876543210'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final success = await WhatsAppBusinessService.sendQuoteMessage(
                        phoneNumber: '+919876543210',
                        quote: _quoteController.text,
                        agentName: 'B.Sridhar',
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quote sent via WhatsApp!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to send WhatsApp message')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(child: Text('P')),
                    title: const Text('Priya Sharma'),
                    subtitle: const Text('+91 9876543211'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final success = await WhatsAppBusinessService.sendQuoteMessage(
                        phoneNumber: '+919876543211',
                        quote: _quoteController.text,
                        agentName: 'B.Sridhar',
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quote sent via WhatsApp!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to send WhatsApp message')),
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ));
    }

    return Column(children: sendOptions);
  }

  Widget _buildSendOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tracking System',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Monitor quote forwards and recipient information. Track client resharing analytics.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrackingStat('Sent', '0'),
              _buildTrackingStat('Forwarded', '0'),
              _buildTrackingStat('Viewed', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
