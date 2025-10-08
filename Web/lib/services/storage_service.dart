import 'dart:html' as html;
import 'dart:convert';

/// Service for managing user's job history in browser localStorage
class StorageService {
  static const String _jobsKey = 'voltran_user_jobs';

  /// Get list of user's job IDs from localStorage
  static List<String> getUserJobIds() {
    try {
      final storage = html.window.localStorage;
      final jobsJson = storage[_jobsKey];

      if (jobsJson == null || jobsJson.isEmpty) {
        return [];
      }

      final List<dynamic> jobsList = json.decode(jobsJson);
      return jobsList.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error reading user jobs from localStorage: $e');
      return [];
    }
  }

  /// Add a job ID to user's list
  static void addJobId(String jobId) {
    try {
      final currentJobs = getUserJobIds();

      // Avoid duplicates
      if (!currentJobs.contains(jobId)) {
        currentJobs.add(jobId);

        final storage = html.window.localStorage;
        storage[_jobsKey] = json.encode(currentJobs);
      }
    } catch (e) {
      print('Error saving job ID to localStorage: $e');
    }
  }

  /// Remove a job ID from user's list
  static void removeJobId(String jobId) {
    try {
      final currentJobs = getUserJobIds();
      currentJobs.remove(jobId);

      final storage = html.window.localStorage;
      storage[_jobsKey] = json.encode(currentJobs);
    } catch (e) {
      print('Error removing job ID from localStorage: $e');
    }
  }

  /// Clear all user's job IDs
  static void clearAllJobIds() {
    try {
      final storage = html.window.localStorage;
      storage.remove(_jobsKey);
    } catch (e) {
      print('Error clearing job IDs from localStorage: $e');
    }
  }

  /// Check if a job ID belongs to current user
  static bool isUserJob(String jobId) {
    return getUserJobIds().contains(jobId);
  }
}
