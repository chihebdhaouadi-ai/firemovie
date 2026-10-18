import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class AddTile extends StatelessWidget {
  const AddTile({
    super.key,
    required this.width,
    required this.label,
    required this.onTap,
  });

  final double width;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusMd);

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: width,
        height: tokens.posterHeight(width),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border:
                Border.all(color: AppColors.outline, width: tokens.borderWidth),
          ),
          child: Material(
            color: AppColors.transparent,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: ExcludeSemantics(
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: AppColors.textSecondary,
                    size: tokens.iconLarge,
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
