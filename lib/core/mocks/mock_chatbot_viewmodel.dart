import 'package:flutter/material.dart';
import '../../features/chatbot/data/models/chatbot_model.dart';

/// Mock ChatbotViewModel for web compatibility
class MockChatbotViewModel extends ChangeNotifier {
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;
  String _currentMessage = '';

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;
  String get currentMessage => _currentMessage;
  bool get hasActiveSession => _currentSession != null && _currentSession!.status == 'active';
  List<ChatMessage> get recentMessages => _messages.take(50).toList();

  MockChatbotViewModel(String agentId) {
    _initializeMockData();
  }

  void _initializeMockData() {
    _currentSession = ChatSession(
      sessionId: 'session_123',
      agentId: 'agent_123',
      customerId: 'user_123',
      startedAt: DateTime.now(),
      status: 'active',
    );

    _messages = [
      ChatMessage(
        messageId: '1',
        sessionId: 'session_123',
        sender: 'bot',
        content: 'Hello! I\'m your insurance assistant. How can I help you today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: '2',
        sessionId: 'session_123',
        sender: 'user',
        content: 'I need help with my policy details',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        messageType: 'text',
      ),
      ChatMessage(
        messageId: '3',
        sessionId: 'session_123',
        sender: 'bot',
        content: 'I\'d be happy to help you with your policy details. Could you please provide your policy number?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        messageType: 'text',
      ),
    ];
  }

  void updateCurrentMessage(String message) {
    _currentMessage = message;
    notifyListeners();
  }

  Future<void> sendMessage() async {
    if (_currentMessage.trim().isEmpty) return;

    final userMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _currentSession!.sessionId,
      sender: 'user',
      content: _currentMessage,
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    _messages.add(userMessage);
    _currentMessage = '';
    _isTyping = true;
    notifyListeners();

    // Simulate bot response
    await Future.delayed(const Duration(seconds: 2));

    final botResponse = ChatMessage(
      messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      sessionId: _currentSession!.sessionId,
      sender: 'bot',
      content: 'Thank you for your message. A human agent will assist you shortly.',
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    _messages.add(botResponse);
    _isTyping = false;
    notifyListeners();
  }

  Future<void> startNewSession() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentSession = ChatSession(
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
      agentId: 'agent_123',
      customerId: 'user_123',
      startedAt: DateTime.now(),
      status: 'active',
    );

    _messages.clear();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> endSession() async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(status: 'ended');
      notifyListeners();
    }
  }

  Future<void> loadChatHistory() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadChatHistory();
  }
}
