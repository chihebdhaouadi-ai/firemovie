/// Votes on questions and discussions. Reviews use [VoteKind] instead.
enum TopicVote {
  like('like'),
  dislike('dislike');

  const TopicVote(this.apiValue);

  final String apiValue;
}
