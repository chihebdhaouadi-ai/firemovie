import 'package:film_wise_mobile/features/film_reviews/data/review_parser.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/poll_option.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take.dart';
import 'package:film_wise_mobile/features/film_reviews/domain/take_tag.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _takeJson({
  String tag = 'poll',
  Map<String, dynamic> extra = const {},
}) =>
    {
      'id': 7,
      'author_id': 2,
      'author_name': 'Ada',
      'is_mine': false,
      'reaction': null,
      'body': 'Best Nolan film?',
      'tag': tag,
      'votes': const <String, int>{},
      'my_votes': const <String>[],
      'comment_count': 0,
      'is_most_helpful': false,
      ...extra,
    };

Take _poll({int? mine}) => Take(
      id: 7,
      authorId: 2,
      authorName: 'Ada',
      isMine: false,
      reaction: null,
      body: 'Best Nolan film?',
      votes: const {},
      myVotes: const {},
      commentCount: 0,
      isMostHelpful: false,
      tag: TakeTag.poll,
      pollOptions: const [
        PollOption(id: 1, label: 'Memento', votes: 4),
        PollOption(id: 2, label: 'Inception', votes: 6),
        PollOption(id: 3, label: 'Interstellar', votes: 0),
      ],
      myPollOptionId: mine,
    );

void main() {
  group('TakeTag.fromApi', () {
    test('reads poll and scene', () {
      expect(TakeTag.fromApi('poll'), TakeTag.poll);
      expect(TakeTag.fromApi('scene'), TakeTag.scene);
      expect(TakeTag.poll.apiValue, 'poll');
      expect(TakeTag.scene.apiValue, 'scene');
    });

    test('still reads the existing tags', () {
      expect(TakeTag.fromApi('hot_take'), TakeTag.hotTake);
      expect(TakeTag.fromApi('question'), TakeTag.question);
      expect(TakeTag.fromApi('discussion'), TakeTag.discussion);
    });

    test('falls back to review for unknown or missing values', () {
      expect(TakeTag.fromApi('something_new'), TakeTag.review);
      expect(TakeTag.fromApi(null), TakeTag.review);
    });
  });

  group('ReviewParser.take', () {
    test('reads spoiler, scene, timecode, poll options and the viewer choice',
        () {
      final take = ReviewParser.take(_takeJson(extra: {
        'spoiler': true,
        'scene': 'The interrogation room',
        'timecode': '1h 12m',
        'poll_options': [
          {'id': 1, 'label': 'Memento', 'votes': 4},
          {'id': 2, 'label': 'Inception', 'votes': 6},
        ],
        'my_poll_option_id': 2,
      }));

      expect(take.tag, TakeTag.poll);
      expect(take.spoiler, isTrue);
      expect(take.scene, 'The interrogation room');
      expect(take.timecode, '1h 12m');
      expect(take.pollOptions.map((o) => o.label), ['Memento', 'Inception']);
      expect(take.pollOptions.last.votes, 6);
      expect(take.totalPollVotes, 10);
      expect(take.myPollOptionId, 2);
    });

    test('defaults the new fields when an older payload omits them', () {
      final take = ReviewParser.take(_takeJson(tag: 'question'));

      expect(take.spoiler, isFalse);
      expect(take.scene, '');
      expect(take.timecode, '');
      expect(take.pollOptions, isEmpty);
      expect(take.myPollOptionId, isNull);
    });

    test('treats null scene and timecode as empty', () {
      final take = ReviewParser.take(_takeJson(tag: 'scene', extra: {
        'scene': null,
        'timecode': null,
        'spoiler': null,
        'poll_options': null,
        'my_poll_option_id': null,
      }));

      expect(take.scene, '');
      expect(take.timecode, '');
      expect(take.spoiler, isFalse);
      expect(take.pollOptions, isEmpty);
      expect(take.myPollOptionId, isNull);
    });
  });

  group('Take.withPollVote', () {
    test('a first vote adds one to the chosen option', () {
      final voted = _poll().withPollVote(3);

      expect(voted.myPollOptionId, 3);
      expect(voted.pollOptions.map((o) => o.votes), [4, 6, 1]);
      expect(voted.totalPollVotes, 11);
    });

    test('changing the vote moves the count from the old option', () {
      final changed = _poll(mine: 1).withPollVote(2);

      expect(changed.myPollOptionId, 2);
      expect(changed.pollOptions.map((o) => o.votes), [3, 7, 0]);
      expect(changed.totalPollVotes, 10);
    });

    test('voting for the current choice changes nothing', () {
      final poll = _poll(mine: 2);

      expect(identical(poll.withPollVote(2), poll), isTrue);
    });

    test('clearing the vote removes its count', () {
      final cleared = _poll(mine: 2).withPollVote(null);

      expect(cleared.myPollOptionId, isNull);
      expect(cleared.pollOptions.map((o) => o.votes), [4, 5, 0]);
    });

    test('keeps the rest of the take as it was', () {
      final voted = _poll().withPollVote(1);

      expect(voted.id, 7);
      expect(voted.body, 'Best Nolan film?');
      expect(voted.tag, TakeTag.poll);
      expect(voted.pollOptions.map((o) => o.label),
          ['Memento', 'Inception', 'Interstellar']);
    });
  });
}
