import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:universal_html/html.dart' as html;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/job.dart';
import '../services/api_service.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/job_history_widget.dart';
import '../widgets/before_after_slider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _promptController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String?
  _currentBeforeImageUrl; // For displaying correct before image in history
  Job? _currentJob;
  bool _isProcessing = false;
  String? _error;
  String _selectedModel = 'seedream'; // Default model

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelected(Uint8List bytes, String name) async {
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = name;
      _currentBeforeImageUrl = null; // Reset when new image uploaded
      _error = null;
    });
  }

  Future<void> _handleGenerateEdit() async {
    if (_selectedImageBytes == null) {
      _showError('Please select an image first');
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt');
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
      _currentJob = null;
    });

    try {
      // Create job
      final job = await _apiService.createJob(
        imageBytes: _selectedImageBytes!,
        fileName: _selectedImageName!,
        prompt: _promptController.text.trim(),
        model: _selectedModel,
      );

      setState(() {
        _currentJob = job;
      });

      // Poll for results
      await for (final updatedJob in _apiService.pollJob(job.id)) {
        setState(() {
          _currentJob = updatedJob;
        });

        if (updatedJob.isCompleted || updatedJob.isFailed) {
          break;
        }
      }

      if (_currentJob!.isFailed) {
        _showError(_currentJob!.errorMessage ?? 'Job failed');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleDownload() async {
    if (_currentJob?.resultImageUrl == null) return;

    try {
      final url = _apiService.getImageUrl(_currentJob!.resultImageUrl!);

      // Fetch the image as blob to avoid CORS issues with download
      final response = await html.window.fetch(url);
      final blob = await response.blob();

      // Create object URL from blob
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // Create and trigger download
      final anchor = html.AnchorElement(href: blobUrl)
        ..setAttribute('download', 'voltran_edited_${_currentJob!.id}.jpg')
        ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();

      // Cleanup
      anchor.remove();
      html.Url.revokeObjectUrl(blobUrl);
    } catch (e) {
      _showError('Failed to download image: $e');
    }
  }

  void _handleJobSelected(Job job) {
    setState(() {
      _currentJob = job;
      _promptController.text = job.prompt;
      // Set the before image URL from the job's original image
      _currentBeforeImageUrl = job.originalImagePath;
      // Clear the uploaded image bytes since we're viewing a history item
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  Widget _buildResultSection() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentJob == null) {
      return const SizedBox.shrink();
    }

    if (_isProcessing) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : const Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: SpinKitFadingCircle(
                  color: theme.colorScheme.primary,
                  size: 60.0,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getStatusMessage(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[100] : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                locale.mayTakeMinutes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentJob!.isCompleted && _currentJob!.resultImageUrl != null) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale.result,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey[100]
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleDownload,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                locale.download,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Display result image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _apiService.getImageUrl(_currentJob!.resultImageUrl!),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 48,
                          color: isDark
                              ? const Color(0xFFFF6B6B)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Before/After comparison
              if (_selectedImageBytes != null ||
                  _currentBeforeImageUrl != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFF59E0B).withOpacity(0.2)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.compare,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      locale.beforeAfter,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey[100]
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BeforeAfterSlider(
                  beforeImage: _selectedImageBytes,
                  beforeImageUrl: _currentBeforeImageUrl,
                  afterImageUrl: _apiService.getImageUrl(
                    _currentJob!.resultImageUrl!,
                  ),
                  apiService: _apiService,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusMessage() {
    final locale = AppLocalizations.of(context);

    if (_currentJob == null) return locale.processing;

    switch (_currentJob!.status) {
      case 'pending':
        return locale.jobQueued;
      case 'processing':
        return locale.aiEditing;
      case 'completed':
        return locale.complete;
      case 'failed':
        return locale.failed;
      default:
        return locale.processing;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final locale = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_fix_high,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(locale.appTitle),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          // Language toggle button
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 20,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                const SizedBox(width: 4),
                Text(
                  localeProvider.isEnglish ? 'EN' : 'TR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ],
            ),
            onSelected: (String value) {
              localeProvider.setLocale(Locale(value));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text('🇺🇸'),
                    const SizedBox(width: 8),
                    const Text('English'),
                    if (localeProvider.isEnglish) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tr',
                child: Row(
                  children: [
                    const Text('🇹🇷'),
                    const SizedBox(width: 8),
                    const Text('Türkçe'),
                    if (localeProvider.isTurkish) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        locale.poweredBy,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isMobile || isTablet ? _buildMobileLayout() : _buildDesktopLayout(),
      floatingActionButton: (isMobile || isTablet)
          ? FloatingActionButton.extended(
              onPressed: () => _showHistoryBottomSheet(context),
              icon: const Icon(Icons.history),
              label: const Text('History'),
              backgroundColor: const Color(0xFF6366F1),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // Main content area
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildUploadSection(),
                    const SizedBox(height: 24),
                    _buildPromptSection(),
                    const SizedBox(height: 24),
                    _buildGenerateButton(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorDisplay(),
                    ],
                    const SizedBox(height: 32),
                    _buildResultSection(),
                    const SizedBox(height: 48),
                    _buildCreatorFooter(locale),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Job history sidebar
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              left: BorderSide(color: theme.dividerColor, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: JobHistoryWidget(onJobSelected: _handleJobSelected),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final locale = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildUploadSection(),
          const SizedBox(height: 20),
          _buildPromptSection(),
          const SizedBox(height: 20),
          _buildGenerateButton(),
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorDisplay(),
          ],
          const SizedBox(height: 24),
          _buildResultSection(),
          const SizedBox(height: 32),
          _buildCreatorFooter(locale),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.transformImages,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[100] : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          locale.uploadImageDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                    Icons.cloud_upload_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  locale.uploadImage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[100] : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ImageUploadWidget(
              onImageSelected: _handleImageSelected,
              currentImage: _selectedImageBytes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptSection() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFF59E0B).withOpacity(0.2)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  locale.describeEdit,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[100] : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              maxLines: 4,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[100] : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: locale.promptHint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? theme.dividerColor : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? theme.dividerColor : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            _buildModelSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final models = [
      {
        'value': 'seedream',
        'name': locale.modelSeedream,
        'desc': locale.modelSeedreamDesc,
        'icon': Icons.flash_on,
      },
      {
        'value': 'nano_banana',
        'name': locale.modelNanoBanana,
        'desc': locale.modelNanoBananaDesc,
        'icon': Icons.speed,
      },
      {
        'value': 'flux_dev',
        'name': locale.modelFluxDev,
        'desc': locale.modelFluxDevDesc,
        'icon': Icons.auto_awesome,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.selectModel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[100] : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? theme.dividerColor : Colors.grey[300]!,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _selectedModel,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[100] : Colors.black87,
            ),
            items: models.map((model) {
              return DropdownMenuItem<String>(
                value: model['value'] as String,
                child: Row(
                  children: [
                    Icon(
                      model['icon'] as IconData,
                      size: 20,
                      color: _selectedModel == model['value']
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            model['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.grey[100] : Colors.black87,
                            ),
                          ),
                          Text(
                            model['desc'] as String,
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
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedModel = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: _isProcessing
            ? null
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isProcessing
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _handleGenerateEdit,
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_fix_high, size: 22),
        label: Text(
          _isProcessing ? locale.processing : locale.generateEdit,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isProcessing ? Colors.grey : Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFEF4444).withOpacity(0.1)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.history, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      locale.jobHistory,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: JobHistoryWidget(
                  onJobSelected: (job) {
                    _handleJobSelected(job);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorFooter(AppLocalizations locale) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              locale.createdBy,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Berkay',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 20,
              width: 1,
              color: isDark
                  ? theme.colorScheme.outline.withOpacity(0.3)
                  : Colors.grey[300],
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                final uri = Uri.parse('https://github.com/berkawaii');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      locale.viewGithub,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
