import 'dart:async';

import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/data/login_repo.dart';
import 'package:film_wise_mobile/account/views/pages/login.dart';
import 'package:film_wise_mobile/core/auth/auth_cubit.dart';
import 'package:film_wise_mobile/core/auth/auth_gate.dart';
import 'package:film_wise_mobile/core/auth/auth_state.dart';
import 'package:film_wise_mobile/core/auth/auth_token_store.dart';
import 'package:film_wise_mobile/core/auth/sign_in_prompt.dart';
import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final _en = lookupAppLocalizations(const Locale('en'));

const _runLabel = 'Run gated action';
const _logInLabel = 'Log in now';
const _cancelLabel = 'Cancel login';

/// Records the names of routes pushed onto the app navigator.
class _RouteRecorder extends NavigatorObserver {
  final pushedNames = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedNames.add(route.settings.name);
  }

  bool get loginOpened => pushedNames.contains(loginRouteName);
}

/// What the gated action did, what [requireAuth] returned, and any error.
class _Gate {
  int runs = 0;
  bool? result;
  Object? error;
}

/// A minimal gated button. [failFirstWithAuth] simulates the server rejecting
/// the token on the first run, the way an ApiClient 401 does.
class _GatedAction extends StatelessWidget {
  const _GatedAction({
    required this.gate,
    required this.reason,
    this.failFirstWithAuth = false,
  });

  final _Gate gate;
  final String reason;
  final bool failFirstWithAuth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            unawaited(requireAuth(
              context,
              reason: reason,
              action: () async {
                gate.runs++;
                if (failFirstWithAuth && gate.runs == 1) {
                  Session.reportUnauthorized();
                  throw const AuthFailure('You need to sign in again.');
                }
              },
            ).then<void>(
              (ran) => gate.result = ran,
              onError: (Object e) => gate.error = e,
            ));
          },
          child: const Text(_runLabel),
        ),
      ),
    );
  }
}

/// Stands in for the login page when the test only needs the gate's outcome.
/// Signing in goes through [AuthCubit] first, as the real login page does.
class _FakeLogin extends StatelessWidget {
  const _FakeLogin();

  @override
  Widget build(BuildContext context) {
    final reason = ModalRoute.of(context)?.settings.arguments;
    final reasonText =
        reason is LoginRouteArgs ? reason.reason ?? 'no reason' : 'no args';
    return Scaffold(
      body: Column(
        children: [
          Text(reasonText),
          ElevatedButton(
            onPressed: () async {
              final cubit = context.read<AuthCubit>();
              await cubit.signIn('fresh-token');
              if (context.mounted) {
                Navigator.of(context).pop(
                  const LoginOutcome(isNewAccount: false),
                );
              }
            },
            child: const Text(_logInLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(_cancelLabel),
          ),
        ],
      ),
    );
  }
}

/// The real login page, provided the same way the app provides it.
Widget _realLogin(BuildContext context) => BlocProvider<LoginBLoc>(
      create: (_) => LoginBLoc(LoginRepo()),
      child: const Login(),
    );

Widget _fakeLogin(BuildContext context) => const _FakeLogin();

/// Pumps the gate harness.
///
/// By default the login route is generated with a typed `MaterialPageRoute`
/// through `onGenerateRoute`, so these tests exercise the gate itself.
/// [productionRoutes] instead registers the login page through the `routes`
/// map, exactly as lib/main.dart does. That path currently fails; see the
/// regression test below.
Future<AuthCubit> _pumpApp(
  WidgetTester tester, {
  required Widget home,
  required _RouteRecorder recorder,
  required Widget Function(BuildContext) loginPage,
  bool productionRoutes = false,
  String? storedToken,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final cubit = AuthCubit(store: InMemoryAuthTokenStore(storedToken));
  addTearDown(cubit.close);
  await cubit.restore();

  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: cubit,
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: [recorder],
        routes: productionRoutes ? {loginRouteName: loginPage} : const {},
        onGenerateRoute: (settings) {
          if (settings.name != loginRouteName) return null;
          return MaterialPageRoute<LoginOutcome>(
            settings: settings,
            builder: loginPage,
          );
        },
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  setUp(Session.clear);
  tearDown(Session.clear);

  group('guest taps a gated action', () {
    testWidgets('login opens with the reason for that action', (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        home: _GatedAction(gate: gate, reason: _en.authReasonSearch),
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();

      expect(recorder.loginOpened, isTrue);
      expect(find.text(_en.authReasonSearch), findsOneWidget);
      expect(gate.runs, 0);
      expect(Session.token, isEmpty);
    });

    testWidgets('SignInPrompt opens the register form', (tester) async {
      final recorder = _RouteRecorder();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SignInPrompt(
              title: _en.authSignInSubtitle,
              reason: _en.authReasonHome,
            ),
          ),
        ),
      );

      await tester.tap(find.text(_en.authSignIn));
      await tester.pumpAndSettle();

      expect(recorder.loginOpened, isTrue);
      expect(find.text(_en.authCreateAccount), findsNWidgets(2));
      expect(Session.token, isEmpty);
    });

    testWidgets('SignInPrompt expands to the available page width',
        (tester) async {
      final recorder = _RouteRecorder();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SignInPrompt(
              title: _en.authSignInSubtitle,
              reason: _en.authReasonHome,
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SignInPrompt)).width, 400);
    });

    testWidgets('back press cancels login and the action does not run',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      final cubit = await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _fakeLogin,
        home: _GatedAction(gate: gate, reason: _en.authReasonProfile),
      );
      expect(cubit.state, isA<AuthGuest>());

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();
      expect(find.text(_en.authReasonProfile), findsOneWidget);

      // System back press on the login route.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(gate.runs, 0);
      expect(gate.result, isFalse);
      expect(cubit.state, isA<AuthGuest>());
      expect(Session.token, isEmpty);
    });

    testWidgets(
        'close button on the real login cancels and the action does not run',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        home: _GatedAction(gate: gate, reason: _en.authReasonSearch),
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(_en.authClose));
      await tester.pumpAndSettle();

      expect(gate.runs, 0);
      expect(gate.result, isFalse);
      expect(Session.token, isEmpty);
    });
  });

  group('resume after login', () {
    testWidgets('a successful login runs the action exactly once',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      final cubit = await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _fakeLogin,
        home: _GatedAction(gate: gate, reason: _en.authReasonSearch),
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();
      expect(gate.runs, 0);

      await tester.tap(find.text(_logInLabel));
      await tester.pumpAndSettle();

      expect(gate.runs, 1);
      expect(gate.result, isTrue);
      expect(cubit.state, const AuthAuthenticated('fresh-token'));
      expect(Session.token, 'fresh-token');
    });

    testWidgets('a signed-in person runs the action with no login',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _fakeLogin,
        home: _GatedAction(gate: gate, reason: _en.authReasonSearch),
        storedToken: 'stored-token',
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();

      expect(gate.runs, 1);
      expect(gate.result, isTrue);
      expect(recorder.loginOpened, isFalse);
    });

    testWidgets(
        'a 401 during the action drops to guest, logs in, and runs the action once more',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      final cubit = await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _fakeLogin,
        home: _GatedAction(
          gate: gate,
          reason: _en.authReasonSearch,
          failFirstWithAuth: true,
        ),
        storedToken: 'expired-token',
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();
      expect(recorder.loginOpened, isTrue);
      expect(gate.runs, 1);

      await tester.tap(find.text(_logInLabel));
      await tester.pumpAndSettle();

      expect(gate.runs, 2);
      expect(gate.result, isTrue);
      expect(cubit.state, const AuthAuthenticated('fresh-token'));
    });

    testWidgets('a 401 followed by cancel runs the action only once',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      final cubit = await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _fakeLogin,
        home: _GatedAction(
          gate: gate,
          reason: _en.authReasonSearch,
          failFirstWithAuth: true,
        ),
        storedToken: 'expired-token',
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_cancelLabel));
      await tester.pumpAndSettle();

      expect(gate.runs, 1);
      expect(gate.result, isFalse);
      expect(cubit.state, isA<AuthGuest>());
      expect(Session.token, isEmpty);
    });
  });

  group('regression', () {
    testWidgets(
        'production routes map: a guest reaches login from a gated action',
        (tester) async {
      final recorder = _RouteRecorder();
      final gate = _Gate();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        productionRoutes: true,
        home: _GatedAction(gate: gate, reason: _en.authReasonSearch),
      );

      await tester.tap(find.text(_runLabel));
      await tester.pumpAndSettle();

      expect(gate.error, isNull,
          reason: 'requireAuth must not throw for a guest');
      expect(recorder.loginOpened, isTrue);
      expect(find.text(_en.authReasonSearch), findsOneWidget);
    });

    testWidgets('production routes map: SignInPrompt opens registration',
        (tester) async {
      final recorder = _RouteRecorder();
      await _pumpApp(
        tester,
        recorder: recorder,
        loginPage: _realLogin,
        productionRoutes: true,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: SignInPrompt(
              title: _en.authSignInSubtitle,
              reason: _en.authReasonHome,
            ),
          ),
        ),
      );

      await tester.tap(find.text(_en.authSignIn));
      await tester.pumpAndSettle();

      expect(recorder.loginOpened, isTrue);
      expect(find.text(_en.authCreateAccount), findsNWidgets(2));
    });
  });
}
