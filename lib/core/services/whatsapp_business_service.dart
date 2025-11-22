import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'logger_service.dart';

/// WhatsApp Business API Integration Service
/// Handles WhatsApp Business messaging with pre-filled context sharing
class WhatsAppBusinessService {
  static const String _whatsappUrlScheme = 'whatsapp://send';
  static const String _whatsappWebUrl = 'https://wa.me/';

  // Business phone numbers (configurable)
  static const String _defaultBusinessNumber = '+919876543210';

  /// Send WhatsApp message with pre-filled content
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
    Map<String, dynamic>? contextData,
  }) async {
    try {
      final formattedNumber = _formatPhoneNumber(phoneNumber);
      final enhancedMessage = _enhanceMessageWithContext(message, contextData);

      final url = _buildWhatsAppUrl(formattedNumber, enhancedMessage);

      LoggerService().info('Sending WhatsApp message to $formattedNumber');

      final success = await _launchUrl(url);

      if (success) {
        LoggerService().info('WhatsApp message sent successfully');
        return true;
      } else {
        LoggerService().error('Failed to launch WhatsApp');
        return false;
      }
    } catch (e) {
      LoggerService().error('Error sending WhatsApp message: $e');
      return false;
    }
  }

  /// Send policy-related WhatsApp message
  static Future<bool> sendPolicyMessage({
    required String phoneNumber,
    required String policyNumber,
    required String policyType,
    String? customMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = customMessage ?? _buildPolicyMessage(policyNumber, policyType);
    final contextData = {
      'type': 'policy',
      'policyNumber': policyNumber,
      'policyType': policyType,
      ...?additionalData,
    };

    return sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      contextData: contextData,
    );
  }

  /// Send quote-related WhatsApp message
  static Future<bool> sendQuoteMessage({
    required String phoneNumber,
    required String quote,
    String? agentName,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = _buildQuoteMessage(quote, agentName);
    final contextData = {
      'type': 'quote',
      'quote': quote,
      ...?additionalData,
    };

    return sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      contextData: contextData,
    );
  }

  /// Send premium reminder WhatsApp message
  static Future<bool> sendPremiumReminder({
    required String phoneNumber,
    required String policyNumber,
    required double premiumAmount,
    required DateTime dueDate,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = _buildPremiumReminderMessage(
      policyNumber,
      premiumAmount,
      dueDate,
    );
    final contextData = {
      'type': 'premium_reminder',
      'policyNumber': policyNumber,
      'premiumAmount': premiumAmount,
      'dueDate': dueDate.toIso8601String(),
      ...?additionalData,
    };

    return sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      contextData: contextData,
    );
  }

  /// Send claim assistance WhatsApp message
  static Future<bool> sendClaimAssistance({
    required String phoneNumber,
    required String policyNumber,
    required String claimType,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = _buildClaimAssistanceMessage(policyNumber, claimType);
    final contextData = {
      'type': 'claim_assistance',
      'policyNumber': policyNumber,
      'claimType': claimType,
      ...?additionalData,
    };

    return sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      contextData: contextData,
    );
  }

  /// Send document request WhatsApp message
  static Future<bool> sendDocumentRequest({
    required String phoneNumber,
    required List<String> requiredDocuments,
    String? policyNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    final message = _buildDocumentRequestMessage(requiredDocuments, policyNumber);
    final contextData = {
      'type': 'document_request',
      'requiredDocuments': requiredDocuments,
      'policyNumber': policyNumber,
      ...?additionalData,
    };

    return sendMessage(
      phoneNumber: phoneNumber,
      message: message,
      contextData: contextData,
    );
  }

  /// Share content via WhatsApp (fallback to system share)
  static Future<bool> shareContent({
    required String content,
    String? subject,
  }) async {
    try {
      await Share.share(
        content,
        subject: subject,
      );
      return true;
    } catch (e) {
      LoggerService().error('Error sharing content: $e');
      return false;
    }
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final url = Uri.parse(_whatsappUrlScheme);
      return await canLaunchUrl(url);
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for WhatsApp URL
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    var cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with +
    if (!cleaned.startsWith('+')) {
      // Assume Indian number if no country code
      cleaned = '+91$cleaned';
    }

    return cleaned;
  }

  /// Build WhatsApp URL
  static String _buildWhatsAppUrl(String phoneNumber, String message) {
    final encodedMessage = Uri.encodeComponent(message);
    return '$_whatsappUrlScheme?phone=$phoneNumber&text=$encodedMessage';
  }

  /// Launch URL
  static Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      LoggerService().error('Error launching URL: $e');
      return false;
    }
  }

  /// Enhance message with context data
  static String _enhanceMessageWithContext(
    String message,
    Map<String, dynamic>? contextData,
  ) {
    if (contextData == null) return message;

    // Add context metadata (invisible to user but useful for tracking)
    final contextJson = json.encode(contextData);
    final contextPrefix = '<!-- Context: $contextJson -->';

    return '$contextPrefix\n\n$message';
  }

  /// Build policy-related message
  static String _buildPolicyMessage(String policyNumber, String policyType) {
    return '''Hello! 👋

I'm your LIC Agent. I'd like to discuss your *$policyType* policy (Policy No: $policyNumber).

How can I assist you today?

📞 Call me for immediate support
💬 Continue chatting here
📋 Check policy details
💰 Premium payment options

Best regards,
Your LIC Agent''';
  }

  /// Build quote message
  static String _buildQuoteMessage(String quote, String? agentName) {
    final agentSignature = agentName != null ? '\n\n- $agentName\nYour LIC Agent' : '';

    return '''🌟 *Daily Motivation*

"$quote"

Keep pushing forward! 💪$agentSignature

#Motivation #Success #LIC''';
  }

  /// Build premium reminder message
  static String _buildPremiumReminderMessage(
    String policyNumber,
    double premiumAmount,
    DateTime dueDate,
  ) {
    final formattedAmount = '₹${premiumAmount.toStringAsFixed(0)}';
    final formattedDate = '${dueDate.day}/${dueDate.month}/${dueDate.year}';

    return '''🔔 *Premium Due Reminder*

Dear Policyholder,

Your premium payment of *$formattedAmount* for Policy No: $policyNumber is due on *$formattedDate*.

⏰ Don't miss the payment deadline!
💳 Pay online for convenience
🏦 Visit nearest branch
📞 Call me for assistance

Secure your policy coverage today!

Best regards,
Your LIC Agent''';
  }

  /// Build claim assistance message
  static String _buildClaimAssistanceMessage(String policyNumber, String claimType) {
    return '''📋 *Claim Assistance Required*

Hello! I'm here to help you with your *$claimType* claim for Policy No: $policyNumber.

Please provide the following information to process your claim quickly:

1. 📅 Date of incident
2. 📄 Claim form (if available)
3. 🏥 Hospital/Doctor details
4. 💼 Supporting documents

I can guide you through the entire process!

📞 Call me: +91-XXXX-XXXXXX
💬 Reply here for immediate assistance

Your LIC Agent''';
  }

  /// Build document request message
  static String _buildDocumentRequestMessage(
    List<String> requiredDocuments,
    String? policyNumber,
  ) {
    final documentsList = requiredDocuments.map((doc) => '• $doc').join('\n');
    final policyInfo = policyNumber != null ? ' for Policy No: $policyNumber' : '';

    return '''📄 *Document Request*

Hello! To complete your verification process$policyInfo, please share the following documents:

$documentsList

📷 Please ensure:
• Documents are clear and readable
• All corners are visible
• File size under 5MB each

You can send them here or email to: documents@licagent.com

📞 Need help? Call me anytime!

Best regards,
Your LIC Agent''';
  }

  /// Pre-defined message templates
  static const Map<String, String> messageTemplates = {
    'greeting': 'Hello! 👋 I\'m your LIC Agent. How can I help you today?',
    'policy_inquiry': 'I\'d like to inquire about LIC policies. Can you provide information?',
    'premium_payment': 'I need to make a premium payment. What are my options?',
    'claim_process': 'I need assistance with filing a claim. Can you guide me?',
    'document_submission': 'I\'m ready to submit my documents for verification.',
    'policy_upgrade': 'I\'m interested in upgrading my current policy.',
  };
}
