import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../providers/locale_provider.dart';

/// Widget to display job history
class JobHistoryWidget extends StatefulWidget {
  final Function(Job) onJobSelected;

  const JobHistoryWidget({super.key, required this.onJobSelected});

  @override
  State<JobHistoryWidget> createState() => _JobHistoryWidgetState();
}

class _JobHistoryWidgetState extends State<JobHistoryWidget> {
  final ApiService _apiService = ApiService();
  List<Job> _jobs = [];
  bool _isLoading = false;
  bool _isServerWakingUp = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _isServerWakingUp = false;
      _error = null;
    });

    try {
      final response = await _apiService.listJobs();

      // Filter jobs to show only user's own jobs
      final userJobIds = StorageService.getUserJobIds();
      final userJobs = response.jobs
          .where((job) => userJobIds.contains(job.id))
          .toList();

      setState(() {
        _jobs = userJobs;
        _isLoading = false;
        _isServerWakingUp = false;
      });
    } catch (e) {
      // Check if it's a server cold start
      if (e.toString().contains('SERVER_COLD_START')) {
        setState(() {
          _isServerWakingUp = true;
          _isLoading = false;
          _error = null;
        });
        
        // Retry after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          _loadJobs();
        }
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isServerWakingUp = false;
        });
      }
    }
  }

  Widget _buildStatusChip(Job job, AppLocalizations locale, ThemeData theme) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    final isDark = theme.brightness == Brightness.dark;

    if (job.isCompleted) {
      bgColor = isDark
          ? const Color(0xFF10B981).withOpacity(0.2)
          : const Color(0xFFD1FAE5);
      textColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      label = locale.completed;
    } else if (job.isFailed) {
      bgColor = isDark
          ? const Color(0xFFEF4444).withOpacity(0.2)
          : const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
      label = locale.failed;
    } else if (job.isProcessing) {
      bgColor = isDark
          ? const Color(0xFFF59E0B).withOpacity(0.2)
          : const Color(0xFFFED7AA);
      textColor = const Color(0xFFF59E0B);
      icon = Icons.hourglass_bottom_rounded;
      label = locale.processingStatus;
    } else {
      bgColor = isDark
          ? theme.colorScheme.primary.withOpacity(0.2)
          : const Color(0xFFDFE3FF);
      textColor = theme.colorScheme.primary;
      icon = Icons.schedule_rounded;
      label = locale.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? theme.colorScheme.background : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.history,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          locale.yourEdits,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey[100]
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locale.privateHistory,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _loadJobs,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.refresh,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
          if (_isServerWakingUp)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : const Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_sync_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locale.serverWakingUp,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey[100]
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale.serverColdStart,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        locale.pleaseWait,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_isLoading)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFFEF4444).withOpacity(0.2)
                              : const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locale.errorLoading,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey[100]
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadJobs,
                        icon: const Icon(Icons.refresh),
                        label: Text(locale.retry),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_jobs.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.image_search,
                          size: 48,
                          color: isDark
                              ? Colors.grey[600]
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        locale.noJobs,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey[100]
                              : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale.createFirst,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _jobs.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.dividerColor,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onJobSelected(job),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  job.isCompleted && job.resultImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _apiService.getImageUrl(
                                          job.resultImageUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image_outlined,
                                                color: Color(0xFF9CA3AF),
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFF9CA3AF),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Job info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.prompt,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.grey[100]
                                          : const Color(0xFF1F2937),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDateTime(job.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _buildStatusChip(job, locale, theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
