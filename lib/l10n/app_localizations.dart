import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @homeNotificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get homeNotificationsTooltip;

  /// No description provided for @homePointsLabel.
  ///
  /// In en, this message translates to:
  /// **'{points} Points'**
  String homePointsLabel(int points);

  /// No description provided for @homeTop5Title.
  ///
  /// In en, this message translates to:
  /// **'Your Top 5'**
  String get homeTop5Title;

  /// No description provided for @homeTop5Hint.
  ///
  /// In en, this message translates to:
  /// **'Pick five films you love'**
  String get homeTop5Hint;

  /// No description provided for @homeTop5SlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Top 5 slot {index}, {state}'**
  String homeTop5SlotLabel(Object index, Object state);

  /// No description provided for @homeTop5SlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get homeTop5SlotEmpty;

  /// No description provided for @homeTop5SlotFilled.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String homeTop5SlotFilled(String title);

  /// No description provided for @homeTop5AddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a film to your Top 5'**
  String get homeTop5AddLabel;

  /// No description provided for @homeRecommendTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommend me'**
  String get homeRecommendTitle;

  /// No description provided for @homeRecommendHint.
  ///
  /// In en, this message translates to:
  /// **'Pick exactly 3 films to generate a recommendation'**
  String get homeRecommendHint;

  /// No description provided for @homeGenerateButton.
  ///
  /// In en, this message translates to:
  /// **'GENERATE'**
  String get homeGenerateButton;

  /// No description provided for @homeGenerateButtonSemantics.
  ///
  /// In en, this message translates to:
  /// **'Generate recommendation from 3 picked films'**
  String get homeGenerateButtonSemantics;

  /// No description provided for @homeGenerateDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Pick {remaining} more film(s) to enable'**
  String homeGenerateDisabledHint(int remaining);

  /// No description provided for @homeGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get homeGenerating;

  /// No description provided for @homeGenerateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recommendation ready'**
  String get homeGenerateSuccess;

  /// No description provided for @homeQuickActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsLabel;

  /// No description provided for @homeQuickActionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeQuickActionSearch;

  /// No description provided for @homeQuickActionAddFilm.
  ///
  /// In en, this message translates to:
  /// **'Add film'**
  String get homeQuickActionAddFilm;

  /// No description provided for @homeQuickActionRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get homeQuickActionRandom;

  /// No description provided for @homeQuickActionFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get homeQuickActionFriends;

  /// No description provided for @homeWatchedTitle.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get homeWatchedTitle;

  /// No description provided for @homeWatchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get homeWatchlistTitle;

  /// No description provided for @homePopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular With Friends'**
  String get homePopularTitle;

  /// No description provided for @homeFilmCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Films'**
  String homeFilmCount(int count);

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get homeSeeAll;

  /// No description provided for @homeSeeAllSemantics.
  ///
  /// In en, this message translates to:
  /// **'See all {section}'**
  String homeSeeAllSemantics(Object section);

  /// No description provided for @homeAddTileLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to {section}'**
  String homeAddTileLabel(String section);

  /// No description provided for @homeFilmTileSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}, {section}'**
  String homeFilmTileSemantics(String title, String section);

  /// No description provided for @homeSectionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get homeSectionEmptyTitle;

  /// No description provided for @homeSectionEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add a film'**
  String get homeSectionEmptyAction;

  /// No description provided for @homeSectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this list'**
  String get homeSectionErrorTitle;

  /// No description provided for @homeSectionErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeSectionErrorRetry;

  /// No description provided for @homeRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed {title}'**
  String homeRemovedSnackbar(String title);

  /// No description provided for @homeUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get homeUndo;

  /// No description provided for @homeRefreshSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get homeRefreshSemantics;

  /// No description provided for @homeTop5FullSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your Top 5 is full. Remove a film first.'**
  String get homeTop5FullSnackbar;

  /// No description provided for @homeRecommendFullSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You can pick up to 3 films.'**
  String get homeRecommendFullSnackbar;

  /// No description provided for @homeGenericErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get homeGenericErrorSnackbar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
