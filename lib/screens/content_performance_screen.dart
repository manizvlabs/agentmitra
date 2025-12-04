import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/widgets/offline_indicator.dart';

/// Content Performance Analytics Screen for Agent App
/// Shows detailed analytics for video content and educational materials
class ContentPerformanceScreen extends StatefulWidget {
  const ContentPerformanceScreen({super.key});

  @override
  State<ContentPerformanceScreen> createState() => _ContentPerformanceScreenState();
}

class _ContentPerformanceScreenState extends State<ContentPerformanceScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // TODO: Implement real content analytics API integration
  // TODO: Implement real content analytics API integration
  final Map<String, dynamic> contentAnalytics = {};

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
  }

  @override
  void dispose() {
    _animationController.dispose();
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
                  // Content Overview
                  _buildContentOverview(),

                  const SizedBox(height: 24),

                  // Top Performing Content
                  _buildTopPerformingContent(),

                  const SizedBox(height: 24),

                  // Engagement Analytics
                  _buildEngagementAnalytics(),

                  const SizedBox(height: 24),

                  // Audience Demographics
                  _buildAudienceDemographics(),

                  const SizedBox(height: 24),

                  // Content Insights
                  _buildContentInsights(),

                  const SizedBox(height: 24),

                  // Content Actions
                  _buildContentActions(),

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
        'Content Performance',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // TODO: Refresh data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refreshing content analytics...')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // TODO: Filter options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter options coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContentOverview() {
    final overview = contentAnalytics['overview'];
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
            'Content Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildOverviewStat(
                '${overview['totalVideos']} Videos',
                Icons.video_library,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildOverviewStat(
                '${overview['totalDocuments']} Documents',
                Icons.description,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildOverviewStat(
                '${overview['totalViews']} Views',
                Icons.visibility,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildOverviewStat(
                '${overview['watchTime']} Watch Time',
                Icons.access_time,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildOverviewStat(
                '⭐ ${overview['averageRating']}/5 Rating',
                Icons.star,
                Colors.amber,
              ),
              const SizedBox(width: 16),
              _buildOverviewStat(
                '+${overview['growth']}% Growth',
                Icons.trending_up,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformingContent() {
    final topContent = contentAnalytics['topContent'] as List;
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
            'Top Performing Content',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topContent.map((content) => _buildContentItem(content, topContent.indexOf(content))),
        ],
      ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> content, int rank) {
    final rankIcons = ['🥇', '🥈', '🥉'];
    final rankColors = [Colors.amber, Colors.grey, Colors.brown];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rankColors[rank].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColors[rank].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            rankIcons[rank],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${content['views']} views',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '⏱️ ${content['watchTime']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '⭐ ${content['rating']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '💬 ${content['shares']} shares',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementAnalytics() {
    final engagement = contentAnalytics['engagement'];
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
            'Engagement Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildEngagementMetric('👁️ Views', engagement['views'].toString(), Colors.blue),
              const SizedBox(width: 12),
              _buildEngagementMetric('⏱️ Watch Time', engagement['watchTime'], Colors.green),
              const SizedBox(width: 12),
              _buildEngagementMetric('📊 Completion', '${engagement['completionRate']}%', Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildEngagementMetric('💬 Shares', engagement['shares'].toString(), Colors.orange),
              const SizedBox(width: 12),
              _buildEngagementMetric('👍 Likes', engagement['likes'].toString(), Colors.red),
              const SizedBox(width: 12),
              _buildEngagementMetric('📝 Comments', engagement['comments'].toString(), Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceDemographics() {
    final demographics = contentAnalytics['demographics'];
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
            'Audience Demographics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Age Groups
          const Text(
            'Age Groups',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildDemographicChart(demographics['ageGroups']),

          const SizedBox(height: 16),

          // Geographic
          const Text(
            'Geographic Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildGeographicStats(demographics['geographic']),

          const SizedBox(height: 16),

          // Device Types
          const Text(
            'Device Types',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildDeviceStats(demographics['deviceTypes']),
        ],
      ),
    );
  }

  Widget _buildDemographicChart(Map<String, int> ageGroups) {
    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 50,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const ageLabels = ['25-35', '35-50', '50+'];
                  return Text(
                    ageLabels[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: ageGroups.entries.map((entry) {
            final index = ageGroups.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGeographicStats(Map<String, int> geographic) {
    return Row(
      children: [
        _buildGeoStat('Mumbai', geographic['mumbai'] ?? 0, Colors.red),
        const SizedBox(width: 12),
        _buildGeoStat('Delhi', geographic['delhi'] ?? 0, Colors.blue),
        const SizedBox(width: 12),
        _buildGeoStat('Others', geographic['others'] ?? 0, Colors.green),
      ],
    );
  }

  Widget _buildGeoStat(String city, int percentage, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            city,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStats(Map<String, int> devices) {
    return Row(
      children: [
        _buildDeviceStat('📱 Mobile', devices['mobile'] ?? 0, Colors.blue),
        const SizedBox(width: 12),
        _buildDeviceStat('💻 Desktop', devices['desktop'] ?? 0, Colors.green),
      ],
    );
  }

  Widget _buildDeviceStat(String device, int percentage, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              device,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInsights() {
    final insights = contentAnalytics['insights'] as List<String>;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: Colors.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Content Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildContentActions() {
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
            'Content Actions',
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
                  onPressed: _exportAnalytics,
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
                  onPressed: _createContent,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Content'),
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
                  onPressed: _optimizeStrategy,
                  icon: const Icon(Icons.trending_up),
                  label: const Text('Optimize Strategy'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.purple),
                    foregroundColor: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scheduleReports,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule Reports'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.orange),
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting content analytics report...')),
    );
  }

  void _createContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening content creation tool...')),
    );
  }

  void _optimizeStrategy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analyzing optimization opportunities...')),
    );
  }

  void _scheduleReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening report scheduler...')),
    );
  }
}
