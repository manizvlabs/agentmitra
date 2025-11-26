import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'api_service.dart';

class FileUploadService {
  static const String baseUrl = 'http://localhost:8012';
  static const String apiVersion = '/api/v1';

  /// Upload file to presentations media endpoint
  static Future<Map<String, dynamic>> uploadPresentationMedia(
    String filePath,
    List<int> fileBytes, {
    String? fileName,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    final uri = Uri.parse('$baseUrl$apiVersion/presentations/media/upload');

    final request = http.MultipartRequest('POST', uri);

    // Add authorization header if available
    final headers = await ApiService.getHeaders();
    request.headers.addAll(headers);

    // Create multipart file
    final fileNameToUse = fileName ?? path.basename(filePath);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileNameToUse,
    );

    request.files.add(multipartFile);

    // Add metadata as fields
    if (metadata != null) {
      metadata.forEach((key, value) {
        request.fields[key] = value;
      });
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiService.handleResponse(response);
      } else {
        throw Exception('Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Upload file to general file upload endpoint
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    List<int> fileBytes, {
    String? fileName,
    String? contentType,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('$baseUrl$apiVersion$endpoint');

    final request = http.MultipartRequest('POST', uri);

    // Add authorization header if available
    final headers = await ApiService.getHeaders();
    request.headers.addAll(headers);

    // Create multipart file
    final fileNameToUse = fileName ?? path.basename(filePath);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileNameToUse,
    );

    request.files.add(multipartFile);

    // Add additional fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiService.handleResponse(response);
      } else {
        throw Exception('Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  /// Upload profile image
  static Future<Map<String, dynamic>> uploadProfileImage(
    String userId,
    String filePath,
    List<int> fileBytes,
  ) async {
    return uploadFile(
      '/users/$userId/profile-image',
      filePath,
      fileBytes,
      fields: {'user_id': userId},
    );
  }

  /// Upload document
  static Future<Map<String, dynamic>> uploadDocument(
    String documentType,
    String filePath,
    List<int> fileBytes, {
    String? userId,
    Map<String, String>? metadata,
  }) async {
    final fields = <String, String>{
      'document_type': documentType,
    };

    if (userId != null) fields['user_id'] = userId;
    if (metadata != null) {
      metadata.forEach((key, value) {
        fields['metadata_$key'] = value;
      });
    }

    return uploadFile(
      '/documents/upload',
      filePath,
      fileBytes,
      fields: fields,
    );
  }

  /// Get upload progress (if supported by endpoint)
  static Future<Map<String, dynamic>> getUploadStatus(String uploadId) async {
    return await ApiService.get('/uploads/status/$uploadId');
  }

  /// Delete uploaded file
  static Future<void> deleteUploadedFile(String fileId) async {
    await ApiService.delete('/uploads/files/$fileId');
  }
}
