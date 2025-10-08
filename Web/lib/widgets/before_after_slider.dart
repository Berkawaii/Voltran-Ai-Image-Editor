import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';

/// Widget for comparing before and after images
class BeforeAfterSlider extends StatefulWidget {
  final Uint8List? beforeImage;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final ApiService? apiService;

  const BeforeAfterSlider({
    super.key,
    this.beforeImage,
    this.beforeImageUrl,
    required this.afterImageUrl,
    this.apiService,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if ((widget.beforeImage == null && widget.beforeImageUrl == null) ||
        widget.afterImageUrl == null) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
          border: Border.all(
            color: isDark ? theme.dividerColor : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            locale.noImagesCompare,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 450,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Before image (full width) - either from bytes or URL
                Positioned.fill(
                  child: widget.beforeImage != null
                      ? Image.memory(widget.beforeImage!, fit: BoxFit.contain)
                      : Image.network(
                          widget.apiService!.getImageUrl(
                            widget.beforeImageUrl!,
                          ),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Color(0xFFEF4444),
                                size: 48,
                              ),
                            );
                          },
                        ),
                ),
                // After image (clipped)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _ImageClipper(_sliderPosition),
                    child: Image.network(
                      widget.afterImageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Slider line with handle
                Positioned(
                  left: _sliderPosition * constraints.maxWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.drag_indicator,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Labels
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildLabel(
                    locale.before,
                    Icons.image_outlined,
                    isDark,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildLabel(locale.after, Icons.auto_fix_high, isDark),
                ),
                // Gesture detector
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sliderPosition =
                            (details.localPosition.dx / constraints.maxWidth)
                                .clamp(0.0, 1.0);
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        _sliderPosition =
                            (details.localPosition.dx / constraints.maxWidth)
                                .clamp(0.0, 1.0);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.7) : Colors.black87,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double position;

  _ImageClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(position * size.width, 0, size.width, size.height);
  }

  @override
  bool shouldReclip(_ImageClipper oldClipper) {
    return oldClipper.position != position;
  }
}
