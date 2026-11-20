import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/luxe_palette.dart';
import '../../../../core/widgets/scroll_exit_effect.dart';

/// The Friends tab: the messaging inbox will live here. Until messaging
/// ships it shows an under-construction notice. Friends' films and takes
/// moved to the You tab.
class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key, required this.exitInset});

  /// Where sections start to fade and narrow under the pinned header.
  final ExitInset exitInset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return ScrollExitEffect(
      exitInset: exitInset,
      child: Padding(
        padding: EdgeInsets.only(top: tokens.spaceXl * 2),
        child: Column(
          children: [
            Semantics(
              container: true,
              label: '${l10n.homeInboxTitle}. ${l10n.homeInboxSoonTitle}',
              excludeSemantics: true,
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: LuxeColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: LuxeColors.hair),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(BootstrapIcons.inbox_fill,
                            size: 44, color: LuxeColors.muted),
                        PositionedDirectional(
                          end: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: LuxeColors.bg,
                              shape: BoxShape.circle,
                              border: Border.all(color: LuxeColors.hair),
                            ),
                            child: Icon(BootstrapIcons.tools,
                                size: 18, color: LuxeColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spaceLg),
                  Text(
                    l10n.homeInboxTitle,
                    style: TextStyle(
                      color: LuxeColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  Text(
                    l10n.homeInboxSoonTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: LuxeColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceXl),
                    child: Text(
                      l10n.homeInboxSoonBody,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: LuxeColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
