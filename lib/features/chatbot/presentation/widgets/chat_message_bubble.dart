import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/chatbot_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onQuickReplySelected;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onQuickReplySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';

    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          _buildAvatar(),
          const SizedBox(width: 8),
        ],

        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: isUser ? const Color(0xFF1a237e) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 16 : 4),
                    topRight: Radius.circular(isUser ? 4 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),

                    // Quick replies for bot messages
                    if (!isUser && message.metadata?['quick_replies'] != null)
                      _buildQuickReplies(message.metadata!['quick_replies']),

                    // Agent escalation notice
                    if (!isUser && message.metadata?['requires_agent'] == true)
                      _buildEscalationNotice(message.metadata!['escalation_reason']),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Timestamp and Status
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                  if (message.sender == 'user') ...[
                    const SizedBox(width: 4),
                    _buildMessageStatus(),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (isUser) ...[
          const SizedBox(width: 8),
          _buildAvatar(),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    final isUser = message.sender == 'user';

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? Colors.grey.shade300 : const Color(0xFF1a237e),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.grey.shade700 : Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildQuickReplies(List<dynamic> quickReplies) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: quickReplies.map((reply) {
          return GestureDetector(
            onTap: () {
              if (onQuickReplySelected != null) {
                onQuickReplySelected!(reply.toString());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                reply.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEscalationNotice(String? reason) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.support_agent,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              reason ?? 'Transferring to human agent...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    // Simple status indicator - could be enhanced with actual delivery status
    return Icon(
      Icons.check,
      size: 12,
      color: message.isRead == true ? Colors.blue : Colors.grey,
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
