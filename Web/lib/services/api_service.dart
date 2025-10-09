import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/job.dart';

/// API service for communicating with the backend
class ApiService {
  // Backend URL - change this when deploying
  static const String baseUrl = 'https://voltran-ai-image-editor.onrender.com';

  /// Create a new image editing job
  ///
  /// [imageBytes] - Image file bytes
  /// [fileName] - Image file name
  /// [prompt] - Edit prompt
  /// [model] - AI model to use (seedream, nano_banana, or flux_dev)
  Future<Job> createJob({
    required Uint8List imageBytes,
    required String fileName,
    required String prompt,
    String model = 'seedream',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs');

      final request = http.MultipartRequest('POST', uri);
      request.fields['prompt'] = prompt;
      request.fields['model'] = model;

      // Determine content type from file extension
      String contentTypeString = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentTypeString = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentTypeString = 'image/webp';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        contentTypeString = 'image/jpeg';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(contentTypeString),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return Job.fromJson(jsonData);
      } else {
        throw Exception('Failed to create job: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  /// Get job by ID
  ///
  /// [jobId] - Job identifier
  Future<Job> getJob(String jobId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs/$jobId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return Job.fromJson(jsonData);
      } else {
        throw Exception('Failed to get job: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting job: $e');
    }
  }

  /// Get all jobs
  ///
  /// [skip] - Number of records to skip
  /// [limit] - Maximum number of records to return
  Future<JobListResponse> listJobs({int skip = 0, int limit = 100}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs?skip=$skip&limit=$limit');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 60), // Longer timeout for cold start
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return JobListResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to list jobs: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException') || 
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('SERVER_COLD_START');
      }
      throw Exception('Error listing jobs: $e');
    }
  }

  /// Delete a job
  ///
  /// [jobId] - Job identifier
  Future<void> deleteJob(String jobId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/jobs/$jobId');
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete job: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting job: $e');
    }
  }

  /// Poll job until it completes or fails
  ///
  /// [jobId] - Job identifier
  /// [maxAttempts] - Maximum number of polling attempts
  /// [intervalSeconds] - Seconds between each poll
  Stream<Job> pollJob(
    String jobId, {
    int maxAttempts = 120,
    int intervalSeconds = 5,
  }) async* {
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(seconds: intervalSeconds));

      final job = await getJob(jobId);
      yield job;

      if (job.isCompleted || job.isFailed) {
        break;
      }
    }
  }

  /// Get the full URL for an uploaded image
  String getImageUrl(String imagePath) {
    // If it's already a full URL (from fal.ai), return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Otherwise, it's a local backend path
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/$path';
  }
}
