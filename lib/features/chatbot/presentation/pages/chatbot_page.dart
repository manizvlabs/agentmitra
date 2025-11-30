import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../viewmodels/chatbot_viewmodel.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/chat_header.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: ChatbotPage.initState called');
    developer.log('DEBUG: ChatbotPage.initState called', name: 'CHATBOT_PAGE');

    // Show debug message on screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: ChatbotPage - Checking authentication first');
      developer.log('DEBUG: ChatbotPage - Checking authentication first', name: 'CHATBOT_PAGE');

      // Check if user is authenticated before proceeding
      _checkAuthenticationAndInitialize();
    });
  }

  Future<void> _checkAuthenticationAndInitialize() async {
    try {
      final authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated(context);

      if (!isAuthenticated) {
        print('🔍 DEBUG: ChatbotPage - User not authenticated, cannot initialize chatbot');
        developer.log('DEBUG: ChatbotPage - User not authenticated, cannot initialize chatbot', name: 'CHATBOT_PAGE');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to use the chatbot'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      print('🔍 DEBUG: ChatbotPage - User authenticated, proceeding with initialization');
      developer.log('DEBUG: ChatbotPage - User authenticated, proceeding with initialization', name: 'CHATBOT_PAGE');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔍 DEBUG: Initializing Chatbot...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Test direct API call first
      await _testDirectApiCall();

      // Initialize chatbot
      if (mounted) {
        context.read<ChatbotViewModel>().initializeChat();
      }
    } catch (e) {
      print('🔍 DEBUG: ChatbotPage - Error during authentication check: $e');
      developer.log('DEBUG: ChatbotPage - Error during authentication check: $e', name: 'CHATBOT_PAGE', error: e);
    }
  }

  Future<void> _testDirectApiCall() async {
    print('🔍 DEBUG: Testing direct API call');
    try {
      final response = await ApiService.post('/chat/sessions', {
        'device_info': {'platform': 'web_test'},
      });
      print('🔍 DEBUG: Direct API call successful: $response');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔍 API Test Success: ${response['session_id']}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('🔍 DEBUG: Direct API call failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔍 API Test Failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('DEBUG: ChatbotPage.build called', name: 'CHATBOT_PAGE');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<ChatbotViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  developer.log('DEBUG: ChatbotPage - Menu selected: $value', name: 'CHATBOT_PAGE');
                  switch (value) {
                    case 'end_session':
                      developer.log('DEBUG: ChatbotPage - Showing end session dialog', name: 'CHATBOT_PAGE');
                      _showEndSessionDialog(context, viewModel);
                      break;
                    case 'transfer':
                      developer.log('DEBUG: ChatbotPage - Showing transfer dialog', name: 'CHATBOT_PAGE');
                      _showTransferDialog(context, viewModel);
                      break;
                    case 'clear':
                      developer.log('DEBUG: ChatbotPage - Showing clear chat dialog', name: 'CHATBOT_PAGE');
                      _showClearChatDialog(context, viewModel);
                      break;
                    case 'export':
                      developer.log('DEBUG: ChatbotPage - Exporting conversation', name: 'CHATBOT_PAGE');
                      viewModel.exportConversation();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'end_session',
                    child: Text('End Session'),
                  ),
                  const PopupMenuItem(
                    value: 'transfer',
                    child: Text('Transfer to Agent'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Chat'),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Text('Export Conversation'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatbotViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.messages.isEmpty) {
            return _buildErrorView(viewModel);
          }

          return Column(
            children: [
              // Chat Header
              if (viewModel.currentSession != null)
                ChatHeader(session: viewModel.currentSession!),

              // Messages List
              Expanded(
                child: ChatMessageList(
                  messages: viewModel.messages,
                  isTyping: viewModel.isTyping,
                  onQuickReplySelected: (reply) {
                    viewModel.updateCurrentMessage(reply);
                    viewModel.sendMessage();
                  },
                ),
              ),

              // Input Field
              ChatInputField(
                currentMessage: viewModel.currentMessage,
                onMessageChanged: viewModel.updateCurrentMessage,
                onSendMessage: viewModel.sendMessage,
                isEnabled: viewModel.hasActiveSession && !viewModel.isTyping,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorView(ChatbotViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to start chat',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.initializeChat,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, ChatbotViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Chat Session'),
        content: const Text('Are you sure you want to end this chat session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.endSession();
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, ChatbotViewModel viewModel) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer to Human Agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for transferring to a human agent:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for transfer',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                viewModel.transferToAgent(reasonController.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, ChatbotViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('This will clear all messages in this chat session. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.clearChat();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
