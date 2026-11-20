import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/views/widgets/empty_error_views.dart';
import '../data/browse_repository.dart';
import '../domain/streaming_service.dart';
import 'browse_films_screen.dart';

/// Step 1 of Browse by streaming service: pick a service. Step 2 is
/// [BrowseFilmsScreen] with the films on that service.
class StreamingServicesScreen extends StatefulWidget {
  const StreamingServicesScreen({super.key, this.repository});

  final BrowseRepository? repository;

  @override
  State<StreamingServicesScreen> createState() =>
      _StreamingServicesScreenState();
}

class _StreamingServicesScreenState extends State<StreamingServicesScreen> {
  late final BrowseRepository _repository =
      widget.repository ?? ApiBrowseRepository();
  late Future<List<StreamingService>> _services =
      _repository.fetchStreamingServices();

  void _retry() =>
      setState(() => _services = _repository.fetchStreamingServices());

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.browseServicesTitle),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<StreamingService>>(
          future: _services,
          builder: (context, snapshot) {
            if (snapshot.hasError) return SearchError(onRetry: _retry);
            final services = snapshot.data;
            if (services == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (services.isEmpty) {
              return FindMessageView(
                icon: BootstrapIcons.tv,
                title: l10n.browseServicesEmpty,
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: GridView.builder(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 130,
                    mainAxisSpacing: tokens.spaceMd,
                    crossAxisSpacing: tokens.spaceMd,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) => _ServiceTile(
                    service: services[index],
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => BrowseFilmsScreen(
                          title: services[index].name,
                          serviceId: services[index].id,
                          repository: widget.repository,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onTap});

  final StreamingService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final logo = service.logoUrl;
    return Semantics(
      button: true,
      label: service.name,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    child: SizedBox.square(
                      dimension: 64,
                      child: logo == null
                          ? ColoredBox(
                              color: AppColors.surfaceRaised,
                              child: Icon(
                                BootstrapIcons.tv_fill,
                                color: AppColors.textMuted,
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: logo,
                              fit: BoxFit.cover,
                              memCacheWidth: 154,
                            ),
                    ),
                  ),
                  SizedBox(height: tokens.spaceSm),
                  Text(
                    service.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
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
