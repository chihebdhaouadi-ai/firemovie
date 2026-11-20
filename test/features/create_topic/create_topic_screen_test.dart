import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/game_button.dart';
import 'package:film_wise_mobile/features/create_topic/views/create_topic_screen.dart';
import 'package:film_wise_mobile/features/film_reviews/data/review_repository.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/film_reaction.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/movie_review_summary.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_skin.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:film_wise_mobile/features/find/data/find_repository.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/features/film_reviews/presentation/reaction_labels.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _pulp = Movie(id: 'tt0110912', title: 'Pulp Fiction', year: 1994);

class _Calls {
  final List<String> log = [];
  String? reactionFilm;
  FilmReaction? reaction;
  String? takeFilm;
  String? takeBody;
  TakeTag? takeTag;
  String? topicFilm;
  String? topicBody;
  TakeTag? topicTag;
  XFile? topicImage;
  List<String> topicOptions = const [];
  String? topicScene;
  String? topicTimecode;
  bool? topicSpoiler;
  bool? takeSpoiler;
}

class _FakeReviews implements ReviewRepository {
  _FakeReviews(this.calls);

  final _Calls calls;

  @override
  Future<MovieReviewSummary> setReaction(
    String filmId,
    FilmReaction? reaction,
  ) async {
    calls.log.add('reaction');
    calls.reactionFilm = filmId;
    calls.reaction = reaction;
    return MovieReviewSummary(
      myReaction: reaction,
      mostFelt: const [],
      everyonePercent: null,
      trustedPercent: null,
    );
  }

  @override
  Future<Take> postTake(
    String filmId, {
    required String body,
    TakeTag tag = TakeTag.review,
    TakeSkin skin = TakeSkin.normal,
    bool spoiler = false,
  }) async {
    calls.log.add('take');
    calls.takeSpoiler = spoiler;
    calls.takeFilm = filmId;
    calls.takeBody = body;
    calls.takeTag = tag;
    return _take(body, tag);
  }

  @override
  Future<Take> postTopic({
    String? filmId,
    required String body,
    required TakeTag tag,
    XFile? image,
    List<String> options = const [],
    String? scene,
    String? timecode,
    bool spoiler = false,
    TakeSkin skin = TakeSkin.normal,
    String title = '',
  }) async {
    calls.log.add('topic');
    calls.topicFilm = filmId;
    calls.topicBody = body;
    calls.topicTag = tag;
    calls.topicImage = image;
    calls.topicOptions = options;
    calls.topicScene = scene;
    calls.topicTimecode = timecode;
    calls.topicSpoiler = spoiler;
    return _take(body, tag);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Take _take(String body, TakeTag tag) => Take(
      id: 1,
      authorId: 1,
      authorName: 'me',
      isMine: true,
      reaction: null,
      body: body,
      votes: const {},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
      tag: tag,
    );

class _StubFind extends FindRepository {
  @override
  Future<MovieSearchPage> search(String query, {int page = 1}) async =>
      const MovieSearchPage(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: [_pulp],
      );
}

Future<void> _pump(
  WidgetTester tester,
  _Calls calls, {
  Future<XFile?> Function()? pickPhoto,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CreateTopicScreen(
        reviews: _FakeReviews(calls),
        finder: _StubFind(),
        pickPhoto: pickPhoto,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _next() => find.widgetWithText(GameButton, _en.createNext);
Finder _post() => find.widgetWithText(GameButton, _en.topicPostButton);

Future<void> _chooseType(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _searchAndPickPulp(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).last, 'pulp');
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Pulp Fiction'));
  await tester.pumpAndSettle();
}

Future<void> _answerSpoiler(WidgetTester tester,
    {required bool spoiler}) async {
  final choice = find.byKey(Key(spoiler ? 'spoiler-yes' : 'spoiler-no'));
  await tester.ensureVisible(choice);
  await tester.tap(choice);
  await tester.pumpAndSettle();
}

/// Types the body and answers the required spoiler question.
Future<void> _writeBody(
  WidgetTester tester,
  String text, {
  bool? spoiler = false,
}) async {
  // The body is the last field; topics other than polls have a title first.
  await tester.enterText(find.byType(TextField).last, text);
  await tester.pumpAndSettle();
  if (spoiler != null) await _answerSpoiler(tester, spoiler: spoiler);
}

void main() {
  testWidgets(
      'review: write, then movie, then feeling, then posts reaction and take',
      (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagReview);
    expect(_next(), findsOneWidget);
    expect(tester.widget<GameButton>(_next()).onPressed, isNull);

    await _writeBody(tester, 'Still gripping');
    await tester.tap(_next());
    await tester.pumpAndSettle();

    // Movie step: Next stays disabled until a movie is chosen.
    expect(tester.widget<GameButton>(_next()).onPressed, isNull);
    await _searchAndPickPulp(tester);
    await tester.tap(_next());
    await tester.pumpAndSettle();

    // Feeling step: post is disabled until a reaction is chosen.
    expect(find.text(_en.createFeelTitle), findsOneWidget);
    expect(tester.widget<GameButton>(_post()).onPressed, isNull);
    await tester
        .tap(find.widgetWithText(GameButton, _en.reviewReactionTapToReact));
    await tester.pumpAndSettle();
    await tester.tap(find.text(reactionEmoji(FilmReaction.loved)).last);
    await tester.pumpAndSettle();

    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['reaction', 'take']);
    expect(calls.reactionFilm, 'tt0110912');
    expect(calls.reaction, FilmReaction.loved);
    expect(calls.takeFilm, 'tt0110912');
    expect(calls.takeBody, 'Still gripping');
    expect(calls.takeTag, TakeTag.review);
    expect(calls.takeSpoiler, isFalse);
  });

  testWidgets('review: Next waits for the spoiler answer, then sends it',
      (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagReview);
    await _writeBody(tester, 'Bruce Willis was dead.', spoiler: null);
    expect(tester.widget<GameButton>(_next()).onPressed, isNull);

    await _answerSpoiler(tester, spoiler: true);
    expect(find.text(_en.takeSpoilerBlurNote), findsOneWidget);
    await tester.tap(_next());
    await tester.pumpAndSettle();
    await _searchAndPickPulp(tester);
    await tester.tap(_next());
    await tester.pumpAndSettle();
    await tester
        .tap(find.widgetWithText(GameButton, _en.reviewReactionTapToReact));
    await tester.pumpAndSettle();
    await tester.tap(find.text(reactionEmoji(FilmReaction.loved)).last);
    await tester.pumpAndSettle();
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.takeSpoiler, isTrue);
  });

  testWidgets('question about a movie posts a topic with the film and no photo',
      (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagQuestion);
    await _writeBody(tester, 'Who shot the cafe scene?');
    await tester.tap(_next());
    await tester.pumpAndSettle();

    expect(find.text(_en.createSubjectTitle), findsOneWidget);
    await _searchAndPickPulp(tester);
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['topic']);
    expect(calls.topicFilm, 'tt0110912');
    expect(calls.topicTag, TakeTag.question);
    expect(calls.topicImage, isNull);
  });

  testWidgets('hot take can be created as a hot_take topic', (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagHotTake);
    await _writeBody(tester, 'The sequel is better.');
    await tester.tap(_next());
    await tester.pumpAndSettle();

    expect(find.text(_en.createSubjectTitle), findsOneWidget);
    await _searchAndPickPulp(tester);
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['topic']);
    expect(calls.topicFilm, 'tt0110912');
    expect(calls.topicBody, 'The sequel is better.');
    expect(calls.topicTag, TakeTag.hotTake);
    expect(calls.topicTag!.apiValue, 'hot_take');
    expect(calls.topicImage, isNull);
  });

  testWidgets('discussion with a photo posts without a movie', (tester) async {
    final calls = _Calls();
    final photo = XFile('/tmp/does-not-exist-photo.png');
    await _pump(tester, calls, pickPhoto: () async => photo);

    await _chooseType(tester, _en.topicTagDiscussion);
    await _writeBody(tester, 'Where was this shot?');
    await tester.tap(_next());
    await tester.pumpAndSettle();

    await tester.tap(find.text(_en.createSubjectPhoto));
    await tester.pumpAndSettle();
    expect(_post(), findsOneWidget);
    expect(tester.widget<GameButton>(_post()).onPressed, isNull);

    await tester.tap(find.text(_en.createAddPhoto));
    await tester.pumpAndSettle();
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['topic']);
    expect(calls.topicFilm, isNull);
    expect(calls.topicTag, TakeTag.discussion);
    expect(calls.topicImage?.path, photo.path);
  });
  testWidgets('poll: question, then two options, posts the options',
      (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagPoll);
    await _writeBody(tester, 'Best Nolan film?');
    await tester.tap(_next());
    await tester.pumpAndSettle();

    // Options step: two blank rows, so Post stays disabled.
    expect(find.text(_en.createPollOptionsTitle), findsOneWidget);
    expect(tester.widget<GameButton>(_post()).onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), 'Memento');
    await tester.enterText(find.byType(TextField).at(1), '  Inception ');
    await tester.pumpAndSettle();
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['topic']);
    expect(calls.topicTag, TakeTag.poll);
    expect(calls.topicBody, 'Best Nolan film?');
    expect(calls.topicOptions, ['Memento', 'Inception']);
    expect(calls.topicFilm, isNull);
    expect(calls.topicSpoiler, isFalse);
  });

  testWidgets(
      'scene: movie, then scene details, posts scene fields and spoiler',
      (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagScene);
    await _searchAndPickPulp(tester);
    await tester.tap(_next());
    await tester.pumpAndSettle();

    expect(tester.widget<GameButton>(_post()).onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(0), 'The diner');
    await tester.enterText(find.byType(TextField).at(1), '1h 12m');
    await tester.enterText(
        find.byType(TextField).at(2), 'Nothing moves but the talk.');
    await _answerSpoiler(tester, spoiler: true);
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.log, ['topic']);
    expect(calls.topicTag, TakeTag.scene);
    expect(calls.topicFilm, 'tt0110912');
    expect(calls.topicScene, 'The diner');
    expect(calls.topicTimecode, '1h 12m');
    expect(calls.topicBody, 'Nothing moves but the talk.');
    expect(calls.topicSpoiler, isTrue);
  });

  testWidgets('hot take spoiler answer is sent with the topic', (tester) async {
    final calls = _Calls();
    await _pump(tester, calls);

    await _chooseType(tester, _en.topicTagHotTake);
    await _writeBody(tester, 'The twist was obvious.', spoiler: true);
    await tester.tap(_next());
    await tester.pumpAndSettle();
    await _searchAndPickPulp(tester);
    await tester.tap(_post());
    await tester.pumpAndSettle();

    expect(calls.topicSpoiler, isTrue);
    expect(calls.topicTag, TakeTag.hotTake);
  });
}
