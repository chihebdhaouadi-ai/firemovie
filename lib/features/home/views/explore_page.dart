import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sage_nav_bar/sage_nav_tokens.dart';
import '../../create_topic/views/create_topic_screen.dart';
import '../../film_reviews/data/review_repository.dart';
import 'tabs/explore_tab.dart';

const _exploreBackground = Color(0xFF131417);

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key, this.reviews, this.onBack});

  final ReviewRepository? reviews;

  /// Called by the top-left back arrow. Falls back to popping the route.
  final VoidCallback? onBack;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  /// Bumped after a topic is posted so the feed reloads with it.
  int _feedRevision = 0;

  Future<void> _openCreate() async {
    final posted = await Navigator.of(context).push<bool>(
      CreateTopicScreen.route(reviews: widget.reviews),
    );
    if (posted == true && mounted) {
      setState(() => _feedRevision++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final carouselHeight = (MediaQuery.sizeOf(context).height * .74)
        .clamp(460.0, 640.0)
        .toDouble();
    final back = widget.onBack ?? () => Navigator.maybePop(context);

    return ColoredBox(
      color: _exploreBackground,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              tokens.spaceLg,
              tokens.spaceSm,
              tokens.spaceLg,
              // The card's bottom rests on the nav bar's dome; the centre button overlaps it.
              SageNavTokens.domeDepth +
                  SageNavTokens.barBodyHeight +
                  MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Tooltip(
                      message: l10n.overviewBack,
                      child: Semantics(
                        button: true,
                        label: l10n.overviewBack,
                        child: Material(
                          color: const Color(0xFF1B1D23),
                          shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF2A2D36)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: back,
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 20,
                                color: Color(0xFFE8E9EE),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: tokens.spaceSm),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l10n.homeTabExplore,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFE8E9EE),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: l10n.exploreCreateButton,
                      child: Semantics(
                        button: true,
                        label: l10n.exploreCreateButton,
                        child: Material(
                          color: const Color(0xFF1B1D23),
                          shape: const CircleBorder(
                            side: BorderSide(color: Color(0xFF2A2D36)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _openCreate,
                            child: SizedBox(
                              width: tokens.minTouchTarget,
                              height: tokens.minTouchTarget,
                              child: Icon(
                                Icons.add_rounded,
                                size: tokens.iconSmall + 4,
                                color: const Color(0xFFE8E9EE),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spaceXs),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Text(
                    l10n.exploreSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8D919D),
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: tokens.spaceSm),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: carouselHeight),
                      child: ExploreTab(
                        key: ValueKey(_feedRevision),
                        reviews: widget.reviews,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
