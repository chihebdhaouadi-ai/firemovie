/// A reader's verdict on a review: one of up, draw or down.
enum VoteKind {
  up('up'),
  draw('draw'),
  down('down');

  const VoteKind(this.apiValue);

  final String apiValue;
}
