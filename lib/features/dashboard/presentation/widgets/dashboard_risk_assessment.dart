import 'package:flutter/material.dart';

/// Risk Assessment Widget
/// Shows risk factors, probability assessments, and mitigation strategies
class RiskAssessmentWidget extends StatelessWidget {
  final Map<String, dynamic> forecastData;
  final String selectedScenario;

  const RiskAssessmentWidget({
    super.key,
    required this.forecastData,
    required this.selectedScenario,
  });

  @override
  Widget build(BuildContext context) {
    final riskFactors = _getRiskFactors();
    final mitigationStrategies = _getMitigationStrategies();

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
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Assessment',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Potential risks and mitigation strategies for ${selectedScenario.replaceAll('_', ' ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Risk Level Indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRiskColor(selectedScenario).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRiskColor(selectedScenario).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getRiskColor(selectedScenario),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Risk Level: ${_getRiskLevel(selectedScenario)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(selectedScenario),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getRiskDescription(selectedScenario),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_getRiskPercentage(selectedScenario)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(selectedScenario),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Risk Factors
          Text(
            'Key Risk Factors',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...riskFactors.map((factor) => _buildRiskFactor(context, factor)),

          const SizedBox(height: 24),

          // Mitigation Strategies
          Text(
            'Mitigation Strategies',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...mitigationStrategies.map((strategy) => _buildMitigationStrategy(context, strategy)),

          const SizedBox(height: 20),

          // Risk Mitigation Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended Actions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildRecommendedAction(
                  context,
                  'Diversify revenue streams',
                  'Reduce dependency on single revenue source',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildRecommendedAction(
                  context,
                  'Build cash reserves',
                  'Maintain 3-6 months of operating expenses',
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildRecommendedAction(
                  context,
                  'Monitor key metrics weekly',
                  'Track leading indicators for early warning signs',
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactor(BuildContext context, Map<String, dynamic> factor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: factor['severity'] == 'high'
            ? Colors.red.withOpacity(0.1)
            : factor['severity'] == 'medium'
                ? Colors.orange.withOpacity(0.1)
                : Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: factor['severity'] == 'high'
              ? Colors.red.withOpacity(0.3)
              : factor['severity'] == 'medium'
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.yellow.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            factor['severity'] == 'high'
                ? Icons.warning
                : factor['severity'] == 'medium'
                    ? Icons.warning_amber
                    : Icons.info_outline,
            color: factor['severity'] == 'high'
                ? Colors.red
                : factor['severity'] == 'medium'
                    ? Colors.orange
                    : Colors.yellow.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  factor['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: factor['probability'] > 0.7
                  ? Colors.red.withOpacity(0.2)
                  : factor['probability'] > 0.4
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(factor['probability'] * 100).toInt()}%',
              style: TextStyle(
                color: factor['probability'] > 0.7
                    ? Colors.red
                    : factor['probability'] > 0.4
                        ? Colors.orange
                        : Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMitigationStrategy(BuildContext context, Map<String, dynamic> strategy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  strategy['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(strategy['effectiveness'] * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedAction(BuildContext context, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.arrow_forward,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRiskFactors() {
    return [
      {
        'title': 'Market Competition',
        'description': 'Increasing competition from new market entrants',
        'severity': selectedScenario == 'worst_case' ? 'high' : 'medium',
        'probability': selectedScenario == 'worst_case' ? 0.8 : 0.6,
      },
      {
        'title': 'Economic Slowdown',
        'description': 'Potential economic recession affecting customer spending',
        'severity': selectedScenario == 'worst_case' ? 'high' : 'medium',
        'probability': selectedScenario == 'worst_case' ? 0.7 : 0.4,
      },
      {
        'title': 'Regulatory Changes',
        'description': 'New insurance regulations impacting business operations',
        'severity': 'medium',
        'probability': 0.3,
      },
      {
        'title': 'Customer Retention',
        'description': 'Higher than expected customer churn rates',
        'severity': selectedScenario == 'worst_case' ? 'high' : 'low',
        'probability': selectedScenario == 'worst_case' ? 0.6 : 0.2,
      },
    ];
  }

  List<Map<String, dynamic>> _getMitigationStrategies() {
    return [
      {
        'title': 'Customer Loyalty Programs',
        'description': 'Implement retention incentives and loyalty rewards',
        'effectiveness': 0.8,
      },
      {
        'title': 'Market Diversification',
        'description': 'Expand into new customer segments and geographies',
        'effectiveness': 0.7,
      },
      {
        'title': 'Cost Optimization',
        'description': 'Streamline operations and reduce operational expenses',
        'effectiveness': 0.6,
      },
      {
        'title': 'Digital Transformation',
        'description': 'Invest in technology to improve efficiency and customer experience',
        'effectiveness': 0.9,
      },
    ];
  }

  String _getRiskLevel(String scenario) {
    switch (scenario) {
      case 'best_case': return 'Low';
      case 'base_case': return 'Medium';
      case 'worst_case': return 'High';
      default: return 'Medium';
    }
  }

  String _getRiskDescription(String scenario) {
    switch (scenario) {
      case 'best_case': return 'Favorable market conditions with minimal risks';
      case 'base_case': return 'Moderate risks with balanced opportunities';
      case 'worst_case': return 'Challenging conditions requiring strong mitigation';
      default: return 'Standard risk assessment';
    }
  }

  int _getRiskPercentage(String scenario) {
    switch (scenario) {
      case 'best_case': return 25;
      case 'base_case': return 50;
      case 'worst_case': return 75;
      default: return 50;
    }
  }

  Color _getRiskColor(String scenario) {
    switch (scenario) {
      case 'best_case': return Colors.green;
      case 'base_case': return Colors.orange;
      case 'worst_case': return Colors.red;
      default: return Colors.grey;
    }
  }
}
