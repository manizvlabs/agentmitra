import '../../features/auth/data/models/user_model.dart';
import '../../features/notifications/data/models/notification_model.dart';
import '../../features/chatbot/data/models/chatbot_model.dart';
import '../../features/agent/data/models/agent_model.dart';

/// Comprehensive mock data for production-grade testing
class MockData {
  // User Models
  static UserModel get mockUser => UserModel(
        userId: 'user_123',
        phoneNumber: '+91 9876543210',
        email: 'john.doe@example.com',
        fullName: 'John Doe',
        agentCode: 'AGT001',
        role: 'agent',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

  static UserModel get mockCustomer => UserModel(
        userId: 'cust_456',
        phoneNumber: '+91 9876543211',
        email: 'jane.smith@example.com',
        fullName: 'Jane Smith',
        role: 'customer',
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      );

  // Notification Models
  static List<NotificationModel> get mockNotifications => [
    NotificationModel(
      id: 'notif_001',
      title: 'Policy Renewal Reminder',
      body: 'Your policy POL001 is due for renewal in 7 days',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.policy,
      priority: NotificationPriority.medium,
      isRead: false,
      actionUrl: '/policies',
      actionText: 'View Policy',
      category: 'policy',
    ),
    NotificationModel(
      id: 'notif_002',
      title: 'Payment Reminder',
      body: 'Premium payment of ₹2,500 is due tomorrow',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.payment,
      priority: NotificationPriority.high,
      isRead: false,
      actionUrl: '/payments',
      actionText: 'Pay Now',
      category: 'payment',
    ),
    NotificationModel(
      id: 'notif_003',
      title: 'Claim Approved',
      body: 'Your claim CLM001 has been approved for ₹50,000',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.claim,
      priority: NotificationPriority.medium,
      isRead: true,
      actionUrl: '/claims',
      actionText: 'View Details',
      category: 'claim',
    ),
    NotificationModel(
      id: 'notif_004',
      title: 'Policy Expiring Soon',
      body: 'Policy POL002 expires in 30 days',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.renewal,
      priority: NotificationPriority.low,
      isRead: false,
      actionUrl: '/policies',
      actionText: 'Renew Now',
      category: 'renewal',
    ),
    NotificationModel(
      id: 'notif_005',
      title: 'New Marketing Offer',
      body: 'Special discount on life insurance policies',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.marketing,
      priority: NotificationPriority.low,
      isRead: true,
      actionUrl: '/offers',
      actionText: 'View Offer',
      category: 'marketing',
    ),
  ];

  static NotificationSettings get mockNotificationSettings => NotificationSettings(
        enablePushNotifications: true,
        enablePolicyNotifications: true,
        enablePaymentReminders: true,
        enableClaimUpdates: true,
        enableRenewalNotices: true,
        enableMarketingNotifications: false,
        enableSound: true,
        enableVibration: true,
        showBadge: true,
        quietHoursEnabled: false,
        enabledTopics: ['policy', 'payment', 'claim'],
      );

  // Chat Models
  static ChatSession get mockChatSession => ChatSession(
        sessionId: 'chat_123',
        agentId: 'agent_001',
        customerId: 'user_123',
        startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'active',
        topic: 'Policy Inquiry',
        messageCount: 6,
      );

  static List<ChatMessage> get mockChatMessages => [
    ChatMessage(
      messageId: 'msg_001',
      sessionId: 'chat_123',
      content: 'Hello! How can I help you with your insurance needs today?',
      sender: 'bot',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      messageType: 'text',
    ),
    ChatMessage(
      messageId: 'msg_002',
      sessionId: 'chat_123',
      content: 'I need help understanding my policy coverage',
      sender: 'user',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      messageType: 'text',
    ),
    ChatMessage(
      messageId: 'msg_003',
      sessionId: 'chat_123',
      content: 'I\'d be happy to help you understand your policy coverage. Could you please provide your policy number?',
      sender: 'bot',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      messageType: 'text',
    ),
    ChatMessage(
      messageId: 'msg_004',
      sessionId: 'chat_123',
      content: 'My policy number is POL001',
      sender: 'user',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      messageType: 'text',
    ),
    ChatMessage(
      messageId: 'msg_005',
      sessionId: 'chat_123',
      content: 'Thank you for providing your policy number. Let me look up your policy details...',
      sender: 'bot',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      messageType: 'text',
    ),
    ChatMessage(
      messageId: 'msg_006',
      sessionId: 'chat_123',
      content: 'I found your policy! It covers health, life, and vehicle insurance. Would you like me to explain any specific coverage?',
      sender: 'bot',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      messageType: 'text',
    ),
  ];

  // Utility methods
  static List<NotificationModel> getUnreadNotifications() =>
      mockNotifications.where((n) => !n.isRead).toList();

  static List<NotificationModel> getRecentNotifications() =>
      mockNotifications.where((n) => n.isRecent).toList();

  static List<NotificationModel> getNotificationsByType(NotificationType type) =>
      mockNotifications.where((n) => n.type == type).toList();

  static List<NotificationModel> getNotificationsByPriority(NotificationPriority priority) =>
      mockNotifications.where((n) => n.priority == priority).toList();

  // Agent Profile Mock
  static AgentProfile get mockAgentProfile => AgentProfile(
        agentId: 'agent_123',
        userId: 'user_123',
        agentCode: 'AGT001',
        licenseNumber: 'LIC2023001',
        licenseExpiryDate: DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        companyName: 'ABC Insurance',
        branchName: 'Mumbai Central',
        designation: 'Senior Insurance Agent',
        department: 'Life Insurance',
        joiningDate: DateTime.now().subtract(const Duration(days: 365)),
        employmentStatus: 'active',
        contactDetails: {
          'phone': '+91 9876543210',
          'email': 'rajesh.kumar@abcinsurance.com',
          'address': '123 MG Road, Mumbai, Maharashtra 400001'
        },
        verificationStatus: 'verified',
        lastVerificationDate: DateTime.now().subtract(const Duration(days: 30)),
        performanceMetrics: {
          'totalPolicies': 156,
          'commissionEarned': 125000.0,
          'customerSatisfaction': 4.5,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

  // Simple Claim Model (since Freezed version doesn't exist)
  static Map<String, dynamic> get mockClaim => {
    'claimId': 'CLM001',
    'policyId': 'POL001',
    'customerId': 'CUST001',
    'customerName': 'John Doe',
    'claimAmount': 50000.0,
    'claimReason': 'Medical Emergency',
    'description': 'Hospitalization due to accident',
    'status': 'approved',
    'submittedDate': DateTime.now().subtract(const Duration(days: 7)),
    'approvedDate': DateTime.now().subtract(const Duration(days: 3)),
    'documents': ['medical_report.pdf', 'bill_receipt.pdf'],
    'comments': 'Claim approved after document verification',
  };

  // Simple Policy Model (using the Freezed Policy class)
  static Map<String, dynamic> get mockPolicyData => {
    'policyId': 'POL001',
    'policyNumber': 'LI2023001',
    'providerPolicyId': 'EXT_POL_001',
    'policyholderId': 'CUST001',
    'agentId': 'agent_123',
    'providerId': 'PROV001',
    'policyType': 'Life Insurance',
    'planName': 'Comprehensive Life Plan',
    'planCode': 'LIFE_COMP_001',
    'category': 'Life Insurance',
    'sumAssured': 500000.0,
    'premiumAmount': 5000.0,
    'premiumFrequency': 'monthly',
    'premiumMode': 'online',
    'applicationDate': DateTime.now().subtract(const Duration(days: 30)),
    'approvalDate': DateTime.now().subtract(const Duration(days: 25)),
    'startDate': DateTime.now().subtract(const Duration(days: 25)),
    'maturityDate': DateTime.now().add(const Duration(days: 35 * 365)),
    'renewalDate': DateTime.now().add(const Duration(days: 365)),
    'status': 'active',
    'paymentStatus': 'paid',
    'coverageDetails': {
      'deathBenefit': 500000.0,
      'criticalIllness': 250000.0,
      'accidentBenefit': 100000.0,
    },
    'policyDocumentUrl': 'https://example.com/policy.pdf',
    'lastPaymentDate': DateTime.now().subtract(const Duration(days: 30)),
    'nextPaymentDate': DateTime.now().add(const Duration(days: 30)),
    'outstandingAmount': 0.0,
  };
}
