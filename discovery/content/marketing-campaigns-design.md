# Agent Mitra - Marketing Campaigns System Design

## 1. Marketing Campaigns Architecture Overview

### 1.1 Campaign System Philosophy

```
🎯 CAMPAIGN SYSTEM PHILOSOPHY

📊 Data-Driven Marketing → Personalized Communication → Revenue Growth

Core Principles:
├── 🎯 Customer-Centric - Campaigns based on customer data and behavior
├── 📱 Multi-Channel - WhatsApp, SMS, Email, In-App notifications
├── 🤖 Automation - Smart triggers and personalized messaging
├── 📈 Analytics-First - Measure everything, optimize continuously
├── 🎨 Creative Freedom - Templates + customization for agents
├── 💰 ROI Tracking - Every campaign tied to revenue metrics
└── 🔄 Continuous Learning - AI-powered campaign optimization
```

### 1.2 Campaign Types & Categories

```
📢 CAMPAIGN ECOSYSTEM

🎉 Acquisition Campaigns
├── Welcome Series - New customer onboarding
├── Referral Programs - Encourage customer referrals
├── Cross-sell Promotions - Additional policy offers
└── Seasonal Campaigns - Festival/special occasion offers

💎 Retention Campaigns
├── Renewal Reminders - Policy renewal notifications
├── Loyalty Programs - Reward long-term customers
├── Anniversary Celebrations - Policy milestone recognition
└── Re-engagement Campaigns - Win back lapsed customers

📈 Upselling Campaigns
├── Premium Upgrades - Higher coverage offers
├── Add-on Riders - Supplementary benefits
├── Investment Reviews - Portfolio optimization
└── Family Coverage - Extended family protection

🎯 Behavioral Campaigns
├── Birthday Campaigns - Personalized birthday wishes
├── Policy Anniversary - Policy milestone celebrations
├── Payment Reminders - Friendly payment nudges
└── Health Check-ups - Preventive care reminders
```

## 2. Campaign Management Dashboard

### 2.1 Campaign Creation Interface

#### Campaign Builder Implementation
```dart
class CampaignBuilderPage extends StatefulWidget {
  @override
  _CampaignBuilderPageState createState() => _CampaignBuilderPageState();
}

class _CampaignBuilderPageState extends State<CampaignBuilderPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Campaign data
  String _campaignName = '';
  String _campaignType = 'acquisition';
  String _campaignGoal = 'lead_generation';
  DateTimeRange? _campaignPeriod;
  double _budget = 0.0;
  String _targetAudience = 'all';

  // Content data
  String _messageType = 'whatsapp';
  String _subject = '';
  String _message = '';
  List<String> _attachments = [];

  // Targeting data
  List<String> _selectedSegments = [];
  Map<String, dynamic> _targetingRules = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Content'),
            Tab(text: 'Targeting'),
            Tab(text: 'Schedule'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildContentTab(),
          _buildTargetingTab(),
          _buildScheduleTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Campaign Name',
                hintText: 'Enter campaign name',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Campaign name is required';
                }
                return null;
              },
              onChanged: (value) => _campaignName = value,
            ),
            const SizedBox(height: 16),

            // Campaign Type
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Campaign Type',
              ),
              value: _campaignType,
              items: const [
                DropdownMenuItem(value: 'acquisition', child: Text('Customer Acquisition')),
                DropdownMenuItem(value: 'retention', child: Text('Customer Retention')),
                DropdownMenuItem(value: 'upselling', child: Text('Upselling')),
                DropdownMenuItem(value: 'behavioral', child: Text('Behavioral')),
              ],
              onChanged: (value) => setState(() => _campaignType = value ?? 'acquisition'),
            ),
            const SizedBox(height: 16),

            // Campaign Goal
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Campaign Goal',
              ),
              value: _campaignGoal,
              items: const [
                DropdownMenuItem(value: 'lead_generation', child: Text('Lead Generation')),
                DropdownMenuItem(value: 'policy_sales', child: Text('Policy Sales')),
                DropdownMenuItem(value: 'renewal_rate', child: Text('Improve Renewal Rate')),
                DropdownMenuItem(value: 'engagement', child: Text('Increase Engagement')),
              ],
              onChanged: (value) => setState(() => _campaignGoal = value ?? 'lead_generation'),
            ),
            const SizedBox(height: 16),

            // Budget
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Budget (₹)',
                hintText: '0.00',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _budget = double.tryParse(value) ?? 0.0,
            ),
            const SizedBox(height: 16),

            // Campaign Description
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Campaign Description',
                hintText: 'Brief description of the campaign',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message Type Selection
          Text(
            'Message Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMessageTypeCard('WhatsApp', Icons.message, 'whatsapp'),
              const SizedBox(width: 12),
              _buildMessageTypeCard('SMS', Icons.sms, 'sms'),
              const SizedBox(width: 12),
              _buildMessageTypeCard('Email', Icons.email, 'email'),
            ],
          ),
          const SizedBox(height: 24),

          // Message Content
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Subject/Headline',
              hintText: 'Enter subject line',
            ),
            onChanged: (value) => _subject = value,
          ),
          const SizedBox(height: 16),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Message Content',
              hintText: 'Enter your message',
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            onChanged: (value) => _message = value,
          ),
          const SizedBox(height: 16),

          // Personalization Tags
          _buildPersonalizationTags(),

          const SizedBox(height: 24),

          // Attachments/Media
          _buildAttachmentsSection(),

          const SizedBox(height: 24),

          // Preview
          _buildMessagePreview(),
        ],
      ),
    );
  }

  Widget _buildMessageTypeCard(String title, IconData icon, String type) {
    final isSelected = _messageType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _messageType = type),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizationTags() {
    final tags = ['{{customer_name}}', '{{policy_number}}', '{{premium_amount}}', '{{due_date}}'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalization Tags',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) => _buildTagChip(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return InkWell(
      onTap: () {
        // Insert tag into message
        setState(() {
          _message += tag;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _addAttachment,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_attachments.isEmpty)
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text('No attachments added'),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _attachments.map((attachment) => _buildAttachmentChip(attachment)).toList(),
          ),
      ],
    );
  }

  Widget _buildAttachmentChip(String attachment) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image, size: 16),
          const SizedBox(width: 4),
          Text(attachment.split('/').last),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _attachments.remove(attachment)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message Preview',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_subject.isNotEmpty) ...[
                Text(
                  _subject,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
              ],
              Text(_message.isNotEmpty ? _message : 'Your message will appear here...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Audience
          Text(
            'Target Audience',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Quick audience selection
          Row(
            children: [
              _buildAudienceCard('All Customers', 'all', Icons.people),
              const SizedBox(width: 12),
              _buildAudienceCard('Active Policyholders', 'active', Icons.verified_user),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAudienceCard('Lapsed Customers', 'lapsed', Icons.warning),
              const SizedBox(width: 12),
              _buildAudienceCard('Prospects', 'prospects', Icons.person_add),
            ],
          ),

          const SizedBox(height: 24),

          // Advanced targeting
          Text(
            'Advanced Targeting',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Customer segments
          _buildSegmentSelection(),

          const SizedBox(height: 24),

          // Behavioral targeting
          _buildBehavioralTargeting(),

          const SizedBox(height: 24),

          // Estimated reach
          _buildEstimatedReach(),
        ],
      ),
    );
  }

  Widget _buildAudienceCard(String title, String value, IconData icon) {
    final isSelected = _targetAudience == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _targetAudience = value),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Segments',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'High Value Customers',
            'New Customers',
            'Birthday This Month',
            'Policy Renewing Soon',
            'Inactive Users',
            'Cross-sell Opportunities',
          ].map((segment) => _buildSegmentChip(segment)).toList(),
        ),
      ],
    );
  }

  Widget _buildSegmentChip(String segment) {
    final isSelected = _selectedSegments.contains(segment);
    return FilterChip(
      label: Text(segment),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedSegments.add(segment);
          } else {
            _selectedSegments.remove(segment);
          }
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBehavioralTargeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Behavioral Targeting',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Days since last interaction
              Row(
                children: [
                  const Expanded(child: Text('Days since last interaction:')),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: '30',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Engagement score
              Row(
                children: [
                  const Expanded(child: Text('Minimum engagement score:')),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: '50',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedReach() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Estimated Reach',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildReachMetric('Target Audience', '2,450'),
              _buildReachMetric('Estimated Reach', '1,850'),
              _buildReachMetric('Estimated Response', '12.5%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReachMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign timing
          Text(
            'Campaign Schedule',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Send timing options
          Column(
            children: [
              RadioListTile<String>(
                title: const Text('Send Immediately'),
                value: 'immediate',
                groupValue: 'schedule_type',
                onChanged: (value) {},
              ),
              RadioListTile<String>(
                title: const Text('Schedule for later'),
                value: 'scheduled',
                groupValue: 'schedule_type',
                onChanged: (value) {},
              ),
              RadioListTile<String>(
                title: const Text('Automated trigger'),
                value: 'automated',
                groupValue: 'schedule_type',
                onChanged: (value) {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date and time picker (shown when scheduled is selected)
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Send Date & Time',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  // Handle date and time selection
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Automation rules (shown when automated is selected)
          Text(
            'Automation Triggers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Trigger options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Policy Renewal Due',
              'Birthday',
              'Payment Overdue',
              'New Policy Purchased',
              'Customer Inquiry',
              'Custom Event',
            ].map((trigger) => _buildTriggerChip(trigger)).toList(),
          ),

          const SizedBox(height: 24),

          // A/B Testing
          _buildABTestingSection(),

          const SizedBox(height: 24),

          // Campaign budget tracking
          _buildBudgetTracking(),
        ],
      ),
    );
  }

  Widget _buildTriggerChip(String trigger) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Text(
        trigger,
        style: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildABTestingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'A/B Testing',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Switch(value: false, onChanged: (value) {}),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Test different versions of your message to optimize performance',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTracking() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget & Cost Estimation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Cost:'),
              Text('₹${(_budget * 0.15).toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cost per recipient:'),
              Text('₹${(_budget * 0.15 / 1850).toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Save Draft',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAndLaunchCampaign,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Launch Campaign'),
            ),
          ),
        ],
      ),
    );
  }

  void _addAttachment() {
    // Implement attachment picker
  }

  void _saveAndLaunchCampaign() {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement campaign saving and launching
      Navigator.pop(context);
    }
  }
}
```

### 2.2 Campaign Analytics Dashboard

#### Campaign Performance Analytics Implementation
```dart
class CampaignAnalyticsPage extends StatefulWidget {
  final String campaignId;

  const CampaignAnalyticsPage({Key? key, required this.campaignId}) : super(key: key);

  @override
  _CampaignAnalyticsPageState createState() => _CampaignAnalyticsPageState();
}

class _CampaignAnalyticsPageState extends State<CampaignAnalyticsPage> {
  late CampaignAnalytics _analytics;
  bool _isLoading = true;
  String _selectedMetric = 'overview';

  @override
  void initState() {
    super.initState();
    _loadCampaignAnalytics();
  }

  Future<void> _loadCampaignAnalytics() async {
    try {
      _analytics = await CampaignService.getCampaignAnalytics(widget.campaignId);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_analytics.campaignName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign overview
              _buildCampaignOverview(),

              const SizedBox(height: 24),

              // Key metrics
              _buildKeyMetrics(),

              const SizedBox(height: 24),

              // Performance charts
              _buildPerformanceCharts(),

              const SizedBox(height: 24),

              // Channel breakdown
              _buildChannelBreakdown(),

              const SizedBox(height: 24),

              // Customer responses
              _buildCustomerResponses(),

              const SizedBox(height: 24),

              // ROI analysis
              _buildROISection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _analytics.campaignName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _analytics.campaignType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_analytics.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  _analytics.status.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildOverviewMetric('Sent', _analytics.totalSent.toString()),
              _buildOverviewMetric('Delivered', '${_analytics.deliveryRate}%'),
              _buildOverviewMetric('Opened', '${_analytics.openRate}%'),
              _buildOverviewMetric('Clicked', '${_analytics.clickRate}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'draft':
        return Colors.grey;
      case 'paused':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            '₹${_analytics.totalRevenue}',
            Icons.currency_rupee,
            Colors.green,
            '+${_analytics.revenueGrowth}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Conversion Rate',
            '${_analytics.conversionRate}%',
            Icons.trending_up,
            Colors.blue,
            '${_analytics.conversionChange}%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const Spacer(),
              Text(
                change,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Over Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Performance chart placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Performance Trend Chart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Channel Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._analytics.channelBreakdown.map((channel) =>
            _buildChannelRow(channel)
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow(ChannelMetrics channel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${channel.sent} sent • ${channel.delivered} delivered',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${channel.responseRate}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Response Rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerResponses() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Responses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._analytics.customerResponses.take(5).map((response) =>
            _buildResponseItem(response)
          ),
          if (_analytics.customerResponses.length > 5)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/all-responses'),
              child: Text(
                'View All Responses',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponseItem(CustomerResponse response) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(response.customerName.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  response.customerName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  response.response,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                response.responseType,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getResponseTypeColor(response.responseType),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTimeAgo(response.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getResponseTypeColor(String responseType) {
    switch (responseType.toLowerCase()) {
      case 'interested':
        return Colors.green;
      case 'question':
        return Colors.blue;
      case 'complaint':
        return Colors.red;
      case 'unsubscribe':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildROISection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: BorderRadius.circular(8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign ROI Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildROIMetric(
                  'Total Investment',
                  '₹${_analytics.totalInvestment}',
                  'Campaign cost',
                ),
              ),
              Expanded(
                child: _buildROIMetric(
                  'Revenue Generated',
                  '₹${_analytics.revenueGenerated}',
                  'From campaign',
                ),
              ),
              Expanded(
                child: _buildROIMetric(
                  'ROI',
                  '${_analytics.roi}%',
                  _analytics.roi > 100 ? 'Profitable' : 'Not profitable',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _analytics.roi / 200, // Assuming 200% is max for visualization
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _analytics.roi > 100 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Break-even point: ₹${_analytics.breakEvenAmount}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROIMetric(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _shareAnalytics() {
    // Implement analytics sharing
  }

  void _exportAnalytics() {
    // Implement analytics export
  }
}
```

## 3. Campaign Automation Engine

### 3.1 Smart Campaign Triggers

#### Campaign Automation Service Implementation
```python
# campaign_automation.py
from typing import Dict, List, Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func

from models.campaign import Campaign, CampaignTrigger
from models.customer import Customer
from models.policy import Policy
from models.event import CustomerEvent
from services.messaging import MessagingService

class CampaignAutomationService:
    """Service for automating campaign execution based on triggers"""

    @staticmethod
    def process_customer_events() -> Dict[str, int]:
        """
        Process customer events and trigger relevant campaigns

        Returns:
            Dict with trigger counts and results
        """
        results = {
            'triggers_processed': 0,
            'campaigns_triggered': 0,
            'messages_sent': 0,
            'errors': 0,
        }

        with Session() as session:
            # Get unprocessed events from the last hour
            one_hour_ago = datetime.now() - timedelta(hours=1)
            unprocessed_events = session.query(CustomerEvent).filter(
                and_(
                    CustomerEvent.created_at >= one_hour_ago,
                    CustomerEvent.processed == False
                )
            ).all()

            for event in unprocessed_events:
                try:
                    triggered_campaigns = CampaignAutomationService._process_event(
                        session, event
                    )
                    results['campaigns_triggered'] += len(triggered_campaigns)
                    results['triggers_processed'] += 1

                    # Mark event as processed
                    event.processed = True
                    session.commit()

                except Exception as e:
                    print(f"Error processing event {event.id}: {e}")
                    results['errors'] += 1

        return results

    @staticmethod
    def _process_event(session: Session, event: CustomerEvent) -> List[Campaign]:
        """Process a single customer event and return triggered campaigns"""
        triggered_campaigns = []

        # Find active campaigns with matching triggers
        active_campaigns = session.query(Campaign).filter(
            and_(
                Campaign.status == 'active',
                Campaign.is_automated == True
            )
        ).all()

        for campaign in active_campaigns:
            if CampaignAutomationService._matches_campaign_trigger(
                session, campaign, event
            ):
                # Execute campaign for this customer
                CampaignAutomationService._execute_campaign_for_customer(
                    session, campaign, event.customer_id
                )
                triggered_campaigns.append(campaign)

        return triggered_campaigns

    @staticmethod
    def _matches_campaign_trigger(session: Session, campaign: Campaign,
                                event: CustomerEvent) -> bool:
        """Check if event matches campaign trigger conditions"""
        # Get campaign triggers
        triggers = session.query(CampaignTrigger).filter(
            CampaignTrigger.campaign_id == campaign.id
        ).all()

        for trigger in triggers:
            if CampaignAutomationService._evaluate_trigger_condition(
                session, trigger, event
            ):
                return True

        return False

    @staticmethod
    def _evaluate_trigger_condition(session: Session, trigger: CampaignTrigger,
                                  event: CustomerEvent) -> bool:
        """Evaluate if a trigger condition is met"""
        condition_matched = False

        if trigger.trigger_type == 'event_type':
            condition_matched = event.event_type == trigger.trigger_value

        elif trigger.trigger_type == 'policy_renewal':
            # Check if customer has policy renewing within trigger timeframe
            days_ahead = int(trigger.trigger_value)
            renewal_date = datetime.now() + timedelta(days=days_ahead)

            policy_count = session.query(func.count(Policy.id)).filter(
                and_(
                    Policy.customer_id == event.customer_id,
                    Policy.renewal_date <= renewal_date,
                    Policy.renewal_date >= datetime.now(),
                    Policy.status == 'active'
                )
            ).scalar()

            condition_matched = policy_count > 0

        elif trigger.trigger_type == 'birthday':
            # Check if it's customer's birthday month
            customer = session.query(Customer).filter(
                Customer.id == event.customer_id
            ).first()

            if customer and customer.date_of_birth:
                condition_matched = (
                    customer.date_of_birth.month == datetime.now().month and
                    customer.date_of_birth.day == datetime.now().day
                )

        elif trigger.trigger_type == 'payment_overdue':
            # Check if customer has overdue payments
            overdue_count = session.query(func.count(Payment.id)).join(Policy).filter(
                and_(
                    Policy.customer_id == event.customer_id,
                    Payment.status == 'overdue',
                    Payment.due_date < datetime.now()
                )
            ).scalar()

            condition_matched = overdue_count > 0

        elif trigger.trigger_type == 'engagement_score':
            # Check customer's engagement score
            customer = session.query(Customer).filter(
                Customer.id == event.customer_id
            ).first()

            if customer:
                min_score = int(trigger.trigger_value)
                condition_matched = customer.engagement_score >= min_score

        elif trigger.trigger_type == 'inactive_days':
            # Check days since last interaction
            max_days = int(trigger.trigger_value)

            last_interaction = session.query(func.max(CustomerEvent.created_at)).filter(
                CustomerEvent.customer_id == event.customer_id
            ).scalar()

            if last_interaction:
                days_since = (datetime.now() - last_interaction).days
                condition_matched = days_since >= max_days

        # Apply any additional conditions
        if condition_matched and trigger.additional_conditions:
            condition_matched = CampaignAutomationService._evaluate_additional_conditions(
                session, trigger, event
            )

        return condition_matched

    @staticmethod
    def _evaluate_additional_conditions(session: Session, trigger: CampaignTrigger,
                                      event: CustomerEvent) -> bool:
        """Evaluate additional trigger conditions"""
        conditions = trigger.additional_conditions

        # Example: Check customer segment
        if 'segment' in conditions:
            customer = session.query(Customer).filter(
                Customer.id == event.customer_id
            ).first()

            if customer and customer.segment != conditions['segment']:
                return False

        # Example: Check policy type
        if 'policy_type' in conditions:
            policy_count = session.query(func.count(Policy.id)).filter(
                and_(
                    Policy.customer_id == event.customer_id,
                    Policy.policy_type == conditions['policy_type'],
                    Policy.status == 'active'
                )
            ).scalar()

            if policy_count == 0:
                return False

        return True

    @staticmethod
    def _execute_campaign_for_customer(session: Session, campaign: Campaign,
                                     customer_id: int) -> bool:
        """Execute a campaign for a specific customer"""
        try:
            # Get customer details
            customer = session.query(Customer).filter(
                Customer.id == customer_id
            ).first()

            if not customer:
                return False

            # Personalize campaign content
            personalized_content = CampaignAutomationService._personalize_content(
                campaign, customer
            )

            # Send campaign message
            success = MessagingService.send_campaign_message(
                campaign=campaign,
                customer=customer,
                content=personalized_content
            )

            if success:
                # Log campaign execution
                campaign_execution = CampaignExecution(
                    campaign_id=campaign.id,
                    customer_id=customer_id,
                    executed_at=datetime.now(),
                    status='sent',
                    channel=campaign.primary_channel
                )
                session.add(campaign_execution)
                session.commit()

            return success

        except Exception as e:
            print(f"Error executing campaign {campaign.id} for customer {customer_id}: {e}")
            return False

    @staticmethod
    def _personalize_content(campaign: Campaign, customer: Customer) -> Dict:
        """Personalize campaign content with customer data"""
        content = {
            'subject': campaign.subject,
            'message': campaign.message,
            'channel': campaign.primary_channel,
        }

        # Replace personalization tags
        replacements = {
            '{{customer_name}}': customer.name,
            '{{customer_phone}}': customer.phone_number,
            '{{customer_email}}': customer.email or '',
        }

        # Get customer's active policies for personalization
        with Session() as session:
            active_policies = session.query(Policy).filter(
                and_(
                    Policy.customer_id == customer.id,
                    Policy.status == 'active'
                )
            ).all()

            if active_policies:
                # Use primary policy for personalization
                primary_policy = active_policies[0]
                replacements.update({
                    '{{policy_number}}': primary_policy.policy_number,
                    '{{policy_type}}': primary_policy.policy_type,
                    '{{premium_amount}}': str(primary_policy.premium_amount),
                    '{{next_due_date}}': primary_policy.next_due_date.strftime('%d/%m/%Y') if primary_policy.next_due_date else '',
                })

        # Apply replacements
        for key, value in replacements.items():
            content['subject'] = content['subject'].replace(key, value)
            content['message'] = content['message'].replace(key, value)

        return content

    @staticmethod
    def schedule_campaign_execution(campaign_id: int, customer_ids: List[int]) -> Dict[str, int]:
        """
        Schedule campaign execution for multiple customers

        Args:
            campaign_id: Campaign to execute
            customer_ids: List of customer IDs to target

        Returns:
            Dict with execution results
        """
        results = {
            'scheduled': 0,
            'failed': 0,
            'duplicates': 0,
        }

        with Session() as session:
            campaign = session.query(Campaign).filter(
                Campaign.id == campaign_id
            ).first()

            if not campaign:
                results['failed'] = len(customer_ids)
                return results

            for customer_id in customer_ids:
                try:
                    # Check for duplicate executions (avoid spam)
                    existing_execution = session.query(CampaignExecution).filter(
                        and_(
                            CampaignExecution.campaign_id == campaign_id,
                            CampaignExecution.customer_id == customer_id,
                            CampaignExecution.executed_at >= datetime.now() - timedelta(hours=24)
                        )
                    ).first()

                    if existing_execution:
                        results['duplicates'] += 1
                        continue

                    # Schedule execution
                    scheduled_execution = CampaignExecution(
                        campaign_id=campaign_id,
                        customer_id=customer_id,
                        scheduled_for=datetime.now(),  # Immediate execution
                        status='scheduled',
                        channel=campaign.primary_channel
                    )
                    session.add(scheduled_execution)
                    results['scheduled'] += 1

                except Exception as e:
                    print(f"Error scheduling campaign for customer {customer_id}: {e}")
                    results['failed'] += 1

            session.commit()

        return results

    @staticmethod
    def get_campaign_recommendations(agent_id: int) -> List[Dict]:
        """
        Get personalized campaign recommendations for an agent

        Args:
            agent_id: Agent identifier

        Returns:
            List of recommended campaign configurations
        """
        recommendations = []

        with Session() as session:
            # Analyze agent's customer base and performance
            customer_stats = CampaignAutomationService._analyze_customer_base(
                session, agent_id
            )

            # Generate recommendations based on analysis
            if customer_stats['lapsed_customers'] > 0:
                recommendations.append({
                    'type': 'retention',
                    'title': 'Re-engagement Campaign',
                    'description': f'Reach out to {customer_stats["lapsed_customers"]} lapsed customers',
                    'target_audience': 'lapsed_customers',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['lapsed_customers'],
                    'potential_roi': '25-40%',
                })

            if customer_stats['birthday_customers'] > 0:
                recommendations.append({
                    'type': 'behavioral',
                    'title': 'Birthday Celebration',
                    'description': f'Wish {customer_stats["birthday_customers"]} customers this month',
                    'target_audience': 'birthday_this_month',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['birthday_customers'],
                    'potential_roi': '15-30%',
                })

            if customer_stats['renewal_due'] > 0:
                recommendations.append({
                    'type': 'retention',
                    'title': 'Renewal Reminder',
                    'description': f'Remind {customer_stats["renewal_due"]} customers about upcoming renewals',
                    'target_audience': 'renewal_due_30_days',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['renewal_due'],
                    'potential_roi': '35-50%',
                })

            if customer_stats['cross_sell_opportunities'] > 0:
                recommendations.append({
                    'type': 'upselling',
                    'title': 'Cross-sell Campaign',
                    'description': f'Identify upsell opportunities for {customer_stats["cross_sell_opportunities"]} customers',
                    'target_audience': 'single_policy_customers',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['cross_sell_opportunities'],
                    'potential_roi': '20-35%',
                })

        return recommendations

    @staticmethod
    def _analyze_customer_base(session: Session, agent_id: int) -> Dict:
        """Analyze agent's customer base for campaign recommendations"""
        # Lapsed customers (no activity in 90 days)
        lapsed_cutoff = datetime.now() - timedelta(days=90)
        lapsed_customers = session.query(func.count(func.distinct(Customer.id))).join(Policy).filter(
            and_(
                Policy.agent_id == agent_id,
                Policy.status == 'lapsed',
                Policy.lapse_date >= lapsed_cutoff
            )
        ).scalar() or 0

        # Birthday customers this month
        current_month = datetime.now().month
        birthday_customers = session.query(func.count(Customer.id)).join(Policy).filter(
            and_(
                Policy.agent_id == agent_id,
                func.extract('month', Customer.date_of_birth) == current_month,
                Policy.status == 'active'
            )
        ).scalar() or 0

        # Renewal due in next 30 days
        renewal_cutoff = datetime.now() + timedelta(days=30)
        renewal_due = session.query(func.count(func.distinct(Policy.customer_id))).filter(
            and_(
                Policy.agent_id == agent_id,
                Policy.renewal_date <= renewal_cutoff,
                Policy.renewal_date >= datetime.now(),
                Policy.status == 'active'
            )
        ).scalar() or 0

        # Cross-sell opportunities (customers with only 1 policy)
        cross_sell_opportunities = session.query(func.count(func.distinct(Policy.customer_id))).filter(
            and_(
                Policy.agent_id == agent_id,
                Policy.status == 'active'
            )
        ).group_by(Policy.customer_id).having(func.count(Policy.id) == 1).count()

        return {
            'lapsed_customers': lapsed_customers,
            'birthday_customers': birthday_customers,
            'renewal_due': renewal_due,
            'cross_sell_opportunities': cross_sell_opportunities,
        }
```

## 4. Campaign Templates & A/B Testing

### 4.1 Campaign Template System

#### Campaign Template Library Implementation
```dart
class CampaignTemplateLibrary extends StatefulWidget {
  @override
  _CampaignTemplateLibraryState createState() => _CampaignTemplateLibraryState();
}

class _CampaignTemplateLibraryState extends State<CampaignTemplateLibrary> {
  late List<CampaignTemplate> _templates;
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      _templates = await CampaignService.getTemplates();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Templates'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),

          // Templates grid
          Expanded(
            child: _buildTemplatesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip('All', 'all'),
            const SizedBox(width: 8),
            _buildCategoryChip('Acquisition', 'acquisition'),
            const SizedBox(width: 8),
            _buildCategoryChip('Retention', 'retention'),
            const SizedBox(width: 8),
            _buildCategoryChip('Upselling', 'upselling'),
            const SizedBox(width: 8),
            _buildCategoryChip('Behavioral', 'behavioral'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedCategory = category),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTemplatesGrid() {
    final filteredTemplates = _selectedCategory == 'all'
        ? _templates
        : _templates.where((template) => template.category == _selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(filteredTemplates[index]);
      },
    );
  }

  Widget _buildTemplateCard(CampaignTemplate template) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(template.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(template.category),
                  size: 32,
                  color: _getCategoryColor(template.category),
                ),
              ),
              const SizedBox(height: 12),

              // Template name
              Text(
                template.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Template description
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Template stats
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${template.usageCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${template.avgROI}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'acquisition':
        return Colors.blue;
      case 'retention':
        return Colors.green;
      case 'upselling':
        return Colors.orange;
      case 'behavioral':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'acquisition':
        return Icons.person_add;
      case 'retention':
        return Icons.refresh;
      case 'upselling':
        return Icons.trending_up;
      case 'behavioral':
        return Icons.celebration;
      default:
        return Icons.campaign;
    }
  }

  void _useTemplate(CampaignTemplate template) {
    // Navigate to campaign builder with pre-filled template data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignBuilderPage(template: template),
      ),
    );
  }
}
```

## 5. Campaign System Summary

This comprehensive Marketing Campaigns system provides:

### 🎯 **Key Features**
- **Multi-channel campaign management** across WhatsApp, SMS, Email
- **Advanced targeting** with customer segmentation and behavioral rules
- **Campaign automation** with smart triggers and personalized messaging
- **Real-time analytics** with ROI tracking and performance insights
- **A/B testing** for campaign optimization
- **Template library** with proven campaign structures

### 📊 **Campaign Types**
- **Acquisition campaigns** for new customer onboarding
- **Retention campaigns** to reduce churn and improve loyalty
- **Upselling campaigns** for cross-selling and premium upgrades
- **Behavioral campaigns** for personalized customer engagement

### 🤖 **Automation Capabilities**
- **Event-triggered campaigns** based on customer behavior
- **Personalized messaging** with dynamic content insertion
- **Smart scheduling** with optimal send times
- **Automated follow-ups** for better conversion rates

### 📈 **Analytics & Optimization**
- **Real-time performance tracking** with detailed metrics
- **ROI calculation** for campaign profitability analysis
- **Customer response analysis** for engagement insights
- **A/B testing framework** for continuous improvement

### 🔧 **Technical Implementation**
- **Template-based campaign creation** with drag-and-drop interface
- **Advanced segmentation engine** with behavioral targeting
- **Multi-channel delivery system** with failover mechanisms
- **Real-time analytics dashboard** with predictive insights

This Marketing Campaign system transforms traditional agent-customer communication into a sophisticated, data-driven marketing engine that maximizes revenue while ensuring personalized, timely customer engagement.
