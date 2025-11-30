import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../datasources/chatbot_remote_datasource.dart';
import '../models/chatbot_model.dart';

class ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepository(this.remoteDataSource);

  Future<Either<Exception, ChatSession>> createSession(String agentId, {String? customerId}) async {
    try {
      final session = await remoteDataSource.createSession(agentId, customerId: customerId);
      return Right(session);
    } catch (e) {
      return Left(Exception('Failed to create chat session: $e'));
    }
  }

  Future<Either<Exception, ChatSession>> getSession(String sessionId) async {
    try {
      final session = await remoteDataSource.getSession(sessionId);
      return Right(session);
    } catch (e) {
      return Left(Exception('Failed to get chat session: $e'));
    }
  }

  Future<Either<Exception, List<ChatMessage>>> getMessages(String sessionId, {int limit = 50, int offset = 0}) async {
    try {
      final messages = await remoteDataSource.getMessages(sessionId, limit: limit, offset: offset);
      return Right(messages);
    } catch (e) {
      return Left(Exception('Failed to get messages: $e'));
    }
  }

  Future<Either<Exception, ChatbotResponse>> sendMessage(String sessionId, String message) async {
    developer.log('DEBUG: ChatbotRepository.sendMessage called', name: 'CHATBOT_REPO');
    developer.log('DEBUG: ChatbotRepository - Session ID: $sessionId', name: 'CHATBOT_REPO');
    developer.log('DEBUG: ChatbotRepository - Message: $message', name: 'CHATBOT_REPO');

    try {
      developer.log('DEBUG: ChatbotRepository - Calling remoteDataSource.sendMessage', name: 'CHATBOT_REPO');
      final response = await remoteDataSource.sendMessage(sessionId, message);
      developer.log('DEBUG: ChatbotRepository - Got response from datasource', name: 'CHATBOT_REPO');
      return Right(response);
    } catch (e) {
      developer.log('DEBUG: ChatbotRepository - Exception: $e', name: 'CHATBOT_REPO', error: e);
      return Left(Exception('Failed to send message: $e'));
    }
  }

  Future<Either<Exception, ChatMessage>> sendUserMessage(String sessionId, String message) async {
    try {
      final userMessage = await remoteDataSource.sendUserMessage(sessionId, message);
      return Right(userMessage);
    } catch (e) {
      return Left(Exception('Failed to send user message: $e'));
    }
  }

  Future<Either<Exception, void>> endSession(String sessionId) async {
    try {
      await remoteDataSource.endSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to end session: $e'));
    }
  }

  Future<Either<Exception, void>> transferToAgent(String sessionId, String reason) async {
    try {
      await remoteDataSource.transferToAgent(sessionId, reason);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to transfer to agent: $e'));
    }
  }

  Future<Either<Exception, List<ChatSession>>> getAgentSessions(String agentId, {int limit = 20, int offset = 0}) async {
    try {
      final sessions = await remoteDataSource.getAgentSessions(agentId, limit: limit, offset: offset);
      return Right(sessions);
    } catch (e) {
      return Left(Exception('Failed to get agent sessions: $e'));
    }
  }
}
