import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/data/login_repo.dart';
import 'package:film_wise_mobile/account/views/pages/login.dart';
import 'package:film_wise_mobile/account/views/widgets/social_auth_button.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  Size size = const Size(320, 568),
  Locale locale = const Locale('en'),
  double keyboardInset = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardInset);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<LoginBLoc>(
        create: (_) => LoginBLoc(LoginRepo()),
        child: const Login(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign-in shows three social buttons on a small screen', (tester) async {
    await _pumpLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(SocialAuthButton), findsNWidgets(3));
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('sign-in reports required fields on empty submit', (tester) async {
    await _pumpLogin(tester);

    await _tap(tester, find.widgetWithText(FilledButton, 'Sign in'));

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('sign-in stays usable with the keyboard open', (tester) async {
    await _pumpLogin(tester, keyboardInset: 300);

    await _tap(tester, find.widgetWithText(TextFormField, 'Password').first);

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('sign-up validates confirm password', (tester) async {
    await _pumpLogin(tester);

    await _tap(tester, find.widgetWithText(TextButton, 'Sign up'));

    await tester.enterText(find.widgetWithText(TextFormField, 'Username').last, 'filmfan');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email').last, 'fan@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password').last, 'secret1');
    await tester.enterText(find.widgetWithText(TextFormField, 'Repeat password').last, 'secret2');
    await _tap(tester, find.widgetWithText(FilledButton, 'Create account'));

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('sign-up fits small screens with long Russian strings', (tester) async {
    await _pumpLogin(tester, locale: const Locale('ru'));

    await _tap(tester, find.byType(TextButton).first);

    expect(tester.takeException(), isNull);
    expect(find.byType(SocialAuthButton), findsNWidgets(3));
  });
}
