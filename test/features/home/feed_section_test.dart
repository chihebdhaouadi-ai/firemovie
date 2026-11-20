import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_state.dart';
import 'package:film_wise_mobile/features/home/data/home_models.dart';
import 'package:film_wise_mobile/features/home/views/widgets/feed_section.dart';
import 'package:film_wise_mobile/features/home/views/widgets/feed_take_card.dart';
import 'package:film_wise_mobile/features/home/views/widgets/section_header.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FeedItem _item(int id) => FeedItem(
      film: const Film(imdbId: 'tt1', title: 'Dune'),
      take: Take(
        id: id,
        authorId: 7,
        authorName: 'maya',
        isMine: false,
        reaction: FilmReaction.loved,
        body: 'Take $id',
        votes: const {},
        myVotes: const {},
        commentCount: 0,
        isMostHelpful: false,
      ),
    );

void main() {
  testWidgets(
      'popular takes has no layout switch and its cards sit as close '
      'to the title as other sections', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: FeedSection(
          title: 'Popular takes',
          state: FeedContent([_item(1), _item(2)]),
          onRetry: () {},
        ),
      ),
    ));

    expect(find.byType(IconButton), findsNothing);

    final header = tester.getRect(find.byType(SectionHeader));
    final card = tester.getRect(find.byType(FeedTakeCard).first);
    // The same gap the other sections use, plus the row's 2 px edge room.
    expect(card.top - header.bottom, SectionHeader.contentGap + 2);
  });
}
