/// Job model for API responses
class Job {
  final String id;
  final String prompt;
  final String originalImagePath;
  final String? resultImageUrl;
  final String status;
  final String? errorMessage;
  final String model;
  final DateTime createdAt;
  final DateTime updatedAt;

  Job({
    required this.id,
    required this.prompt,
    required this.originalImagePath,
    this.resultImageUrl,
    required this.status,
    this.errorMessage,
    this.model = 'seedream',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      originalImagePath: json['original_image_path'] as String,
      resultImageUrl: json['result_image_url'] as String?,
      status: json['status'] as String,
      errorMessage: json['error_message'] as String?,
      model: json['model'] as String? ?? 'seedream',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'original_image_path': originalImagePath,
      'result_image_url': resultImageUrl,
      'status': status,
      'error_message': errorMessage,
      'model': model,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';
  bool get isPending => status == 'pending';
}

/// Job list response model
class JobListResponse {
  final List<Job> jobs;
  final int total;

  JobListResponse({required this.jobs, required this.total});

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      jobs: (json['jobs'] as List)
          .map((jobJson) => Job.fromJson(jobJson as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}
