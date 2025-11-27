import '../../../core/services/api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/constants/api_constants.dart';

/// Configuration Portal Repository
/// Handles all API calls for Configuration Portal features
class ConfigPortalRepository {
  final ApiService _apiService;
  final LoggerService _logger;

  ConfigPortalRepository({
    ApiService? apiService,
    LoggerService? logger,
  })  : _apiService = apiService ?? ApiService(),
        _logger = logger ?? LoggerService();

  /// Data Import Methods
  Future<List<Map<String, dynamic>>> getImportHistory({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/data-imports',
        queryParams: queryParams,
      );

      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch import history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getImportStatistics() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/data-imports/statistics',
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to fetch import statistics: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadImportFile({
    required String filePath,
    required String templateId,
  }) async {
    try {
      // TODO: Implement file upload
      final response = await _apiService.post(
        '${ApiConstants.baseUrl}/api/v1/data-imports/upload',
        data: {
          'file_path': filePath,
          'template_id': templateId,
        },
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to upload import file: $e');
      rethrow;
    }
  }

  /// Excel Template Methods
  Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/templates',
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch templates: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveTemplate({
    required Map<String, dynamic> templateData,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.baseUrl}/api/v1/templates',
        data: templateData,
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to save template: $e');
      rethrow;
    }
  }

  /// Customer Data Management Methods
  Future<List<Map<String, dynamic>>> getCustomers({
    String? search,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/customers',
        queryParams: queryParams,
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch customers: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required Map<String, dynamic> customerData,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.baseUrl}/api/v1/customers',
        data: customerData,
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to create customer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCustomer({
    required String customerId,
    required Map<String, dynamic> customerData,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.baseUrl}/api/v1/customers/$customerId',
        data: customerData,
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to update customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.baseUrl}/api/v1/customers/$customerId',
      );
    } catch (e) {
      _logger.error('Failed to delete customer: $e');
      rethrow;
    }
  }

  /// Reporting Methods
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required Map<String, dynamic> filters,
    required String format,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.baseUrl}/api/v1/reports/generate',
        data: {
          'report_type': reportType,
          'filters': filters,
          'format': format,
        },
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to generate report: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledReports() async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/reports/scheduled',
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch scheduled reports: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getReportHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/reports/history',
        queryParams: queryParams,
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch report history: $e');
      rethrow;
    }
  }

  /// User Management Methods
  Future<List<Map<String, dynamic>>> getUsers({
    String? search,
    String? role,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null) queryParams['search'] = search;
      if (role != null) queryParams['role'] = role;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _apiService.get(
        '${ApiConstants.baseUrl}/api/v1/users',
        queryParams: queryParams,
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch users: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.baseUrl}/api/v1/users',
        data: userData,
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to create user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.baseUrl}/api/v1/users/$userId',
        data: userData,
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to update user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete(
        '${ApiConstants.baseUrl}/api/v1/users/$userId',
      );
    } catch (e) {
      _logger.error('Failed to delete user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserPermissions({
    required String userId,
    required List<String> permissions,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.baseUrl}/api/v1/users/$userId/permissions',
        data: {'permissions': permissions},
      );
      return Map<String, dynamic>.from(response['data'] ?? {});
    } catch (e) {
      _logger.error('Failed to update user permissions: $e');
      rethrow;
    }
  }
}

