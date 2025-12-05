/// Base ViewModel class for all feature ViewModels
/// Provides common functionality for state management
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Result wrapper for async operations
class ViewModelResult<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const ViewModelResult({
    this.data,
    this.error,
    this.isLoading = false,
  });

  bool get hasError => error != null;
  bool get hasData => data != null;
  bool get isSuccess => !hasError && hasData && !isLoading;

  ViewModelResult<T> copyWith({
    T? data,
    String? error,
    bool? isLoading,
  }) {
    return ViewModelResult<T>(
      data: data ?? this.data,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ViewModelResult.loading() => ViewModelResult<T>(isLoading: true);
  factory ViewModelResult.error(String error) => ViewModelResult<T>(error: error);
  factory ViewModelResult.success(T data) => ViewModelResult<T>(data: data);
}

abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isInitialized => _isInitialized;

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set initialized state
  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    // Defer notifyListeners to avoid calling during build phase
    scheduleMicrotask(() {
      notifyListeners();
    });
  }

  /// Initialize ViewModel
  @mustCallSuper
  Future<void> initialize() async {
    setInitialized(true);
  }

  /// Reset ViewModel to initial state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Execute async operation with automatic loading/error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? errorMessage,
    bool showLoading = true,
    bool clearErrorOnStart = true,
  }) async {
    try {
      if (clearErrorOnStart) clearError();
      if (showLoading) setLoading(true);

      final result = await operation();
      return result;
    } catch (e) {
      final message = errorMessage ?? 'An error occurred: ${e.toString()}';
      setError(message);
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// Execute operation and update result wrapper
  Future<ViewModelResult<T>> executeWithResult<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      setLoading(true);
      clearError();

      final result = await operation();
      return ViewModelResult<T>.success(result);
    } catch (e) {
      final message = errorMessage ?? 'Operation failed: ${e.toString()}';
      setError(message);
      return ViewModelResult<T>.error(message);
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    clearError();
    super.dispose();
  }
}

