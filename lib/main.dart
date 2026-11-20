import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/data/login_repo.dart';
import 'package:film_wise_mobile/core/app_locale.dart';
import 'package:film_wise_mobile/core/auth/auth_cubit.dart';
import 'package:film_wise_mobile/core/auth/auth_gate.dart';
import 'package:film_wise_mobile/core/auth/auth_state.dart';
import 'package:film_wise_mobile/core/auth/auth_token_store.dart';
import 'package:film_wise_mobile/core/l10n_context.dart';
import 'package:film_wise_mobile/core/motion.dart';
import 'package:film_wise_mobile/core/session.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/core/widgets/paper_grain.dart';
import 'package:film_wise_mobile/features/angel_bird/angel_bird_host.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/home/bloc/home_bloc.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_event.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/home/views/home_screen.dart';
import 'package:film_wise_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:film_wise_mobile/features/profile/data/profile_repository.dart';
import 'package:film_wise_mobile/features/social/data/social_repository.dart';
import 'package:film_wise_mobile/features/messaging/data/messaging_repository.dart';
import 'package:film_wise_mobile/features/stories/data/story_repository.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'account/views/pages/login.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized

  await AppLocale.load();
  await AppThemeMode.load();

  // Restore the session before the first frame so the app opens already
  // knowing whether the person is a guest or signed in.
  final auth = AuthCubit(store: SharedPrefsAuthTokenStore());
  await auth.restore();

  runApp(MyApp(auth: auth));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.auth});

  final AuthCubit auth;

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static final navigatorKey = MyApp.navigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppThemeMode.current.addListener(_applyPalette);
    AppPalette.current = _resolvePalette();
  }

  @override
  void dispose() {
    AppThemeMode.current.removeListener(_applyPalette);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() => _applyPalette();

  AppPalette _resolvePalette() => AppThemeMode.paletteFor(
        AppThemeMode.current.value,
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
      );

  /// Swaps the palette and rebuilds every widget, keeping their state, since
  /// most of them read [AppColors] directly rather than through the theme.
  void _applyPalette() {
    final next = _resolvePalette();
    if (identical(next, AppPalette.current) || !mounted) return;
    AppPalette.current = next;
    setState(() {});
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.current;
    return BlocProvider<AuthCubit>.value(
      value: widget.auth,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: AppLocale.current,
        builder: (context, locale, child) => MaterialApp(
          locale: locale,
          onGenerateTitle: (context) => context.l10n.appWindowTitle,
          navigatorKey: navigatorKey,
          // Opens on the login page. A successful sign-in replaces it with Home.
          initialRoute: loginRouteName,
          // Web shows pages without a slide; see core/motion.dart.
          theme: kIsWeb
              ? AppTheme.forPalette(palette).copyWith(
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    for (final platform in TargetPlatform.values)
                      platform: const NoMotionPageTransitionsBuilder(),
                  }),
                )
              : AppTheme.forPalette(palette),
          themeAnimationDuration: Duration.zero,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            // Web runs with reduced motion, so widgets that already honour
            // the OS setting also go still there.
            data: MediaQuery.of(context).copyWith(
              disableAnimations:
                  kIsWeb || MediaQuery.of(context).disableAnimations,
            ),
            child: PaperGrain(
              color: palette.grain,
              child: AngelBirdHost(
                navigatorKey: navigatorKey,
                child: child!,
              ),
            ),
          ),
          routes: {
            // Home is the front door for guests and members alike.
            '/': _homeRoute,
            '/home': _homeRoute,
            loginRouteName: (context) => RepositoryProvider<LoginRepo>(
                  create: (context) => LoginRepo(),
                  child: BlocProvider<LoginBLoc>(
                    create: (context) => LoginBLoc(context.read<LoginRepo>()),
                    child: const Login(),
                  ),
                ),
            onboardingRouteName: (context) => const OnboardingScreen(),
            '/find': (context) => const FindFilmScreen(),
          },
        ),
      ),
    );
  }
}

Widget _homeRoute(BuildContext context) => BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(
        repository: ApiHomeRepository(),
        gateway: FakePointsGateway(),
        isSignedIn: () => Session.isLoggedIn,
      )..add(const HomeStarted()),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) => HomeScreen(
          profile: ProfileRepository(),
          social: SocialRepository(),
          stories: ApiStoryRepository(),
          messaging: ApiMessagingRepository(),
          signedIn: auth is AuthAuthenticated,
        ),
      ),
    );
