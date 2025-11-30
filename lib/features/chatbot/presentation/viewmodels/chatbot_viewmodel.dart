import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../../../core/services/agent_service.dart';
import '../../data/repositories/chatbot_repository.dart';
import '../../data/models/chatbot_model.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _chatbotRepository;

  ChatbotViewModel(this._chatbotRepository);

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
    print('🔍 DEBUG: ChatbotViewModel.initializeChat called');
    developer.log('DEBUG: ChatbotViewModel.initializeChat called', name: 'CHATBOT_VM');

    if (_isLoading) {
      print('🔍 DEBUG: ChatbotViewModel - Already loading, skipping');
      developer.log('DEBUG: ChatbotViewModel - Already loading, skipping', name: 'CHATBOT_VM');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔍 DEBUG: ChatbotViewModel - Starting initialization process');
    developer.log('DEBUG: ChatbotViewModel - Starting initialization process', name: 'CHATBOT_VM');

    try {
      // Get the current agent ID from authentication service
      print('🔍 DEBUG: ChatbotViewModel - Getting current agent ID');
      developer.log('DEBUG: ChatbotViewModel - Getting current agent ID', name: 'CHATBOT_VM');
      final agentId = await AgentService().getCurrentAgentId();
      if (agentId == null) {
        print('🔍 DEBUG: ChatbotViewModel - No agent profile found, using default agent context');
        developer.log('DEBUG: ChatbotViewModel - No agent profile found, using default agent context', name: 'CHATBOT_VM');
        // For users without agent profiles (like provider admins), use a default agent ID
        // This allows the chatbot to work even without a specific agent context
        _initializeWithoutAgent();
        return;
      }

      print('🔍 DEBUG: ChatbotViewModel - Got agent ID: $agentId');
      developer.log('DEBUG: ChatbotViewModel - Got agent ID: $agentId', name: 'CHATBOT_VM');

      developer.log('DEBUG: ChatbotViewModel - Getting agent sessions', name: 'CHATBOT_VM');
      // Try to get existing active session first
      final sessionsResult = await _chatbotRepository.getAgentSessions(agentId, limit: 1);
      sessionsResult.fold(
        (error) {
          developer.log('DEBUG: ChatbotViewModel - Error getting sessions: $error', name: 'CHATBOT_VM');
          _error = error.toString();
        },
        (sessions) {
          developer.log('DEBUG: ChatbotViewModel - Got ${sessions.length} sessions', name: 'CHATBOT_VM');
          final activeSessions = sessions.where((s) => s.status == 'active');
          if (activeSessions.isNotEmpty) {
            final activeSession = activeSessions.first;
            developer.log('DEBUG: ChatbotViewModel - Found active session: ${activeSession.sessionId}', name: 'CHATBOT_VM');
            _currentSession = activeSession;
            _loadMessages(activeSession.sessionId);
          } else {
            developer.log('DEBUG: ChatbotViewModel - No active sessions, creating new one', name: 'CHATBOT_VM');
            // If no active session, create new one
            _createNewSession(agentId);
          }
        },
      );

      // If no active session, create new one
      if (_currentSession == null) {
        developer.log('DEBUG: ChatbotViewModel - No current session, creating new one', name: 'CHATBOT_VM');
        await _createNewSession(agentId);
      }
    } catch (e) {
      developer.log('DEBUG: ChatbotViewModel - Exception in initializeChat: $e', name: 'CHATBOT_VM', error: e);
      _error = 'Failed to initialize chat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
      developer.log('DEBUG: ChatbotViewModel - initializeChat completed', name: 'CHATBOT_VM');
    }
  }

  Future<void> _initializeWithoutAgent() async {
    print('🔍 DEBUG: ChatbotViewModel._initializeWithoutAgent called');
    developer.log('DEBUG: ChatbotViewModel._initializeWithoutAgent called', name: 'CHATBOT_VM');

    // For users without agent profiles, create a session with a default agent ID
    // This allows provider admins and other non-agent users to use the chatbot
    const defaultAgentId = 'default-agent';
    print('🔍 DEBUG: ChatbotViewModel - Using default agent ID: $defaultAgentId');
    developer.log('DEBUG: ChatbotViewModel - Using default agent ID: $defaultAgentId', name: 'CHATBOT_VM');

    await _createNewSession(defaultAgentId);
  }

  Future<void> _createNewSession(String agentId) async {
    print('🔍 DEBUG: ChatbotViewModel._createNewSession called for agent: $agentId');
    developer.log('DEBUG: ChatbotViewModel._createNewSession called', name: 'CHATBOT_VM');

    print('🔍 DEBUG: ChatbotViewModel - Creating session for agent: $agentId');
    developer.log('DEBUG: ChatbotViewModel - Creating session for agent: $agentId', name: 'CHATBOT_VM');

    final sessionResult = await _chatbotRepository.createSession(agentId);
    sessionResult.fold(
      (error) {
        print('🔍 DEBUG: ChatbotViewModel - Session creation failed: $error');
        developer.log('DEBUG: ChatbotViewModel - Session creation failed: $error', name: 'CHATBOT_VM');
        _error = error.toString();
      },
      (session) {
        print('🔍 DEBUG: ChatbotViewModel - Session created: ${session.sessionId}');
        developer.log('DEBUG: ChatbotViewModel - Session created: ${session.sessionId}', name: 'CHATBOT_VM');
        _currentSession = session;
      },
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
    print('🔍 DEBUG: ChatbotViewModel.sendMessage called');
    developer.log('DEBUG: ChatbotViewModel.sendMessage called', name: 'CHATBOT_VM');
    print('🔍 DEBUG: ChatbotViewModel - Current message: "$_currentMessage"');
    developer.log('DEBUG: ChatbotViewModel - Current message: "$_currentMessage"', name: 'CHATBOT_VM');
    print('🔍 DEBUG: ChatbotViewModel - Current session: ${_currentSession?.sessionId}');
    developer.log('DEBUG: ChatbotViewModel - Current session: ${_currentSession?.sessionId}', name: 'CHATBOT_VM');

    if (_currentMessage.trim().isEmpty || _currentSession == null) {
      print('🔍 DEBUG: ChatbotViewModel - Skipping send: empty message or no session');
      developer.log('DEBUG: ChatbotViewModel - Skipping send: empty message or no session', name: 'CHATBOT_VM');
      return;
    }

    print('🔍 DEBUG: ChatbotViewModel - Processing message: "${_currentMessage.trim()}"');
    developer.log('DEBUG: ChatbotViewModel - Processing message: "${_currentMessage.trim()}"', name: 'CHATBOT_VM');

    final message = _currentMessage.trim();
    _currentMessage = '';
    _isTyping = true;
    notifyListeners();

    developer.log('DEBUG: ChatbotViewModel - Sending message: "$message"', name: 'CHATBOT_VM');

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
      developer.log('DEBUG: ChatbotViewModel - Added user message to UI', name: 'CHATBOT_VM');

      // Send to API and get bot response
      developer.log('DEBUG: ChatbotViewModel - Calling repository.sendMessage', name: 'CHATBOT_VM');
      final responseResult = await _chatbotRepository.sendMessage(_currentSession!.sessionId, message);

      responseResult.fold(
        (error) {
          developer.log('DEBUG: ChatbotViewModel - API error: $error', name: 'CHATBOT_VM', error: error);
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
          developer.log('DEBUG: ChatbotViewModel - Added error message to UI', name: 'CHATBOT_VM');
        },
        (botResponse) {
          developer.log('DEBUG: ChatbotViewModel - Got bot response: "${botResponse.message}"', name: 'CHATBOT_VM');
          print('🔍 DEBUG: ChatbotViewModel - Messages count before adding bot response: ${_messages.length}');
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
          print('🔍 DEBUG: ChatbotViewModel - Messages count after adding bot response: ${_messages.length}');
          print('🔍 DEBUG: ChatbotViewModel - Bot message content: "${botMessage.content}"');
          developer.log('DEBUG: ChatbotViewModel - Added bot message to UI', name: 'CHATBOT_VM');

          // Check if agent escalation is needed
          if (botResponse.requiresAgent == true) {
            developer.log('DEBUG: ChatbotViewModel - Agent escalation needed', name: 'CHATBOT_VM');
            _handleAgentEscalation(botResponse.escalationReason ?? 'Complex query requiring human assistance');
          }
        },
      );
    } catch (e) {
      developer.log('DEBUG: ChatbotViewModel - Exception in sendMessage: $e', name: 'CHATBOT_VM', error: e);
      _error = 'Failed to send message: $e';
    } finally {
      _isTyping = false;
      notifyListeners();
      developer.log('DEBUG: ChatbotViewModel - sendMessage completed', name: 'CHATBOT_VM');
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

  // Removed mock data initialization - using real API now
}
