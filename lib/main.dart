import 'package:film_wise_mobile/account/blocs/login_bloc.dart';
import 'package:film_wise_mobile/account/blocs/login_state.dart';
import 'package:film_wise_mobile/account/data/login_repo.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:film_wise_mobile/features/find/views/find_film_screen.dart';
import 'package:film_wise_mobile/features/home/bloc/home_bloc.dart';
import 'package:film_wise_mobile/features/home/bloc/home_screen_event.dart';
import 'package:film_wise_mobile/features/home/data/home_repository.dart';
import 'package:film_wise_mobile/features/home/views/home_screen.dart';
import 'package:film_wise_mobile/features/onboarding/views/onboarding_screen.dart';
import 'package:film_wise_mobile/l10n/app_localizations.dart';
import 'package:film_wise_mobile/core/session.dart';
import 'package:flutter/material.dart';

import 'account/views/pages/login.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'home/views/widgets/custom_dialgo.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My App',
        initialRoute: '/',
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          '/': (context) => RepositoryProvider<LoginRepo>(
              create: (context) => LoginRepo(),
              child: BlocProvider<LoginBLoc>(
                create: (context) => LoginBLoc(context.read<LoginRepo>()),
                child: BlocListener<LoginBLoc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginLoadedState) {
                        if ((state.services.feature == "login")) {
                          if (state.services.message != "wrong") {
                            Session.token = state.services.token;
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  message: "Wrong email or password",
                                  textColor: Colors.red,
                                  buttonText: "OK",
                                );
                              },
                            );
                          }
                        } else if (state.services.feature == "register") {
                          if (state.services.status == 200) {
                            Session.token = state.services.token;
                            Navigator.pushReplacementNamed(
                                context, '/onboarding');
                          }
                          if (state.services.status == 400)
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  message: "${state.services.message}",
                                  textColor: Colors.red,
                                  buttonText: "OK",
                                );
                              },
                            );
                        }
                      }
                    },
                    child: Login()),
              )),
          '/home': (context) => BlocProvider<HomeBloc>(
                create: (context) => HomeBloc(
                  repository: ApiHomeRepository(),
                  gateway: FakeRecommendationGateway(),
                )..add(const HomeStarted()),
                child: const HomeScreen(),
              ),
          '/onboarding': (context) => const OnboardingScreen(),
          '/find': (context) => const FindFilmScreen(),
        });
  }
}
