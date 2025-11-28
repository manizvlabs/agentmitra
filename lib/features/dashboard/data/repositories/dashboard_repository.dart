import 'package:flutter/material.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_data.dart';
import '../../../../core/services/api_service.dart';

/// Repository for dashboard data management
class DashboardRepository extends BaseRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepository(this._remoteDataSource);

  /// Get dashboard analytics
  Future<DashboardAnalytics> getDashboardAnalytics({
    required String agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _remoteDataSource.fetchDashboardAnalytics(
      agentId: agentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get dashboard notifications
  Future<List<DashboardNotification>> getNotifications({
    required String userId,
    int limit = 10,
  }) async {
    return await _remoteDataSource.fetchNotifications(
      userId: userId,
      limit: limit,
    );
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _remoteDataSource.markNotificationAsRead(notificationId);
  }

  /// Refresh dashboard cache
  Future<void> refreshDashboardCache(String agentId) async {
    await _remoteDataSource.refreshDashboardCache(agentId);
  }

  /// Get ROI dashboard data
  Future<Map<String, dynamic>> getROIDashboardData({
    required String agentId,
    required String timeframe,
  }) async {
    try {
      final response = await ApiService.get('/analytics/roi/agent/$agentId?period=$timeframe');

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch ROI data');
      }
    } catch (e) {
      // Return mock data for development if API fails
      return _getMockROIData(agentId, timeframe);
    }
  }

  /// Get revenue forecast data
  Future<Map<String, dynamic>> getRevenueForecastData({
    required String agentId,
    required String period,
  }) async {
    try {
      final response = await ApiService.get('/analytics/forecast/agent/$agentId?period=$period');

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch forecast data');
      }
    } catch (e) {
      // Return mock data for development if API fails
      return _getMockForecastData(agentId, period);
    }
  }

  /// Get hot leads data
  Future<Map<String, dynamic>> getHotLeadsData({
    required String agentId,
    String priority = 'all',
    String source = 'all',
  }) async {
    try {
      final queryParams = {
        if (priority != 'all') 'priority': priority,
        if (source != 'all') 'source': source,
      };
      final queryString = queryParams.isEmpty ? '' : '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await ApiService.get('/analytics/leads/hot/agent/$agentId$queryString');

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch hot leads data');
      }
    } catch (e) {
      // Return mock data for development if API fails
      return _getMockHotLeadsData(agentId, priority, source);
    }
  }

  /// Get at-risk customers data
  Future<Map<String, dynamic>> getAtRiskCustomersData({
    required String agentId,
    String riskLevel = 'all',
    String priority = 'all',
  }) async {
    try {
      final queryParams = {
        if (riskLevel != 'all') 'risk_level': riskLevel,
        if (priority != 'all') 'priority': priority,
      };
      final queryString = queryParams.isEmpty ? '' : '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await ApiService.get('/analytics/customers/at-risk/agent/$agentId$queryString');

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch at-risk customers data');
      }
    } catch (e) {
      // Return mock data for development if API fails
      return _getMockAtRiskCustomersData(agentId, riskLevel, priority);
    }
  }

  /// Get customer policyholder data
  Future<Map<String, dynamic>> getCustomerPolicyholderData({
    required String customerId,
  }) async {
    try {
      final response = await ApiService.get('/customer/dashboard/$customerId');

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch customer data');
      }
    } catch (e) {
      // Return mock data for development if API fails
      return _getMockCustomerPolicyholderData(customerId);
    }
  }

  /// Get agent performance data from analytics API
  Future<AgentPerformanceData> getAgentPerformanceData(String agentId) async {
    try {
      final response = await ApiService.get('/analytics/agents/$agentId/performance');
      return AgentPerformanceData(
        agentId: response['agent_id'] ?? agentId,
        agentName: response['agent_name'] ?? 'Agent',
        totalCommission: (response['total_premium_collected'] ?? 0.0).toDouble(),
        policiesSold: response['total_policies_sold'] ?? 0,
        customersAcquired: response['active_policyholders'] ?? 0,
        conversionRate: (response['conversion_rate'] ?? 0.0).toDouble() * 100,
        averagePolicyValue: (response['average_policy_value'] ?? 0.0).toDouble(),
        monthlyData: [], // TODO: Fetch from trends API
        commissionByProduct: {}, // TODO: Calculate from revenue analytics
      );
    } catch (e) {
      throw Exception('Failed to fetch agent performance data: $e');
    }
  }

  /// Get business intelligence data
  Future<BusinessIntelligenceData> getBusinessIntelligenceData({
    String? agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dateParams = <String, String>{};
      if (startDate != null) dateParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) dateParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final queryString = dateParams.isNotEmpty
          ? '?${dateParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
          : '';

      final endpoint = agentId != null
          ? '/analytics/dashboard/$agentId$queryString'
          : '/analytics/dashboard/overview$queryString';

      final response = await ApiService.get(endpoint);

      // Fetch revenue trends
      final revenueQuery = agentId != null ? '?agent_id=$agentId' : '';
      final revenueTrendsResponse = await ApiService.get(
        '/analytics/dashboard/charts/revenue-trends$revenueQuery',
      );

      final revenueTrends = (revenueTrendsResponse as List<dynamic>).map((trend) {
        return RevenueTrend(
          date: DateTime.parse(trend['date']),
          revenue: (trend['value'] ?? 0.0).toDouble(),
          target: (trend['target'] ?? trend['value'] ?? 0.0).toDouble() * 1.1, // Mock target as 10% above actual
          growth: trend['growth'] != null ? (trend['growth'] as num).toDouble() : 0.0,
        );
      }).toList();

      // Mock customer engagement data - in real app, fetch from separate API
      final customerEngagement = [
        CustomerEngagement(
          metric: 'App Sessions',
          value: response['total_customers'] ?? 0,
          change: 8.2,
          period: 'vs last month',
        ),
        CustomerEngagement(
          metric: 'Policy Views',
          value: response['total_policies'] ?? 0,
          change: 12.5,
          period: 'vs last month',
        ),
        CustomerEngagement(
          metric: 'Support Queries',
          value: (response['active_customers'] ?? 0) ~/ 10, // Mock data
          change: -5.1,
          period: 'vs last month',
        ),
      ];

      return BusinessIntelligenceData(
        revenueTrends: revenueTrends,
        customerEngagement: customerEngagement,
        roiMetrics: ROIMetrics(
          marketingROI: 245.0,
          customerAcquisitionCost: (response['average_policy_value'] ?? 850.0).toDouble(),
          lifetimeValue: (response['average_policy_value'] ?? 850.0).toDouble() * 14.7,
          churnRate: 3.2,
          retentionRate: 96.8,
        ),
        productPerformance: {
          'Life Insurance': response['total_policies'] ?? 0,
          'Health Insurance': (response['total_policies'] ?? 0) ~/ 4,
          'Motor Insurance': (response['total_policies'] ?? 0) ~/ 6,
          'Investment Plans': (response['total_policies'] ?? 0) ~/ 8,
        },
        geographicDistribution: [], // TODO: Fetch from separate API
      );
    } catch (e) {
      throw Exception('Failed to fetch business intelligence data: $e');
    }
  }

  /// Get quick actions for dashboard
  List<DashboardQuickAction> getQuickActions() {
    return [
      const DashboardQuickAction(
        id: 'new_policy',
        title: 'New Policy',
        subtitle: 'Create insurance policy',
        icon: Icons.add_circle_outline,
        route: '/new-policy',
      ),
      const DashboardQuickAction(
        id: 'view_policies',
        title: 'My Policies',
        subtitle: 'View all policies',
        icon: Icons.policy_outlined,
        route: '/policies',
      ),
      const DashboardQuickAction(
        id: 'claims',
        title: 'File Claim',
        subtitle: 'Submit insurance claim',
        icon: Icons.assignment_outlined,
        route: '/new-claim',
      ),
      const DashboardQuickAction(
        id: 'payments',
        title: 'Payments',
        subtitle: 'View payment history',
        icon: Icons.payment_outlined,
        route: '/payments',
      ),
      const DashboardQuickAction(
        id: 'customers',
        title: 'Customers',
        subtitle: 'Manage customers',
        icon: Icons.people_outline,
        route: '/customers',
      ),
      const DashboardQuickAction(
        id: 'reports',
        title: 'Reports',
        subtitle: 'View analytics',
        icon: Icons.analytics_outlined,
        route: '/reports',
      ),
      const DashboardQuickAction(
        id: 'chatbot',
        title: 'AI Assistant',
        subtitle: 'Get instant help',
        icon: Icons.smart_toy_outlined,
        route: '/smart-chatbot',
      ),
    ];
  }

  /// Mock ROI data for development
  Map<String, dynamic> _getMockROIData(String agentId, String timeframe) {
    return {
      'agent_name': 'Rajesh Kumar',
      'agent_code': 'AGT001',
      'timeframe': timeframe,
      'overall_roi': 87.5,
      'roi_grade': 'A',
      'roi_trend': 'up',
      'roi_change': 5.2,
      'total_revenue': 2450000,
      'total_payments': 45,
      'new_policies': 12,
      'revenue_growth': 12.5,
      'average_premium': 20416.67,
      'collection_rate': 98.5,
      'total_collected': 2450000,
      'total_premium_due': 2489250,
      'total_leads': 150,
      'contacted_leads': 120,
      'total_quotes': 90,
      'total_policies': 12,
      'contact_rate': 80.0,
      'quote_rate': 75.0,
      'conversion_rate': 13.3,
      'collection_efficiency': 98.5,
      'retention_rate': 94.2,
      'avg_response_time': 2.5,
      'action_items': [
        {
          'id': '1',
          'type': 'conversion_improvement',
          'title': 'Improve Lead Conversion Rate',
          'description': 'Your lead conversion rate is below target. Focus on improving follow-up processes.',
          'priority': 'high',
          'potential_revenue': 500000,
          'deadline': '2 weeks',
        },
        {
          'id': '2',
          'type': 'collection',
          'title': 'Follow Up on Overdue Payments',
          'description': '3 customers have overdue payments totaling ₹45,000.',
          'priority': 'medium',
          'potential_revenue': 45000,
          'deadline': '1 week',
        },
        {
          'id': '3',
          'type': 'follow_up',
          'title': 'Contact High-Value Prospects',
          'description': '5 high-value leads haven\'t been contacted in 7+ days.',
          'priority': 'medium',
          'potential_revenue': 250000,
          'deadline': '3 days',
        },
      ],
      'predictive_insights': [
        {
          'id': '1',
          'type': 'opportunity',
          'title': 'Premium Increase Opportunity',
          'description': '15 customers are eligible for premium increases based on inflation adjustment.',
          'confidence': 85,
          'impact': 'high',
          'potential_value': 180000,
          'recommended_actions': [
            'Contact customers proactively',
            'Explain inflation adjustment benefits',
            'Offer payment plan options'
          ],
          'deadline': 'End of quarter',
        },
        {
          'id': '2',
          'type': 'warning',
          'title': 'Potential Customer Churn',
          'description': '3 customers show signs of churn based on reduced engagement.',
          'confidence': 78,
          'impact': 'medium',
          'potential_value': 75000,
          'recommended_actions': [
            'Schedule retention calls',
            'Review policy benefits',
            'Offer loyalty discounts'
          ],
        },
        {
          'id': '3',
          'type': 'trend',
          'title': 'Seasonal Sales Pattern',
          'description': 'Q4 typically brings 35% more sales. Start preparing marketing campaigns.',
          'confidence': 92,
          'impact': 'high',
          'recommended_actions': [
            'Prepare Q4 marketing budget',
            'Train additional staff',
            'Stock up on marketing materials'
          ],
        },
      ],
    };
  }

  /// Mock forecast data for development
  Map<String, dynamic> _getMockForecastData(String agentId, String period) {
    final baseRevenue = 250000.0;
    final baseGrowth = 8.5;
    final confidence = 0.78;

    return {
      'agent_id': agentId,
      'period': period,
      'current_revenue': baseRevenue,
      'projected_revenue': baseRevenue * 1.35,
      'revenue_growth': baseGrowth,
      'confidence_level': confidence,
      'forecast_date': DateTime.now().toIso8601String(),
      'scenarios': {
        'best_case': {
          'revenue': baseRevenue * 1.55,
          'growth_rate': baseGrowth + 12.0,
          'probability': 0.25,
          'confidence': 0.65,
        },
        'base_case': {
          'revenue': baseRevenue * 1.35,
          'growth_rate': baseGrowth + 2.0,
          'probability': 0.50,
          'confidence': confidence,
        },
        'worst_case': {
          'revenue': baseRevenue * 1.15,
          'growth_rate': baseGrowth - 3.0,
          'probability': 0.25,
          'confidence': 0.55,
        },
      },
      'risk_factors': [
        {
          'factor': 'Market Competition',
          'impact': 'medium',
          'probability': 0.6,
          'description': 'Increasing competition from digital insurers',
        },
        {
          'factor': 'Economic Conditions',
          'impact': 'high',
          'probability': 0.4,
          'description': 'Potential economic slowdown affecting premiums',
        },
        {
          'factor': 'Regulatory Changes',
          'impact': 'medium',
          'probability': 0.3,
          'description': 'New insurance regulations and compliance costs',
        },
      ],
      'assumptions': [
        'Stable economic conditions for next 12 months',
        'No major regulatory changes affecting operations',
        'Current customer retention rates remain consistent',
        'Marketing budget increases by 15% annually',
      ],
    };
  }

  /// Mock hot leads data for development
  Map<String, dynamic> _getMockHotLeadsData(String agentId, String priority, String source) {
    // Generate mock leads data
    final allLeads = [
      {
        'customer_name': 'Rajesh Kumar',
        'contact_number': '+91-9876543210',
        'lead_source': 'whatsapp_campaign',
        'lead_age_days': 2,
        'engagement_score': 85.0,
        'budget_range': 'high',
        'insurance_type': 'term_life',
        'urgency_level': 'high',
        'previous_interactions': 3,
        'response_time_hours': 1.5,
        'potential_premium': 50000.0,
        'next_followup_at': '2024-01-15 14:00',
      },
      {
        'customer_name': 'Priya Sharma',
        'contact_number': '+91-9876543211',
        'lead_source': 'website',
        'lead_age_days': 5,
        'engagement_score': 72.0,
        'budget_range': 'medium',
        'insurance_type': 'health',
        'urgency_level': 'medium',
        'previous_interactions': 1,
        'response_time_hours': 4.2,
        'potential_premium': 25000.0,
      },
      {
        'customer_name': 'Amit Patel',
        'contact_number': '+91-9876543212',
        'lead_source': 'referral',
        'lead_age_days': 1,
        'engagement_score': 90.0,
        'budget_range': 'high',
        'insurance_type': 'ulip',
        'urgency_level': 'high',
        'previous_interactions': 5,
        'response_time_hours': 0.8,
        'potential_premium': 100000.0,
        'next_followup_at': '2024-01-16 10:00',
      },
      {
        'customer_name': 'Sunita Gupta',
        'contact_number': '+91-9876543213',
        'lead_source': 'email_campaign',
        'lead_age_days': 12,
        'engagement_score': 68.0,
        'budget_range': 'medium',
        'insurance_type': 'term_life',
        'urgency_level': 'medium',
        'previous_interactions': 2,
        'response_time_hours': 8.5,
        'potential_premium': 35000.0,
      },
      {
        'customer_name': 'Vikram Singh',
        'contact_number': '+91-9876543214',
        'lead_source': 'social_media',
        'lead_age_days': 3,
        'engagement_score': 78.0,
        'budget_range': 'low',
        'insurance_type': 'health',
        'urgency_level': 'low',
        'previous_interactions': 1,
        'response_time_hours': 2.1,
        'potential_premium': 15000.0,
      },
      {
        'customer_name': 'Meera Joshi',
        'contact_number': '+91-9876543215',
        'lead_source': 'cold_call',
        'lead_age_days': 18,
        'engagement_score': 45.0,
        'budget_range': 'medium',
        'insurance_type': 'ulip',
        'urgency_level': 'low',
        'previous_interactions': 0,
        'response_time_hours': 24.0,
        'potential_premium': 20000.0,
      },
      {
        'customer_name': 'Suresh Reddy',
        'contact_number': '+91-9876543216',
        'lead_source': 'partner',
        'lead_age_days': 4,
        'engagement_score': 82.0,
        'budget_range': 'high',
        'insurance_type': 'comprehensive',
        'urgency_level': 'high',
        'previous_interactions': 4,
        'response_time_hours': 1.2,
        'potential_premium': 75000.0,
        'next_followup_at': '2024-01-14 16:00',
      },
      {
        'customer_name': 'Kavita Desai',
        'contact_number': '+91-9876543217',
        'lead_source': 'event',
        'lead_age_days': 7,
        'engagement_score': 75.0,
        'budget_range': 'medium',
        'insurance_type': 'term_life',
        'urgency_level': 'medium',
        'previous_interactions': 2,
        'response_time_hours': 3.8,
        'potential_premium': 40000.0,
      },
    ];

    // Filter leads based on criteria
    var filteredLeads = allLeads;

    if (priority != 'all') {
      filteredLeads = filteredLeads.where((lead) => lead['urgency_level'] == priority).toList();
    }

    if (source != 'all') {
      filteredLeads = filteredLeads.where((lead) => lead['lead_source'] == source).toList();
    }

    // Calculate statistics
    final totalLeads = filteredLeads.length;
    final highPriorityLeads = filteredLeads.where((lead) => lead['urgency_level'] == 'high').length;
    final convertedLeads = (totalLeads * 0.15).round(); // Assume 15% conversion rate
    final avgResponseTime = filteredLeads.isEmpty ? 0 : filteredLeads.map((l) => l['response_time_hours'] as double).reduce((a, b) => a + b) / filteredLeads.length;
    final conversionRate = totalLeads > 0 ? (convertedLeads / totalLeads) * 100 : 0;
    final avgQualityScore = filteredLeads.isEmpty ? 0 : filteredLeads.map((l) => l['engagement_score'] as double).reduce((a, b) => a + b) / filteredLeads.length;
    final totalPotentialRevenue = filteredLeads.isEmpty ? 0 : filteredLeads.map((l) => l['potential_premium'] as double).reduce((a, b) => a + b);

    return {
      'statistics': {
        'total_leads': totalLeads,
        'conversion_rate': conversionRate,
        'avg_response_time': avgResponseTime,
        'avg_quality_score': avgQualityScore,
        'total_potential_revenue': totalPotentialRevenue,
        'conversion_trend': 'up',
        'response_trend': 'improving',
        'quality_trend': 'stable',
        'revenue_trend': 'up',
        'lead_generation_performance': 75,
        'followup_efficiency': 82,
        'conversion_quality': 68,
        'new_leads_count': (totalLeads * 0.4).round(),
        'in_progress_count': (totalLeads * 0.35).round(),
        'qualified_count': (totalLeads * 0.2).round(),
        'converted_count': convertedLeads,
      },
      'priority_distribution': {
        'high': highPriorityLeads,
        'medium': (totalLeads * 0.5).round(),
        'low': totalLeads - highPriorityLeads - (totalLeads * 0.5).round(),
      },
      'source_performance': {
        'whatsapp_campaign': {'count': 2, 'conversion_rate': 25.0},
        'website': {'count': 1, 'conversion_rate': 20.0},
        'referral': {'count': 2, 'conversion_rate': 35.0},
        'email_campaign': {'count': 1, 'conversion_rate': 15.0},
        'social_media': {'count': 1, 'conversion_rate': 10.0},
        'partner': {'count': 1, 'conversion_rate': 30.0},
      },
      'conversion_metrics': {
        'total_leads': totalLeads,
        'converted': convertedLeads,
        'conversion_rate': conversionRate,
      },
      'leads': filteredLeads,
      'recent_activities': [
        {'type': 'call', 'description': 'Called Rajesh Kumar - interested in term life', 'time': '2 hours ago'},
        {'type': 'email', 'description': 'Sent quote to Priya Sharma', 'time': '4 hours ago'},
        {'type': 'meeting', 'description': 'Meeting scheduled with Amit Patel', 'time': '6 hours ago'},
        {'type': 'call', 'description': 'Follow-up call with Suresh Reddy', 'time': '1 day ago'},
      ],
    };
  }

  /// Mock at-risk customers data for development
  Map<String, dynamic> _getMockAtRiskCustomersData(String agentId, String riskLevel, String priority) {
    // Generate mock at-risk customers data
    final allCustomers = [
      {
        'customer_name': 'Vijay Kumar',
        'policy_number': 'POL001234',
        'risk_level': 'high',
        'risk_score': 85.0,
        'premium_value': 25000,
        'last_payment_date': '2024-11-01',
        'engagement_score': 25,
        'complaints_count': 3,
        'support_queries': 8,
        'policy_age_months': 24,
        'missed_payments': 2,
        'days_since_contact': 35,
        'policy_type': 'term_life',
        'risk_factors': ['Payment delays', 'Low engagement', 'Multiple complaints'],
        'last_retention_action': {
          'description': 'Retention call made - offered payment plan',
          'date': '2024-11-20',
        },
        'retention_plan': {
          'next_action': 'Schedule follow-up meeting',
          'priority': 'high',
        },
      },
      {
        'customer_name': 'Anjali Gupta',
        'policy_number': 'POL001235',
        'risk_level': 'high',
        'risk_score': 78.0,
        'premium_value': 15000,
        'last_payment_date': '2024-10-15',
        'engagement_score': 15,
        'complaints_count': 5,
        'support_queries': 12,
        'policy_age_months': 18,
        'missed_payments': 3,
        'days_since_contact': 45,
        'policy_type': 'health',
        'risk_factors': ['Payment delays', 'High complaints', 'Low engagement'],
        'last_retention_action': {
          'description': 'Email sent with discount offer',
          'date': '2024-11-18',
        },
        'retention_plan': {
          'next_action': 'Personal visit to discuss concerns',
          'priority': 'urgent',
        },
      },
      {
        'customer_name': 'Rajesh Patel',
        'policy_number': 'POL001236',
        'risk_level': 'medium',
        'risk_score': 65.0,
        'premium_value': 50000,
        'last_payment_date': '2024-11-10',
        'engagement_score': 45,
        'complaints_count': 1,
        'support_queries': 2,
        'policy_age_months': 36,
        'missed_payments': 1,
        'days_since_contact': 20,
        'policy_type': 'ulip',
        'risk_factors': ['Recent payment delay'],
        'last_retention_action': {
          'description': 'WhatsApp message sent for renewal reminder',
          'date': '2024-11-25',
        },
        'retention_plan': {
          'next_action': 'Follow-up call in 3 days',
          'priority': 'medium',
        },
      },
      {
        'customer_name': 'Priya Singh',
        'policy_number': 'POL001237',
        'risk_level': 'medium',
        'risk_score': 55.0,
        'premium_value': 12000,
        'last_payment_date': '2024-11-05',
        'engagement_score': 35,
        'complaints_count': 2,
        'support_queries': 4,
        'policy_age_months': 12,
        'missed_payments': 1,
        'days_since_contact': 25,
        'policy_type': 'health',
        'risk_factors': ['Low engagement', 'Recent policy'],
        'last_retention_action': {
          'description': 'Policy benefits email sent',
          'date': '2024-11-22',
        },
        'retention_plan': {
          'next_action': 'Educational call about benefits',
          'priority': 'medium',
        },
      },
      {
        'customer_name': 'Amit Sharma',
        'policy_number': 'POL001238',
        'risk_level': 'high',
        'risk_score': 92.0,
        'premium_value': 35000,
        'last_payment_date': '2024-09-01',
        'engagement_score': 10,
        'complaints_count': 6,
        'support_queries': 15,
        'policy_age_months': 48,
        'missed_payments': 4,
        'days_since_contact': 60,
        'policy_type': 'comprehensive',
        'risk_factors': ['Multiple payment delays', 'High complaints', 'Very low engagement', 'Long time no contact'],
        'last_retention_action': {
          'description': 'Urgent retention meeting scheduled',
          'date': '2024-11-15',
        },
        'retention_plan': {
          'next_action': 'Senior agent intervention required',
          'priority': 'urgent',
        },
      },
      {
        'customer_name': 'Sunita Reddy',
        'policy_number': 'POL001239',
        'risk_level': 'low',
        'risk_score': 35.0,
        'premium_value': 8000,
        'last_payment_date': '2024-11-20',
        'engagement_score': 75,
        'complaints_count': 0,
        'support_queries': 1,
        'policy_age_months': 8,
        'missed_payments': 0,
        'days_since_contact': 15,
        'policy_type': 'two_wheeler',
        'risk_factors': ['Recent policy holder'],
        'last_retention_action': {
          'description': 'Welcome call completed successfully',
          'date': '2024-11-28',
        },
        'retention_plan': {
          'next_action': 'Regular check-in in 30 days',
          'priority': 'low',
        },
      },
      {
        'customer_name': 'Karan Mehta',
        'policy_number': 'POL001240',
        'risk_level': 'medium',
        'risk_score': 58.0,
        'premium_value': 30000,
        'last_payment_date': '2024-11-08',
        'engagement_score': 55,
        'complaints_count': 1,
        'support_queries': 3,
        'policy_age_months': 30,
        'missed_payments': 1,
        'days_since_contact': 18,
        'policy_type': 'term_life',
        'risk_factors': ['Minor payment delay', 'Moderate engagement'],
        'last_retention_action': {
          'description': 'Payment reminder call',
          'date': '2024-11-26',
        },
        'retention_plan': {
          'next_action': 'Monitor payment status',
          'priority': 'medium',
        },
      },
      {
        'customer_name': 'Neha Jain',
        'policy_number': 'POL001241',
        'risk_level': 'high',
        'risk_score': 88.0,
        'premium_value': 18000,
        'last_payment_date': '2024-10-25',
        'engagement_score': 20,
        'complaints_count': 4,
        'support_queries': 9,
        'policy_age_months': 15,
        'missed_payments': 2,
        'days_since_contact': 28,
        'policy_type': 'health',
        'risk_factors': ['Payment delays', 'Multiple complaints', 'Low engagement'],
        'last_retention_action': {
          'description': 'Retention package offered via email',
          'date': '2024-11-19',
        },
        'retention_plan': {
          'next_action': 'Follow-up on package acceptance',
          'priority': 'high',
        },
      },
    ];

    // Filter customers based on criteria
    var filteredCustomers = allCustomers;

    if (riskLevel != 'all') {
      filteredCustomers = filteredCustomers.where((customer) => customer['risk_level'] == riskLevel).toList();
    }

    if (priority != 'all') {
      filteredCustomers = filteredCustomers.where((customer) {
        final retentionPriority = customer['retention_plan']?['priority'] ?? 'medium';
        return retentionPriority == priority;
      }).toList();
    }

    // Calculate statistics
    final totalAtRisk = filteredCustomers.length;
    final highRisk = filteredCustomers.where((c) => c['risk_level'] == 'high').length;
    final mediumRisk = filteredCustomers.where((c) => c['risk_level'] == 'medium').length;
    final lowRisk = filteredCustomers.where((c) => c['risk_level'] == 'low').length;

    final totalRevenueAtRisk = filteredCustomers.isEmpty ? 0 : filteredCustomers.map((c) => c['premium_value'] as int).reduce((a, b) => a + b);
    final avgRiskScore = filteredCustomers.isEmpty ? 0 : filteredCustomers.map((c) => c['risk_score'] as double).reduce((a, b) => a + b) / filteredCustomers.length;

    final churnRiskPercentage = 24.5;
    final retentionRate = 87.3;
    final avgResponseDays = 2.1;
    final revenueSaved = 125000;

    // Mock retention actions
    final retentionActions = [
      {
        'id': '1',
        'customer_name': 'Vijay Kumar',
        'action_type': 'call',
        'description': 'Schedule retention meeting to discuss payment plan',
        'status': 'pending',
        'priority': 'high',
        'due_date': '2024-12-01',
        'progress': 0.0,
      },
      {
        'id': '2',
        'customer_name': 'Anjali Gupta',
        'action_type': 'meeting',
        'description': 'Personal visit to address concerns and offer solutions',
        'status': 'in_progress',
        'priority': 'urgent',
        'due_date': '2024-11-30',
        'progress': 0.6,
      },
      {
        'id': '3',
        'customer_name': 'Rajesh Patel',
        'action_type': 'email',
        'description': 'Send renewal reminder with discount offer',
        'status': 'completed',
        'priority': 'medium',
        'outcome': {
          'description': 'Customer agreed to renewal with 10% discount',
          'value': 5000,
        },
      },
      {
        'id': '4',
        'customer_name': 'Amit Sharma',
        'action_type': 'personal_visit',
        'description': 'Senior agent intervention for high-risk customer',
        'status': 'pending',
        'priority': 'urgent',
        'due_date': '2024-11-29',
        'progress': 0.0,
      },
    ];

    return {
      'statistics': {
        'total_at_risk': totalAtRisk,
        'churn_risk_percentage': churnRiskPercentage,
        'retention_rate': retentionRate,
        'revenue_at_risk': totalRevenueAtRisk,
        'avg_risk_score': avgRiskScore,
        'churn_trend': 'decreasing',
        'retention_trend': 'improving',
        'revenue_trend': 'stable',
        'score_trend': 'stable',
        'thirty_day_trend': 'decreasing',
        'thirty_day_change': -3,
        'ninety_day_trend': 'decreasing',
        'ninety_day_change': -8,
        'year_trend': 'decreasing',
        'year_change': -12,
        'prevented_churn': 12,
        'recovered_customers': 8,
        'active_interventions': 15,
      },
      'risk_distribution': {
        'high': highRisk,
        'medium': mediumRisk,
        'low': lowRisk,
      },
      'retention_performance': {
        'success_rate': 78.5,
        'avg_response_days': avgResponseDays,
        'revenue_saved': revenueSaved,
      },
      'common_risk_factors': [
        {'type': 'payment', 'percentage': 65, 'description': 'Payment delays and missed payments'},
        {'type': 'engagement', 'percentage': 45, 'description': 'Low engagement and interaction'},
        {'type': 'support', 'percentage': 35, 'description': 'High support queries and complaints'},
        {'type': 'policy_age', 'percentage': 25, 'description': 'Recent policy holders at higher risk'},
      ],
      'retention_actions_summary': {
        'pending': 8,
        'in_progress': 5,
        'completed': 12,
        'successful': 9,
      },
      'retention_strategies': [
        {
          'title': 'Personal Retention Calls',
          'description': 'Direct phone contact with personalized retention offers',
          'success_rate': 85,
        },
        {
          'title': 'Email Retention Campaigns',
          'description': 'Automated email sequences with special offers',
          'success_rate': 62,
        },
        {
          'title': 'Loyalty Discounts',
          'description': 'Premium discounts for loyal customers',
          'success_rate': 78,
        },
        {
          'title': 'Policy Review Meetings',
          'description': 'In-person meetings to review and optimize policies',
          'success_rate': 92,
        },
      ],
      'customers': filteredCustomers,
      'retention_actions': retentionActions,
    };
  }

  /// Mock customer policyholder data for development
  Map<String, dynamic> _getMockCustomerPolicyholderData(String customerId) {
    return {
      'customer_name': 'Rajesh Kumar',
      'policyholder_id': 'PH001234',
      'quick_stats': {
        'active_policies': 2,
        'total_coverage': 5000000,
        'pending_claims': 1,
      },
      'policies': [
        {
          'policy_number': 'POL001234',
          'policy_type': 'term_life',
          'coverage_amount': 3000000,
          'premium_amount': 25000,
          'expiry_date': '2025-12-15',
          'status': 'active',
        },
        {
          'policy_number': 'POL001235',
          'policy_type': 'health',
          'coverage_amount': 2000000,
          'premium_amount': 15000,
          'expiry_date': '2025-08-20',
          'status': 'active',
        },
      ],
      'premium_data': {
        'next_due_date': '2024-12-15',
        'due_amount': 40000,
        'payment_status': 'paid',
        'auto_pay_enabled': true,
        'payment_history': [
          {
            'amount': 40000,
            'date': '2024-11-15',
            'status': 'completed',
            'method': 'Auto Pay',
          },
          {
            'amount': 40000,
            'date': '2024-10-15',
            'status': 'completed',
            'method': 'Online',
          },
          {
            'amount': 40000,
            'date': '2024-09-15',
            'status': 'completed',
            'method': 'Online',
          },
        ],
      },
      'claims': [
        {
          'claim_number': 'CLM001234',
          'policy_number': 'POL001235',
          'claim_amount': 75000,
          'claim_type': 'Health',
          'status': 'processing',
          'submitted_date': '2024-11-20',
        },
      ],
      'quick_actions': [
        {'id': 'pay_premium', 'title': 'Pay Premium', 'available': true},
        {'id': 'file_claim', 'title': 'File Claim', 'available': true},
        {'id': 'download_docs', 'title': 'Download Documents', 'available': true},
        {'id': 'contact_agent', 'title': 'Contact Agent', 'available': true},
        {'id': 'update_profile', 'title': 'Update Profile', 'available': true},
        {'id': 'view_history', 'title': 'Payment History', 'available': true},
      ],
      'recent_activity': [
        {
          'type': 'payment',
          'description': 'Premium payment of ₹40,000 received',
          'date': '2 days ago',
        },
        {
          'type': 'policy',
          'description': 'Policy POL001235 documents updated',
          'date': '1 week ago',
        },
        {
          'type': 'claim',
          'description': 'Claim CLM001234 submitted for processing',
          'date': '2 weeks ago',
        },
        {
          'type': 'support',
          'description': 'Support ticket #12345 resolved',
          'date': '3 weeks ago',
        },
      ],
    };
  }
}
