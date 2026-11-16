/// What kind of post a take is. Reviews carry a reaction; topics are free-form.
enum TakeTag {
  review('review'),
  question('question'),
  discussion('discussion'),
  hotTake('hot_take'),
  poll('poll'),
  scene('scene');

  const TakeTag(this.apiValue);

  final String apiValue;

  static TakeTag fromApi(String? value) {
    for (final tag in TakeTag.values) {
      if (tag.apiValue == value) return tag;
    }
    return TakeTag.review;
  }
}
