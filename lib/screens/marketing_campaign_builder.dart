import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../features/campaigns/presentation/viewmodels/campaign_viewmodel.dart';
import '../features/campaigns/data/models/campaign_model.dart';

class MarketingCampaignBuilder extends StatefulWidget {
  final Campaign? existingCampaign;

  const MarketingCampaignBuilder({super.key, this.existingCampaign});

  @override
  State<MarketingCampaignBuilder> createState() => _MarketingCampaignBuilderState();
}

class _MarketingCampaignBuilderState extends State<MarketingCampaignBuilder>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CampaignViewModel _viewModel = CampaignViewModel();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _campaignType = 'acquisition';
  String? _campaignGoal;
  String _primaryChannel = 'whatsapp';
  List<String> _selectedChannels = ['whatsapp'];

  // Content Controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _messageTemplateId;
  List<String> _personalizationTags = [];
  Map<String, dynamic>? _attachments;
  final TextEditingController _tagController = TextEditingController();

  // Targeting Controllers
  String _targetAudience = 'all';
  List<String> _selectedSegments = [];
  Map<String, dynamic>? _targetingRules;
  int _estimatedReach = 0;

  // Schedule Controllers
  String _scheduleType = 'immediate';
  DateTime? _scheduledAt;
  DateTimeRange? _dateRange;
  bool _isAutomated = false;
  Map<String, dynamic>? _automationTriggers;

  // Budget & A/B Testing
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();
  bool _abTestingEnabled = false;
  Map<String, dynamic>? _abTestVariants;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeFromExisting();
    _viewModel.initialize();
  }

  void _initializeFromExisting() {
    if (widget.existingCampaign != null) {
      final campaign = widget.existingCampaign!;
      _campaignNameController.text = campaign.campaignName;
      _descriptionController.text = campaign.description ?? '';
      _campaignType = campaign.campaignType;
      _campaignGoal = campaign.campaignGoal;
      _subjectController.text = campaign.subject ?? '';
      _messageController.text = campaign.message;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _campaignNameController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _budgetController.dispose();
    _estimatedCostController.dispose();
    _tagController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Campaign Builder',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1a237e),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1a237e),
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Content'),
            Tab(text: 'Targeting'),
            Tab(text: 'Schedule'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _showPreview,
            child: const Text(
              'Preview',
              style: TextStyle(color: Color(0xFF1a237e)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildContentTab(),
            _buildTargetingTab(),
            _buildScheduleTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _campaignNameController,
            decoration: const InputDecoration(
              labelText: 'Campaign Name *',
              hintText: 'March Renewal Drive',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.campaign),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Campaign name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Brief description of the campaign',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _campaignType,
            decoration: const InputDecoration(
              labelText: 'Campaign Type *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: const [
              DropdownMenuItem(value: 'acquisition', child: Text('Acquisition')),
              DropdownMenuItem(value: 'retention', child: Text('Retention')),
              DropdownMenuItem(value: 'upselling', child: Text('Upselling')),
              DropdownMenuItem(value: 'behavioral', child: Text('Behavioral')),
            ],
            onChanged: (value) => setState(() => _campaignType = value!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _campaignGoal,
            decoration: const InputDecoration(
              labelText: 'Campaign Goal',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            items: const [
              DropdownMenuItem(value: 'lead_generation', child: Text('Lead Generation')),
              DropdownMenuItem(value: 'conversion', child: Text('Conversion')),
              DropdownMenuItem(value: 'engagement', child: Text('Engagement')),
              DropdownMenuItem(value: 'awareness', child: Text('Awareness')),
            ],
            onChanged: (value) => setState(() => _campaignGoal = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _primaryChannel,
            decoration: const InputDecoration(
              labelText: 'Primary Channel *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.chat),
            ),
            items: const [
              DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
              DropdownMenuItem(value: 'sms', child: Text('SMS')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
            ],
            onChanged: (value) => setState(() => _primaryChannel = value!),
          ),
          const SizedBox(height: 16),
          const Text(
            'Additional Channels',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['whatsapp', 'sms', 'email'].map((channel) {
              final isSelected = _selectedChannels.contains(channel);
              return FilterChip(
                label: Text(channel.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedChannels.add(channel);
                    } else {
                      _selectedChannels.remove(channel);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject Line',
              hintText: 'Your Policy Renewal is Due!',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subject),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message Content *',
              hintText: 'Enter your campaign message...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            validator: (value) => value?.isEmpty ?? true ? 'Message is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Add Personalization Tag',
                    hintText: 'e.g., {{customer_name}}',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addPersonalizationTag,
                color: const Color(0xFF1a237e),
              ),
            ],
          ),
          if (_personalizationTags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _personalizationTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() => _personalizationTags.remove(tag));
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Available Tags',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '{{customer_name}}',
              '{{policy_number}}',
              '{{due_date}}',
              '{{premium_amount}}',
              '{{agent_name}}',
            ].map((tag) {
              return ActionChip(
                label: Text(tag),
                onPressed: () {
                  setState(() {
                    if (!_personalizationTags.contains(tag)) {
                      _personalizationTags.add(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Attachments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addAttachment,
            icon: const Icon(Icons.attach_file),
            label: const Text('Add Attachment'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Message Preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_subjectController.text.isNotEmpty)
                  Text(
                    _subjectController.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                Text(_messageController.text.isEmpty
                    ? 'Your message preview will appear here...'
                    : _messageController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _targetAudience,
            decoration: const InputDecoration(
              labelText: 'Target Audience',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Customers')),
              DropdownMenuItem(value: 'segment', child: Text('Specific Segments')),
              DropdownMenuItem(value: 'custom', child: Text('Custom Rules')),
            ],
            onChanged: (value) => setState(() => _targetAudience = value!),
          ),
          const SizedBox(height: 16),
          const Text(
            'Customer Segments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'High Value (AOV > ₹5,000)',
              'Regular Payers (100% payment)',
              'New Customers (< 6 months)',
              'Premium Due Soon',
              'Lapsed Policies',
              'Renewal Due',
            ].map((segment) {
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
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Behavioral Targeting',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: const Text('Last Login > 30 days ago'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('No purchases in last 90 days'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: const Text('Opened previous campaigns'),
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Estimated Reach',
              hintText: '0',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people_outline),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _estimatedReach = int.tryParse(value) ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _scheduleType,
            decoration: const InputDecoration(
              labelText: 'Schedule Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule),
            ),
            items: const [
              DropdownMenuItem(value: 'immediate', child: Text('Send Immediately')),
              DropdownMenuItem(value: 'scheduled', child: Text('Schedule for Later')),
              DropdownMenuItem(value: 'recurring', child: Text('Recurring')),
            ],
            onChanged: (value) => setState(() => _scheduleType = value!),
          ),
          if (_scheduleType == 'scheduled') ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Scheduled Date & Time'),
              subtitle: Text(_scheduledAt != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_scheduledAt!)
                  : 'Not set'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectScheduledDate,
            ),
          ],
          if (_scheduleType == 'recurring') ...[
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              subtitle: Text(_dateRange != null
                  ? '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}'
                  : 'Not set'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDateRange,
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Automated Campaign'),
            subtitle: const Text('Enable trigger-based automation'),
            value: _isAutomated,
            onChanged: (value) => setState(() => _isAutomated = value),
          ),
          const SizedBox(height: 16),
          const Text(
            'Budget & Cost',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Budget (₹)',
              hintText: '0.00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _estimatedCostController,
            decoration: const InputDecoration(
              labelText: 'Estimated Cost (₹)',
              hintText: '0.00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calculate),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('A/B Testing'),
            subtitle: const Text('Enable A/B testing for this campaign'),
            value: _abTestingEnabled,
            onChanged: (value) => setState(() => _abTestingEnabled = value),
          ),
          if (_abTestingEnabled) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A/B Test Variants',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Variant A (50%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Variant B (50%)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saveDraft,
              icon: const Icon(Icons.save),
              label: const Text('Save Draft'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF1a237e)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _sendTest,
              icon: const Icon(Icons.send),
              label: const Text('Send Test'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.green),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _launchCampaign,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Launch Campaign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addPersonalizationTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        if (!_personalizationTags.contains(_tagController.text)) {
          _personalizationTags.add(_tagController.text);
          _tagController.clear();
        }
      });
    }
  }

  void _addAttachment() {
    // TODO: Implement file picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachment feature coming soon')),
    );
  }

  void _selectScheduledDate() async {
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
        setState(() {
          _scheduledAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campaign Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${_campaignNameController.text}'),
              Text('Type: $_campaignType'),
              Text('Subject: ${_subjectController.text}'),
              const SizedBox(height: 8),
              Text('Message: ${_messageController.text}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final success = await _viewModel.createCampaign(_buildCampaignData());
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign saved as draft')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage ?? 'Failed to save campaign')),
      );
    }
  }

  Future<void> _sendTest() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test message feature coming soon')),
    );
  }

  Future<void> _launchCampaign() async {
    if (!_formKey.currentState!.validate()) {
      _tabController.animateTo(0);
      return;
    }

    final campaignData = _buildCampaignData();
    final success = await _viewModel.createCampaign(campaignData);
    if (success && _viewModel.campaigns.isNotEmpty) {
      final campaignId = _viewModel.campaigns.first.campaignId;
      final launched = await _viewModel.launchCampaign(campaignId);
      if (launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign launched successfully!')),
        );
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage ?? 'Failed to launch campaign')),
      );
    }
  }

  Map<String, dynamic> _buildCampaignData() {
    return {
      'campaign_name': _campaignNameController.text,
      'campaign_type': _campaignType,
      'campaign_goal': _campaignGoal,
      'description': _descriptionController.text,
      'subject': _subjectController.text,
      'message': _messageController.text,
      'message_template_id': _messageTemplateId,
      'personalization_tags': _personalizationTags,
      'attachments': _attachments,
      'primary_channel': _primaryChannel,
      'channels': _selectedChannels,
      'target_audience': _targetAudience,
      'selected_segments': _selectedSegments,
      'targeting_rules': _targetingRules,
      'estimated_reach': _estimatedReach,
      'schedule_type': _scheduleType,
      'scheduled_at': _scheduledAt?.toIso8601String(),
      'start_date': _dateRange?.start.toIso8601String(),
      'end_date': _dateRange?.end.toIso8601String(),
      'is_automated': _isAutomated,
      'automation_triggers': _automationTriggers,
      'budget': double.tryParse(_budgetController.text) ?? 0.0,
      'estimated_cost': double.tryParse(_estimatedCostController.text) ?? 0.0,
      'ab_testing_enabled': _abTestingEnabled,
      'ab_test_variants': _abTestVariants,
    };
  }
}
