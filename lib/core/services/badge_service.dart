import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Badge Service
/// Manages notification badges for navigation items
class BadgeService {
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  static const String _badgesKey = 'navigation_badges';

  final StreamController<Map<String, String?>> _badgeController = StreamController<Map<String, String?>>.broadcast();
  Map<String, String?> _badges = {};

  // Public stream
  Stream<Map<String, String?>> get badgeStream => _badgeController.stream;

  // Badge keys
  static const String dailyQuotes = 'daily_quotes';
  static const String agentChat = 'agent_chat';
  static const String reminders = 'reminders';

  /// Initialize badge service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgesJson = prefs.getString(_badgesKey);

      if (badgesJson != null) {
        final badges = Map<String, String?>.from(
          badgesJson as Map<String, dynamic>,
        );
        _badges = badges;
        _badgeController.add(_badges);
      }

      LoggerService().info('Badge service initialized');
    } catch (e) {
      LoggerService().error('Failed to initialize badge service: $e');
    }
  }

  /// Set badge for a navigation item
  Future<void> setBadge(String key, String? value) async {
    _badges[key] = value;
    await _saveBadges();
    _badgeController.add(Map.from(_badges));

    LoggerService().info('Badge updated: $key = $value');
  }

  /// Get badge for a navigation item
  String? getBadge(String key) {
    return _badges[key];
  }

  /// Clear badge for a navigation item
  Future<void> clearBadge(String key) async {
    _badges.remove(key);
    await _saveBadges();
    _badgeController.add(Map.from(_badges));

    LoggerService().info('Badge cleared: $key');
  }

  /// Clear all badges
  Future<void> clearAllBadges() async {
    _badges.clear();
    await _saveBadges();
    _badgeController.add(Map.from(_badges));

    LoggerService().info('All badges cleared');
  }

  /// Get all current badges
  Map<String, String?> getAllBadges() {
    return Map.from(_badges);
  }

  /// Increment numeric badge
  Future<void> incrementBadge(String key) async {
    final currentValue = _badges[key];
    if (currentValue == null) {
      await setBadge(key, '1');
      return;
    }

    final currentNumber = int.tryParse(currentValue);
    if (currentNumber != null) {
      await setBadge(key, (currentNumber + 1).toString());
    }
  }

  /// Decrement numeric badge
  Future<void> decrementBadge(String key) async {
    final currentValue = _badges[key];
    if (currentValue == null) return;

    final currentNumber = int.tryParse(currentValue);
    if (currentNumber != null && currentNumber > 1) {
      await setBadge(key, (currentNumber - 1).toString());
    } else {
      await clearBadge(key);
    }
  }

  Future<void> _saveBadges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_badgesKey, _badges.toString());
    } catch (e) {
      LoggerService().error('Failed to save badges: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _badgeController.close();
  }
}
