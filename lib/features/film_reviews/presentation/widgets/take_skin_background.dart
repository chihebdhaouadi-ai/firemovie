import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/take_skin.dart';

/// The visible name of [skin].
String takeSkinLabel(AppLocalizations l10n, TakeSkin skin) => switch (skin) {
      TakeSkin.normal => l10n.takeSkinNormal,
      TakeSkin.electricThunder => l10n.takeSkinElectricThunder,
    };

/// The icon shown next to [skin]'s name, so the choice is not told by
/// color alone.
IconData takeSkinIcon(TakeSkin skin) => switch (skin) {
      TakeSkin.normal => BootstrapIcons.square,
      TakeSkin.electricThunder => BootstrapIcons.lightning_fill,
    };

const _thunderAsset = 'assets/lottie/skin_electric_thunder.json';

/// Frame of the thunder loop shown when motion is reduced: a bolt is lit.
const _thunderStillProgress = 16 / 90;

Color get _thunderTop =>
    themed(const Color(0xFF0B1633), const Color(0xFFD8E2F7));
Color get _thunderBottom =>
    themed(const Color(0xFF1B1140), const Color(0xFFE0D8F2));
Color get _thunderEdge =>
    themed(const Color(0x805CE1FF), const Color(0x993A7BD5));
Color get _thunderShadow =>
    themed(const Color(0x402F8CFF), const Color(0x332F6FD6));
Color get _thunderScrimTop =>
    themed(const Color(0x260A0E1F), const Color(0x1AF2EEE6));
Color get _thunderScrimBottom =>
    themed(const Color(0xA60A0E1F), const Color(0x8CF2EEE6));

/// Draws [child] on the take card background [skin].
///
/// [TakeSkin.normal] returns [child] untouched (the plain card look), unless
/// [framed] asks for a visible card around it. [TakeSkin.electricThunder]
/// plays a lightning loop behind [child], or a still frame when the system
/// asks to reduce motion.
class TakeSkinBackground extends StatelessWidget {
  const TakeSkinBackground({
    super.key,
    required this.skin,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.framed = false,
    this.animate = true,
  });

  final TakeSkin skin;
  final Widget child;

  /// Space between the skin's edge and [child] (not used for a bare normal
  /// skin).
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  /// Whether a normal skin gets its own card surface (previews and pickers).
  final bool framed;

  /// Whether an animated skin plays. When false, or when the system asks to
  /// reduce motion, a still frame is shown.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return switch (skin) {
      TakeSkin.normal when !framed => child,
      TakeSkin.normal => DecoratedBox(
          decoration: BoxDecoration(
            color: LuxeColors.surface2,
            borderRadius: borderRadius,
            border: Border.all(color: LuxeColors.hair),
          ),
          child: Padding(padding: padding, child: child),
        ),
      TakeSkin.electricThunder => _ThunderBackground(
          animate: animate,
          padding: padding,
          borderRadius: borderRadius,
          child: child,
        ),
    };
  }
}

class _ThunderBackground extends StatelessWidget {
  const _ThunderBackground({
    required this.child,
    required this.padding,
    required this.borderRadius,
    required this.animate,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final still = !animate || MediaQuery.disableAnimationsOf(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [_thunderTop, _thunderBottom],
        ),
        border: Border.all(color: _thunderEdge),
        boxShadow: [BoxShadow(color: _thunderShadow, blurRadius: 18)],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: Lottie.asset(
                      _thunderAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      controller: still
                          ? const AlwaysStoppedAnimation(_thunderStillProgress)
                          : null,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
            // Keeps the text readable when the sky flashes.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_thunderScrimTop, _thunderScrimBottom],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Lets the author pick a card skin; each option shows the skin itself.
class TakeSkinPicker extends StatelessWidget {
  const TakeSkinPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final TakeSkin selected;
  final ValueChanged<TakeSkin> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final skin in TakeSkin.values) ...[
          if (skin != TakeSkin.values.first) const SizedBox(width: 10),
          Expanded(
            child: _SkinOption(
              skin: skin,
              selected: skin == selected,
              onTap: enabled ? () => onChanged(skin) : null,
            ),
          ),
        ],
      ],
    );
  }
}

class _SkinOption extends StatelessWidget {
  const _SkinOption({
    required this.skin,
    required this.selected,
    required this.onTap,
  });

  final TakeSkin skin;
  final bool selected;
  final VoidCallback? onTap;

  static const _radius = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    final label = takeSkinLabel(context.l10n, skin);

    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: _radius,
            border: Border.all(
              color: selected ? LuxeColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: TakeSkinBackground(
            skin: skin,
            framed: true,
            // A still swatch; the live preview shows the skin moving.
            animate: false,
            borderRadius: const BorderRadius.all(Radius.circular(11)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Icon(takeSkinIcon(skin), size: 20, color: LuxeColors.text),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: LuxeColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      BootstrapIcons.check_circle_fill,
                      size: 20,
                      color: LuxeColors.accentHi,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A live look at the take as others will see it: [text] (or a placeholder
/// while empty) on the chosen [skin].
class TakeSkinPreview extends StatelessWidget {
  const TakeSkinPreview({super.key, required this.skin, required this.text});

  final TakeSkin skin;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trimmed = text.trim();
    final empty = trimmed.isEmpty;

    return TakeSkinBackground(
      skin: skin,
      framed: true,
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            empty ? l10n.takeSkinPreviewEmpty : l10n.reviewQuote(trimmed),
            maxLines: 6,
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: empty ? LuxeColors.muted : LuxeColors.text,
              fontSize: 15,
              height: 1.5,
              fontStyle: empty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }
}
