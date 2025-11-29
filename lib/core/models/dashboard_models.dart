/// Dashboard Data Models

class SystemOverviewData {
  final int totalUsers;
  final int activeUsers;
  final int totalAgents;
  final int activeAgents;
  final int totalPolicies;
  final int activePolicies;
  final double totalPremium;
  final double monthlyRevenue;
  final int activeSessions;
  final double systemHealth;
  final int apiCalls24h;
  final int pendingApprovals;

  SystemOverviewData({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalAgents,
    required this.activeAgents,
    required this.totalPolicies,
    required this.activePolicies,
    required this.totalPremium,
    required this.monthlyRevenue,
    required this.activeSessions,
    required this.systemHealth,
    required this.apiCalls24h,
    required this.pendingApprovals,
  });

  factory SystemOverviewData.fromJson(Map<String, dynamic> json) {
    return SystemOverviewData(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalAgents: json['totalAgents'] ?? 0,
      activeAgents: json['activeAgents'] ?? 0,
      totalPolicies: json['totalPolicies'] ?? 0,
      activePolicies: json['activePolicies'] ?? 0,
      totalPremium: (json['totalPremium'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      activeSessions: json['activeSessions'] ?? 0,
      systemHealth: (json['systemHealth'] ?? 0).toDouble(),
      apiCalls24h: json['apiCalls24h'] ?? 0,
      pendingApprovals: json['pendingApprovals'] ?? 0,
    );
  }

  factory SystemOverviewData.empty() {
    return SystemOverviewData(
      totalUsers: 0,
      activeUsers: 0,
      totalAgents: 0,
      activeAgents: 0,
      totalPolicies: 0,
      activePolicies: 0,
      totalPremium: 0.0,
      monthlyRevenue: 0.0,
      activeSessions: 0,
      systemHealth: 0.0,
      apiCalls24h: 0,
      pendingApprovals: 0,
    );
  }
}

class ProviderOverviewData {
  final int totalAgents;
  final int activeAgents;
  final int totalPolicies;
  final double monthlyRevenue;
  final int pendingVerifications;
  final List<TopPerformingAgent> topPerformingAgents;
  final List<RecentPolicy> recentPolicies;

  ProviderOverviewData({
    required this.totalAgents,
    required this.activeAgents,
    required this.totalPolicies,
    required this.monthlyRevenue,
    required this.pendingVerifications,
    required this.topPerformingAgents,
    required this.recentPolicies,
  });

  factory ProviderOverviewData.fromJson(Map<String, dynamic> json) {
    return ProviderOverviewData(
      totalAgents: json['totalAgents'] ?? 0,
      activeAgents: json['activeAgents'] ?? 0,
      totalPolicies: json['totalPolicies'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      pendingVerifications: json['pendingVerifications'] ?? 0,
      topPerformingAgents: (json['topPerformingAgents'] as List<dynamic>?)
          ?.map((e) => TopPerformingAgent.fromJson(e))
          .toList() ?? [],
      recentPolicies: (json['recentPolicies'] as List<dynamic>?)
          ?.map((e) => RecentPolicy.fromJson(e))
          .toList() ?? [],
    );
  }

  factory ProviderOverviewData.empty() {
    return ProviderOverviewData(
      totalAgents: 0,
      activeAgents: 0,
      totalPolicies: 0,
      monthlyRevenue: 0.0,
      pendingVerifications: 0,
      topPerformingAgents: [],
      recentPolicies: [],
    );
  }
}

class TopPerformingAgent {
  final String agentId;
  final String name;
  final int policiesSold;
  final double totalPremium;

  TopPerformingAgent({
    required this.agentId,
    required this.name,
    required this.policiesSold,
    required this.totalPremium,
  });

  factory TopPerformingAgent.fromJson(Map<String, dynamic> json) {
    return TopPerformingAgent(
      agentId: json['agentId'] ?? '',
      name: json['name'] ?? '',
      policiesSold: json['policiesSold'] ?? 0,
      totalPremium: (json['totalPremium'] ?? 0).toDouble(),
    );
  }
}

class RecentPolicy {
  final String policyId;
  final String policyNumber;
  final String customerName;
  final double premiumAmount;
  final String? createdAt;

  RecentPolicy({
    required this.policyId,
    required this.policyNumber,
    required this.customerName,
    required this.premiumAmount,
    this.createdAt,
  });

  factory RecentPolicy.fromJson(Map<String, dynamic> json) {
    return RecentPolicy(
      policyId: json['policyId'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      premiumAmount: (json['premiumAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'],
    );
  }
}

class RegionalOverviewData {
  final int totalAgents;
  final int activeAgents;
  final double regionalRevenue;
  final double monthlyGrowth;
  final List<TopPerformer> topPerformers;
  final Map<String, dynamic> regionalStats;

  RegionalOverviewData({
    required this.totalAgents,
    required this.activeAgents,
    required this.regionalRevenue,
    required this.monthlyGrowth,
    required this.topPerformers,
    required this.regionalStats,
  });

  factory RegionalOverviewData.fromJson(Map<String, dynamic> json) {
    return RegionalOverviewData(
      totalAgents: json['totalAgents'] ?? 0,
      activeAgents: json['activeAgents'] ?? 0,
      regionalRevenue: (json['regionalRevenue'] ?? 0).toDouble(),
      monthlyGrowth: (json['monthlyGrowth'] ?? 0).toDouble(),
      topPerformers: (json['topPerformers'] as List<dynamic>?)
          ?.map((e) => TopPerformer.fromJson(e))
          .toList() ?? [],
      regionalStats: json['regionalStats'] ?? {},
    );
  }

  factory RegionalOverviewData.empty() {
    return RegionalOverviewData(
      totalAgents: 0,
      activeAgents: 0,
      regionalRevenue: 0.0,
      monthlyGrowth: 0.0,
      topPerformers: [],
      regionalStats: {},
    );
  }
}

class TopPerformer {
  final String agentId;
  final String name;
  final int policiesSold;
  final double totalPremium;

  TopPerformer({
    required this.agentId,
    required this.name,
    required this.policiesSold,
    required this.totalPremium,
  });

  factory TopPerformer.fromJson(Map<String, dynamic> json) {
    return TopPerformer(
      agentId: json['agentId'] ?? '',
      name: json['name'] ?? '',
      policiesSold: json['policiesSold'] ?? 0,
      totalPremium: (json['totalPremium'] ?? 0).toDouble(),
    );
  }
}

class SeniorAgentOverviewData {
  final Map<String, dynamic> personalStats;
  final Map<String, dynamic> teamStats;
  final double monthlyRevenue;
  final int pendingTasks;
  final List<TopCustomer> topCustomers;
  final List<RecentActivity> recentActivities;

  SeniorAgentOverviewData({
    required this.personalStats,
    required this.teamStats,
    required this.monthlyRevenue,
    required this.pendingTasks,
    required this.topCustomers,
    required this.recentActivities,
  });

  factory SeniorAgentOverviewData.fromJson(Map<String, dynamic> json) {
    return SeniorAgentOverviewData(
      personalStats: json['personalStats'] ?? {},
      teamStats: json['teamStats'] ?? {},
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      pendingTasks: json['pendingTasks'] ?? 0,
      topCustomers: (json['topCustomers'] as List<dynamic>?)
          ?.map((e) => TopCustomer.fromJson(e))
          .toList() ?? [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
          ?.map((e) => RecentActivity.fromJson(e))
          .toList() ?? [],
    );
  }

  factory SeniorAgentOverviewData.empty() {
    return SeniorAgentOverviewData(
      personalStats: {},
      teamStats: {},
      monthlyRevenue: 0.0,
      pendingTasks: 0,
      topCustomers: [],
      recentActivities: [],
    );
  }
}

class TopCustomer {
  final String customerId;
  final String name;
  final int policyCount;
  final double totalPremium;

  TopCustomer({
    required this.customerId,
    required this.name,
    required this.policyCount,
    required this.totalPremium,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerId: json['customerId'] ?? '',
      name: json['name'] ?? '',
      policyCount: json['policyCount'] ?? 0,
      totalPremium: (json['totalPremium'] ?? 0).toDouble(),
    );
  }
}

class RecentActivity {
  final String type;
  final String description;
  final String? timestamp;
  final double amount;

  RecentActivity({
    required this.type,
    required this.description,
    this.timestamp,
    required this.amount,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'],
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
