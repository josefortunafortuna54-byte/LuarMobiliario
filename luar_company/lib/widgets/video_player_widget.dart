import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../l10n/app_localizations.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  /// Primeira imagem do anúncio, usada como poster enquanto o vídeo carrega
  /// (ou quando o utilizador desativou a reprodução automática).
  final String? posterUrl;

  final bool autoPlay;
  final bool looping;

  /// Controla se o vídeo pode reproduzir. No feed vertical (Luar Discover),
  /// apenas a página ativa deve ter [isActive] a `true`.
  final bool isActive;

  /// Como o vídeo ocupa a área disponível: [BoxFit.contain] preserva o ratio
  /// nativo com barras; [BoxFit.cover] preenche a área (modo TikTok) e recorta
  /// o excesso.
  final BoxFit fit;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.posterUrl,
    this.autoPlay = false,
    this.looping = false,
    this.isActive = true,
    this.fit = BoxFit.contain,
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
  bool _wantsPlay = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoPlay) {
      _initialize();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _reinitialize();
      return;
    }
    if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay && _controller == null && !_hasError) {
        _initialize();
      }
      _syncPlayback();
    }
    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      // Evita corridas com um _reinitialize concorrente: só avança se este
      // controller ainda for o ativo e o widget continuar montado.
      if (!mounted || !identical(_controller, controller)) {
        await controller.dispose();
        return;
      }
      await controller.setLooping(widget.looping);
      if (!mounted || !identical(_controller, controller)) {
        await controller.dispose();
        return;
      }
      setState(() => _initialized = true);
      await _syncPlayback();
    } catch (_) {
      if (mounted && identical(_controller, controller)) {
        setState(() => _hasError = true);
      }
    }
  }

  Future<void> _reinitialize() async {
    final old = _controller;
    _controller = null;
    _initialized = false;
    _hasError = false;
    _userPaused = false;
    _wantsPlay = false;
    if (mounted) setState(() {});
    await old?.dispose();
    if (widget.autoPlay) await _initialize();
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
        (widget.autoPlay || _wantsPlay) &&
        widget.isActive &&
        _isAppActive &&
        !_userPaused &&
        _isVisible;

    if (!mounted) return;
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
    if (controller == null || !controller.value.isInitialized) {
      // Com reprodução automática desativada, o primeiro toque inicia o
      // carregamento e a reprodução do vídeo.
      _wantsPlay = true;
      _userPaused = false;
      _initialize();
      return;
    }
    _userPaused = controller.value.isPlaying;
    _syncPlayback();
  }

  Widget _buildPoster({bool dimmed = false}) {
    final poster = widget.posterUrl;
    if (poster == null || poster.isEmpty) {
      return Container(
        color: AppColors.navy,
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_circle_outline_rounded,
          size: 56,
          color: Colors.white54,
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: poster,
          fit: BoxFit.cover,
          memCacheWidth: 1080,
          placeholder: (_, _) => Container(color: AppColors.navy),
          errorWidget: (_, _, _) => Container(
            color: AppColors.navy,
            alignment: Alignment.center,
            child: const Icon(
              Icons.play_circle_outline_rounded,
              size: 56,
              color: Colors.white54,
            ),
          ),
        ),
        if (dimmed) Container(color: AppColors.black.withValues(alpha: 0.35)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-${widget.url}'),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.6;
        if (visible != _isVisible) {
          _isVisible = visible;
          _syncPlayback();
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildVideo(VideoPlayerController controller) {
    final size = controller.value.size;
    final canCover =
        widget.fit == BoxFit.cover && size.width > 0 && size.height > 0;

    if (!canCover) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    }

    // `BoxFit.cover`: preenche a área disponível e recorta o excesso, como no
    // feed vertical estilo TikTok (evita as barras pretas do letterbox).
    return SizedBox.expand(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildPoster(dimmed: true),
          Center(
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final controller = _controller;
    if (!_initialized || controller == null) {
      // Poster visível enquanto o vídeo carrega (ou até o utilizador tocar,
      // quando a reprodução automática está desativada).
      return GestureDetector(
        onTap: widget.autoPlay ? null : _togglePlayback,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPoster(),
            if (!widget.autoPlay)
              const Center(
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildVideo(controller),
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
