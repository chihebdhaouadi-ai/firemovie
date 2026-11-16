import 'package:flutter/widgets.dart';

import '../../features/find/data/movie.dart';
import '../session.dart';

/// Named route of the login page.
const loginRouteName = '/login';

/// Named route of the onboarding flow shown after a new account is created.
const onboardingRouteName = '/onboarding';

/// Arguments for [loginRouteName]. [reason] is the context line shown above
/// the form, for example "Log in to search and add films".
class LoginRouteArgs {
  const LoginRouteArgs({this.reason, this.startOnSignUp = false});

  final String? reason;
  final bool startOnSignUp;
}

/// Popped by the login page after a successful sign-in. A cancelled login pops
/// with null instead.
class LoginOutcome {
  const LoginOutcome({required this.isNewAccount});

  final bool isNewAccount;
}

/// Runs [action] only for a signed-in person. A guest is sent to the login page
/// with [reason] as the context line.
///
/// The pending [action] and the return point live in this call's async frame:
/// the login route is pushed on top of the caller, so popping it returns here,
/// and the action resumes on success. The gate never stores a global queue.
///
/// Returns true when [action] ran. Returns false when the person cancelled
/// login (back press or close) or created a new account. A new account goes to
/// onboarding, which ends at Home, so the action is dropped in that case.
///
/// If the server rejects the token during [action] (HTTP 401), the session has
/// already dropped to guest, so the gate opens login and runs [action] once more
/// after a successful sign-in. It never retries in a loop.
///
/// Errors other than [AuthFailure] propagate to the caller.
Future<bool> requireAuth(
  BuildContext context, {
  required String reason,
  required Future<void> Function() action,
  bool startOnSignUp = false,
}) async {
  if (Session.isLoggedIn) {
    try {
      await action();
      return true;
    } on AuthFailure {
      // Token expired. AuthCubit already moved to guest; fall through to login.
    }
  }

  if (!context.mounted) return false;
  final navigator = Navigator.of(context, rootNavigator: true);
  final outcome = await navigator.pushNamed<dynamic>(
    loginRouteName,
    arguments: LoginRouteArgs(
      reason: reason,
      startOnSignUp: startOnSignUp,
    ),
  );
  if (outcome is! LoginOutcome) return false;

  if (outcome.isNewAccount) {
    await navigator.pushNamed<void>(onboardingRouteName);
    return false;
  }

  await action();
  return true;
}
