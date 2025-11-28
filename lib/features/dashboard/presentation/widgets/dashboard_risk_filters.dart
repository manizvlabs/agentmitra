import 'package:flutter/material.dart';

/// Risk Filters Widget
/// Advanced filtering options for at-risk customers management
class RiskFiltersWidget extends StatefulWidget {
  final String selectedRiskLevel;
  final String selectedPriority;
  final Function(String) onRiskLevelChanged;
  final Function(String) onPriorityChanged;

  const RiskFiltersWidget({
    super.key,
    required this.selectedRiskLevel,
    required this.selectedPriority,
    required this.onRiskLevelChanged,
    required this.onPriorityChanged,
  });

  @override
  State<RiskFiltersWidget> createState() => _RiskFiltersWidgetState();
}

class _RiskFiltersWidgetState extends State<RiskFiltersWidget> {
  late String _riskLevel;
  late String _priority;
  late RangeValues _riskScoreRange;
  late RangeValues _daysSinceContactRange;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _riskLevel = widget.selectedRiskLevel;
    _priority = widget.selectedPriority;
    _riskScoreRange = const RangeValues(0, 100);
    _daysSinceContactRange = const RangeValues(0, 90);
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
            'Risk Level',
            DropdownButtonFormField<String>(
              value: _riskLevel,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Risk Levels')),
                const DropdownMenuItem(value: 'high', child: Text('High Risk')),
                const DropdownMenuItem(value: 'medium', child: Text('Medium Risk')),
                const DropdownMenuItem(value: 'low', child: Text('Low Risk')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _riskLevel = value);
                  widget.onRiskLevelChanged(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

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
                const DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
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
              'Risk Score Range',
              Column(
                children: [
                  RangeSlider(
                    values: _riskScoreRange,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    labels: RangeLabels(
                      '${_riskScoreRange.start.round()}%',
                      '${_riskScoreRange.end.round()}%',
                    ),
                    onChanged: (values) => setState(() => _riskScoreRange = values),
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
              'Days Since Last Contact',
              Column(
                children: [
                  RangeSlider(
                    values: _daysSinceContactRange,
                    min: 0,
                    max: 180,
                    divisions: 36,
                    labels: RangeLabels(
                      '${_daysSinceContactRange.start.round()} days',
                      '${_daysSinceContactRange.end.round()} days',
                    ),
                    onChanged: (values) => setState(() => _daysSinceContactRange = values),
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
                        '180 days',
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
              'Risk Factors',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildRiskFactorChip('payment_delays', 'Payment Delays'),
                  _buildRiskFactorChip('low_engagement', 'Low Engagement'),
                  _buildRiskFactorChip('support_issues', 'Support Issues'),
                  _buildRiskFactorChip('policy_age', 'Policy Age'),
                  _buildRiskFactorChip('premium_changes', 'Premium Changes'),
                  _buildRiskFactorChip('complaint_history', 'Complaint History'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Policy Types',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPolicyTypeChip('term_life', 'Term Life'),
                  _buildPolicyTypeChip('health', 'Health'),
                  _buildPolicyTypeChip('ulip', 'ULIP'),
                  _buildPolicyTypeChip('comprehensive', 'Comprehensive'),
                  _buildPolicyTypeChip('two_wheeler', 'Two Wheeler'),
                  _buildPolicyTypeChip('four_wheeler', 'Four Wheeler'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              'Premium Range',
              Column(
                children: [
                  RangeSlider(
                    values: const RangeValues(5000, 100000),
                    min: 1000,
                    max: 500000,
                    divisions: 50,
                    labels: const RangeLabels('₹5K', '₹1L'),
                    onChanged: (values) {
                      // Handle premium range filter
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹1K',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '₹5L',
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

  Widget _buildRiskFactorChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // Would need state management for multiple selections
      onSelected: (selected) {
        // Handle risk factor filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.red.withOpacity(0.2),
      checkmarkColor: Colors.red,
    );
  }

  Widget _buildPolicyTypeChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: false, // Would need state management for multiple selections
      onSelected: (selected) {
        // Handle policy type filter
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  void _resetFilters() {
    setState(() {
      _riskLevel = 'all';
      _priority = 'all';
      _riskScoreRange = const RangeValues(0, 100);
      _daysSinceContactRange = const RangeValues(0, 90);
    });
    widget.onRiskLevelChanged('all');
    widget.onPriorityChanged('all');
  }

  void _applyFilters() {
    // Apply advanced filters - would need to pass these to parent
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced filters applied')),
    );
  }
}
