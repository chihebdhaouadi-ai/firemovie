import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../overview/views/widgets/overview_panel.dart';
import '../../domain/movie_review_summary.dart';
import '../reaction_labels.dart';

class ScoreCard extends StatefulWidget {
  const ScoreCard({super.key, required this.summary});

  final MovieReviewSummary summary;

  @override
  State<ScoreCard> createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> {
  bool _trustOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final summary = widget.summary;
    final trusted = summary.trustedPercent;
    final everyone = summary.everyonePercent;

    return OverviewPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                trusted == null ? '—' : '$trusted%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Flexible(
                child: Text(
                  l10n.reviewTrustedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceXs),
          Text(
            l10n.reviewEveryoneTogether(everyone == null ? '—' : '$everyone%'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          if (summary.mostFelt.isNotEmpty) ...[
            SizedBox(height: tokens.spaceMd),
            Text(
              l10n.reviewMostFelt,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: tokens.spaceXs),
            Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceSm,
              children: [
                for (final item in summary.mostFelt)
                  OverviewChip(
                    label: reactionChipLabel(l10n, item.reaction),
                  ),
              ],
            ),
          ],
          SizedBox(height: tokens.spaceMd),
          InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            onTap: () => setState(() => _trustOpen = !_trustOpen),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spaceXs),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      l10n.reviewWhatIsTrusted,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.accentGlow,
                      ),
                    ),
                  ),
                  Icon(
                    _trustOpen ? Icons.expand_less : Icons.expand_more,
                    size: tokens.iconSmall,
                    color: AppColors.accentGlow,
                  ),
                ],
              ),
            ),
          ),
          if (_trustOpen) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              l10n.reviewTrustedNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
