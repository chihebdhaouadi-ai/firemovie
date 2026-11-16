import 'package:equatable/equatable.dart';

/// One choice on a poll. [votes] includes the viewer's own vote, if any.
class PollOption extends Equatable {
  const PollOption({
    required this.id,
    required this.label,
    required this.votes,
  });

  final int id;
  final String label;
  final int votes;

  @override
  List<Object?> get props => [id, label, votes];
}
