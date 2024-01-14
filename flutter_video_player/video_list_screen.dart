import 'package:native_video_player/native_video_player.dart';
import 'package:flutter/material.dart';

class VideoListScreenView extends StatelessWidget {
  const VideoListScreenView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const VideoListView();
  }
}

class VideoListView extends StatelessWidget {
  const VideoListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return VideoListItemView(
          videoSource: videoSources[index],
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: videoSources.length,
    );
  }
}

class VideoListItemView extends StatefulWidget {
  final VideoSource videoSource;

  const VideoListItemView({
    super.key,
    required this.videoSource,
  });

  @override
  State<VideoListItemView> createState() => _VideoListItemViewState();
}

class _VideoListItemViewState extends State<VideoListItemView> {
  NativeVideoPlayerController? _controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          NativeVideoPlayerView(
            onViewReady: (controller) async {
              _controller = controller;
              await _controller?.setVolume(1);
              await _loadVideoSource();
            },
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _togglePlayback,
              child: Center(
                child: FutureBuilder(
                  future: _isPlaying,
                  initialData: false,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    final isPlaying = snapshot.data ?? false;
                    return Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 64,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVideoSource() async {
    final videoSource = await VideoSource.init(
      type: widget.videoSource.type,
      path: widget.videoSource.path,
    );
    await _controller?.loadVideoSource(videoSource);
  }

  Future<void> _togglePlayback() async {
    final isPlaying = await _isPlaying;
    if (isPlaying) {
      await _controller?.pause();
    } else {
      await _controller?.play();
    }
    setState(() {});
  }

  Future<bool> get _isPlaying async => await _controller?.isPlaying() ?? false;
}
