import 'package:flutter/material.dart';

// The detail side reads MovieReviewsCubit, which the overlay cannot reach,
// so the flight always shows the feed-card side.
Widget takeHeroFlightShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final feedSide = flightDirection == HeroFlightDirection.push
      ? fromHeroContext
      : toHeroContext;
  // The flight is painted in the Overlay, which has no Material ancestor. The feed
  // card contains an InkWell (GameCard), and InkWell asserts on a Material ancestor,
  // so provide a transparent one here.
  // The flight is painted in the Overlay, which has no Material ancestor. The feed
  // card contains an InkWell (GameCard), and InkWell asserts on a Material ancestor,
  // so provide a transparent one here.
  return Material(
    type: MaterialType.transparency,
    child: ClipRect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: (feedSide.widget as Hero).child,
      ),
    ),
  );
}
