import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/views/widgets/empty_error_views.dart';

/// One choice on a [BrowsePickScreen].
class BrowsePickOption {
  const BrowsePickOption({
    required this.label,
    required this.screen,
    this.imageUrl,
  });

  final String label;

  /// Optional small image shown before the label (a country flag).
  final String? imageUrl;

  /// Step 2: the film list opened when this option is picked.
  final Widget Function() screen;
}

/// Step 1 of a two-step browse (genre, country, language): pick one option,
/// then its film list opens.
class BrowsePickScreen extends StatefulWidget {
  const BrowsePickScreen({
    super.key,
    required this.title,
    required this.load,
    this.subtitle,
  });

  final String title;

  /// Optional line under the app bar explaining what the options mean.
  final String? subtitle;
  final Future<List<BrowsePickOption>> Function() load;

  @override
  State<BrowsePickScreen> createState() => _BrowsePickScreenState();
}

class _BrowsePickScreenState extends State<BrowsePickScreen> {
  late Future<List<BrowsePickOption>> _options = widget.load();

  void _retry() => setState(() => _options = widget.load());

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final subtitle = widget.subtitle;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<BrowsePickOption>>(
          future: _options,
          builder: (context, snapshot) {
            if (snapshot.hasError) return SearchError(onRetry: _retry);
            final options = snapshot.data;
            if (options == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (options.isEmpty) {
              return FindMessageView(
                icon: Icons.inbox_outlined,
                title: context.l10n.browsePickEmpty,
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: ListView(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  children: [
                    if (subtitle != null) ...[
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: tokens.spaceMd),
                    ],
                    Material(
                      color: AppColors.surface,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      child: Column(
                        children: [
                          for (var i = 0; i < options.length; i++) ...[
                            if (i > 0)
                              const Divider(
                                height: 1,
                                color: AppColors.surfaceRaised,
                              ),
                            _OptionRow(option: options[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.option});

  final BrowsePickOption option;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final image = option.imageUrl;
    return Semantics(
      button: true,
      label: option.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => option.screen()),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.minTouchTarget + 4),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm,
            ),
            child: Row(
              children: [
                if (image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: image,
                      width: 32,
                      height: 22,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const SizedBox(width: 32, height: 22),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
