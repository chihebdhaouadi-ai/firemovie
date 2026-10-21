enum FilmReaction {
  loved('loved'),
  brokeHeart('broke_heart'),
  blewMind('blew_mind'),
  madeCry('made_cry'),
  shocked('shocked'),
  madeLaugh('made_laugh'),
  bored('bored'),
  disappointed('disappointed'),
  madeThink('made_think'),
  masterpiece('masterpiece');

  const FilmReaction(this.apiValue);

  final String apiValue;
}
