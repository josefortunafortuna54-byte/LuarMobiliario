import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/theme/app_palette.dart';
import '../l10n/app_localizations.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(widget.looping);
      if (widget.autoPlay) {
        await controller.play();
      }
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (_hasError) {
      return Container(
        color: AppColors.navy,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 40, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).erroCarregarVideo,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    if (!_initialized || controller == null) {
      return Container(
        color: palette.surfaceAlt,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          if (!controller.value.isPlaying)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.gold,
                bufferedColor: Colors.white38,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
