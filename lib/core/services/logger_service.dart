/// Logger Service
/// Provides structured logging for Flutter application
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  static const String _logStorageKey = 'app_logs';
  static const int _maxLogs = 1000;
  List<LogEntry> _logs = [];
  bool _enableFileLogging = false;
  LogLevel _minLevel = LogLevel.debug;

  /// Initialize logger
  Future<void> initialize({bool enableFileLogging = false}) async {
    _enableFileLogging = enableFileLogging;
    _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
    
    if (_enableFileLogging) {
      await _loadLogs();
    }
  }

  /// Log a debug message
  void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Log an info message
  void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log a warning message
  void warning(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a critical message
  void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(
      LogLevel.critical,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Internal log method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (level.index < _minLevel.index) {
      return;
    }

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag ?? 'App',
      timestamp: DateTime.now(),
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      data: data,
    );

    // Add to in-memory logs
    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // Log to console
    final levelName = level.name.toUpperCase();
    final logMessage = '[${entry.timestamp.toIso8601String()}] '
        '[$levelName] [${entry.tag}] $message';
    
    if (error != null) {
      developer.log(
        logMessage,
        name: entry.tag,
        error: error,
        stackTrace: stackTrace,
        level: _getDeveloperLogLevel(level),
      );
    } else {
      developer.log(
        logMessage,
        name: entry.tag,
        level: _getDeveloperLogLevel(level),
      );
    }

    // Save to storage if enabled
    if (_enableFileLogging) {
      _saveLogs();
    }
  }

  /// Get logs
  List<LogEntry> getLogs({LogLevel? minLevel, int? limit}) {
    var filteredLogs = _logs;
    
    if (minLevel != null) {
      filteredLogs = _logs.where((log) => log.level.index >= minLevel.index).toList();
    }
    
    if (limit != null && limit > 0) {
      filteredLogs = filteredLogs.reversed.take(limit).toList().reversed.toList();
    }
    
    return filteredLogs;
  }

  /// Clear logs
  Future<void> clearLogs() async {
    _logs.clear();
    if (_enableFileLogging) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logStorageKey);
    }
  }

  /// Export logs as JSON
  String exportLogsAsJson({LogLevel? minLevel, int? limit}) {
    final logs = getLogs(minLevel: minLevel, limit: limit);
    final jsonLogs = logs.map((log) => log.toJson()).toList();
    return jsonEncode(jsonLogs);
  }

  /// Load logs from storage
  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_logStorageKey);
      
      if (logsJson != null) {
        final List<dynamic> logsList = jsonDecode(logsJson);
        _logs = logsList.map((json) => LogEntry.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('Failed to load logs: $e', name: 'LoggerService');
    }
  }

  /// Save logs to storage
  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only recent logs
      final recentLogs = _logs.length > _maxLogs
          ? _logs.sublist(_logs.length - _maxLogs)
          : _logs;
      final logsJson = jsonEncode(recentLogs.map((log) => log.toJson()).toList());
      await prefs.setString(_logStorageKey, logsJson);
    } catch (e) {
      developer.log('Failed to save logs: $e', name: 'LoggerService');
    }
  }

  /// Convert LogLevel to developer log level
  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.critical:
        return 1200;
    }
  }
}

/// Log entry model
class LogEntry {
  final LogLevel level;
  final String message;
  final String tag;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.level,
    required this.message,
    required this.tag,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'tag': tag,
      'timestamp': timestamp.toIso8601String(),
      if (error != null) 'error': error,
      if (stackTrace != null) 'stackTrace': stackTrace,
      if (data != null) 'data': data,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      tag: json['tag'] as String? ?? 'App',
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

