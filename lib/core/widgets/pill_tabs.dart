import 'package:flutter/material.dart';

import 'luxe_palette.dart';

/// Segmented tabs with a sliding blue pill, the same look as Home's
/// You / Friends / Films switcher, for any short list of labels.
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.height = 46,
    this.fontSize = 12,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  /// Bar height; the film page shrinks it while the tabs are pinned on top.
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LuxeColors.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: width * selected,
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LuxeColors.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: LuxeColors.accent.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == selected,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onSelected(i),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    color: i == selected
                                        ? Colors.white
                                        : LuxeColors.muted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: fontSize,
                                    letterSpacing: .2,
                                  ),
                                  // Long labels shrink a little instead
                                  // of being cut off.
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(labels[i], maxLines: 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
