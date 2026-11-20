import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Motion policy for the app.
///
/// The web build shows no motion: page changes, tab slides, tap bounces,
/// looping glows and Lottie bursts are all skipped, so screens appear in
/// their final state. Mobile keeps its animations unless the OS asks for
/// reduced motion (`MediaQuery.disableAnimations`).
bool motionEnabled(BuildContext context) =>
    !kIsWeb && !MediaQuery.disableAnimationsOf(context);

/// Whether content reacts to scrolling (sections fading and narrowing under
/// the header, the header collapsing, the inbox row shrinking). Off on web:
/// with a mouse wheel these per-frame effects lag behind and the page stutters,
/// so the web keeps a still, opaque header instead.
const bool scrollEffectsEnabled = !kIsWeb;

/// [duration] when motion is on, [Duration.zero] when it is off.
Duration motionDuration(BuildContext context, Duration duration) =>
    motionEnabled(context) ? duration : Duration.zero;

/// Route builder that shows the new page at once (used on web).
class NoMotionPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoMotionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
