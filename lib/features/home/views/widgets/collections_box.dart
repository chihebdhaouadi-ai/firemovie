import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CollectionsBox extends StatefulWidget {
  const CollectionsBox({
    super.key,
    required this.title,
    required this.resizeLabel,
    required this.children,
  });

  final String title;
  final String resizeLabel;
  final List<Widget> children;

  @override
  State<CollectionsBox> createState() => _CollectionsBoxState();
}

class _CollectionsBoxState extends State<CollectionsBox> {
  static const _initialHeight = 360.0;
  static const _minHeight = 200.0;

  double _height = _initialHeight;

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
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceLg,
              tokens.spaceLg,
              0,
            ),
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
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
