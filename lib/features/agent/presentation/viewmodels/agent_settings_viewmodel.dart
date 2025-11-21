import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/models/agent_model.dart';

class AgentSettingsViewModel extends ChangeNotifier {
  final AgentRepository _agentRepository;
  final String agentId;

  AgentSettingsViewModel(this._agentRepository, this.agentId);

  // State
  AgentSettings? _settings;
  bool _isLoading = false;
  String? _error;

  // Form state
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  String _language = 'en';
  String _theme = 'system';
  String _dateFormat = 'dd/MM/yyyy';
  String _timeFormat = '12h';
  String _timezone = 'Asia/Kolkata';
  bool _biometricEnabled = false;
  bool _autoBackupEnabled = true;
  int _sessionTimeoutMinutes = 30;
  bool _twoFactorEnabled = false;

  // Getters
  AgentSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Form getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;
  bool get pushNotifications => _pushNotifications;
  String get language => _language;
  String get theme => _theme;
  String get dateFormat => _dateFormat;
  String get timeFormat => _timeFormat;
  String get timezone => _timezone;
  bool get biometricEnabled => _biometricEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  bool get twoFactorEnabled => _twoFactorEnabled;

  // Available options
  final List<String> availableLanguages = ['en', 'hi', 'te'];
  final List<String> availableThemes = ['light', 'dark', 'system'];
  final List<String> availableDateFormats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'];
  final List<String> availableTimeFormats = ['12h', '24h'];
  final List<String> availableTimezones = [
    'Asia/Kolkata',
    'Asia/Dubai',
    'America/New_York',
    'Europe/London',
  ];
  final List<int> availableTimeouts = [15, 30, 60, 120, 480];

  // Actions
  Future<void> loadAgentSettings({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _agentRepository.getAgentSettings(agentId, forceRefresh: forceRefresh);

      result.fold(
        (error) => _error = error.toString(),
        (settings) {
          _settings = settings;
          // Initialize form fields
          _notificationsEnabled = settings.notificationsEnabled ?? true;
          _emailNotifications = settings.emailNotifications ?? true;
          _smsNotifications = settings.smsNotifications ?? false;
          _pushNotifications = settings.pushNotifications ?? true;
          _language = settings.language ?? 'en';
          _theme = settings.theme ?? 'system';
          _dateFormat = settings.dateFormat ?? 'dd/MM/yyyy';
          _timeFormat = settings.timeFormat ?? '12h';
          _timezone = settings.timezone ?? 'Asia/Kolkata';
          _biometricEnabled = settings.biometricEnabled ?? false;
          _autoBackupEnabled = settings.autoBackupEnabled ?? true;
          _sessionTimeoutMinutes = settings.sessionTimeoutMinutes ?? 30;
          _twoFactorEnabled = settings.twoFactorEnabled ?? false;
        },
      );
    } catch (e) {
      _error = 'Failed to load agent settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSettings() async {
    await loadAgentSettings(forceRefresh: true);
  }

  // Form update actions
  void updateNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    if (!value) {
      _emailNotifications = false;
      _smsNotifications = false;
      _pushNotifications = false;
    }
    notifyListeners();
  }

  void updateEmailNotifications(bool value) {
    _emailNotifications = value;
    notifyListeners();
  }

  void updateSmsNotifications(bool value) {
    _smsNotifications = value;
    notifyListeners();
  }

  void updatePushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  void updateLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void updateTheme(String value) {
    _theme = value;
    notifyListeners();
  }

  void updateDateFormat(String value) {
    _dateFormat = value;
    notifyListeners();
  }

  void updateTimeFormat(String value) {
    _timeFormat = value;
    notifyListeners();
  }

  void updateTimezone(String value) {
    _timezone = value;
    notifyListeners();
  }

  void updateBiometricEnabled(bool value) {
    _biometricEnabled = value;
    notifyListeners();
  }

  void updateAutoBackupEnabled(bool value) {
    _autoBackupEnabled = value;
    notifyListeners();
  }

  void updateSessionTimeoutMinutes(int value) {
    _sessionTimeoutMinutes = value;
    notifyListeners();
  }

  void updateTwoFactorEnabled(bool value) {
    _twoFactorEnabled = value;
    notifyListeners();
  }

  // Settings update
  Future<Either<Exception, AgentSettings>> saveSettings() async {
    final settingsData = {
      'notifications_enabled': _notificationsEnabled,
      'email_notifications': _emailNotifications,
      'sms_notifications': _smsNotifications,
      'push_notifications': _pushNotifications,
      'language': _language,
      'theme': _theme,
      'date_format': _dateFormat,
      'time_format': _timeFormat,
      'timezone': _timezone,
      'biometric_enabled': _biometricEnabled,
      'auto_backup_enabled': _autoBackupEnabled,
      'session_timeout_minutes': _sessionTimeoutMinutes,
      'two_factor_enabled': _twoFactorEnabled,
    };

    final result = await _agentRepository.updateAgentSettings(agentId, settingsData);

    result.fold(
      (error) => _error = error.toString(),
      (updatedSettings) => _settings = updatedSettings,
    );

    notifyListeners();
    return result;
  }

  // Biometric setting update
  Future<Either<Exception, void>> updateBiometricSetting(bool enabled) async {
    final result = await _agentRepository.updateBiometricSetting(agentId, enabled);

    result.fold(
      (error) => _error = error.toString(),
      (_) => _biometricEnabled = enabled,
    );

    notifyListeners();
    return result;
  }

  // Password change
  Future<Either<Exception, void>> changePassword(String currentPassword, String newPassword) async {
    final result = await _agentRepository.changePassword(agentId, currentPassword, newPassword);
    return result;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset form to current settings values
  void resetForm() {
    if (_settings != null) {
      _notificationsEnabled = _settings!.notificationsEnabled ?? true;
      _emailNotifications = _settings!.emailNotifications ?? true;
      _smsNotifications = _settings!.smsNotifications ?? false;
      _pushNotifications = _settings!.pushNotifications ?? true;
      _language = _settings!.language ?? 'en';
      _theme = _settings!.theme ?? 'system';
      _dateFormat = _settings!.dateFormat ?? 'dd/MM/yyyy';
      _timeFormat = _settings!.timeFormat ?? '12h';
      _timezone = _settings!.timezone ?? 'Asia/Kolkata';
      _biometricEnabled = _settings!.biometricEnabled ?? false;
      _autoBackupEnabled = _settings!.autoBackupEnabled ?? true;
      _sessionTimeoutMinutes = _settings!.sessionTimeoutMinutes ?? 30;
      _twoFactorEnabled = _settings!.twoFactorEnabled ?? false;
    }
    notifyListeners();
  }
}
