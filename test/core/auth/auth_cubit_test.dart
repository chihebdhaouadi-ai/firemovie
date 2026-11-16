import 'package:bloc_test/bloc_test.dart';
import 'package:film_wise_mobile/core/auth/auth_cubit.dart';
import 'package:film_wise_mobile/core/auth/auth_state.dart';
import 'package:film_wise_mobile/core/auth/auth_token_store.dart';
import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/features/find/data/api_client.dart';
import 'package:film_wise_mobile/features/find/data/movie.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Lets the fire-and-forget store clear in [AuthCubit] finish.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

ApiClient _apiReturning(int status, {String body = ''}) => ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((_) async => http.Response(body, status)),
    );

void main() {
  late InMemoryAuthTokenStore store;

  setUp(() {
    Session.clear();
    store = InMemoryAuthTokenStore();
  });
  tearDown(Session.clear);

  group('restore', () {
    blocTest<AuthCubit, AuthState>(
      'with no stored token becomes guest and leaves Session empty',
      build: () => AuthCubit(store: store),
      act: (cubit) => cubit.restore(),
      expect: () => const [AuthGuest()],
      verify: (_) {
        expect(Session.token, isEmpty);
        expect(Session.isLoggedIn, isFalse);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'with a stored token becomes authenticated and mirrors the token to Session',
      setUp: () => store = InMemoryAuthTokenStore('stored-token'),
      build: () => AuthCubit(store: store),
      act: (cubit) => cubit.restore(),
      expect: () => const [AuthAuthenticated('stored-token')],
      verify: (_) {
        expect(Session.token, 'stored-token');
        expect(Session.isLoggedIn, isTrue);
      },
    );
  });

  group('sign in and out', () {
    blocTest<AuthCubit, AuthState>(
      'signIn stores the token and emits authenticated',
      build: () => AuthCubit(store: store),
      act: (cubit) => cubit.signIn('new-token'),
      expect: () => const [AuthAuthenticated('new-token')],
      verify: (_) {
        expect(Session.token, 'new-token');
        expect(store.token, 'new-token');
      },
    );

    blocTest<AuthCubit, AuthState>(
      'signOut clears the store and emits guest',
      setUp: () => store = InMemoryAuthTokenStore('stored-token'),
      build: () => AuthCubit(store: store),
      act: (cubit) async {
        await cubit.restore();
        await cubit.signOut();
      },
      expect: () => const [
        AuthAuthenticated('stored-token'),
        AuthGuest(),
      ],
      verify: (_) {
        expect(Session.token, isEmpty);
        expect(store.token, isNull);
      },
    );
  });

  group('401 expiry', () {
    blocTest<AuthCubit, AuthState>(
      'reportUnauthorized while signed in moves to guest and clears the store',
      build: () => AuthCubit(store: store),
      act: (cubit) async {
        await cubit.signIn('expiring-token');
        Session.reportUnauthorized();
      },
      expect: () => const [
        AuthAuthenticated('expiring-token'),
        AuthGuest(),
      ],
      verify: (_) async {
        await _settle();
        expect(Session.token, isEmpty);
        expect(store.token, isNull);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'reportUnauthorized while already guest emits nothing and does not throw',
      build: () => AuthCubit(store: store),
      act: (cubit) async {
        await cubit.restore();
        Session.reportUnauthorized();
        Session.reportUnauthorized();
      },
      expect: () => const [AuthGuest()],
      verify: (cubit) {
        expect(cubit.state, isA<AuthGuest>());
        expect(Session.token, isEmpty);
      },
    );

    test('a 401 from ApiClient drops a signed-in session to guest', () async {
      final cubit = AuthCubit(store: InMemoryAuthTokenStore('expiring-token'));
      addTearDown(cubit.close);
      await cubit.restore();
      expect(cubit.state, const AuthAuthenticated('expiring-token'));

      final api = _apiReturning(401, body: '{"detail":"Token expired."}');
      await expectLater(
        api.getJson('/api/account/me'),
        throwsA(isA<AuthFailure>()),
      );

      expect(cubit.state, isA<AuthGuest>());
      expect(Session.token, isEmpty);
      await _settle();
      expect(cubit.state, isA<AuthGuest>());
    });

    test('a second 401 while guest does not loop, emit, or crash the cubit',
        () async {
      final cubit = AuthCubit(store: InMemoryAuthTokenStore('expiring-token'));
      addTearDown(cubit.close);
      await cubit.restore();

      final api = _apiReturning(401);
      await expectLater(
        api.getJson('/api/account/me'),
        throwsA(isA<AuthFailure>()),
      );
      expect(cubit.state, isA<AuthGuest>());

      final emitted = <AuthState>[];
      final sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      await expectLater(
        api.getJson('/api/account/me'),
        throwsA(isA<AuthFailure>()),
      );
      await _settle();

      expect(emitted, isEmpty);
      expect(cubit.state, isA<AuthGuest>());
      expect(Session.token, isEmpty);
    });

    test('a 403 does not sign the person out', () async {
      final cubit = AuthCubit(store: InMemoryAuthTokenStore('valid-token'));
      addTearDown(cubit.close);
      await cubit.restore();

      final api = _apiReturning(403, body: '{"detail":"Not allowed."}');
      await expectLater(
        api.getJson('/api/account/me'),
        throwsA(isA<ServerFailure>()),
      );

      expect(cubit.state, const AuthAuthenticated('valid-token'));
      expect(Session.token, 'valid-token');
    });
  });
}
