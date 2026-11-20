import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../movie_lists/data/movie_list.dart';
import '../../movie_lists/data/movie_list_repository.dart';
import '../../movie_lists/presentation/movie_list_screen.dart';
import '../data/messaging_models.dart';

/// A movie list sent in the chat: its name, who made it, a few posters and
/// how many films. Tapping it opens the list.
class ListCard extends StatelessWidget {
  const ListCard({super.key, required this.list, this.mine = false});

  final SharedList list;

  /// Whether I sent it (the label then speaks from my side).
  final bool mine;

  void _open(BuildContext context) {
    // The list page loads the full list from this id.
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MovieListScreen(
          list: MovieList(
            id: list.listId,
            name: list.name,
            owner: ListPerson(id: 0, username: list.owner),
            isMine: false,
            filmCount: list.filmCount,
            posters: list.posters,
          ),
          repository: ApiMovieListRepository(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final posters = list.posters.where((p) => p.startsWith('http')).toList();
    return Semantics(
      button: true,
      child: Material(
        color: LuxeColors.surface2,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context),
          child: SizedBox(
            width: 260,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(BootstrapIcons.collection_play,
                          size: 13, color: LuxeColors.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mine ? l10n.chatYouSharedList : l10n.chatListShared,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: LuxeColors.muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(BootstrapIcons.chevron_right,
                          size: 12, color: LuxeColors.muted),
                    ],
                  ),
                  if (posters.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final poster in posters.take(4))
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: poster,
                                width: 44,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => SizedBox(
                                  width: 44,
                                  height: 64,
                                  child: ColoredBox(color: LuxeColors.hair),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    list.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LuxeColors.text,
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (list.owner.isNotEmpty) l10n.listBy(list.owner),
                      l10n.listFilmCount(list.filmCount),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: LuxeColors.muted, fontSize: 12),
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
