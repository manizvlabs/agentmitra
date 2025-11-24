import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/callback_repository.dart';
import '../../data/models/callback_model.dart';

/// ViewModel for callback request management
class CallbackViewModel extends BaseViewModel {
  final CallbackRepository _repository;

  CallbackViewModel({CallbackRepository? repository})
      : _repository = repository ?? CallbackRepository();

  List<CallbackRequest> _callbacks = [];
  CallbackRequest? _selectedCallback;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedPriority;
  String? _selectedStatus;

  List<CallbackRequest> get callbacks => _callbacks;
  CallbackRequest? get selectedCallback => _selectedCallback;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedPriority => _selectedPriority;
  String? get selectedStatus => _selectedStatus;

  // Filtered lists
  List<CallbackRequest> get highPriorityCallbacks =>
      _callbacks.where((c) => c.priority == 'high').toList();
  List<CallbackRequest> get mediumPriorityCallbacks =>
      _callbacks.where((c) => c.priority == 'medium').toList();
  List<CallbackRequest> get lowPriorityCallbacks =>
      _callbacks.where((c) => c.priority == 'low').toList();
  List<CallbackRequest> get pendingCallbacks =>
      _callbacks.where((c) => c.status == 'pending').toList();
  List<CallbackRequest> get assignedCallbacks =>
      _callbacks.where((c) => c.status == 'assigned').toList();
  List<CallbackRequest> get completedCallbacks =>
      _callbacks.where((c) => c.status == 'completed').toList();

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadCallbacks();
  }

  /// Load callback requests
  Future<void> loadCallbacks({String? status, String? priority}) async {
    await executeAsync(
      () async {
        _isLoading = true;
        _selectedStatus = status;
        _selectedPriority = priority;
        notifyListeners();
        try {
          _callbacks = await _repository.getCallbackRequests(
            status: status,
            priority: priority,
          );
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Load callback details
  Future<void> loadCallback(String callbackId) async {
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          _selectedCallback = await _repository.getCallbackRequest(callbackId);
          _errorMessage = null;
        } catch (e) {
          _errorMessage = e.toString();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Create new callback request
  Future<bool> createCallbackRequest(Map<String, dynamic> callbackData) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final callback = await _repository.createCallbackRequest(callbackData);
          _callbacks.insert(0, callback);
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Update callback status
  Future<bool> updateCallbackStatus(String callbackId, String status) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final callback = await _repository.updateCallbackStatus(callbackId, status);
          final index = _callbacks.indexWhere((c) => c.callbackRequestId == callbackId);
          if (index != -1) {
            _callbacks[index] = callback;
          }
          if (_selectedCallback?.callbackRequestId == callbackId) {
            _selectedCallback = callback;
          }
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Assign callback to agent
  Future<bool> assignCallback(String callbackId, {String? agentId}) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final callback = await _repository.assignCallback(callbackId, agentId: agentId);
          final index = _callbacks.indexWhere((c) => c.callbackRequestId == callbackId);
          if (index != -1) {
            _callbacks[index] = callback;
          }
          if (_selectedCallback?.callbackRequestId == callbackId) {
            _selectedCallback = callback;
          }
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Complete callback request
  Future<bool> completeCallback(
    String callbackId, {
    String? resolution,
    String? resolutionCategory,
    int? satisfactionRating,
  }) async {
    bool success = false;
    await executeAsync(
      () async {
        _isLoading = true;
        notifyListeners();
        try {
          final callback = await _repository.completeCallback(
            callbackId,
            resolution: resolution,
            resolutionCategory: resolutionCategory,
            satisfactionRating: satisfactionRating,
          );
          final index = _callbacks.indexWhere((c) => c.callbackRequestId == callbackId);
          if (index != -1) {
            _callbacks[index] = callback;
          }
          if (_selectedCallback?.callbackRequestId == callbackId) {
            _selectedCallback = callback;
          }
          _errorMessage = null;
          success = true;
        } catch (e) {
          _errorMessage = e.toString();
          success = false;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
    return success;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

