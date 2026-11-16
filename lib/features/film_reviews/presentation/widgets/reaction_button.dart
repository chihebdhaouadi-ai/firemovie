import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/film_reaction.dart';
import '../reaction_labels.dart';
import '../../../../core/widgets/game_button.dart';

const _disc = 268.0;
const _radius = 100.0;
const _itemSize = 54.0;
const _centerLabelWidth = 112.0;
const _pickerDuration = Duration(milliseconds: 350);
const _hoverDuration = Duration(milliseconds: 150);

class ReactionButton extends StatelessWidget {
  const ReactionButton({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final FilmReaction? selected;
  final ValueChanged<FilmReaction> onChanged;

  Future<void> _open(BuildContext context) async {
    final l10n = context.l10n;
    final FilmReaction? picked;
    if (MediaQuery.accessibleNavigationOf(context)) {
      picked = await showModalBottomSheet<FilmReaction>(
        context: context,
        showDragHandle: true,
        builder: (_) => _ReactionList(selected: selected),
      );
    } else {
      final box = context.findRenderObject()! as RenderBox;
      final anchor = box.localToGlobal(box.size.center(Offset.zero));
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      picked = await showGeneralDialog<FilmReaction>(
        context: context,
        barrierDismissible: true,
        barrierLabel: l10n.reviewReactionClose,
        barrierColor: Colors.black54,
        transitionDuration: reduceMotion ? Duration.zero : _pickerDuration,
        pageBuilder: (_, animation, __) => _RadialPicker(
          anchor: anchor,
          selected: selected,
          animation: animation,
          reduceMotion: reduceMotion,
        ),
        transitionBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      );
    }
    if (picked == null || !context.mounted) return;
    HapticFeedback.lightImpact();
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final reaction = selected;

    return SizedBox(
      width: double.infinity,
      child: GameButton(
        onPressed: () => _open(context),
        style: GameButtonStyle.dark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              reaction == null ? '😊' : reactionEmoji(reaction),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontSize: 24),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Text(
                reaction == null
                    ? l10n.reviewReactionTapToReact
                    : reactionLabel(l10n, reaction),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (reaction != null) ...[
              SizedBox(width: tokens.spaceSm),
              Text(
                l10n.reviewReactionChange,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.accentGlow,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RadialPicker extends StatefulWidget {
  const _RadialPicker({
    required this.anchor,
    required this.selected,
    required this.animation,
    required this.reduceMotion,
  });

  final Offset anchor;
  final FilmReaction? selected;
  final Animation<double> animation;
  final bool reduceMotion;

  @override
  State<_RadialPicker> createState() => _RadialPickerState();
}

class _RadialPickerState extends State<_RadialPicker> {
  FilmReaction? _active;
  late final List<CurvedAnimation> _pops = [
    for (var i = 0; i < FilmReaction.values.length; i++)
      CurvedAnimation(
        parent: widget.animation,
        curve: Interval(
          i * 0.05,
          math.min(1.0, 0.5 + i * 0.05),
          curve: Curves.easeOutBack,
        ),
      ),
  ];

  @override
  void dispose() {
    for (final pop in _pops) {
      pop.dispose();
    }
    super.dispose();
  }

  void _setActive(FilmReaction reaction, bool on) {
    setState(() {
      if (on) {
        _active = reaction;
      } else if (_active == reaction) {
        _active = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final size = MediaQuery.sizeOf(context);
    const half = _disc / 2;
    final cx = widget.anchor.dx
        .clamp(half, math.max(half, size.width - half))
        .toDouble();
    final cy = widget.anchor.dy
        .clamp(half, math.max(half, size.height - half))
        .toDouble();
    final active = _active ?? widget.selected;
    final centerText = active == null
        ? l10n.reviewReactionPickOne
        : reactionLabel(l10n, active);
    final hoverDuration = widget.reduceMotion ? Duration.zero : _hoverDuration;

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned(
              left: cx - half,
              top: cy - half,
              width: _disc,
              height: _disc,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.panelBorder),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: _centerLabelWidth,
                          child: Text(
                            centerText,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (var i = 0; i < FilmReaction.values.length; i++)
                      _pickerItem(
                        context,
                        index: i,
                        reaction: FilmReaction.values[i],
                        rtl: rtl,
                        hoverDuration: hoverDuration,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerItem(
    BuildContext context, {
    required int index,
    required FilmReaction reaction,
    required bool rtl,
    required Duration hoverDuration,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    const half = _disc / 2;
    final theta =
        -math.pi / 2 + index * 2 * math.pi / FilmReaction.values.length;
    final dx = _radius * math.cos(theta) * (rtl ? -1 : 1);
    final dy = _radius * math.sin(theta);
    final isSelected = widget.selected == reaction;
    final isActive = _active == reaction;

    return Positioned(
      left: half + dx - _itemSize / 2,
      top: half + dy - _itemSize / 2,
      width: _itemSize,
      height: _itemSize,
      child: ScaleTransition(
        scale: _pops[index],
        child: AnimatedScale(
          scale: isActive ? 1.3 : 1.0,
          duration: hoverDuration,
          child: Semantics(
            button: true,
            selected: isSelected,
            label: reactionLabel(l10n, reaction),
            child: ExcludeSemantics(
              child: InkWell(
                customBorder: const CircleBorder(),
                onTapDown: (_) => _setActive(reaction, true),
                onHover: (hovering) => _setActive(reaction, hovering),
                onFocusChange: (focused) => _setActive(reaction, focused),
                onTap: () => Navigator.of(context).pop(reaction),
                child: Ink(
                  width: _itemSize,
                  height: _itemSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelected ? AppColors.accent : AppColors.surfaceRaised,
                    border: Border.all(
                      color:
                          isActive ? AppColors.accentGlow : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      reactionEmoji(reaction),
                      textScaler: TextScaler.noScaling,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionList extends StatelessWidget {
  const _ReactionList({required this.selected});

  final FilmReaction? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.reviewReactionTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final reaction in FilmReaction.values)
                  ListTile(
                    leading: Text(
                      reactionEmoji(reaction),
                      textScaler: TextScaler.noScaling,
                    ),
                    title: Text(reactionLabel(l10n, reaction)),
                    selected: selected == reaction,
                    onTap: () => Navigator.of(context).pop(reaction),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
