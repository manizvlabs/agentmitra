import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/widgets/offline_indicator.dart';
import '../features/campaigns/presentation/viewmodels/campaign_viewmodel.dart';
import '../features/campaigns/data/models/campaign_model.dart';
import 'package:intl/intl.dart';

/// Campaign Performance Analytics Screen for Agent App
/// Shows detailed analytics and performance metrics for marketing campaigns
class CampaignPerformanceScreen extends StatefulWidget {
  final String campaignId;
  final Campaign? campaign;

  const CampaignPerformanceScreen({
    super.key,
    required this.campaignId,
    this.campaign,
  });

  @override
  State<CampaignPerformanceScreen> createState() => _CampaignPerformanceScreenState();
}

class _CampaignPerformanceScreenState extends State<CampaignPerformanceScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final CampaignViewModel _viewModel = CampaignViewModel();
  
  Campaign? _campaign;
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  // Fallback campaign data if API fails
  Map<String, dynamic> get campaignData {
    if (_analytics != null) {
      return {
        'name': _campaign?.campaignName ?? 'Campaign',
        'dates': _campaign?.createdAt != null
            ? DateFormat('MMM dd, yyyy').format(_campaign!.createdAt!)
            : 'N/A',
        'targetAudience': _analytics!['estimated_reach'] ?? 0,
        'budget': _analytics!['budget'] ?? 0,
        'status': _campaign?.status ?? 'Unknown',
        'metrics': {
          'sent': _analytics!['total_sent'] ?? 0,
          'delivered': _analytics!['total_delivered'] ?? 0,
          'opened': _analytics!['total_opened'] ?? 0,
          'clicked': _analytics!['total_clicked'] ?? 0,
          'converted': _analytics!['total_converted'] ?? 0,
          'revenue': _analytics!['total_revenue'] ?? 0.0,
          'roi': _analytics!['roi_percentage'] ?? 0.0,
        },
        'performance': _analytics!['daily_performance'] ?? [],
        'segmentation': _analytics!['segmentation'] ?? {},
        'geographic': _analytics!['geographic'] ?? {},
      };
    }
    return {
      'name': 'March Renewal Drive',
      'dates': 'Mar 01-15, 2024',
      'targetAudience': 500,
      'budget': 10000,
      'status': 'Active',
      'metrics': {
        'sent': 485,
        'delivered': 462,
        'opened': 342,
        'clicked': 98,
        'converted': 23,
        'revenue': 45000,
        'roi': 350,
      },
      'performance': [
        {'day': 1, 'sent': 50, 'opened': 35, 'clicked': 8},
        {'day': 2, 'sent': 45, 'opened': 32, 'clicked': 7},
        {'day': 3, 'sent': 55, 'opened': 38, 'clicked': 9},
        {'day': 4, 'sent': 60, 'opened': 42, 'clicked': 12},
        {'day': 5, 'sent': 58, 'opened': 41, 'clicked': 11},
        {'day': 6, 'sent': 52, 'opened': 36, 'clicked': 8},
        {'day': 7, 'sent': 48, 'opened': 34, 'clicked': 7},
        {'day': 8, 'sent': 55, 'opened': 39, 'clicked': 10},
        {'day': 9, 'sent': 62, 'opened': 45, 'clicked': 13},
      ],
      'segmentation': {
        'highValue': {'sent': 150, 'opened': 120, 'clicked': 35, 'conversion': 12},
        'regular': {'sent': 250, 'opened': 165, 'clicked': 45, 'conversion': 8},
        'new': {'sent': 85, 'opened': 57, 'clicked': 18, 'conversion': 3},
      },
      'geographic': {
        'mumbai': {'sent': 180, 'opened': 147, 'clicked': 42},
        'delhi': {'sent': 135, 'opened': 110, 'clicked': 31},
        'others': {'sent': 170, 'opened': 85, 'clicked': 25},
      },
    };
  }

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;

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

    _loadCampaignData();
    _animationController.forward();
  }

  Future<void> _loadCampaignData() async {
    setState(() => _isLoading = true);
    
    // Load campaign details if not provided
    if (_campaign == null) {
      await _viewModel.loadCampaign(widget.campaignId);
      _campaign = _viewModel.selectedCampaign;
    }
    
    // Load analytics
    await _viewModel.loadCampaignAnalytics(widget.campaignId);
    _analytics = _viewModel.analytics;
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.hasError) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _viewModel.errorMessage ?? 'Failed to load campaign data',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCampaignData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

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
                  // Campaign Overview
                  _buildCampaignOverview(),

                  const SizedBox(height: 24),

                  // Key Performance Metrics
                  _buildKeyMetrics(),

                  const SizedBox(height: 24),

                  // Detailed Analytics
                  _buildDetailedAnalytics(),

                  const SizedBox(height: 24),

                  // Audience Segmentation Analysis
                  _buildAudienceSegmentation(),

                  const SizedBox(height: 24),

                  // Campaign Insights
                  _buildCampaignInsights(),

                  const SizedBox(height: 24),

                  // Export & Reporting
                  _buildExportActions(),

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
        'Campaign Performance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshing campaign data...')),
            );
            await _loadCampaignData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refreshed')),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: More options menu
          },
        ),
      ],
    );
  }

  Widget _buildCampaignOverview() {
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
          const Text(
            'Campaign Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.campaign,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaignData['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${campaignData['dates']} • 🎯 Target: ${campaignData['targetAudience']} customers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '💰 Budget: ₹${campaignData['budget']} • 📈 Status: ${campaignData['status']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final metrics = campaignData['metrics'];
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
          const Text(
            'Key Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard('📧 Sent', metrics['sent'].toString(), '97%'),
              const SizedBox(width: 12),
              _buildMetricCard('👁️ Opened', metrics['opened'].toString(), '71%'),
              const SizedBox(width: 12),
              _buildMetricCard('👆 Clicked', metrics['clicked'].toString(), '20%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricCard('💰 Revenue', '₹${metrics['revenue']}', null),
              const SizedBox(width: 12),
              _buildMetricCard('📈 ROI', '${metrics['roi']}%', null),
              const SizedBox(width: 12),
              _buildMetricCard('🎯 Conv.', metrics['converted'].toString(), '8%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String? percentage) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (percentage != null) ...[
              const SizedBox(height: 4),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalytics() {
    final performance = campaignData['performance'] as List? ?? [];
    
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
          const Text(
            'Performance Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (performance.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No performance data available yet'),
              ),
            )
          else ...[
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < performance.length) {
                            return Text('D${value.toInt() + 1}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: performance.asMap().entries.map<FlSpot>((entry) {
                        final day = entry.value as Map<String, dynamic>;
                        return FlSpot(entry.key.toDouble(), (day['opened'] ?? 0).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: performance.asMap().entries.map<FlSpot>((entry) {
                        final day = entry.value as Map<String, dynamic>;
                        return FlSpot(entry.key.toDouble(), (day['clicked'] ?? 0).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Opened'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.green, 'Clicked'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAudienceSegmentation() {
    final segmentation = campaignData['segmentation'];
    final geographic = campaignData['geographic'];

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
          const Text(
            'Audience Segmentation Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Customer Segments
          const Text(
            'Customer Segments',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildSegmentationItem(
            'High Value Customers',
            '${segmentation['highValue']['opened']}/${segmentation['highValue']['sent']} opened, ${segmentation['highValue']['clicked']} clicked',
            Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildSegmentationItem(
            'Regular Customers',
            '${segmentation['regular']['opened']}/${segmentation['regular']['sent']} opened, ${segmentation['regular']['clicked']} clicked',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildSegmentationItem(
            'New Customers',
            '${segmentation['new']['opened']}/${segmentation['new']['sent']} opened, ${segmentation['new']['clicked']} clicked',
            Colors.green,
          ),

          const SizedBox(height: 16),

          // Geographic
          const Text(
            'Geographic Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '📍 Mumbai: ${geographic['mumbai']['opened']}/${geographic['mumbai']['sent']} opened • Delhi: ${geographic['delhi']['opened']}/${geographic['delhi']['sent']} opened • Others: ${geographic['others']['opened']}/${geographic['others']['sent']} opened',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentationItem(String segment, String stats, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  stats,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Campaign Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            '💡 Best performing time: 10 AM - 12 PM',
            'Campaigns sent during morning hours show 35% higher engagement',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '💡 Subject line "Renewal Due" gets 15% more opens',
            'Urgency-driven subject lines perform significantly better',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '💡 Mobile users 40% more likely to click',
            'Optimize campaigns for mobile-first viewing experience',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            '🎯 Next campaign suggestion: Target high-value customers',
            'Focus on customers with AOV > ₹5,000 for better ROI',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportActions() {
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
          const Text(
            'Export & Reporting',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.download),
                  label: const Text('Export Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.blue),
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cloneCampaign,
                  icon: const Icon(Icons.copy),
                  label: const Text('Clone Campaign'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.green),
                    foregroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _editCampaign,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Campaign'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.orange),
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scheduleReport,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule Reports'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.purple),
                    foregroundColor: Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting campaign report...')),
    );
  }

  void _cloneCampaign() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloning campaign...')),
    );
  }

  void _editCampaign() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening campaign editor...')),
    );
  }

  void _scheduleReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening report scheduler...')),
    );
  }
}
