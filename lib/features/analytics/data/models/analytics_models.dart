/// Analytics data models for charts and reports

class ChartDataPoint {
  final String date;
  final double value;
  final String? label;
  final String? category;

  ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
    this.category,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: json['date'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      label: json['label'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'value': value,
      'label': label,
      'category': category,
    };
  }
}

class AnalyticsReport {
  final String reportId;
  final String title;
  final String type;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
  final String? description;

  AnalyticsReport({
    required this.reportId,
    required this.title,
    required this.type,
    required this.generatedAt,
    required this.data,
    this.description,
  });

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    return AnalyticsReport(
      reportId: json['report_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      generatedAt: DateTime.parse(json['generated_at'] ?? DateTime.now().toIso8601String()),
      data: json['data'] ?? {},
      description: json['description'],
    );
  }
}

class AgentPerformance {
  final String agentId;
  final String agentName;
  final int policiesSold;
  final double premiumCollected;
  final double commissionEarned;
  final int customersAcquired;
  final double conversionRate;
  final double customerSatisfaction;

  AgentPerformance({
    required this.agentId,
    required this.agentName,
    required this.policiesSold,
    required this.premiumCollected,
    required this.commissionEarned,
    required this.customersAcquired,
    required this.conversionRate,
    required this.customerSatisfaction,
  });

  factory AgentPerformance.fromJson(Map<String, dynamic> json) {
    return AgentPerformance(
      agentId: json['agent_id'] ?? '',
      agentName: json['agent_name'] ?? '',
      policiesSold: json['policies_sold'] ?? 0,
      premiumCollected: (json['premium_collected'] ?? 0.0).toDouble(),
      commissionEarned: (json['commission_earned'] ?? 0.0).toDouble(),
      customersAcquired: json['customers_acquired'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0.0).toDouble(),
      customerSatisfaction: (json['customer_satisfaction'] ?? 0.0).toDouble(),
    );
  }
}

class TopAgentsReport {
  final List<AgentPerformance> topAgents;
  final String period;
  final DateTime generatedAt;

  TopAgentsReport({
    required this.topAgents,
    required this.period,
    required this.generatedAt,
  });

  factory TopAgentsReport.fromJson(Map<String, dynamic> json) {
    return TopAgentsReport(
      topAgents: (json['top_agents'] as List<dynamic>?)
          ?.map((agent) => AgentPerformance.fromJson(agent))
          .toList() ?? [],
      period: json['period'] ?? '',
      generatedAt: DateTime.parse(json['generated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
