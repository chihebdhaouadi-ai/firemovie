import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/film_reaction.dart';
import '../reaction_labels.dart';

class ReactionCard extends StatefulWidget {
  const ReactionCard({
    super.key,
    required this.reaction,
    required this.hasTake,
    required this.onReactionChanged,
    required this.onShare,
  });

  final FilmReaction? reaction;
  final bool hasTake;
  final Future<bool> Function(FilmReaction reaction) onReactionChanged;
  final Future<bool> Function(String body) onShare;

  @override
  State<ReactionCard> createState() => _ReactionCardState();
}

class _ReactionCardState extends State<ReactionCard> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _whyOpen = false;
  bool _sharing = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pick(FilmReaction reaction) async {
    setState(() {
      _message = null;
      _messageIsError = false;
    });
    final ok = await widget.onReactionChanged(reaction);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _message = context.l10n.reviewReactionFailed;
        _messageIsError = true;
      });
      return;
    }
    if (!widget.hasTake) setState(() => _whyOpen = true);
  }

  Future<void> _share() async {
    final body = _controller.text.trim();
    if (body.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    setState(() => _sharing = true);
    final ok = await widget.onShare(body);
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _sharing = false;
      if (ok) {
        _whyOpen = false;
        _controller.clear();
        _message = l10n.reviewSharedThanks;
        _messageIsError = false;
      } else {
        _message = l10n.reviewTakeFailed;
        _messageIsError = true;
      }
    });
  }

  void _skipWhy() {
    setState(() {
      _whyOpen = false;
      _message = context.l10n.reviewCountedThanks;
      _messageIsError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final showWhy = _whyOpen && !widget.hasTake && widget.reaction != null;

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewReactionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            l10n.reviewReactionHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          Wrap(
            spacing: tokens.spaceSm,
            runSpacing: tokens.spaceSm,
            children: [
              for (final reaction in FilmReaction.values)
                ChoiceChip(
                  label: Text(reactionChipLabel(l10n, reaction)),
                  selected: widget.reaction == reaction,
                  showCheckmark: false,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surfaceRaised,
                  side: BorderSide.none,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    color: widget.reaction == reaction
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  onSelected: (selected) {
                    if (selected) _pick(reaction);
                  },
                ),
            ],
          ),
          if (showWhy) ...[
            SizedBox(height: tokens.spaceMd),
            Text(
              l10n.reviewWhyPrompt,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 280,
              minLines: 2,
              maxLines: 4,
              buildCounter: (_,
                      {required currentLength,
                      required isFocused,
                      required maxLength}) =>
                  null,
              decoration: InputDecoration(
                hintText: l10n.reviewWhyHint,
                filled: true,
                fillColor: AppColors.surfaceRaised,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Row(
              children: [
                FilledButton(
                  onPressed: _sharing ? null : _share,
                  child: Text(l10n.reviewShare),
                ),
                SizedBox(width: tokens.spaceSm),
                TextButton(
                  onPressed: _sharing ? null : _skipWhy,
                  child: Text(l10n.reviewNoThanks),
                ),
              ],
            ),
          ],
          if (_message != null) ...[
            SizedBox(height: tokens.spaceSm),
            Text(
              _message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _messageIsError ? AppColors.error : AppColors.accentGlow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
