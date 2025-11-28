import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../../../core/services/api_service.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../shared/constants/api_constants.dart';

/// Configuration Portal Repository
/// Handles all API calls for Configuration Portal features
class ConfigPortalRepository {
  final LoggerService _logger;

  ConfigPortalRepository({
    LoggerService? logger,
  }) : _logger = logger ?? LoggerService();

  /// Data Import Methods
  Future<List<Map<String, dynamic>>> getImportHistory({
    String? status,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await ApiService.get(
        ApiConstants.importHistory(),
        queryParameters: queryParams,
      );

      // Handle both direct list and wrapped response
      if (response is List) {
        return List<Map<String, dynamic>>.from(response as List);
      }
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['items'] ?? response;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      _logger.error('Failed to fetch import history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getImportStatistics() async {
    try {
      final response = await ApiService.get(
        ApiConstants.importStatistics(),
      );
      // Handle both direct map and wrapped response
      if (response is Map<String, dynamic>) {
        return response.containsKey('data') ? response['data'] as Map<String, dynamic> : response;
      }
      return {};
    } catch (e) {
      _logger.error('Failed to fetch import statistics: $e');
      rethrow;
    }
  }

  /// Upload import file with progress tracking
  Future<Map<String, dynamic>> uploadImportFile({
    required String filePath,
    String? templateId,
    Map<String, String>? options,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final fileBytes = await file.readAsBytes();
      final fileName = path.basename(filePath);
      
      // Determine content type
      String contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      if (fileName.endsWith('.csv')) {
        contentType = 'text/csv';
      } else if (fileName.endsWith('.xls')) {
        contentType = 'application/vnd.ms-excel';
      }

      // Prepare fields
      final fields = <String, String>{};
      if (templateId != null) {
        fields['template_id'] = templateId;
      }
      if (options != null) {
        fields['options'] = options.toString(); // Will be JSON encoded on backend
      }

      // Use FileUploadService for multipart upload
      // FileUploadService expects endpoint path starting with /
      final endpoint = ApiConstants.importUpload();
      final response = await FileUploadService.uploadFile(
        endpoint,
        filePath,
        fileBytes,
        fileName: fileName,
        contentType: contentType,
        fields: fields,
      );

      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to upload import file: $e');
      rethrow;
    }
  }

  /// Validate uploaded file
  Future<Map<String, dynamic>> validateImportFile({
    required String fileId,
    String? templateId,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.importValidate(fileId),
        {
          if (templateId != null) 'template_id': templateId,
        },
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to validate import file: $e');
      rethrow;
    }
  }

  /// Process import file
  Future<Map<String, dynamic>> processImportFile({
    required String fileId,
    String? templateId,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.importProcess(fileId),
        {
          if (templateId != null) 'template_id': templateId,
        },
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to process import file: $e');
      rethrow;
    }
  }

  /// Get import status (for progress tracking)
  Future<Map<String, dynamic>> getImportStatus(String fileId) async {
    try {
      final response = await ApiService.get(
        ApiConstants.importStatus(fileId),
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to get import status: $e');
      rethrow;
    }
  }

  /// Excel Template Methods
  Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await ApiService.get(
        ApiConstants.importTemplates(),
      );
      // Handle both direct list and wrapped response
      if (response is List) {
        return List<Map<String, dynamic>>.from(response as List);
      }
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['templates'] ?? response;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      _logger.error('Failed to fetch templates: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTemplate(String templateId) async {
    try {
      final response = await ApiService.get(
        ApiConstants.importTemplate(templateId),
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to fetch template: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveTemplate({
    required Map<String, dynamic> templateData,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.importTemplates(),
        templateData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to save template: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTemplate({
    required String templateId,
    required Map<String, dynamic> templateData,
  }) async {
    try {
      final response = await ApiService.put(
        ApiConstants.importTemplate(templateId),
        templateData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to update template: $e');
      rethrow;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await ApiService.delete(
        ApiConstants.importTemplate(templateId),
      );
    } catch (e) {
      _logger.error('Failed to delete template: $e');
      rethrow;
    }
  }

  /// Customer Data Management Methods with Pagination
  Future<Map<String, dynamic>> getCustomers({
    String? search,
    String? status,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await ApiService.get(
        ApiConstants.customers,
        queryParameters: queryParams,
      );

      // Return paginated response
      return {
        'items': List<Map<String, dynamic>>.from(
          response['data'] ?? response['items'] ?? [],
        ),
        'total': response['total'] ?? response['count'] ?? 0,
        'limit': limit,
        'offset': offset,
        'hasMore': (response['total'] ?? response['count'] ?? 0) > ((offset ?? 0) + (limit ?? 20)),
      };
    } catch (e) {
      _logger.error('Failed to fetch customers: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required Map<String, dynamic> customerData,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.customers,
        customerData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
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
      final response = await ApiService.put(
        ApiConstants.customerById(customerId),
        customerData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to update customer: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await ApiService.delete(
        ApiConstants.customerById(customerId),
      );
    } catch (e) {
      _logger.error('Failed to delete customer: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCustomer(String customerId) async {
    try {
      final response = await ApiService.get(
        ApiConstants.customerById(customerId),
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to fetch customer: $e');
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
      final response = await ApiService.post(
        ApiConstants.reportGenerate(),
        {
          'report_type': reportType,
          'filters': filters,
          'format': format,
        },
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to generate report: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledReports() async {
    try {
      final response = await ApiService.get(
        ApiConstants.reportScheduled(),
      );
      // Handle both direct list and wrapped response
      if (response is List) {
        return List<Map<String, dynamic>>.from(response as List);
      }
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['scheduled'] ?? response;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return [];
    } catch (e) {
      _logger.error('Failed to fetch scheduled reports: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReportHistory({
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      final response = await ApiService.get(
        ApiConstants.reportHistory(),
        queryParameters: queryParams,
      );

      // Return paginated response
      return {
        'items': List<Map<String, dynamic>>.from(
          response['data'] ?? response['items'] ?? [],
        ),
        'total': response['total'] ?? response['count'] ?? 0,
        'limit': limit,
        'offset': offset,
        'hasMore': (response['total'] ?? response['count'] ?? 0) > ((offset ?? 0) + (limit ?? 20)),
      };
    } catch (e) {
      _logger.error('Failed to fetch report history: $e');
      rethrow;
    }
  }

  Future<String> downloadReport(String reportId) async {
    try {
      // Returns download URL
      final response = await ApiService.get(
        ApiConstants.reportDownload(reportId),
      );
      return response['download_url'] ?? response['url'] ?? '';
    } catch (e) {
      _logger.error('Failed to get report download URL: $e');
      rethrow;
    }
  }

  /// User Management Methods with Pagination
  Future<Map<String, dynamic>> getUsers({
    String? search,
    String? role,
    int? limit = 20,
    int? offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (role != null && role != 'all') {
        queryParams['role'] = role;
      }

      final response = await ApiService.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      // Handle response - backend returns List<UserResponse> directly
      List<Map<String, dynamic>> usersList;
      if (response is List) {
        usersList = List<Map<String, dynamic>>.from(response as List);
      } else {
        usersList = [];
      }

      // Since backend doesn't provide total count, estimate it
      // If we got a full page, assume there might be more
      // If we got less than requested, this is the last page
      final requestedLimit = limit ?? 20;
      final hasMore = usersList.length >= requestedLimit;

      return {
        'items': usersList,
        'total': hasMore ? (offset ?? 0) + usersList.length + requestedLimit : (offset ?? 0) + usersList.length,
        'limit': limit,
        'offset': offset,
        'hasMore': hasMore,
      };
    } catch (e) {
      _logger.error('Failed to fetch users: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await ApiService.post(
        ApiConstants.users,
        userData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
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
      final response = await ApiService.put(
        ApiConstants.userById(userId),
        userData,
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to update user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await ApiService.delete(
        ApiConstants.userById(userId),
      );
    } catch (e) {
      _logger.error('Failed to delete user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await ApiService.get(
        ApiConstants.userById(userId),
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to fetch user: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserPermissions({
    required String userId,
    required List<String> permissions,
  }) async {
    try {
      final response = await ApiService.put(
        ApiConstants.userPermissions(userId),
        {'permissions': permissions},
      );
      return Map<String, dynamic>.from(response['data'] ?? response);
    } catch (e) {
      _logger.error('Failed to update user permissions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivity({
    required String userId,
    int? limit = 50,
    int? offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      final response = await ApiService.get(
        ApiConstants.userActivity(userId),
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response['data'] ?? response['activity'] ?? []);
    } catch (e) {
      _logger.error('Failed to fetch user activity: $e');
      rethrow;
    }
  }
}

