import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final String currentMessage;
  final Function(String) onMessageChanged;
  final VoidCallback onSendMessage;
  final bool isEnabled;

  const ChatInputField({
    super.key,
    required this.currentMessage,
    required this.onMessageChanged,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentMessage;
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(ChatInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMessage != widget.currentMessage) {
      _controller.text = widget.currentMessage;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onMessageChanged(_controller.text);
  }

  void _handleSend() {
    if (widget.currentMessage.trim().isNotEmpty && widget.isEnabled) {
      widget.onSendMessage();
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Attachment button (future feature)
          IconButton(
            onPressed: widget.isEnabled ? () {
              // TODO: Implement file attachment
            } : null,
            icon: Icon(
              Icons.attach_file,
              color: widget.isEnabled ? Colors.grey : Colors.grey.shade300,
            ),
          ),

          // Text input field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.isEnabled,
              decoration: InputDecoration(
                hintText: widget.isEnabled ? 'Type your message...' : 'Chat unavailable',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFF1a237e)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: widget.isEnabled ? Colors.grey.shade50 : Colors.grey.shade100,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          Container(
            decoration: BoxDecoration(
              color: widget.currentMessage.trim().isNotEmpty && widget.isEnabled
                  ? const Color(0xFF1a237e)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.currentMessage.trim().isNotEmpty && widget.isEnabled
                  ? _handleSend
                  : null,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
