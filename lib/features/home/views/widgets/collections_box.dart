import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CollectionsBox extends StatefulWidget {
  const CollectionsBox({
    super.key,
    this.title,
    required this.resizeLabel,
    required this.children,
    this.initialHeight = defaultHeight,
  });

  /// The content area's height when the box first appears.
  static const defaultHeight = 360.0;

  /// The smallest the box can be dragged to.
  static const minHeight = 200.0;

  /// Height of the content area when the box first shows; it can then be
  /// dragged between [minHeight] and most of the screen.
  final double initialHeight;

  /// Shown inside the box at the top; leave null when the title sits above
  /// the box instead.
  final String? title;
  final String resizeLabel;
  final List<Widget> children;

  @override
  State<CollectionsBox> createState() => _CollectionsBoxState();
}

class _CollectionsBoxState extends State<CollectionsBox> {
  static const _minHeight = CollectionsBox.minHeight;

  late double _height = widget.initialHeight;

  double _maxHeight(BuildContext context) =>
      math.max(_minHeight, MediaQuery.sizeOf(context).height * 0.8);

  double _clampedHeight(BuildContext context) =>
      _height.clamp(_minHeight, _maxHeight(context)).toDouble();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(color: AppColors.panelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title case final title?) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceLg,
                tokens.spaceLg,
                tokens.spaceLg,
                0,
              ),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: tokens.spaceMd),
          ] else
            SizedBox(height: tokens.spaceMd),
          SizedBox(
            height: _clampedHeight(context),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ),
          _ResizeGrip(
            label: widget.resizeLabel,
            onDrag: (delta) => setState(() {
              _height = _clampedHeight(context) + delta;
            }),
          ),
        ],
      ),
    );
  }
}

class _ResizeGrip extends StatelessWidget {
  const _ResizeGrip({required this.label, required this.onDrag});

  final String label;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      label: label,
      container: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
          child: SizedBox(
            height: tokens.minTouchTarget / 2,
            child: Center(
              child: Container(
                width: tokens.minTouchTarget,
                height: tokens.spaceXs,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(tokens.spaceXs),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
