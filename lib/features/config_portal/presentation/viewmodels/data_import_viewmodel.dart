import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../data/repositories/config_portal_repository.dart';
import 'dart:async';

/// ViewModel for Data Import Dashboard
class DataImportViewModel extends BaseViewModel {
  final ConfigPortalRepository _repository;

  List<Map<String, dynamic>> _importHistory = [];
  Map<String, dynamic>? _statistics;
  String _selectedFilter = 'all';
  Timer? _progressTimer;
  String? _trackingFileId;

  DataImportViewModel({
    ConfigPortalRepository? repository,
  }) : _repository = repository ?? ConfigPortalRepository();

  List<Map<String, dynamic>> get importHistory => _importHistory;
  Map<String, dynamic>? get statistics => _statistics;
  String get selectedFilter => _selectedFilter;

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadData();
  }

  /// Load dashboard data
  Future<void> loadData() async {
    await executeAsync(
      () async {
        await Future.wait([
          loadImportHistory(),
          loadStatistics(),
        ]);
      },
      errorMessage: 'Failed to load dashboard data',
    );
  }

  /// Load import history with pagination
  Future<void> loadImportHistory({
    int limit = 20,
    int offset = 0,
    bool append = false,
  }) async {
    await executeAsync(
      () async {
        final history = await _repository.getImportHistory(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
          limit: limit,
          offset: offset,
        );

        if (append) {
          _importHistory.addAll(history);
        } else {
          _importHistory = history;
        }
        notifyListeners();
      },
      errorMessage: 'Failed to load import history',
    );
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    await executeAsync(
      () async {
        _statistics = await _repository.getImportStatistics();
        notifyListeners();
      },
      errorMessage: 'Failed to load statistics',
    );
  }

  /// Set filter and reload
  Future<void> setFilter(String filter) async {
    _selectedFilter = filter;
    await loadImportHistory();
  }

  /// Upload import file
  Future<Map<String, dynamic>?> uploadFile({
    required String filePath,
    String? templateId,
    Function(int sent, int total)? onProgress,
  }) async {
    return await executeAsync(
      () async {
        final result = await _repository.uploadImportFile(
          filePath: filePath,
          templateId: templateId,
          onProgress: onProgress,
        );
        // Reload history after upload
        await loadImportHistory();
        await loadStatistics();
        return result;
      },
      errorMessage: 'Failed to upload file',
    );
  }

  /// Validate import file
  Future<Map<String, dynamic>?> validateFile({
    required String fileId,
    String? templateId,
  }) async {
    return await executeAsync(
      () async {
        return await _repository.validateImportFile(
          fileId: fileId,
          templateId: templateId,
        );
      },
      errorMessage: 'Failed to validate file',
    );
  }

  /// Process import file
  Future<Map<String, dynamic>?> processFile({
    required String fileId,
    String? templateId,
  }) async {
    return await executeAsync(
      () async {
        final result = await _repository.processImportFile(
          fileId: fileId,
          templateId: templateId,
        );
        // Start tracking progress
        _trackingFileId = fileId;
        _startProgressTracking(fileId);
        return result;
      },
      errorMessage: 'Failed to process file',
    );
  }

  /// Start tracking import progress (polling)
  void _startProgressTracking(String fileId) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final status = await _repository.getImportStatus(fileId);
        final importStatus = status['status'] as String?;

        // Update the import in history
        final index = _importHistory.indexWhere((item) => item['id'] == fileId);
        if (index != -1) {
          _importHistory[index] = {
            ..._importHistory[index],
            ...status,
          };
          notifyListeners();
        }

        // Stop tracking if completed or failed
        if (importStatus == 'completed' || importStatus == 'failed') {
          timer.cancel();
          _trackingFileId = null;
          // Reload statistics
          await loadStatistics();
        }
      } catch (e) {
        // Stop tracking on error
        timer.cancel();
        _trackingFileId = null;
      }
    });
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}

