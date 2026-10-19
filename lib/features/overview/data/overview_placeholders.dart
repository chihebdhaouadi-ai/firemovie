// Stand-in content until the API provides reviews, friend activity, credits and
// ratings counts. Nothing here is persisted or sent anywhere.

class OverviewReview {
  const OverviewReview({
    required this.body,
    required this.author,
    required this.date,
  });

  final String body;
  final String author;
  final String date;
}

abstract final class OverviewPlaceholders {
  static const ratingsCount = 128;
  static const userStars = 4;

  static const cast = [
    'Timothée Chalamet',
    'Zendaya',
    'Oscar Isaac',
    'Rebecca Ferguson',
  ];
  static const crew = ['Denis Villeneuve', 'Hans Zimmer', 'Greig Fraser'];
  static const production = ['Legendary Pictures', 'Warner Bros.'];

  static const friends = ['Maya', 'Youssef', 'Lina'];

  static const friendReviews = [
    OverviewReview(
      body: 'Visually stunning and slow in the best way.',
      author: 'Maya',
      date: 'Oct 12',
    ),
    OverviewReview(
      body: 'The score alone is worth the ticket.',
      author: 'Youssef',
      date: 'Oct 9',
    ),
  ];

  static const popularReviews = [
    OverviewReview(
      body: 'A long watch that rewards patience.',
      author: 'Alex',
      date: 'Sep 30',
    ),
    OverviewReview(
      body: 'Sound design you feel in your chest.',
      author: 'Priya',
      date: 'Sep 28',
    ),
  ];
}
