import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/video_player_widget.dart';

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
  late int _index = widget.initialIndex.clamp(0, widget.videos.length - 1);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.videos.length > 1
              ? '${l10n.videos} ${_index + 1}/${widget.videos.length}'
              : l10n.videos,
          style: AppTextStyles.h6.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: VideoPlayerWidget(
                key: ValueKey(widget.videos[_index]),
                url: widget.videos[_index],
                autoPlay: true,
              ),
            ),
          ),
          if (widget.videos.length > 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.black,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(widget.videos.length, (i) {
                    final isActive = i == _index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _index = i),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.gold
                                : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.bodyMediumBold.copyWith(
                              color: isActive ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
