import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_forecast_chart.dart';
import '../widgets/dashboard_scenario_analysis.dart';
import '../widgets/dashboard_risk_assessment.dart';

/// Revenue Forecasting Dashboard Page
/// Shows revenue projections, scenario analysis, and risk factors
class RevenueForecastingDashboardPage extends StatefulWidget {
  const RevenueForecastingDashboardPage({super.key});

  @override
  State<RevenueForecastingDashboardPage> createState() => _RevenueForecastingDashboardPageState();
}

class _RevenueForecastingDashboardPageState extends State<RevenueForecastingDashboardPage> {
  String _selectedPeriod = '3m';
  String _selectedScenario = 'base_case';

  final List<String> _periods = ['1m', '3m', '6m', '1y'];
  final List<String> _scenarios = ['best_case', 'base_case', 'worst_case'];

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    final viewModel = context.read<DashboardViewModel>();
    await viewModel.loadRevenueForecastData(_selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Revenue Forecasting'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Period selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(
                    _getPeriodLabel(period),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                  _loadForecastData();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForecastData,
            tooltip: 'Refresh Forecast',
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating revenue forecast...'),
                ],
              ),
            );
          }

          if (viewModel.forecastData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Unable to load forecast data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadForecastData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final forecastData = viewModel.forecastData!;

          return RefreshIndicator(
            onRefresh: _loadForecastData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Forecast Summary Cards
                    _buildForecastSummaryCards(forecastData),

                    const SizedBox(height: 24),

                    // Scenario Selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
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
                            'Forecast Scenarios',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _scenarios.map((scenario) {
                                final isSelected = scenario == _selectedScenario;
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(_getScenarioLabel(scenario)),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedScenario = scenario);
                                      }
                                    },
                                    backgroundColor: Colors.grey.shade100,
                                    selectedColor: _getScenarioColor(scenario).withOpacity(0.2),
                                    checkmarkColor: _getScenarioColor(scenario),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? _getScenarioColor(scenario)
                                          : Colors.grey.shade700,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Forecast Chart
                    Container(
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
                      child: ForecastChartWidget(
                        forecastData: forecastData,
                        selectedScenario: _selectedScenario,
                        period: _selectedPeriod,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Scenario Analysis
                    ScenarioAnalysisWidget(
                      forecastData: forecastData,
                      selectedScenario: _selectedScenario,
                    ),

                    const SizedBox(height: 24),

                    // Risk Assessment
                    RiskAssessmentWidget(
                      forecastData: forecastData,
                      selectedScenario: _selectedScenario,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForecastSummaryCards(Map<String, dynamic> forecastData) {
    final projectedRevenue = forecastData['projected_revenue'] ?? 0;
    final revenueGrowth = forecastData['revenue_growth'] ?? 0.0;
    final confidenceLevel = forecastData['confidence_level'] ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Projected Revenue',
            '₹${projectedRevenue.toStringAsFixed(0)}',
            Icons.show_chart,
            Colors.blue,
            '+${revenueGrowth.toStringAsFixed(1)}% growth',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Confidence Level',
            '${(confidenceLevel * 100).toStringAsFixed(0)}%',
            Icons.verified,
            confidenceLevel > 0.8 ? Colors.green : confidenceLevel > 0.6 ? Colors.orange : Colors.red,
            _getConfidenceDescription(confidenceLevel),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
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
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '1m': return '1 Month';
      case '3m': return '3 Months';
      case '6m': return '6 Months';
      case '1y': return '1 Year';
      default: return period;
    }
  }

  String _getScenarioLabel(String scenario) {
    switch (scenario) {
      case 'best_case': return 'Best Case';
      case 'base_case': return 'Base Case';
      case 'worst_case': return 'Worst Case';
      default: return scenario;
    }
  }

  Color _getScenarioColor(String scenario) {
    switch (scenario) {
      case 'best_case': return Colors.green;
      case 'base_case': return Colors.blue;
      case 'worst_case': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.8) return 'High confidence';
    if (confidence >= 0.6) return 'Medium confidence';
    return 'Low confidence';
  }
}
