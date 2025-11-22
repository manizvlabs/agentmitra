import 'package:flutter/foundation.dart';
import '../../data/repositories/chatbot_repository.dart';
import '../../data/models/chatbot_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _chatbotRepository;
  final String agentId;

  ChatbotViewModel(this._chatbotRepository, this.agentId) {
    // Initialize with mock data for Phase 5 testing
    _initializeMockData();
  }

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
        orElse: () => throw StateError('No bot messages found'),
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
          final activeSessions = sessions.where((s) => s.status == 'active');
          if (activeSessions.isNotEmpty) {
            final activeSession = activeSessions.first;
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

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  Future<void> exportConversation() async {
    // TODO: Implement conversation export functionality
    // This could save to file or share via system share sheet
    // For now, just show a placeholder
    _error = 'Export functionality will be implemented soon';
    notifyListeners();
  }

  void _initializeMockData() {
    // Mock chatbot session and messages for Phase 5 testing
    _currentSession = ChatSession(
      sessionId: 'session_001',
      agentId: agentId,
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      status: 'active',
      context: {'user_type': 'agent', 'last_topic': 'policies'},
    );

    _messages = [
      ChatMessage(
        messageId: 'msg_001',
        sessionId: 'session_001',
        sender: 'bot',
        content: 'Hello! I\'m your AI assistant. How can I help you with insurance queries today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: 'msg_002',
        sessionId: 'session_001',
        sender: 'user',
        content: 'I need help understanding policy renewal process',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: 'msg_003',
        sessionId: 'session_001',
        sender: 'bot',
        content: 'I\'d be happy to help you with policy renewals! Here\'s what you need to know:\n\n1. Renewal notices are sent 30 days before expiry\n2. You can renew online through the agent portal\n3. Premium amounts may change based on claim history\n4. Early renewal discounts are available\n\nWould you like me to guide you through the renewal process?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: 'msg_004',
        sessionId: 'session_001',
        sender: 'user',
        content: 'Yes, please show me how to renew a policy',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: 'msg_005',
        sessionId: 'session_001',
        sender: 'bot',
        content: 'Great! Here are the steps to renew a policy:\n\n📋 **Step 1:** Go to the Policies section in your dashboard\n📋 **Step 2:** Find the policy expiring soon (marked with orange indicator)\n📋 **Step 3:** Click "Renew Policy" button\n📋 **Step 4:** Review the new premium amount\n📋 **Step 5:** Complete payment\n\nYou can also set up auto-renewal to avoid missing deadlines!\n\nWould you like me to take you to the policies page?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        messageType: 'text',
      ),
    ];
  }
}
