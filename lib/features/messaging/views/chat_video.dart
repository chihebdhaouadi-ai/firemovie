import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/l10n_context.dart';

/// A video post played inside the chat. It loads as soon as it is shown
/// (without playing), so the tile shows the video's first frame with a play
/// button on top, then plays in place with play / pause, a scrub bar, the
/// time and full screen.
class ChatVideo extends StatefulWidget {
  const ChatVideo({super.key, required this.url, this.width = 240});

  final String? url;
  final double width;

  @override
  State<ChatVideo> createState() => _ChatVideoState();
}

class _ChatVideoState extends State<ChatVideo> {
  VideoPlayerController? _controller;
  bool _loading = false;
  bool _failed = false;

  /// Set when the play button is tapped before the video has loaded, so it
  /// starts playing as soon as it is ready.
  bool _playWhenReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final url = widget.url;
    if (_loading || _controller != null) return;
    if (url == null || !url.startsWith('http')) {
      setState(() => _failed = true);
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
      });
      if (_playWhenReady) await controller.play();
    } on Exception catch (error) {
      debugPrint('Chat video failed to load: $error');
      await controller.dispose();
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
          _playWhenReady = false;
        });
      }
    }
  }

  /// The play button on the tile shown before the video has loaded.
  void _start() {
    _playWhenReady = true;
    if (_failed) unawaited(_load());
    setState(() {});
  }

  Future<void> _fullScreen() async {
    final controller = _controller;
    if (controller == null) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullScreenVideo(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    Widget frame(Widget child, {double? aspect}) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: widget.width,
            color: const Color(0xFF1A1A18),
            child: aspect == null
                ? SizedBox(height: widget.width * 0.58, child: child)
                : AspectRatio(aspectRatio: aspect, child: child),
          ),
        );

    if (controller == null) {
      return frame(
        Semantics(
          button: true,
          label: l10n.chatPlayVideo,
          child: InkWell(
            key: const Key('chat-video-start'),
            onTap: _start,
            child: Center(
              child: _failed
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.chatVideoFailed,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  : _loading && _playWhenReady
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(BootstrapIcons.play_circle_fill,
                          color: Colors.white, size: 44),
            ),
          ),
        ),
      );
    }
    final ratio = controller.value.aspectRatio;
    // Tall phone videos stay a reasonable height in the chat.
    return frame(
      VideoControls(controller: controller, onFullScreen: _fullScreen),
      aspect: ratio < 0.75 ? 0.75 : ratio,
    );
  }
}

/// The video with its controls on top: tap to play or pause, and a bottom
/// bar with the scrub bar, the time and an optional full-screen button.
class VideoControls extends StatelessWidget {
  const VideoControls({
    super.key,
    required this.controller,
    this.onFullScreen,
  });

  final VideoPlayerController controller;
  final VoidCallback? onFullScreen;

  static String _time(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final ended = value.isInitialized &&
            !value.isPlaying &&
            value.position >= value.duration &&
            value.duration > Duration.zero;
        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
            Semantics(
              button: true,
              label: value.isPlaying ? l10n.chatPauseVideo : l10n.chatPlayVideo,
              child: GestureDetector(
                key: const Key('chat-video-toggle'),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (value.isPlaying) {
                    unawaited(controller.pause());
                  } else {
                    if (ended) unawaited(controller.seekTo(Duration.zero));
                    unawaited(controller.play());
                  }
                },
                child: AnimatedOpacity(
                  opacity: value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: const Center(
                    child: Icon(BootstrapIcons.play_circle_fill,
                        color: Colors.white, size: 44),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 12, 4, 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_time(value.position)} / ${_time(value.duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        colors: const VideoProgressColors(
                          playedColor: Colors.white,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                    if (onFullScreen != null)
                      IconButton(
                        tooltip: l10n.chatFullScreen,
                        iconSize: 16,
                        onPressed: onFullScreen,
                        icon: const Icon(BootstrapIcons.arrows_fullscreen,
                            color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The same video on a black page; it keeps playing where it was.
class _FullScreenVideo extends StatelessWidget {
  const _FullScreenVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(child: VideoControls(controller: controller)),
      );
}
