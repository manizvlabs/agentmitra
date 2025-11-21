import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/chatbot_repository.dart';
import '../../data/models/chatbot_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _chatbotRepository;
  final String agentId;

  ChatbotViewModel(this._chatbotRepository, this.agentId);

  // State
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  String _currentMessage = '';

  // Getters
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;
  String get currentMessage => _currentMessage;
  bool get hasActiveSession => _currentSession != null && _currentSession!.status == 'active';

  // Computed properties
  List<ChatMessage> get recentMessages => _messages.take(50).toList();

  ChatMessage? get lastBotMessage =>
      _messages.where((msg) => msg.sender == 'bot').lastWhere(
        (_) => true,
        orElse: () => null,
      );

  List<ChatMessage> get unreadMessages =>
      _messages.where((msg) => msg.sender == 'bot' && !(msg.isRead ?? false)).toList();

  // Actions
  Future<void> initializeChat() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to get existing active session first
      final sessionsResult = await _chatbotRepository.getAgentSessions(agentId, limit: 1);
      sessionsResult.fold(
        (error) => _error = error.toString(),
        (sessions) {
          final activeSession = sessions.where((s) => s.status == 'active').firstWhere(
            (_) => true,
            orElse: () => null,
          );

          if (activeSession != null) {
            _currentSession = activeSession;
            _loadMessages(activeSession.sessionId);
          }
        },
      );

      // If no active session, create new one
      if (_currentSession == null) {
        await _createNewSession();
      }
    } catch (e) {
      _error = 'Failed to initialize chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createNewSession() async {
    final sessionResult = await _chatbotRepository.createSession(agentId);
    sessionResult.fold(
      (error) => _error = error.toString(),
      (session) => _currentSession = session,
    );
  }

  Future<void> _loadMessages(String sessionId) async {
    final messagesResult = await _chatbotRepository.getMessages(sessionId);
    messagesResult.fold(
      (error) => _error = error.toString(),
      (messages) {
        _messages = messages;
        // Mark bot messages as read
        _messages.where((msg) => msg.sender == 'bot').forEach((msg) {
          msg = msg.copyWith(isRead: true);
        });
      },
    );
  }

  void updateCurrentMessage(String message) {
    _currentMessage = message;
    notifyListeners();
  }

  Future<void> sendMessage() async {
    if (_currentMessage.trim().isEmpty || _currentSession == null) return;

    final message = _currentMessage.trim();
    _currentMessage = '';
    _isTyping = true;
    notifyListeners();

    try {
      // Add user message to UI immediately
      final userMessage = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSession!.sessionId,
        content: message,
        sender: 'user',
        timestamp: DateTime.now(),
        messageType: 'text',
        isRead: true,
      );

      _messages.add(userMessage);
      notifyListeners();

      // Send to API and get bot response
      final responseResult = await _chatbotRepository.sendMessage(_currentSession!.sessionId, message);

      responseResult.fold(
        (error) {
          _error = error.toString();
          // Add error message
          final errorMessage = ChatMessage(
            messageId: DateTime.now().millisecondsSinceEpoch.toString(),
            sessionId: _currentSession!.sessionId,
            content: 'Sorry, I encountered an error. Please try again.',
            sender: 'bot',
            timestamp: DateTime.now(),
            messageType: 'text',
            isRead: true,
          );
          _messages.add(errorMessage);
        },
        (botResponse) {
          // Add bot response
          final botMessage = ChatMessage(
            messageId: DateTime.now().millisecondsSinceEpoch.toString(),
            sessionId: _currentSession!.sessionId,
            content: botResponse.message,
            sender: 'bot',
            timestamp: DateTime.now(),
            messageType: 'text',
            metadata: {
              'intent': botResponse.intent,
              'confidence': botResponse.confidence,
              'quick_replies': botResponse.quickReplies,
              'requires_agent': botResponse.requiresAgent,
            },
            isRead: true,
          );
          _messages.add(botMessage);

          // Check if agent escalation is needed
          if (botResponse.requiresAgent == true) {
            _handleAgentEscalation(botResponse.escalationReason ?? 'Complex query requiring human assistance');
          }
        },
      );
    } catch (e) {
      _error = 'Failed to send message: $e';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void _handleAgentEscalation(String reason) {
    // TODO: Implement agent escalation logic
    // This could show a notification or transfer to human agent
  }

  Future<void> endSession() async {
    if (_currentSession == null) return;

    final result = await _chatbotRepository.endSession(_currentSession!.sessionId);
    result.fold(
      (error) => _error = error.toString(),
      (_) {
        _currentSession = _currentSession!.copyWith(
          status: 'ended',
          endedAt: DateTime.now(),
        );
      },
    );
    notifyListeners();
  }

  Future<void> transferToAgent(String reason) async {
    if (_currentSession == null) return;

    final result = await _chatbotRepository.transferToAgent(_currentSession!.sessionId, reason);
    result.fold(
      (error) => _error = error.toString(),
      (_) => _handleAgentEscalation(reason),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void markMessagesAsRead() {
    _messages.where((msg) => msg.sender == 'bot').forEach((msg) {
      final index = _messages.indexOf(msg);
      if (index != -1) {
        _messages[index] = msg.copyWith(isRead: true);
      }
    });
    notifyListeners();
  }
}
