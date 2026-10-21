enum VoteKind {
  changedMyMind('changed_my_mind'),
  wellArgued('well_argued'),
  disagreeButFair('disagree_but_fair');

  const VoteKind(this.apiValue);

  final String apiValue;
}
