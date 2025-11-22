import 'package:flutter/material.dart';
import '../../features/chatbot/data/models/chatbot_model.dart';
import 'mock_data.dart';

/// Production-grade Mock ChatbotViewModel for web compatibility
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
    _initializeMockData(agentId);
  }

  void _initializeMockData(String agentId) {
    _currentSession = MockData.mockChatSession.copyWith(agentId: agentId);
    _messages = MockData.mockChatMessages;
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
      content: _currentMessage,
      sender: 'user',
      timestamp: DateTime.now(),
      messageType: 'text',
    );

    _messages.add(userMessage);
    _currentMessage = '';
    _isTyping = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      final botResponse = ChatMessage(
        messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        sessionId: _currentSession!.sessionId,
        content: 'Thank you for your message. A human agent will assist you shortly.',
        sender: 'bot',
        timestamp: DateTime.now(),
        messageType: 'text',
      );

      _messages.add(botResponse);
      _isTyping = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> startNewSession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _currentSession = ChatSession(
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        agentId: _currentSession!.agentId,
        customerId: _currentSession!.customerId,
        startedAt: DateTime.now(),
        status: 'active',
        topic: 'New Conversation',
        messageCount: 0,
      );

      _messages.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start new session: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> endSession() async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: 'ended',
        endedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> loadChatHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Messages are already loaded in initialization
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load chat history: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeChat() async {
    await loadChatHistory();
  }

  Future<void> exportConversation() async {
    // Mock export functionality
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> transferToAgent(String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Mock transfer to human agent
      final transferMessage = ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _currentSession!.sessionId,
        content: 'Transferring you to a human agent...',
        sender: 'bot',
        timestamp: DateTime.now(),
        messageType: 'system',
      );

      _messages.add(transferMessage);
      _currentSession = _currentSession!.copyWith(status: 'transferred');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to transfer to agent: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
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
