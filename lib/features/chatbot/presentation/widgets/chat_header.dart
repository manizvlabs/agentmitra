import 'package:flutter/material.dart';
import '../../data/models/chatbot_model.dart';

class ChatHeader extends StatelessWidget {
  final ChatSession session;

  const ChatHeader({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a237e),
                  ),
                ),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (session.topic != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                session.topic!,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (session.status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'ended':
        return Colors.grey;
      case 'transferred':
        return Colors.orange;
      default:
        return Colors.yellow;
    }
  }

  String _getStatusText() {
    switch (session.status?.toLowerCase()) {
      case 'active':
        return 'Online - Ready to help';
      case 'ended':
        return 'Session ended';
      case 'transferred':
        return 'Transferred to agent';
      default:
        return 'Connecting...';
    }
  }
}
