import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_text_styles.dart';
import '../../widgets/video_player_widget.dart';

/// Visualizador de vídeos em ecrã inteiro (estilo TikTok).
///
/// Sem AppBar e com sistema em modo imersivo; vários vídeos passam a poder ser
/// percorridos com swipe vertical. O ratio nativo é ignorado (`BoxFit.cover`)
/// para o vídeo preencher a tela; a orientação é desbloqueada enquanto o ecrã
/// está aberto e reposta no [dispose].
class VideoViewerScreen extends StatefulWidget {
  final List<String> videos;
  final int initialIndex;

  const VideoViewerScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  late final PageController _pageController;
  late int _index = widget.initialIndex.clamp(0, widget.videos.length - 1);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _index);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.videos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => VideoPlayerWidget(
              key: ValueKey('viewer-${widget.videos[i]}'),
              url: widget.videos[i],
              autoPlay: true,
              looping: true,
              isActive: i == _index,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: widget.videos.length > 1
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_index + 1}/${widget.videos.length}',
                                  style: AppTextStyles.bodyMediumBold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          if (widget.videos.length > 1)
            const Positioned(
              right: 16,
              bottom: 24,
              child: Icon(
                Icons.swipe_vertical_rounded,
                color: Colors.white54,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}
