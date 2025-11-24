/// Callback request data models
class CallbackRequest {
  final String callbackRequestId;
  final String policyholderId;
  final String? agentId;
  final String requestType;
  final String description;
  final String priority;
  final double priorityScore;
  final String status;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final DateTime? dueAt;
  final DateTime? createdAt;

  CallbackRequest({
    required this.callbackRequestId,
    required this.policyholderId,
    this.agentId,
    required this.requestType,
    required this.description,
    required this.priority,
    required this.priorityScore,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    this.dueAt,
    this.createdAt,
  });

  factory CallbackRequest.fromJson(Map<String, dynamic> json) {
    return CallbackRequest(
      callbackRequestId: json['callback_request_id'] ?? json['data']?['callback_request_id'] ?? '',
      policyholderId: json['policyholder_id'] ?? json['data']?['policyholder_id'] ?? '',
      agentId: json['agent_id'] ?? json['data']?['agent_id'],
      requestType: json['request_type'] ?? json['data']?['request_type'] ?? '',
      description: json['description'] ?? json['data']?['description'] ?? '',
      priority: json['priority'] ?? json['data']?['priority'] ?? 'low',
      priorityScore: (json['priority_score'] ?? json['data']?['priority_score'] ?? 0).toDouble(),
      status: json['status'] ?? json['data']?['status'] ?? 'pending',
      customerName: json['customer_name'] ?? json['data']?['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? json['data']?['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? json['data']?['customer_email'],
      dueAt: json['due_at'] != null ? DateTime.tryParse(json['due_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'policyholder_id': policyholderId,
      'request_type': requestType,
      'description': description,
      'urgency_level': 'medium',
      'customer_value': 'bronze',
      'source': 'mobile',
    };
  }
}

