import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

/// A circular trailing action that shows a "+" to add, or an animated "Added"
/// check when the film is already present in the target.
class AddButton extends StatefulWidget {
  const AddButton({
    super.key,
    required this.onPressed,
    this.added = false,
    this.processing = false,
    this.semanticsLabel = 'Add',
  });

  final VoidCallback? onPressed;
  final bool added;
  final bool processing;
  final String semanticsLabel;

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = widget.onPressed != null;
    final added = widget.added;

    final backgroundColor = added
        ? AppColors.accent
        : (enabled ? AppColors.primaryButton : AppColors.surfaceRaised);

    return Semantics(
      button: enabled && !added,
      enabled: enabled && !added,
      label: widget.semanticsLabel,
      child: AnimatedContainer(
        duration: context.motion(tokens.durationBase),
        curve: Curves.easeOut,
        constraints: const BoxConstraints.tightFor(
          width: 40,
          height: 40,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: added ? tokens.glowShadow : const [],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: (enabled && !added)
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed!();
                  }
                : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: context.motion(tokens.durationFast),
                child: widget.processing
                    ? const SizedBox(
                        key: ValueKey('processing'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimaryButton,
                        ),
                      )
                    : added
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey('added'),
                            size: 22,
                            color: AppColors.onPrimaryButton,
                          )
                        : const Icon(
                            Icons.add_rounded,
                            key: ValueKey('add'),
                            size: 24,
                            color: AppColors.onPrimaryButton,
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
