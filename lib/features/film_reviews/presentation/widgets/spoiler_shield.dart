import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';

Color get _veil => themed(const Color(0xB30A0E1F), const Color(0xCCE9E4DA));

/// Blurs [child] behind a "Contains spoilers · Tap to reveal" veil while
/// [hidden]. A tap reveals it for as long as this widget lives; the reveal is
/// not remembered.
class SpoilerShield extends StatefulWidget {
  const SpoilerShield({
    super.key,
    required this.hidden,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  /// Whether the content is a spoiler the reader has not chosen to see.
  final bool hidden;
  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<SpoilerShield> createState() => _SpoilerShieldState();
}

class _SpoilerShieldState extends State<SpoilerShield> {
  bool _revealed = false;

  @override
  void didUpdateWidget(SpoilerShield oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A take newly marked as a spoiler hides again.
    if (widget.hidden && !oldWidget.hidden) _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hidden || _revealed) return widget.child;
    final l10n = context.l10n;

    final label = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            BootstrapIcons.eye_slash_fill,
            color: LuxeColors.accentHi,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.topicSpoilerLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LuxeColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.exploreSpoilerReveal,
            textAlign: TextAlign.center,
            style: TextStyle(color: LuxeColors.muted, fontSize: 13),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        // The veil spans the full width, not just a short line of text.
        width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        child: Semantics(
          button: true,
          label: '${l10n.topicSpoilerLabel}. ${l10n.exploreSpoilerReveal}',
          excludeSemantics: true,
          onTap: _reveal,
          child: GestureDetector(
            key: const Key('spoiler-reveal'),
            behavior: HitTestBehavior.opaque,
            onTap: _reveal,
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              // Both the content and the label size the stack, so the label
              // always fits, even under a one-line take or large text.
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IgnorePointer(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
                      child: widget.child,
                    ),
                  ),
                  Positioned.fill(child: ColoredBox(color: _veil)),
                  label,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _reveal() => setState(() => _revealed = true);
}

/// The author's required answer to "Does it have spoilers?". [value] is
/// null until they pick one.
class SpoilerChoice extends StatelessWidget {
  const SpoilerChoice({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.showError = false,
  });

  final bool? value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  /// Whether to remind the author that the answer is still missing.
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget option(bool spoiler, IconData icon, String label) {
      final selected = value == spoiler;
      return Expanded(
        child: ChoiceChip(
          key: Key(spoiler ? 'spoiler-yes' : 'spoiler-no'),
          selected: selected,
          showCheckmark: false,
          avatar: Icon(
            selected ? BootstrapIcons.check_circle_fill : icon,
            size: 18,
            color: selected ? LuxeColors.accentHi : LuxeColors.muted,
          ),
          label: SizedBox(width: double.infinity, child: Text(label)),
          onSelected: enabled ? (_) => onChanged(spoiler) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.takeSpoilerTitle,
          style: TextStyle(
            color: LuxeColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            option(false, BootstrapIcons.eye_fill, l10n.takeSpoilerNo),
            const SizedBox(width: 10),
            option(true, BootstrapIcons.eye_slash_fill, l10n.topicSpoilerLabel),
          ],
        ),
        const SizedBox(height: 6),
        Semantics(
          liveRegion: showError,
          child: Text(
            value == true
                ? l10n.takeSpoilerBlurNote
                : showError
                    ? l10n.takeSpoilerRequired
                    : l10n.takeSpoilerHint,
            style: TextStyle(
              color: showError && value == null
                  ? LuxeColors.accentHi
                  : LuxeColors.muted,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
