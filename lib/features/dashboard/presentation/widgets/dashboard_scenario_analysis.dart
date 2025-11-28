import 'package:flutter/material.dart';

/// Scenario Analysis Widget
/// Shows side-by-side comparison of different forecast scenarios
class ScenarioAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> forecastData;
  final String selectedScenario;

  const ScenarioAnalysisWidget({
    super.key,
    required this.forecastData,
    required this.selectedScenario,
  });

  @override
  Widget build(BuildContext context) {
    final scenarios = _getScenarios();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scenario Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compare different forecasting scenarios and their potential outcomes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          // Scenario cards in a row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: scenarios.map((scenario) {
                final isSelected = scenario['key'] == selectedScenario;
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildScenarioCard(context, scenario, isSelected),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Scenario comparison table
          _buildScenarioComparisonTable(context, scenarios),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, Map<String, dynamic> scenario, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected
            ? scenario['color'].withOpacity(0.1)
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? scenario['color']
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: scenario['color'],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scenario['name'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? scenario['color'] : null,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: scenario['color'],
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${scenario['revenue'].toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scenario['color'],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Projected Revenue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                scenario['growthRate'] >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: scenario['growthRate'] >= 0 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${scenario['growthRate'] >= 0 ? '+' : ''}${scenario['growthRate'].toStringAsFixed(1)}%',
                style: TextStyle(
                  color: scenario['growthRate'] >= 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: scenario['probability'],
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(scenario['color']),
          ),
          const SizedBox(height: 4),
          Text(
            '${(scenario['probability'] * 100).toInt()}% probability',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioComparisonTable(BuildContext context, List<Map<String, dynamic>> scenarios) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 120), // For scenario name column
                ...scenarios.map((scenario) => Expanded(
                  child: Text(
                    scenario['name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scenario['color'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
              ],
            ),
          ),
          // Rows
          _buildComparisonRow(context, 'Revenue', scenarios, (s) => '₹${s['revenue'].toStringAsFixed(0)}'),
          _buildComparisonRow(context, 'Growth Rate', scenarios, (s) => '${s['growthRate'] >= 0 ? '+' : ''}${s['growthRate'].toStringAsFixed(1)}%'),
          _buildComparisonRow(context, 'Probability', scenarios, (s) => '${(s['probability'] * 100).toInt()}%'),
          _buildComparisonRow(context, 'Risk Level', scenarios, (s) => s['riskLevel']),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, String label, List<Map<String, dynamic>> scenarios,
      String Function(Map<String, dynamic>) valueGetter) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...scenarios.map((scenario) => Expanded(
            child: Text(
              valueGetter(scenario),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scenario['color'],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getScenarios() {
    final baseRevenue = forecastData['projected_revenue'] ?? 300000;
    final baseGrowth = forecastData['revenue_growth'] ?? 8.5;

    return [
      {
        'key': 'best_case',
        'name': 'Best Case',
        'color': Colors.green,
        'revenue': baseRevenue * 1.25,
        'growthRate': baseGrowth + 7.0,
        'probability': 0.25,
        'riskLevel': 'Low',
      },
      {
        'key': 'base_case',
        'name': 'Base Case',
        'color': Colors.blue,
        'revenue': baseRevenue,
        'growthRate': baseGrowth,
        'probability': 0.50,
        'riskLevel': 'Medium',
      },
      {
        'key': 'worst_case',
        'name': 'Worst Case',
        'color': Colors.red,
        'revenue': baseRevenue * 0.75,
        'growthRate': baseGrowth - 5.0,
        'probability': 0.25,
        'riskLevel': 'High',
      },
    ];
  }
}
