/// Optional position on a top-level review comment.
enum ReviewStance {
  changedMyMind('changed_my_mind'),
  disagreeButFair('disagree_but_fair');

  const ReviewStance(this.apiValue);

  final String apiValue;

  static ReviewStance? fromApi(Object? value) {
    for (final stance in ReviewStance.values) {
      if (stance.apiValue == value) return stance;
    }
    return null;
  }
}
