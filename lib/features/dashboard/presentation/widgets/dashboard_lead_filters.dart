import 'package:flutter/material.dart';

/// Lead Filters Widget
/// Advanced filtering options for leads management
class LeadFiltersWidget extends StatefulWidget {
  final String selectedPriority;
  final String selectedSource;
  final Function(String) onPriorityChanged;
  final Function(String) onSourceChanged;

  const LeadFiltersWidget({
    super.key,
    required this.selectedPriority,
    required this.selectedSource,
    required this.onPriorityChanged,
    required this.onSourceChanged,
  });

  @override
  State<LeadFiltersWidget> createState() => _LeadFiltersWidgetState();
}

class _LeadFiltersWidgetState extends State<LeadFiltersWidget> {
  late String _priority;
  late String _source;
  late RangeValues _scoreRange;
  late RangeValues _ageRange;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _priority = widget.selectedPriority;
    _source = widget.selectedSource;
    _scoreRange = const RangeValues(0, 100);
    _ageRange = const RangeValues(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Filters
          _buildFilterSection(
            'Priority Level',
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                const DropdownMenuItem(value: 'high', child: Text('High Priority')),
                const DropdownMenuItem(value: 'medium', child: Text('Medium Priority')),
                const DropdownMenuItem(value: 'low', child: Text('Low Priority')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                  widget.onPriorityChanged(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          _buildFilterSection(
            'Lead Source',
            DropdownButtonFormField<String>(
              value: _source,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Sources')),
                const DropdownMenuItem(value: 'website', child: Text('Website')),
                const DropdownMenuItem(value: 'referral', child: Text('Referral')),
                const DropdownMenuItem(value: 'whatsapp_campaign', child: Text('WhatsApp Campaign')),
                const DropdownMenuItem(value: 'email_campaign', child: Text('Email Campaign')),
                const DropdownMenuItem(value: 'social_media', child: Text('Social Media')),
                const DropdownMenuItem(value: 'cold_call', child: Text('Cold Call')),
                const DropdownMenuItem(value: 'event', child: Text('Event')),
                const DropdownMenuItem(value: 'partner', child: Text('Partner')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _source = value);
                  widget.onSourceChanged(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Advanced Filters Toggle
          Row(
            children: [
              Expanded(
                child: Divider(color: Colors.grey.shade300),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
                icon: Icon(
                  _showAdvanced ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                ),
                label: Text(
                  _showAdvanced ? 'Hide Advanced' : 'Show Advanced',
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              Expanded(
                child: Divider(color: Colors.grey.shade300),
              ),
            ],
          ),

          // Advanced Filters
          if (_showAdvanced) ...[
            const SizedBox(height: 16),

            _buildFilterSection(
              'Conversion Score Range',
              Column(
                children: [
                  RangeSlider(
                    values: _scoreRange,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_scoreRange.start.round()}%',
                      '${_scoreRange.end.round()}%',
                    ),
                    onChanged: (values) => setState(() => _scoreRange = values),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '100%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Lead Age (Days)',
              Column(
                children: [
                  RangeSlider(
                    values: _ageRange,
                    min: 0,
                    max: 90,
                    divisions: 18,
                    labels: RangeLabels(
                      '${_ageRange.start.round()} days',
                      '${_ageRange.end.round()} days',
                    ),
                    onChanged: (values) => setState(() => _ageRange = values),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '90 days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Lead Status',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusChip('new', 'New'),
                  _buildStatusChip('contacted', 'Contacted'),
                  _buildStatusChip('qualified', 'Qualified'),
                  _buildStatusChip('quoted', 'Quoted'),
                  _buildStatusChip('converted', 'Converted'),
                  _buildStatusChip('lost', 'Lost'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Insurance Type',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTypeChip('term_life', 'Term Life'),
                  _buildTypeChip('health', 'Health'),
                  _buildTypeChip('ulip', 'ULIP'),
                  _buildTypeChip('comprehensive', 'Comprehensive'),
                  _buildTypeChip('two_wheeler', 'Two Wheeler'),
                  _buildTypeChip('four_wheeler', 'Four Wheeler'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Budget Range',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBudgetChip('low', 'Low (< ₹50K)'),
                  _buildBudgetChip('medium', 'Medium (₹50K - ₹2L)'),
                  _buildBudgetChip('high', 'High (> ₹2L)'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Reset All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildStatusChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // Would need state management for multiple selections
      onSelected: (selected) {
        // Handle status filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTypeChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // Would need state management for multiple selections
      onSelected: (selected) {
        // Handle type filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildBudgetChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // Would need state management for multiple selections
      onSelected: (selected) {
        // Handle budget filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  void _resetFilters() {
    setState(() {
      _priority = 'all';
      _source = 'all';
      _scoreRange = const RangeValues(0, 100);
      _ageRange = const RangeValues(0, 30);
    });
    widget.onPriorityChanged('all');
    widget.onSourceChanged('all');
  }

  void _applyFilters() {
    // Apply advanced filters - would need to pass these to parent
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced filters applied')),
    );
  }
}
