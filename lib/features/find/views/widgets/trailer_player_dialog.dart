import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';

/// Plays a film's YouTube trailer in a pop-up over the film page, inside the
/// app. Starts playing at once; the full-screen button is available.
class TrailerPlayerDialog extends StatefulWidget {
  const TrailerPlayerDialog({
    super.key,
    required this.videoId,
    required this.title,
  });

  final String videoId;
  final String title;

  /// Shows the pop-up and completes when it is closed.
  static Future<void> show(
    BuildContext context, {
    required String videoId,
    required String title,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => TrailerPlayerDialog(videoId: videoId, title: title),
    );
  }

  @override
  State<TrailerPlayerDialog> createState() => _TrailerPlayerDialogState();
}

class _TrailerPlayerDialogState extends State<TrailerPlayerDialog> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
    videoId: widget.videoId,
    autoPlay: true,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
      strictRelatedVideos: true,
    ),
  );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.symmetric(horizontal: tokens.spaceMd),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                tokens.spaceMd,
                tokens.spaceXs,
                0,
                tokens.spaceXs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.overviewCloseTrailer,
                    icon: const Icon(BootstrapIcons.x_lg, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            YoutubePlayer(controller: _controller),
          ],
        ),
      ),
    );
  }
}
