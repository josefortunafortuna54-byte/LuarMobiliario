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

  /// Controla se o vídeo pode reproduzir. No feed vertical (Luar Discover),
  /// apenas a página ativa deve ter [isActive] a `true`.
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
    this.isActive = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isAppActive = true;
  bool _userPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _reinitialize();
      return;
    }
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.autoPlay != widget.autoPlay) {
      _syncPlayback();
    }
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(widget.looping);
      _syncPlayback();
      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _reinitialize() async {
    final old = _controller;
    _controller = null;
    _initialized = false;
    _hasError = false;
    _userPaused = false;
    if (mounted) setState(() {});
    await old?.dispose();
    await _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  /// Pausa/retoma o vídeo de acordo com o estado ativo, o ciclo de vida da
  /// aplicação e a preferência do utilizador.
  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final shouldPlay =
        widget.autoPlay &&
        widget.isActive &&
        _isAppActive &&
        !_userPaused;

    if (shouldPlay && !controller.value.isPlaying) {
      await controller.play();
    } else if (!shouldPlay && controller.value.isPlaying) {
      await controller.pause();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _userPaused = controller.value.isPlaying;
    _syncPlayback();
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
            const Icon(
              Icons.videocam_off_outlined,
              size: 40,
              color: Colors.white70,
            ),
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
