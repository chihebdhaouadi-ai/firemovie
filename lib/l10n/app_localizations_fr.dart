// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String homePointsLabel(int points) {
    return '$points points';
  }

  @override
  String get homeTop5Title => 'Ton Top 5';

  @override
  String get homeTop5Hint => 'Choisis cinq films que tu adores';

  @override
  String get homeTop5AddLabel => 'Ajouter un film à ton Top 5';

  @override
  String get homeCollectionsTitle => 'Collections';

  @override
  String get homeTabYou => 'Toi';

  @override
  String get homeTabFriends => 'Amis';

  @override
  String get homeTabExplore => 'Explorer';

  @override
  String get homeTabFilms => 'Films';

  @override
  String get homePopularTakesTitle => 'Critiques populaires';

  @override
  String get homeTrendingTopicsTitle => 'Sujets tendance';

  @override
  String get homeTrendingEmpty => 'No questions or discussions this week yet.';

  @override
  String get homeLatestArticlesTitle => 'Derniers articles';

  @override
  String get homeUpcomingThisMonthTitle => 'Films à venir';

  @override
  String upcomingNotOutYet(String title, String date) {
    return '$title n\'est pas encore sorti. Sortie le $date.';
  }

  @override
  String get homePopularThisWeekTitle => 'Films populaires';

  @override
  String get homeFriendsFilmsTitle => 'Populaire chez tes amis';

  @override
  String get homeFriendsReviewsTitle => 'Derniers avis de tes amis';

  @override
  String get homeMyTakesTitle => 'Mes critiques';

  @override
  String get homeComingSoon => 'Bientôt disponible';

  @override
  String get homeInboxTitle => 'Messages';

  @override
  String get homeInboxSoonTitle => 'En construction';

  @override
  String get homeInboxSoonBody =>
      'Tes messages avec tes amis arriveront ici bientôt.';

  @override
  String get homeFriendsReviewsEmpty =>
      'Tes amis n\'ont pas encore publié d\'avis.';

  @override
  String get homeMyTakesEmpty => 'Tu n\'as pas encore partagé de critique.';

  @override
  String get homeUnderConstruction => 'Cette section est en construction.';

  @override
  String get exploreSkipStamp => 'PASSER';

  @override
  String get exploreOpenStamp => 'OUVRIR';

  @override
  String get exploreCaughtUp => 'Vous avez tout vu';

  @override
  String get exploreReviewButton => 'Avis';

  @override
  String get exploreSubtitle =>
      'Découvre des avis, des discussions et des questions sur les films.';

  @override
  String get createSceneMovieHint =>
      'Ta scène apparaît dans la discussion de ce film.';

  @override
  String get createPollQuestionHint => 'Quelle question poses-tu ?';

  @override
  String get exploreFilterAll => 'Tout';

  @override
  String get exploreFilterConversations => 'Discussions';

  @override
  String get exploreFilterPolls => 'Sondages';

  @override
  String get exploreFilterScenes => 'Scènes';

  @override
  String get exploreFilterQuestions => 'Questions';

  @override
  String get exploreFilterReviews => 'Avis';

  @override
  String get exploreSpoilerReveal => 'Touche pour révéler';

  @override
  String get topicTagPoll => 'Sondage';

  @override
  String get topicTagScene => 'Scène';

  @override
  String get topicSpoilerLabel => 'Contient des spoilers';

  @override
  String get pollVoteHint => 'Touche une option pour voter';

  @override
  String get pollChangeVoteHint =>
      'Touche une autre option pour changer ton vote';

  @override
  String pollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get createTypePollSubtitle =>
      'Laisse les gens voter entre 2 et 4 options.';

  @override
  String get createTypeSceneSubtitle =>
      'Choisis un moment d\'un film et explique pourquoi il marche.';

  @override
  String get createWritePollTitle => 'Écris la question du sondage';

  @override
  String get createPollOptionsTitle => 'Ajoute les options';

  @override
  String get createPollOptionsHint =>
      'Propose 2 à 4 choix. Chacun en choisit un.';

  @override
  String createPollOptionLabel(int number) {
    return 'Option $number';
  }

  @override
  String get createPollAddOption => 'Ajouter une option';

  @override
  String get createPollRemoveOption => 'Supprimer l\'option';

  @override
  String get createSceneTitle => 'Décris la scène';

  @override
  String get createSceneNameLabel => 'Scène';

  @override
  String get createSceneNameHint => 'La salle d\'interrogatoire';

  @override
  String get createSceneTimecodeLabel => 'Repère temporel (facultatif)';

  @override
  String get createSceneTimecodeHint => '1h 12min';

  @override
  String get createSceneExplainLabel => 'Pourquoi ça marche';

  @override
  String get createSceneExplainHint => 'Dis ce qui rend ce moment spécial';

  @override
  String exploreRepliesButton(int count) {
    return 'Voir les $count réponses';
  }

  @override
  String get exploreStripConversation => 'Conversation';

  @override
  String exploreRepliesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
    );
    return '$_temp0';
  }

  @override
  String get exploreNoRepliesYet => 'Aucune réponse pour l\'instant';

  @override
  String get exploreBeFirstRespond => 'Sois le premier à répondre';

  @override
  String explorePeopleTalking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes en parlent',
      one: '1 personne en parle',
    );
    return '$_temp0';
  }

  @override
  String exploreLastReply(String time) {
    return 'dernière réponse $time';
  }

  @override
  String get exploreNoVotesYet => 'Pas encore de votes';

  @override
  String exploreAgreePercent(int percent) {
    return '$percent% d\'accord';
  }

  @override
  String exploreDisagreePercent(int percent) {
    return '$percent% pas d\'accord';
  }

  @override
  String get exploreFor => 'Pour';

  @override
  String get exploreAgainst => 'Contre';

  @override
  String exploreBeFirstArgue(String side) {
    return 'Sois le premier à réagir · $side';
  }

  @override
  String explorePickedBy(String name) {
    return 'choisi par $name';
  }

  @override
  String get exploreThanksVoting => 'Merci pour ton vote';

  @override
  String get exploreJoinConversation => 'Rejoindre la conversation';

  @override
  String get homeCollectionsResizeLabel => 'Redimensionner les collections';

  @override
  String get homeFeedTitle => 'Avis de tes collections';

  @override
  String get homeFeedEmpty =>
      'Aucun avis sur les films de tes collections pour le moment.';

  @override
  String get homeFeedShowAsRow => 'Afficher en ligne';

  @override
  String get homeFeedShowAsColumn => 'Afficher en colonne';

  @override
  String get homeQuickActionsLabel => 'Actions rapides';

  @override
  String get homeQuickActionSearch => 'Rechercher';

  @override
  String get homeQuickActionAddFilm => 'Ajouter un film';

  @override
  String get homeWatchedTitle => 'Déjà vus';

  @override
  String get homeWatchlistTitle => 'À voir';

  @override
  String get homePopularTitle => 'Populaire chez tes amis';

  @override
  String homeFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
  }

  @override
  String homeAddTileLabel(String section) {
    return 'Ajouter à $section';
  }

  @override
  String homeFilmTileSemantics(String title, String section) {
    return '$title, $section';
  }

  @override
  String homeRemoveFilm(String title) {
    return 'Retirer $title';
  }

  @override
  String get homeSectionEmptyTitle => 'Rien ici pour l’instant';

  @override
  String get homeSectionEmptyAction => 'Ajouter un film';

  @override
  String get homeSectionErrorTitle => 'Impossible de charger cette liste';

  @override
  String get homeSectionErrorRetry => 'Réessayer';

  @override
  String homeRemovedSnackbar(String title) {
    return '$title retiré';
  }

  @override
  String get homeUndo => 'Annuler';

  @override
  String get homeTop5FullSnackbar =>
      'Ton Top 5 est plein. Retire d’abord un film.';

  @override
  String get homeGenericErrorSnackbar => 'Une erreur est survenue. Réessaie.';

  @override
  String get findTitleTop5 => 'Ajouter au Top 5';

  @override
  String get findTitleWatched => 'Ajouter aux films vus';

  @override
  String get findTitleWatchlist => 'Ajouter à la liste à voir';

  @override
  String get findTitleSearch => 'Trouver un film';

  @override
  String get findBodySearch => 'Tous les films';

  @override
  String get findSearchHint => 'Titre du film…';

  @override
  String get findSearchClear => 'Effacer la recherche';

  @override
  String get findSearchSubmit => 'Rechercher';

  @override
  String get findMinCharsTitle => 'Continue de taper';

  @override
  String get findMinCharsBody =>
      'Tape au moins 2 caractères pour lancer une recherche.';

  @override
  String get findLoadingTitle => 'Recherche de films…';

  @override
  String findEmptyTitle(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get findEmptyTip1 => 'Vérifie l’orthographe ou essaie un autre titre.';

  @override
  String get findEmptyTip2 =>
      'Essaie un mot-clé plus court ou le nom d’un réalisateur.';

  @override
  String get findErrorTitle => 'Recherche impossible pour le moment';

  @override
  String get findErrorRetry => 'Réessayer';

  @override
  String get findOfflineTitle => 'Tu es hors ligne';

  @override
  String get findOfflineBody =>
      'La recherche et l’ajout sont désactivés hors ligne.';

  @override
  String get findNoMoreResults => 'Fin des résultats';

  @override
  String get findLoadMore => 'Charger plus';

  @override
  String get findRecentTitle => 'Recherches récentes';

  @override
  String get findRecentClear => 'Effacer';

  @override
  String get findRecentSwipeDelete => 'Retirer la recherche récente';

  @override
  String get findRecentEmpty => 'Aucune recherche récente pour l’instant.';

  @override
  String get findDirectedBy => 'Réalisé par';

  @override
  String get findGenreChip => 'Genre';

  @override
  String get findAddToTop5 => 'Ajouter au Top 5';

  @override
  String get findAddToWatched => 'Ajouter aux films vus';

  @override
  String get findAddToWatchlist => 'Ajouter à la liste à voir';

  @override
  String findResultSemantics(
      String title, String year, String director, String action) {
    return '$title, $year, réalisé par $director. $action';
  }

  @override
  String findAddedSemantics(String title, String target) {
    return '$title est déjà dans $target';
  }

  @override
  String findResultDetailsAction(String title) {
    return 'Ouvrir les détails de $title';
  }

  @override
  String get findViewDetails => 'Détails';

  @override
  String get findSendToFriend => 'Envoyer à un ami';

  @override
  String findAddedSnackbar(String target) {
    return 'Ajouté à $target';
  }

  @override
  String get findUndo => 'Annuler';

  @override
  String findRemovedSnackbar(String target) {
    return 'Retiré de $target';
  }

  @override
  String get findMovedToWatched => 'Déplacé dans les films vus';

  @override
  String findReplaceSlotTitle(String current) {
    return 'Remplacer $current ?';
  }

  @override
  String findReplaceSlotBody(String current, String replacement) {
    return 'Cette place est déjà prise par $current. La remplacer par $replacement ?';
  }

  @override
  String get findReplace => 'Remplacer';

  @override
  String get findCancel => 'Annuler';

  @override
  String get findTop5FullTitle => 'Le Top 5 est plein';

  @override
  String get findTop5FullBody =>
      'Retire un film avant d’en ajouter à ton Top 5.';

  @override
  String get findAlreadyWatchedTitle => 'Déjà vu';

  @override
  String get findAlreadyWatchedBody =>
      'Tu ne peux pas ajouter un film déjà vu à ta liste à voir.';

  @override
  String get findAlreadyInListTitle => 'Déjà ajouté';

  @override
  String findAlreadyInListBody(String title, String target) {
    return '$title est déjà dans $target.';
  }

  @override
  String get findGenericErrorTitle => 'Une erreur est survenue';

  @override
  String get findGenericErrorBody => 'Réessaie.';

  @override
  String get findDetailsErrorTitle => 'Impossible de charger le film';

  @override
  String get findDetailsRetry => 'Réessayer';

  @override
  String get findDetailsCast => 'Distribution';

  @override
  String get findDetailsOverview => 'Synopsis';

  @override
  String findDetailsRuntime(int minutes) {
    return '$minutes min';
  }

  @override
  String findDetailsVote(String value) {
    return '$value étoiles';
  }

  @override
  String get findWatchNow => 'Regarder maintenant';

  @override
  String get findAttribution =>
      'Données et affiches des films via TMDB. Disponibilité en streaming via JustWatch.';

  @override
  String get overviewBack => 'Retour';

  @override
  String overviewRating(String value) {
    return '$value / 10';
  }

  @override
  String get overviewNoRating => 'Pas encore de note';

  @override
  String get overviewWhereToWatch => 'Où regarder ?';

  @override
  String get overviewNoStreaming => 'Aucune plateforme de streaming trouvée';

  @override
  String overviewRatingsCount(int count) {
    return 'Notes : $count filmwiser';
  }

  @override
  String overviewStarsValue(String value) {
    return '$value sur 5 étoiles';
  }

  @override
  String get overviewTrailer => 'Bande-annonce';

  @override
  String get overviewNoGenres => 'Aucun genre renseigné';

  @override
  String get overviewTabGenres => 'GENRES';

  @override
  String get overviewTabCast => 'DISTRIBUTION';

  @override
  String get overviewTabCrew => 'ÉQUIPE';

  @override
  String get overviewTabProd => 'PROD';

  @override
  String get overviewActivityTitle => 'Activité de tes amis';

  @override
  String get overviewWantsToWatch => 'Veut voir';

  @override
  String get overviewNoFriendActivity =>
      'Aucune activité de tes amis pour l’instant.';

  @override
  String get overviewShowMore => 'plus';

  @override
  String get overviewShowLess => 'moins';

  @override
  String get overviewReviewsTitle => 'Avis';

  @override
  String get overviewAddReviewHint => 'Ajoute un avis…';

  @override
  String get overviewYourReview => 'Ton avis';

  @override
  String get overviewFriendsReviews => 'Avis de tes amis';

  @override
  String get overviewPopularReviews => 'Avis populaires';

  @override
  String get overviewSeeAll => 'Tout voir';

  @override
  String get reviewTrustedLabel => 'de spectateurs de confiance';

  @override
  String reviewEveryoneTogether(String value) {
    return 'Tout le monde ensemble : $value';
  }

  @override
  String get reviewMostFelt => 'Ressenti le plus :';

  @override
  String get reviewWhatIsTrusted => 'C’est quoi « de confiance » ?';

  @override
  String get reviewTrustedNote =>
      'Les spectateurs gagnent la confiance quand leurs avis sont bien argumentés. Leurs votes comptent un peu plus, pour que le score reste juste et réfléchi.';

  @override
  String get reviewReactionTitle => 'Qu\'as-tu ressenti ?';

  @override
  String get reviewReactionHint => 'Touche celle qui te correspond le mieux.';

  @override
  String get reviewReactionLoved => 'Adoré';

  @override
  String get reviewReactionBrokeHeart => 'M\'a brisé le cœur';

  @override
  String get reviewReactionBlewMind => 'M\'a soufflé';

  @override
  String get reviewReactionMadeCry => 'M\'a fait pleurer';

  @override
  String get reviewReactionShocked => 'M\'a choqué';

  @override
  String get reviewReactionMadeLaugh => 'M\'a fait rire';

  @override
  String get reviewReactionBored => 'M\'a ennuyé';

  @override
  String get reviewReactionDisappointed => 'M\'a déçu';

  @override
  String get reviewReactionMadeThink => 'M\'a fait réfléchir';

  @override
  String get reviewReactionMasterpiece => 'Chef-d\'œuvre';

  @override
  String get reviewReactionTapToReact => 'Touche pour réagir';

  @override
  String get reviewReactionChange => 'Modifier';

  @override
  String get reviewReactionPickOne => 'Choisis';

  @override
  String get reviewReactionClose => 'Fermer';

  @override
  String get reviewWhyPrompt =>
      'Tu veux ajouter une ligne sur le pourquoi ? C\'est facultatif.';

  @override
  String get reviewWhyHint => 'Qu\'est-ce qui t\'est resté ?';

  @override
  String get reviewShare => 'Partager';

  @override
  String get reviewNoThanks => 'Non merci';

  @override
  String get reviewSharedThanks => 'Merci d\'avoir partagé ton avis !';

  @override
  String get reviewCountedThanks => 'Merci ! Ta réaction est comptée.';

  @override
  String get reviewReactionFailed =>
      'Impossible d\'enregistrer ta réaction. Réessaie.';

  @override
  String get reviewSummaryFailed => 'Impossible de charger les réactions.';

  @override
  String get reviewDetailTitle => 'Avis';

  @override
  String get reviewTakesTitle => 'Ce que les gens ont dit';

  @override
  String get reviewTakesHint => 'Courts avis d’autres spectateurs.';

  @override
  String get reviewMostHelpful => 'Avis le plus utile';

  @override
  String get sageNavUnread => 'Non lus';

  @override
  String get sageNavCloseMenu => 'Fermer le menu';

  @override
  String get reviewWriterBadge => 'Auteur';

  @override
  String reviewCommentsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Commentaires $count',
      zero: 'Commentaire',
    );
    return '$_temp0';
  }

  @override
  String get reviewCommentHint => 'Ajoute un commentaire';

  @override
  String get reviewSend => 'Envoyer';

  @override
  String get reviewCommentsFailed => 'Impossible de charger les commentaires.';

  @override
  String get reviewCommentFailed =>
      'Impossible de publier ce commentaire. Réessaie.';

  @override
  String get reviewReply => 'Répondre';

  @override
  String reviewReplyingTo(String name) {
    return 'En réponse à $name';
  }

  @override
  String get reviewCancelReply => 'Annuler la réponse';

  @override
  String reviewShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afficher $count réponses',
      one: 'Afficher 1 réponse',
    );
    return '$_temp0';
  }

  @override
  String get reviewHideReplies => 'Masquer les réponses';

  @override
  String get reviewTimeJustNow => 'À l’instant';

  @override
  String reviewTimeMinutes(int count) {
    return 'il y a $count min';
  }

  @override
  String reviewTimeHours(int count) {
    return 'il y a $count h';
  }

  @override
  String reviewTimeDays(int count) {
    return 'il y a $count j';
  }

  @override
  String get reviewVoteChangedMyMind => 'J’ai changé d’avis';

  @override
  String get reviewVoteWellArgued => 'Bien argumenté';

  @override
  String get reviewVoteDisagreeFair => 'Pas d’accord mais juste';

  @override
  String get reviewVoteFailed =>
      'Impossible de mettre à jour ce vote. Réessaie.';

  @override
  String get reviewTakeFailed => 'Impossible de publier. Réessaie.';

  @override
  String get reviewTakesEmpty => 'Aucun avis pour l’instant.';

  @override
  String get reviewTakesFailed => 'Impossible de charger les avis.';

  @override
  String get reviewRetry => 'Réessayer';

  @override
  String overviewReviewBy(String name, String date) {
    return 'Avis de $name le $date';
  }

  @override
  String get homeOpenProfile => 'Ouvrir le profil';

  @override
  String get profileBack => 'Retour';

  @override
  String get profileSearchTooltip => 'Rechercher';

  @override
  String get profileMoreTooltip => 'Plus d’options';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileFollowers => 'Abonnés';

  @override
  String get profileFollowing => 'Abonnements';

  @override
  String get profileBioHint => 'Modifie ta bio…';

  @override
  String get profileChat => 'Discuter';

  @override
  String get profileFollow => 'Suivre';

  @override
  String get profileSend => 'Envoyer';

  @override
  String get profileAchievementsTitle => 'Succès';

  @override
  String get profileAchievementRookie => 'NOVICE CINÉPHILE';

  @override
  String get profileAchievementMaster => 'MAÎTRE CINÉPHILE';

  @override
  String get profileAchievementLegend => 'LÉGENDE CINÉPHILE';

  @override
  String profileAchievementFilms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
  }

  @override
  String get profileClaim => 'Réclamer';

  @override
  String get profileStatisticsTitle => 'Statistiques';

  @override
  String get profileStatWatched => 'Vus';

  @override
  String get profileStatWatchlist => 'À voir';

  @override
  String get profileStatReviews => 'Avis';

  @override
  String get profileStatRewards => 'Récompenses';

  @override
  String get profileBlockTitle => 'Tu veux bloquer cet utilisateur ?';

  @override
  String get profileBlockReasonHint => 'Pourquoi ?…';

  @override
  String get profileBlockYes => 'Oui';

  @override
  String get profileBlockNo => 'Non';

  @override
  String get profileErrorTitle => 'Impossible de charger ton profil.';

  @override
  String get profileRetry => 'Réessayer';

  @override
  String get profileLanguageButton => 'Gérer les langues';

  @override
  String get profileLanguageDialogTitle => 'Langue de l’application';

  @override
  String get profileLanguageSystem => 'Langue du système';

  @override
  String get profileThemeButton => 'Apparence';

  @override
  String get profileThemeDialogTitle => 'Apparence';

  @override
  String get profileThemeSystem => 'Comme le système';

  @override
  String get profileThemeLight => 'Clair';

  @override
  String get profileThemeDark => 'Sombre';

  @override
  String get onboardingFinishLater => 'Terminer plus tard';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingFinish => 'Terminer';

  @override
  String get onboardingSkip => 'Passer pour l’instant';

  @override
  String get onboardingSaveFailed =>
      'Impossible d’enregistrer. Vérifie ta connexion et réessaie.';

  @override
  String get onboardingAvatarTitle => 'Ajoute une photo de profil';

  @override
  String get onboardingAvatarBody =>
      'Choisis une image pour que les gens puissent te reconnaître. JPG, PNG ou WebP, jusqu’à 5 Mo.';

  @override
  String get onboardingChoosePhoto => 'Choisir une photo';

  @override
  String get onboardingPhotoSaved => 'Photo de profil enregistrée';

  @override
  String get onboardingCoverTitle => 'Ajoute une photo de couverture';

  @override
  String get onboardingCoverBody =>
      'Une image large derrière l’en-tête de ton profil.';

  @override
  String get onboardingChooseCover => 'Choisir une couverture';

  @override
  String get onboardingCoverSaved => 'Couverture enregistrée';

  @override
  String get onboardingBioTitle => 'Écris une courte bio';

  @override
  String get onboardingBioBody =>
      'Dis aux autres quel genre de films tu aimes.';

  @override
  String get onboardingBioHint =>
      'Quelques mots sur tes goûts en matière de films';

  @override
  String get onboardingTop5Title => 'Choisis tes 5 films préférés';

  @override
  String get onboardingTop5Body =>
      'Tes films favoris, affichés en premier sur ton profil.';

  @override
  String onboardingTop5Progress(int count) {
    return '$count sur 5 choisis';
  }

  @override
  String get onboardingWatchedTitle => 'Ajoute les films que tu as vus';

  @override
  String get onboardingWatchedBody => 'Note les films que tu as déjà regardés.';

  @override
  String get onboardingWatchlistTitle => 'Ajoute des films à voir';

  @override
  String get onboardingWatchlistBody =>
      'Enregistre les films que tu prévois de regarder ensuite.';

  @override
  String onboardingFilmsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films ajoutés',
      one: '1 film ajouté',
    );
    return '$_temp0';
  }

  @override
  String get onboardingSearchFilms => 'Rechercher des films';

  @override
  String get profileNotificationsTooltip => 'Notifications';

  @override
  String get profileEditPhoto => 'Modifier la photo';

  @override
  String get profileEditCover => 'Modifier la couverture';

  @override
  String get profileEditBio => 'Modifier la bio';

  @override
  String get profileEditBioTitle => 'Modifie ta bio';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get profileCancel => 'Annuler';

  @override
  String get profileSaveFailed => 'Impossible d’enregistrer. Réessaie.';

  @override
  String get profileNoConnections => 'Personne ici pour l’instant.';

  @override
  String get friendAdd => 'Ajouter en ami';

  @override
  String get friendCancelRequest => 'Annuler la demande';

  @override
  String get friendAccept => 'Accepter';

  @override
  String get friendDecline => 'Refuser';

  @override
  String get friendFriends => 'Amis';

  @override
  String get friendRequestSent => 'Demande d’ami envoyée.';

  @override
  String get friendActionFailed =>
      'Impossible de mettre à jour la demande d’ami. Réessaie.';

  @override
  String get friendRequestGone => 'Cette demande n’est plus disponible.';

  @override
  String get friendAlreadyConnected =>
      'Tu es déjà ami avec cette personne, ou une demande est en attente.';

  @override
  String get searchPeopleTitle => 'Trouver des personnes';

  @override
  String get searchPeopleHint => 'Recherche par nom d’utilisateur';

  @override
  String get searchPeopleMinChars => 'Tape au moins 2 caractères.';

  @override
  String get searchPeopleEmpty => 'Aucun utilisateur trouvé.';

  @override
  String get searchPeopleFailed =>
      'Recherche impossible pour le moment. Réessaie.';

  @override
  String get suggestMovieAction => 'Suggérer un film';

  @override
  String get suggestionTitle => 'Suggérer un film';

  @override
  String get suggestionSearchHint => 'Rechercher le titre d’un film';

  @override
  String get suggestionSearchMinChars => 'Tape au moins 2 caractères.';

  @override
  String get suggestionSearchEmpty => 'Aucun film trouvé.';

  @override
  String get suggestionSearchFailed =>
      'Recherche impossible pour le moment. Réessaie.';

  @override
  String get suggestionMovieSection => 'Film';

  @override
  String get suggestionPickMovie => 'Choisis un film à suggérer.';

  @override
  String get suggestionChangeMovie => 'Changer de film';

  @override
  String get suggestionRecipientsSection => 'Envoyer à';

  @override
  String get suggestionSelectAll => 'Tout sélectionner';

  @override
  String get suggestionNoFriends =>
      'Ajoute d’abord des amis pour leur envoyer des suggestions.';

  @override
  String get suggestionFriendsFailed => 'Impossible de charger tes amis.';

  @override
  String get suggestionCommentHint => 'Ajoute un commentaire (facultatif)';

  @override
  String get suggestionSend => 'Envoyer la suggestion';

  @override
  String get suggestionSent => 'Suggestion envoyée.';

  @override
  String get suggestionFailed =>
      'Impossible d’envoyer la suggestion. Réessaie.';

  @override
  String get suggestionNotFriends =>
      'Tu ne peux suggérer des films qu’à tes amis. Modifie ta sélection et réessaie.';

  @override
  String notificationMovieSuggestion(String name, String title) {
    return '$name t’a suggéré $title.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Aucune notification pour l’instant.';

  @override
  String get notificationsFailed => 'Impossible de charger les notifications.';

  @override
  String notificationFriendRequest(String name) {
    return '$name t’a envoyé une demande d’ami.';
  }

  @override
  String notificationFriendAccepted(String name) {
    return '$name a accepté ta demande d’ami.';
  }

  @override
  String get angelBirdQuestion =>
      'Tu veux rejoindre un débat sur l\'un de tes 5 films préférés ? La communauté Sage serait ravie d\'entendre ton avis.';

  @override
  String get angelBirdYes => 'Oui, débattons';

  @override
  String get angelBirdNotNow => 'Pas maintenant';

  @override
  String get angelBirdPickFilm => 'Choisis un film à débattre';

  @override
  String get angelBirdEmptyTop5 =>
      'Ton top 5 est vide. Ajoute cinq films pour lancer un débat.';

  @override
  String get angelBirdLoadFailed => 'Impossible de charger ton top 5.';

  @override
  String get angelBirdRetry => 'Réessayer';

  @override
  String get angelBirdReviewQuestion =>
      'Tu veux ouvrir un débat sur cet avis ? Choisis quelqu\'un de la conversation avec qui échanger.';

  @override
  String get angelBirdPickPerson => 'Avec qui veux-tu débattre ?';

  @override
  String get angelBirdNoPeople =>
      'Personne avec qui débattre pour l\'instant. Attends qu\'un commentaire arrive sur cet avis.';

  @override
  String get angelBirdPeopleFailed =>
      'Impossible de charger les personnes de cet avis.';

  @override
  String debateWaitingTitle(String name) {
    return 'En attente de $name';
  }

  @override
  String debateWaitingBody(String name) {
    return 'Ton invitation est envoyée. Le débat commence dès que $name accepte.';
  }

  @override
  String debateDeclined(String name) {
    return '$name ne peut pas débattre pour le moment. Essaie quelqu\'un d\'autre de la conversation.';
  }

  @override
  String get debateInviteFailed =>
      'Impossible d\'envoyer ton invitation. Réessaie.';

  @override
  String get debateLoadFailed =>
      'Impossible de charger les questions. Réessaie.';

  @override
  String get debateSubmitFailed =>
      'Impossible d\'envoyer tes réponses. Réessaie.';

  @override
  String get debateRetry => 'Réessayer';

  @override
  String get debateCancel => 'Annuler';

  @override
  String get debateDone => 'Terminé';

  @override
  String debateVsTitle(String name) {
    return 'Toi contre $name';
  }

  @override
  String debateQuestionCounter(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get debateResultWon => 'Tu as gagné le débat !';

  @override
  String debateResultLost(String name) {
    return '$name remporte cette manche.';
  }

  @override
  String get debateResultTied => 'Égalité.';

  @override
  String debateScoreLine(int mine, String name, int theirs) {
    return 'Toi $mine · $name $theirs';
  }

  @override
  String debateSagePointsWon(int points) {
    return '+$points points Sage';
  }

  @override
  String debateSagePointsLost(int points, String name) {
    return '$points points Sage pour $name.';
  }

  @override
  String get authTagline => 'DÉBLOQUE TON CINÉPHILE INTÉRIEUR';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authNoAccountPrompt => 'Tu n\'as pas encore de compte ?';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authPasswordsMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authUsername => 'Nom d\'utilisateur';

  @override
  String get authRepeatPassword => 'Répète le mot de passe';

  @override
  String get authHaveAccountPrompt => 'Tu as déjà un compte ?';

  @override
  String get authEmailRequired => 'Saisis ton e-mail';

  @override
  String get authEmailInvalid => 'Saisis une adresse e-mail valide';

  @override
  String get authPasswordRequired => 'Saisis ton mot de passe';

  @override
  String get authPasswordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authUsernameRequired => 'Saisis un nom d\'utilisateur';

  @override
  String get authUsernameTooShort =>
      'Le nom d\'utilisateur doit contenir au moins 6 caractères';

  @override
  String get authHidePassword => 'Masquer le mot de passe';

  @override
  String get authShowPassword => 'Afficher le mot de passe';

  @override
  String get authAccountCreated =>
      'Compte créé avec succès. Connecte-toi pour continuer.';

  @override
  String get authOr => 'ou';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueWithReddit => 'Continuer avec Reddit';

  @override
  String get authWelcomeBack => 'Bon retour';

  @override
  String get authSignInSubtitle =>
      'Connecte-toi pour reprendre là où tu t\'es arrêté.';

  @override
  String get authCreateAccountSubtitle =>
      'Rejoins la communauté et partage tes avis.';

  @override
  String get authMinLengthHint => 'Au moins 6 caractères';

  @override
  String get authErrorInvalidCredentials =>
      'E-mail ou mot de passe incorrect. Réessaie.';

  @override
  String get authErrorRegisterFailed =>
      'Impossible de créer ton compte. Réessaie.';

  @override
  String get authErrorNetwork =>
      'Impossible de joindre le serveur. Vérifie ta connexion et réessaie.';

  @override
  String get appWindowTitle => 'Mon app';

  @override
  String get findActionAdd => 'Ajouter';

  @override
  String get findActionAdded => 'Ajouté';

  @override
  String get reviewTranslate => 'Traduire';

  @override
  String get reviewShowOriginal => 'Voir l’original';

  @override
  String get reviewTranslateFailed => 'Impossible de traduire pour le moment.';

  @override
  String reviewQuote(String body) {
    return '« $body »';
  }

  @override
  String get exploreCreateButton => 'Créer';

  @override
  String get topicCreateTitle => 'Créer un sujet';

  @override
  String get topicFindMovie => 'Trouver un film';

  @override
  String get topicSearchHint => 'Rechercher un film';

  @override
  String get topicNoResults => 'Aucun film trouvé';

  @override
  String get topicChangeMovie => 'Changer';

  @override
  String get topicTypeLabel => 'Type';

  @override
  String get topicTagReview => 'Avis';

  @override
  String get topicTagQuestion => 'Question';

  @override
  String get topicTagDiscussion => 'Discussion';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint => 'Les avis nécessitent ta réaction au film.';

  @override
  String get topicBodyHint =>
      'Écris ton avis, ta question ou ton sujet de discussion';

  @override
  String get topicPostButton => 'Publier';

  @override
  String get topicPostFailed => 'Publication impossible. Réessaie.';

  @override
  String get topicSearchFailed => 'La recherche a échoué. Réessaie.';

  @override
  String get createTypeTitle => 'Choose what you want to share.';

  @override
  String get createTypeReviewSubtitle =>
      'Tell people how a movie made you feel.';

  @override
  String get createTypeQuestionSubtitle =>
      'Ask about a movie or share a photo.';

  @override
  String get createTypeDiscussionSubtitle =>
      'Start a conversation about a movie or a photo.';

  @override
  String get createTypeHotTakeSubtitle => 'Share a bold take about a film.';

  @override
  String get createWriteReviewTitle => 'Write your take';

  @override
  String get createWriteQuestionTitle => 'Write your question';

  @override
  String get createWriteDiscussionTitle => 'Start the discussion';

  @override
  String get createWriteHotTakeTitle => 'Write your hot take';

  @override
  String get createReviewMovieTitle => 'Which movie is it about?';

  @override
  String get createReviewMovieHint =>
      'Your take appears on that movie\'s page.';

  @override
  String get createFeelTitle => 'How did it make you feel?';

  @override
  String get createFeelHint => 'Pick one reaction. It shows with your take.';

  @override
  String get createSubjectTitle => 'What is it about?';

  @override
  String get createSubjectMovie => 'A movie';

  @override
  String get createSubjectPhoto => 'A photo';

  @override
  String get createAddPhoto => 'Choose a photo';

  @override
  String get createChangePhoto => 'Change photo';

  @override
  String get createPhotoFailed =>
      'Could not open your photos. Please try again.';

  @override
  String get createNext => 'Next';

  @override
  String get leaderboardTabLabel => 'Classement';

  @override
  String get leaderboardTitle => 'Meilleurs critiques';

  @override
  String get leaderboardSubtitle => 'Classés par réactions à leurs avis';

  @override
  String get leaderboardHowItWorks => 'Comment ça marche';

  @override
  String get leaderboardPeriodWeek => 'Cette semaine';

  @override
  String get leaderboardPeriodMonth => 'Ce mois-ci';

  @override
  String get leaderboardPeriodAll => 'Depuis toujours';

  @override
  String get leaderboardReactionsLabel => 'réactions';

  @override
  String leaderboardReactionsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'reactions',
      one: 'reaction',
    );
    return '$_temp0';
  }

  @override
  String leaderboardReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardYouSuffix => '(vous)';

  @override
  String get leaderboardEmpty =>
      'Aucune réaction pour l\'instant sur cette période.';

  @override
  String get leaderboardLoadFailed => 'Impossible de charger le classement.';

  @override
  String get leaderboardRetry => 'Réessayer';

  @override
  String get howRankingTitle => 'Comment fonctionne le classement';

  @override
  String get howStep1Title => 'Écrire un avis';

  @override
  String get howStep1Body =>
      'Donne ton avis sur n\'importe quel film. Il apparaît dans Explorer et Amis.';

  @override
  String get howStep2Title => 'Recevez des réactions';

  @override
  String get howStep2Body =>
      'Les lecteurs réagissent à votre avis. Chaque réaction vaut un point.';

  @override
  String get howStep3Title => 'Grimpez au classement';

  @override
  String get howStep3Body =>
      'Les critiques ayant le plus de réactions sur la période montent sur le podium.';

  @override
  String get howNoteReset =>
      'La semaine repart chaque lundi à 00h00. Ce mois-ci et Depuis toujours continuent de compter.';

  @override
  String get howNoteOncePerReview =>
      'Chaque personne ne peut réagir qu\'une fois par avis. Réagir à ton propre avis ne compte pas.';

  @override
  String get howNoteTie =>
      'En cas d\'égalité, le critique qui a atteint le total en premier est mieux classé.';

  @override
  String get howNotePodium =>
      'Les trois premiers portent un cadre de podium (or, bleu, bronze) sur le classement de la période affichée.';

  @override
  String get howLevelsTitle => 'Niveaux et XP';

  @override
  String get howXpReview => 'Écrire un avis';

  @override
  String get howXpComment => 'Écrire un commentaire';

  @override
  String get howXpReaction => 'Recevoir une réaction';

  @override
  String howXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get howLevelFoot =>
      'Chaque niveau demande 50 XP de plus que le précédent.';

  @override
  String get profileBadgesTitle => 'Badges';

  @override
  String get badgeWellArguedTitle => 'Bien argumenté';

  @override
  String badgeWellArguedDesc(int count) {
    return 'Recevez $count réactions « Bien argumenté ».';
  }

  @override
  String get badgeChangedMindTitle => 'J\'ai changé d\'avis';

  @override
  String badgeChangedMindDesc(int count) {
    return 'Recevez $count réactions « J\'ai changé d\'avis ».';
  }

  @override
  String get badgeDisagreeTitle => 'En désaccord mais juste';

  @override
  String badgeDisagreeDesc(int count) {
    return 'Recevez $count réactions « En désaccord mais juste ».';
  }

  @override
  String get badgeTopCriticTitle => 'Meilleur critique';

  @override
  String get badgeTopCriticDesc => 'Terminez dans le top 3 hebdomadaire.';

  @override
  String get badgeFirstTakeTitle => 'Premier avis';

  @override
  String get badgeFirstTakeDesc =>
      'Sois le premier à donner ton avis sur un film.';

  @override
  String get achFilmCriticTitle => 'Critique de films';

  @override
  String achFilmCriticDesc(int count) {
    return 'Écris $count avis.';
  }

  @override
  String get achDebaterTitle => 'Débatteur';

  @override
  String achDebaterDesc(int count) {
    return 'Obtenez $count réactions « Bien argumenté ».';
  }

  @override
  String get achLocalCinemaTitle => 'Cinéma local';

  @override
  String achLocalCinemaDesc(int count) {
    return 'Donne ton avis sur $count films tunisiens.';
  }

  @override
  String get achComingSoon => 'Bientôt';

  @override
  String get frameNewcomerTitle => 'Nouveau';

  @override
  String get frameExplorerTitle => 'Explorateur';

  @override
  String get frameDebaterTitle => 'Débatteur';

  @override
  String get frameTopCriticTitle => 'Meilleur critique';

  @override
  String get frameLegendTitle => 'Légende';

  @override
  String get frameAlwaysUnlocked => 'Tout le monde commence avec ce cadre.';

  @override
  String frameLevelRequirement(int level) {
    return 'Atteignez le niveau $level.';
  }

  @override
  String frameDebaterRequirement(int count) {
    return 'Recevez $count réactions « Bien argumenté ».';
  }

  @override
  String get frameEquipped => 'Équipé';

  @override
  String get frameTapToEquip => 'Touchez pour équiper';

  @override
  String get frameUnlocked => 'Débloqué';

  @override
  String get frameLocked => 'Verrouillé';

  @override
  String get frameUpdateFailed => 'Impossible d\'équiper ce cadre. Réessayez.';

  @override
  String profileLevelLabel(int level) {
    return 'NIVEAU $level';
  }

  @override
  String get profileStatComments => 'Commentaires';

  @override
  String get profileStatReactions => 'Réactions';

  @override
  String get profileFramesTitle => 'Cadres';

  @override
  String profileXpProgress(int into, int span, int next) {
    return '$into / $span XP pour le niveau $next';
  }

  @override
  String get topicDetailTitle => 'Sujet';

  @override
  String topicCommentsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Aucun commentaire',
    );
    return '$_temp0';
  }

  @override
  String get topicAboutFilm => 'À propos du film';

  @override
  String get topicBeFirst => 'Sois le premier à répondre.';

  @override
  String get authClose => 'Close';

  @override
  String get authReasonSearch => 'Log in to search and add films';

  @override
  String get authReasonProfile => 'Log in to open your profile';

  @override
  String get authReasonExplore => 'Log in to explore takes and topics';

  @override
  String get authReasonNotifications => 'Log in to see your notifications';

  @override
  String get authReasonFilm => 'Log in to open film details';

  @override
  String get authReasonHome => 'Log in to see your films, friends and takes';

  @override
  String get authGuestPromptTitle => 'Sign in to see your films and friends';

  @override
  String get authGuestPromptBody =>
      'Upcoming films and news are open to everyone. Sign in to build your lists and join the conversation.';

  @override
  String get browseSectionDiscover => 'Découvrir';

  @override
  String get browseTopTakes => 'Top 100 des critiques';

  @override
  String get browsePopularFilms => 'Films les plus populaires';

  @override
  String get browseByYear => 'Parcourir par année';

  @override
  String get browseByStreaming => 'Parcourir par plateforme de streaming';

  @override
  String get browseSectionTopics => 'Sujets les plus populaires';

  @override
  String get browsePolls => 'Sondages';

  @override
  String get browseConversations => 'Conversations';

  @override
  String get browseScenes => 'Scènes';

  @override
  String get browseQuestions => 'Questions';

  @override
  String get browseHotTakes => 'Avis tranchés';

  @override
  String get browseSectionFilmSage => 'FilmSage';

  @override
  String get browseNewHere => 'Nouveau ici ?';

  @override
  String get browseSocialMedia => 'Réseaux sociaux';

  @override
  String get browseFollowUs => 'Suivez-nous';

  @override
  String get browseGifts => 'Cadeaux';

  @override
  String get browseContact => 'Contact';

  @override
  String get browseTerms =>
      'Conditions d\'utilisation / Règles de la communauté';

  @override
  String get browseYearsTitle => 'Choisissez une année';

  @override
  String browseDecade(String decade) {
    return 'Années $decade';
  }

  @override
  String get browseServicesTitle => 'Choisissez une plateforme';

  @override
  String get browseServicesEmpty => 'Aucune plateforme disponible.';

  @override
  String get browseFilmsEmpty => 'Aucun film ici pour l\'instant.';

  @override
  String get browseTakesEmpty => 'Rien de publié ici pour l\'instant.';

  @override
  String get browseComingSoonTitle => 'Bientôt disponible';

  @override
  String get browseComingSoonBody =>
      'Nous travaillons encore sur cette page. Revenez bientôt.';

  @override
  String get browseByGenre => 'Parcourir par genre';

  @override
  String get browseByCountry => 'Parcourir par pays';

  @override
  String get browseByLanguage => 'Parcourir par langue';

  @override
  String get browseGenresTitle => 'Choisissez un genre';

  @override
  String get browseCountriesTitle => 'Choisissez un pays';

  @override
  String get browseCountriesHint =>
      'Les films populaires en streaming dans chaque pays.';

  @override
  String browseStreamingIn(String country) {
    return 'En streaming : $country';
  }

  @override
  String get browseLanguagesTitle => 'Choisissez une langue';

  @override
  String get browsePickEmpty => 'Rien à choisir pour l\'instant.';

  @override
  String get browseLanguageEn => 'Anglais';

  @override
  String get browseLanguageFr => 'Français';

  @override
  String get browseLanguageEs => 'Espagnol';

  @override
  String get browseLanguageIt => 'Italien';

  @override
  String get browseLanguageDe => 'Allemand';

  @override
  String get browseLanguagePt => 'Portugais';

  @override
  String get browseLanguageRu => 'Russe';

  @override
  String get browseLanguageAr => 'Arabe';

  @override
  String get browseLanguageTr => 'Turc';

  @override
  String get browseLanguageHi => 'Hindi';

  @override
  String get browseLanguageKo => 'Coréen';

  @override
  String get browseLanguageJa => 'Japonais';

  @override
  String get browseLanguageZh => 'Chinois';

  @override
  String get browseLanguageSv => 'Suédois';

  @override
  String get overviewPlayTrailer => 'Lire la bande-annonce';

  @override
  String get overviewTrailerUnavailable =>
      'Impossible d\'ouvrir la bande-annonce.';

  @override
  String get overviewLoading => 'Chargement…';

  @override
  String get overviewNoCastCrew =>
      'Pas encore d\'informations sur la distribution et l\'équipe.';

  @override
  String get overviewOfferStream => 'Streaming';

  @override
  String get overviewOfferFree => 'Gratuit';

  @override
  String get overviewOfferTvProvider => 'Avec un fournisseur TV';

  @override
  String get overviewOfferRent => 'Location';

  @override
  String get overviewOfferBuy => 'Achat';

  @override
  String get overviewCloseTrailer => 'Fermer la bande-annonce';

  @override
  String get filmSuggest => 'Suggérer';

  @override
  String get filmListFailed =>
      'Impossible de mettre à jour ta liste. Réessaie.';

  @override
  String get filmFeelingsEmpty => 'Touche pour dire ce que tu as ressenti';

  @override
  String get filmFeelingsHint => 'Choisis jusqu\'à 3 émotions.';

  @override
  String filmFeelingsCount(String count) {
    return '$count sur 3 choisies';
  }

  @override
  String get filmFeelingsSave => 'Enregistrer';

  @override
  String get filmFeelingsClear => 'Effacer';

  @override
  String get filmAudienceTitle => 'Le public';

  @override
  String get filmAudienceEmpty =>
      'Aucune réaction pour l\'instant. Sois le premier à dire ce que tu as ressenti.';

  @override
  String get filmAudiencePositive => 'ont aimé';

  @override
  String filmAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes ont réagi',
      one: '1 personne a réagi',
    );
    return '$_temp0';
  }

  @override
  String get filmYourTakeTitle => 'Ton avis';

  @override
  String filmTakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avis',
      one: '1 avis',
    );
    return '$_temp0';
  }

  @override
  String get filmTopTake => 'MEILLEUR AVIS';

  @override
  String filmShowMoreTakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voir $count avis de plus',
      one: 'Voir 1 avis de plus',
    );
    return '$_temp0';
  }

  @override
  String get filmShowLessTakes => 'Voir moins';

  @override
  String get filmShareYourTake => 'Partage ton avis';

  @override
  String get filmAddTake => 'Ajouter un avis';

  @override
  String overviewFriendStoryNew(String name, String feeling) {
    return '$name, nouveau : $feeling';
  }

  @override
  String overviewFriendStorySeen(String name, String feeling) {
    return '$name : $feeling';
  }

  @override
  String filmPersonFeelings(String feelings) {
    return 'Ressenti : $feelings';
  }

  @override
  String filmTakeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Aucun commentaire',
    );
    return '$_temp0';
  }

  @override
  String get filmFeelingsDone => 'Terminé';

  @override
  String get personBiography => 'Biographie';

  @override
  String get personFilmography => 'Films';

  @override
  String get personHeight => 'Taille';

  @override
  String get personBorn => 'Né(e) le';

  @override
  String get personDied => 'Décès';

  @override
  String get personNoFilms => 'Aucun film trouvé pour cette personne.';

  @override
  String get personLoadFailed =>
      'Impossible de charger la page de cette personne.';

  @override
  String personAsCharacter(String character) {
    return 'dans le rôle de $character';
  }

  @override
  String get takeSkinTitle => 'Style de carte';

  @override
  String get takeSkinNormal => 'Normal';

  @override
  String get takeSkinElectricThunder => 'Tonnerre électrique';

  @override
  String get takeSkinPreview => 'Aperçu';

  @override
  String get takeSkinPreviewEmpty => 'Ton avis apparaîtra ici.';

  @override
  String get takeSkinWriteTitle => 'Écris ton avis';

  @override
  String get reviewAlreadyShared => 'Tu as déjà partagé un avis sur ce film.';

  @override
  String get reviewNeedsFeeling =>
      'Choisis d’abord ce que le film t’a fait ressentir, puis partage ton avis.';

  @override
  String get reviewYourTake => 'Ton avis — les autres y réagissent';

  @override
  String get reviewBeFirstComment => 'Sois le premier à commenter cet avis.';

  @override
  String get takeMenuTooltip => 'Plus d’options';

  @override
  String get takeActionShare => 'Envoyer à des amis';

  @override
  String get takeActionEdit => 'Modifier';

  @override
  String get takeActionDelete => 'Supprimer';

  @override
  String get takeActionReport => 'Signaler';

  @override
  String get takeEdited => 'modifié';

  @override
  String get takeCancel => 'Annuler';

  @override
  String get takeEditTitle => 'Modifier ton avis';

  @override
  String get takeEditSave => 'Enregistrer';

  @override
  String get takeEditSaved => 'Ton avis a été mis à jour.';

  @override
  String get takeEditFailed => 'Impossible d’enregistrer. Réessaie.';

  @override
  String get takeDeleteTitle => 'Supprimer cet avis ?';

  @override
  String get takeDeleteBody =>
      'Il sera supprimé pour tout le monde, avec ses commentaires.';

  @override
  String get takeDeleted => 'Avis supprimé.';

  @override
  String get takeDeleteFailed => 'Impossible de supprimer. Réessaie.';

  @override
  String get takeReportTitle => 'Signaler cet avis';

  @override
  String get takeReportHint =>
      'Pourquoi le signales-tu ? Seuls les modérateurs voient les signalements.';

  @override
  String get takeReportSpam => 'Spam';

  @override
  String get takeReportHarassment => 'Harcèlement ou intimidation';

  @override
  String get takeReportHate => 'Discours haineux';

  @override
  String get takeReportSpoiler => 'Spoiler non signalé';

  @override
  String get takeReportOther => 'Autre chose';

  @override
  String get takeReportDetailsHint => 'Ajoute des détails (facultatif)';

  @override
  String get takeReportSend => 'Envoyer le signalement';

  @override
  String get takeReportThanks => 'Merci. Notre équipe va l’examiner.';

  @override
  String get takeReportFailed =>
      'Impossible d’envoyer le signalement. Réessaie.';

  @override
  String get takeShareTitle => 'Envoyer à des amis';

  @override
  String get takeShareMessageHint => 'Ajoute un message (facultatif)';

  @override
  String get takeShareNoFriends =>
      'Ajoute des amis pour leur envoyer des avis.';

  @override
  String get takeShareFriendsFailed => 'Impossible de charger tes amis.';

  @override
  String get takeShareFailed => 'Impossible d’envoyer. Réessaie.';

  @override
  String get notificationTakeGone => 'Cet avis n’est plus disponible.';

  @override
  String get mentionSuggestionsLabel => 'Mentionner un ami';

  @override
  String takeShareSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyer à $count amis',
      one: 'Envoyer à 1 ami',
      zero: 'Envoyer',
    );
    return '$_temp0';
  }

  @override
  String takeShareSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyé à $count amis',
      one: 'Envoyé à 1 ami',
    );
    return '$_temp0';
  }

  @override
  String notificationTakeShared(String name) {
    return '$name t’a envoyé un avis';
  }

  @override
  String notificationTakeMention(String name) {
    return '$name t’a mentionné dans un commentaire';
  }

  @override
  String get takeSpoilerTitle => 'Contient-il des spoilers ?';

  @override
  String get takeSpoilerNo => 'Pas de spoilers';

  @override
  String get takeSpoilerHint =>
      'Choisis une option pour prévenir les lecteurs.';

  @override
  String get takeSpoilerRequired =>
      'Indique si ton avis contient des spoilers avant de le partager.';

  @override
  String get takeSpoilerBlurNote =>
      'Les autres le verront flouté jusqu\'à ce qu\'ils touchent pour le révéler.';

  @override
  String get reviewVoteUp => 'Pour';

  @override
  String get reviewVoteDraw => 'Égalité';

  @override
  String get reviewVoteDown => 'Contre';

  @override
  String storyTake(String film) {
    return 'A partagé un avis sur $film';
  }

  @override
  String storyQuestion(String film) {
    return 'A posé une question sur $film';
  }

  @override
  String storyDiscussion(String film) {
    return 'A lancé une discussion sur $film';
  }

  @override
  String storyHotTake(String film) {
    return 'A lâché un avis tranché sur $film';
  }

  @override
  String storyPoll(String film) {
    return 'A créé un sondage sur $film';
  }

  @override
  String storyScene(String film) {
    return 'A partagé une scène de $film';
  }

  @override
  String storyComment(String film) {
    return 'A commenté un post sur $film';
  }

  @override
  String get storyUnknownFilm => 'un film';

  @override
  String get storyOpen => 'Ouvrir';

  @override
  String get storyClose => 'Fermer';

  @override
  String storyRingLabel(String name) {
    return 'Story de $name';
  }

  @override
  String get storiesTitle => 'Stories de tes amis';

  @override
  String get inboxSearch => 'Rechercher';

  @override
  String get inboxSearchHint => 'Rechercher une conversation';

  @override
  String get inboxCloseSearch => 'Fermer la recherche';

  @override
  String get inboxUnreadOnly => 'Non lus seulement';

  @override
  String get inboxAddFriend => 'Ajouter un ami';

  @override
  String get inboxCreate => 'Nouveau chat';

  @override
  String get inboxNewMessage => 'Nouveau message';

  @override
  String get inboxCreateGroup => 'Créer un groupe';

  @override
  String get inboxCreateTopic => 'Créer un sujet privé';

  @override
  String get inboxPrivateTopics => 'Sujets privés';

  @override
  String get inboxNoTopics => 'Aucun sujet. Lance-en un avec tes amis.';

  @override
  String get inboxNewTopic => 'Nouveau sujet privé';

  @override
  String get inboxAllChats => 'Tous les chats';

  @override
  String get inboxEmptyTitle => 'Aucune conversation';

  @override
  String get inboxEmptyBody => 'Écris à un ami pour commencer.';

  @override
  String get inboxNoResults => 'Aucune conversation trouvée';

  @override
  String get inboxLoadFailed => 'Impossible de charger tes messages.';

  @override
  String inboxYouSaid(String text) {
    return 'Toi : $text';
  }

  @override
  String get inboxNoMessagesYet => 'Pas encore de messages';

  @override
  String get inboxGroupName => 'Nom du groupe';

  @override
  String get inboxTopicName => 'Nom du sujet';

  @override
  String get inboxPickFriends => 'Choisis des amis';

  @override
  String get inboxPickFriend => 'Écrire à un ami';

  @override
  String get inboxNoFriends => 'Ajoute d\'abord des amis pour discuter.';

  @override
  String get inboxCreateAction => 'Créer';

  @override
  String get inboxCancel => 'Annuler';

  @override
  String get inboxCreateFailed => 'Impossible de le créer. Réessaie.';

  @override
  String inboxMembers(int count) {
    return '$count membres';
  }

  @override
  String get inboxGroupPhoto => 'Ajouter une photo de groupe';

  @override
  String get inboxGroupDescription => 'Description (facultative)';

  @override
  String get inboxPhotoFailed => 'Créé, mais la photo n\'a pas été envoyée.';

  @override
  String get chatOpenInfo => 'Infos du groupe';

  @override
  String get groupInfoTitle => 'Infos du groupe';

  @override
  String get groupInfoTopicTitle => 'Infos du sujet';

  @override
  String get groupInfoDescription => 'Description';

  @override
  String get groupInfoNoDescription => 'Pas encore de description.';

  @override
  String groupInfoMembers(int count) {
    return 'Membres · $count';
  }

  @override
  String get groupInfoYou => 'Vous';

  @override
  String get groupInfoCreator => 'Créateur';

  @override
  String inboxUnreadLabel(int count) {
    return '$count non lus';
  }

  @override
  String get chatHint => 'Écrire un message';

  @override
  String get chatSend => 'Envoyer';

  @override
  String get chatStart => 'Commence la conversation';

  @override
  String get chatSendFailed => 'Message non envoyé. Réessaie.';

  @override
  String get chatPrivateTopic =>
      'Sujet privé · visible par ses membres seulement';

  @override
  String get inboxSelectChat => 'Choisis une conversation pour discuter';

  @override
  String get chatMenu => 'Menu du groupe';

  @override
  String get chatShareGroup => 'Partager le groupe';

  @override
  String get chatBoostGroup => 'Booster le groupe';

  @override
  String get chatReport => 'Signaler';

  @override
  String get chatLeaveGroup => 'Quitter le groupe';

  @override
  String get chatShareBody => 'Envoyez le groupe dans une conversation.';

  @override
  String chatSharedTo(String name) {
    return 'Partagé dans $name';
  }

  @override
  String chatBoosted(String name) {
    return 'Boost lancé pour $name';
  }

  @override
  String get chatReportTitle => 'Signaler ce groupe';

  @override
  String get chatReportBody =>
      'Dites-nous ce qui ne va pas. Les membres ne sont pas prévenus.';

  @override
  String get chatReportSpam => 'Spam ou arnaque';

  @override
  String get chatReportHarassment => 'Harcèlement';

  @override
  String get chatReportOther => 'Autre chose';

  @override
  String get chatReportSent => 'Signalement envoyé';

  @override
  String get chatCancel => 'Annuler';

  @override
  String get chatClose => 'Fermer';

  @override
  String get chatBack => 'Retour';

  @override
  String get chatActionFailed => 'Ça n\'a pas marché. Réessayez.';

  @override
  String get chatPinned => 'Épinglé';

  @override
  String chatPinnedCount(int count) {
    return 'Épinglés ($count)';
  }

  @override
  String get chatReply => 'Répondre';

  @override
  String chatReplyingTo(String name) {
    return 'Réponse à $name';
  }

  @override
  String get chatCancelReply => 'Annuler la réponse';

  @override
  String get chatPin => 'Épingler le message';

  @override
  String get chatUnpin => 'Désépingler le message';

  @override
  String get chatMessagePinned => 'Message épinglé';

  @override
  String get chatMessageUnpinned => 'Message désépinglé';

  @override
  String chatMention(String name) {
    return 'Mentionner $name';
  }

  @override
  String get chatViewProfile => 'Voir le profil';

  @override
  String get chatMoreReactions => 'Plus de réactions';

  @override
  String chatNotified(String names) {
    return '$names prévenu(s)';
  }

  @override
  String get chatNoMatch => 'Personne ne correspond';

  @override
  String get chatAdd => 'Ajouter une photo, une vidéo, un film ou un sondage';

  @override
  String get chatEmojiButton => 'Emoji, GIF et stickers';

  @override
  String get chatAddTitle => 'Ajouter au chat';

  @override
  String get chatPhoto => 'Photo';

  @override
  String get chatPhotoBody => 'Choisissez une photo sur votre appareil.';

  @override
  String get chatVideo => 'Vidéo';

  @override
  String get chatVideoBody => 'Choisissez une vidéo sur votre appareil.';

  @override
  String get chatMovie => 'Film';

  @override
  String get chatMovieBody => 'Cherchez un film et partagez-le en carte.';

  @override
  String get chatPoll => 'Sondage';

  @override
  String get chatPollBody => 'Posez une question au groupe.';

  @override
  String get chatSendPhoto => 'Envoyer la photo';

  @override
  String get chatSendVideo => 'Envoyer la vidéo';

  @override
  String get chatShareMovie => 'Partager le film';

  @override
  String get chatNewPoll => 'Nouveau sondage';

  @override
  String get chatCaption => 'Ajouter une légende';

  @override
  String get chatPollQuestion => 'Posez une question';

  @override
  String chatPollOption(int number) {
    return 'Option $number';
  }

  @override
  String get chatAddOption => 'Ajouter une option';

  @override
  String get chatAllowedReactions => 'Réactions autorisées sur ce post';

  @override
  String get chatAllowedReactionsBody =>
      'Les membres peuvent réagir avec les emoji choisis. Ils maintiennent un message pour les voir.';

  @override
  String get chatPollInvalid => 'Ajoutez une question et au moins deux options';

  @override
  String get chatFileTooBig => 'Ce fichier est trop lourd (12 Mo max)';

  @override
  String get chatSearchMovie => 'Chercher un film';

  @override
  String get chatSearchMovieHint => 'Titre du film';

  @override
  String get chatNoMovie => 'Aucun film trouvé.';

  @override
  String chatVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '1 vote',
    );
    return '$_temp0';
  }

  @override
  String get chatPlayVideo => 'Lire la vidéo';

  @override
  String get chatGif => 'GIF';

  @override
  String get chatSticker => 'Sticker';

  @override
  String get chatTabEmoji => 'Emoji';

  @override
  String get chatTabGif => 'GIF';

  @override
  String get chatTabStickers => 'Stickers';

  @override
  String get chatSearchEmoji => 'Trouvez l\'emoji parfait';

  @override
  String get chatSearchGif => 'Chercher des GIF';

  @override
  String get chatSearchStickers => 'Chercher des stickers';

  @override
  String chatNothingFound(String query) {
    return 'Rien trouvé pour « $query ».';
  }

  @override
  String get chatCatFrequent => 'Utilisés souvent';

  @override
  String get chatCatFaces => 'Visages';

  @override
  String get chatCatHands => 'Mains';

  @override
  String get chatCatObjects => 'Objets';

  @override
  String get chatCatSymbols => 'Symboles';

  @override
  String get chatClosePicker => 'Fermer le panneau';

  @override
  String sysPinned(String name) {
    return '$name a épinglé un message';
  }

  @override
  String sysRemoved(String name, String target) {
    return '$name a retiré $target du groupe';
  }

  @override
  String sysLeft(String name) {
    return '$name a quitté le groupe';
  }

  @override
  String sysHeritage(String name, String target) {
    return '$name a fait de $target le créateur héritier';
  }

  @override
  String sysPassed(String name, String target) {
    return '$name a passé le rôle de créateur à $target et est parti';
  }

  @override
  String sysVoteStarted(String name) {
    return '$name a lancé un vote pour garder ce groupe';
  }

  @override
  String sysVoteCancelled(String name) {
    return '$name a annulé le vote';
  }

  @override
  String get sysVoteKeep =>
      'La majorité veut garder le groupe. Choisissez maintenant un nouveau propriétaire.';

  @override
  String sysVoteOwnerWon(String target) {
    return '$target a gagné le vote et devient créateur héritier';
  }

  @override
  String get voteKeepTitle => 'Garder ce groupe ?';

  @override
  String voteKeepBody(String name, String time) {
    return '$name veut partir. Il reste $time pour voter. La majorité décide ; en cas d\'égalité, le groupe reste.';
  }

  @override
  String get voteStay => 'Garder';

  @override
  String get voteDelete => 'Supprimer';

  @override
  String voteKeepTally(int stay, int delete) {
    return 'Garder $stay · Supprimer $delete';
  }

  @override
  String get voteOwnPoll => 'Vous ne pouvez pas voter à votre propre sondage.';

  @override
  String get voteCancel => 'Annuler le vote et rester créateur';

  @override
  String get voteOwnerTitle => 'Qui doit gérer ce groupe ?';

  @override
  String voteOwnerBody(String time) {
    return 'Le groupe reste. Choisissez un autre membre que vous. Il reste $time.';
  }

  @override
  String get voteOwnerHint => 'Touchez un membre pour voter.';

  @override
  String get voteOwnerChange =>
      'Vous pouvez changer votre vote jusqu\'à la fin.';

  @override
  String voteTimeLeft(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get voteRunning => 'Un vote est déjà en cours';

  @override
  String get leaveCreatorTitle => 'Vous avez créé ce groupe';

  @override
  String get leaveCreatorBody =>
      'Avant de partir, choisissez ce que devient le groupe.';

  @override
  String get leavePass => 'Passer le rôle de créateur';

  @override
  String get leavePassBody =>
      'Choisissez un membre. Il prend la main tout de suite.';

  @override
  String get leaveVote => 'Laisser le groupe décider';

  @override
  String get leaveVoteBody =>
      'Les membres votent pour garder ou supprimer le groupe, puis pour son propriétaire. Chaque vote dure 24 heures.';

  @override
  String get leavePickTitle => 'Qui prend la relève ?';

  @override
  String get leavePickBody =>
      'Il obtient le rôle de créateur héritier et garde signaler, partager et booster.';

  @override
  String get leaveContinue => 'Continuer';

  @override
  String leavePassConfirmTitle(String name) {
    return 'Passer le rôle à $name et partir ?';
  }

  @override
  String leavePassConfirmBody(String name) {
    return '$name devient créateur héritier tout de suite. Vous quitterez le groupe.';
  }

  @override
  String get leavePassConfirm => 'Passer le rôle et partir';

  @override
  String get leaveVoteConfirmTitle => 'Lancer le vote du groupe ?';

  @override
  String get leaveVoteConfirmBody =>
      'Étape 1 : les membres votent 24 heures pour garder ou supprimer le groupe. Si la majorité garde, l\'étape 2 leur fait choisir le nouveau propriétaire pendant 24 heures. Vous restez créateur jusqu\'à la fin.';

  @override
  String get leaveVoteConfirm => 'Lancer le vote';

  @override
  String leaveSimpleTitle(String group) {
    return 'Quitter $group ?';
  }

  @override
  String get leaveSimpleBody =>
      'Vous ne verrez plus les messages de ce groupe.';

  @override
  String confirmType(String name) {
    return 'Pour confirmer, tapez $name';
  }

  @override
  String get groupInfoSearch => 'Chercher des membres';

  @override
  String groupInfoNoMatch(String query) {
    return 'Aucun membre ne correspond à « $query ».';
  }

  @override
  String get groupInfoHeritage => 'Créateur héritier';

  @override
  String memberViewProfileBody(String name) {
    return 'Voir les films et collections de $name.';
  }

  @override
  String get memberMakeHeritage => 'Nommer créateur héritier';

  @override
  String memberMakeHeritageBody(String name) {
    return '$name prend la main sur le groupe. Vous devenez un membre normal.';
  }

  @override
  String get memberRemove => 'Retirer du groupe';

  @override
  String memberRemoveBody(String name) {
    return '$name perd l\'accès au groupe et à ses messages.';
  }

  @override
  String memberMakeHeritageTitle(String name) {
    return 'Nommer $name créateur héritier ?';
  }

  @override
  String memberMakeHeritageConfirmBody(String name) {
    return '$name obtient le rôle de créateur héritier et peut signaler, partager et booster le groupe. Vous restez dans le groupe comme membre normal.';
  }

  @override
  String memberRemoveTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String memberRemoveConfirmBody(String name, String group) {
    return '$name perdra l\'accès à $group et ne verra plus les nouveaux messages.';
  }

  @override
  String memberRemoveConfirm(String name) {
    return 'Retirer $name';
  }

  @override
  String get chatVideoFailed => 'Impossible de lire cette vidéo.';

  @override
  String get chatPauseVideo => 'Mettre en pause';

  @override
  String get chatFullScreen => 'Plein écran';

  @override
  String get chatMute => 'Mettre en sourdine';

  @override
  String get chatUnmute => 'Réactiver le son';

  @override
  String get chatMutedToast => 'Discussion en sourdine';

  @override
  String get chatUnmutedToast => 'Son réactivé';

  @override
  String get chatPinChat => 'Épingler en haut';

  @override
  String get chatUnpinChat => 'Désépingler';

  @override
  String get chatMarkUnread => 'Marquer comme non lu';

  @override
  String get chatMarkRead => 'Marquer comme lu';

  @override
  String get chatClearHistory => 'Effacer l\'historique';

  @override
  String get chatClearTitle => 'Effacer l\'historique ?';

  @override
  String get chatClearBody =>
      'Tous les messages jusqu\'ici disparaissent pour vous. Les autres les voient toujours.';

  @override
  String get chatCleared => 'Historique effacé';

  @override
  String get chatDeleteChat => 'Supprimer la discussion';

  @override
  String get chatDeleteChatTitle => 'Supprimer cette discussion ?';

  @override
  String chatDeleteChatBody(String name) {
    return 'Elle quitte votre boîte et son historique est effacé pour vous. Elle revient si $name écrit à nouveau.';
  }

  @override
  String get chatChatDeleted => 'Discussion supprimée';

  @override
  String chatBlock(String name) {
    return 'Bloquer $name';
  }

  @override
  String chatUnblock(String name) {
    return 'Débloquer $name';
  }

  @override
  String chatBlockTitle(String name) {
    return 'Bloquer $name ?';
  }

  @override
  String get chatBlockBody =>
      'Aucun de vous ne pourra écrire à l\'autre tant que vous ne le débloquez pas. Il ne sera pas prévenu.';

  @override
  String chatBlockedToast(String name) {
    return '$name est bloqué';
  }

  @override
  String chatUnblockedToast(String name) {
    return '$name est débloqué';
  }

  @override
  String chatYouBlocked(String name) {
    return 'Vous avez bloqué $name.';
  }

  @override
  String get chatBlockedYou =>
      'Vous ne pouvez pas répondre à cette discussion.';

  @override
  String get chatBlockedPeople => 'Personnes bloquées';

  @override
  String get chatNoBlocked => 'Vous n\'avez bloqué personne.';

  @override
  String get chatUnblockShort => 'Débloquer';

  @override
  String get chatCopy => 'Copier le texte';

  @override
  String get chatCopied => 'Copié';

  @override
  String get chatEdit => 'Modifier';

  @override
  String get chatEditing => 'Modification du message';

  @override
  String get chatCancelEdit => 'Annuler la modification';

  @override
  String get chatDeleteMessage => 'Supprimer';

  @override
  String get chatDeleteMessageTitle => 'Supprimer ce message ?';

  @override
  String get chatDeleteMessageBody =>
      'Il est supprimé pour tout le monde dans la discussion.';

  @override
  String get chatMessageDeleted => 'Ce message a été supprimé';

  @override
  String get chatEdited => 'modifié';

  @override
  String get chatReportMessage => 'Signaler le message';

  @override
  String get chatReportHate => 'Discours haineux';

  @override
  String get chatReportNsfw => 'Contenu sexuel';

  @override
  String get chatSeen => 'Vu';

  @override
  String get chatAddMembers => 'Ajouter des membres';

  @override
  String chatAddMembersTitle(String name) {
    return 'Ajouter à $name';
  }

  @override
  String get chatAddMembersNone => 'Tous vos amis sont déjà là.';

  @override
  String get chatAddSelected => 'Ajouter';

  @override
  String get chatMembersAdded => 'Membres ajoutés';

  @override
  String get chatConfirm => 'Confirmer';

  @override
  String get chatViewProfileMenu => 'Voir le profil';

  @override
  String inboxChatOptions(String name) {
    return 'Options pour $name';
  }

  @override
  String get inboxPinnedLabel => 'Épinglée';

  @override
  String get inboxMutedLabel => 'En sourdine';

  @override
  String sysAdded(String name, String target) {
    return '$name a ajouté $target';
  }

  @override
  String get homeTopicFirstReply => 'Soyez le premier à répondre';

  @override
  String get homeFriendsActivityTitle => 'Activité des amis';

  @override
  String get homeFriendsActivityResize => 'Redimensionner l\'activité des amis';

  @override
  String get topicTitleHint => 'Titre (facultatif)';

  @override
  String get topicSeeMore => 'Voir plus';

  @override
  String get topicCommentsExpand => 'Agrandir les commentaires';

  @override
  String get topicCommentsShrink => 'Réduire les commentaires';

  @override
  String get chatTakeShared => 'A partagé un avis';

  @override
  String get chatTopicShared => 'A partagé un sujet';

  @override
  String get chatTaggedYou => 'Vous a identifié dans un commentaire';

  @override
  String get chatYouTagged => 'Vous l’avez identifié dans un commentaire';

  @override
  String get chatTaggedThem => 'L’a identifié dans un commentaire';

  @override
  String get chatYouSharedTopic => 'Vous avez partagé un sujet';

  @override
  String get chatYouSharedTake => 'Vous avez partagé un avis';

  @override
  String get commentAddPhoto => 'Ajouter une photo';

  @override
  String get commentRemovePhoto => 'Retirer la photo';

  @override
  String get takeFeltLabel => 'Ressenti';

  @override
  String homeEditList(String list) {
    return 'Modifier $list';
  }

  @override
  String get homeEditListAdd => 'Ajouter un film';

  @override
  String homeEditListRemove(String title) {
    return 'Retirer $title';
  }

  @override
  String get homeEditListEmpty => 'Aucun film pour l\'instant.';

  @override
  String get homeEditListFull =>
      'Votre Top 5 est complet. Retirez un film pour en ajouter un autre.';

  @override
  String get homeWatchedHint => 'Les films que tu as déjà vus';

  @override
  String get homeWatchlistHint => 'Les films que tu veux voir';

  @override
  String get homeLensHint => 'Fais glisser ton doigt sur les affiches';

  @override
  String homeLensOpen(String title) {
    return 'Ouvrir $title';
  }

  @override
  String get homeListMore => 'Plus d\'options';

  @override
  String get homeListShare => 'Partager ta liste';

  @override
  String get homeListRandom => 'Choisir au hasard';

  @override
  String get homeListShuffle => 'Choisir un autre';

  @override
  String homeListShareText(String list) {
    return 'Ma liste $list sur FilmSage :';
  }

  @override
  String get takeHeartLike => 'J\'aime';

  @override
  String takeHeartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j\'aime',
      one: '1 j\'aime',
      zero: 'Aucun j\'aime',
    );
    return '$_temp0';
  }

  @override
  String get myListsTitle => 'Mes listes';

  @override
  String get myListsHint => 'Les listes que tu as créées et publiées';

  @override
  String get friendsListsTitle => 'Listes de tes amis';

  @override
  String get friendsListsHint => 'Ce que tes amis ont rassemblé';

  @override
  String get listNew => 'Nouvelle liste';

  @override
  String get listsEmptyMine =>
      'Crée ta première liste : donne-lui un nom et choisis des films.';

  @override
  String get listCreateTitle => 'Nouvelle liste';

  @override
  String get listNameLabel => 'Nom de la liste';

  @override
  String get listNameHint => 'Meilleurs films de casse';

  @override
  String get listSearchHint => 'Cherche des films à ajouter';

  @override
  String listAddFilm(String title) {
    return 'Ajouter $title';
  }

  @override
  String listRemoveFilm(String title) {
    return 'Retirer $title';
  }

  @override
  String get listPost => 'Publier la liste';

  @override
  String listFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films',
      one: '1 film',
    );
    return '$_temp0';
  }

  @override
  String listBy(String name) {
    return 'Par $name';
  }

  @override
  String get listCommentsTitle => 'Commentaires';

  @override
  String get listCommentHint => 'Ajouter un commentaire';

  @override
  String get listCommentsEmpty =>
      'Pas encore de commentaires. Dis ce que tu penses de cette liste.';

  @override
  String listCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Aucun commentaire',
    );
    return '$_temp0';
  }

  @override
  String get listDelete => 'Supprimer la liste';

  @override
  String get listDeleteConfirm => 'Supprimer cette liste ? C\'est définitif.';

  @override
  String get listCancel => 'Annuler';

  @override
  String get listPostFailed => 'Impossible de publier la liste. Réessaie.';

  @override
  String get listLoadFailed => 'Impossible de charger les listes.';

  @override
  String listPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count films choisis',
      one: '1 film choisi',
      zero: 'Aucun film pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get listSearchEmpty => 'Aucun film trouvé.';

  @override
  String get listSendFailed => 'Envoi impossible. Réessaie.';

  @override
  String get takeActionSave => 'Enregistrer';

  @override
  String get takeActionUnsave => 'Retirer des enregistrés';

  @override
  String get takeSavedToast => 'Enregistré sur ton profil';

  @override
  String get takeUnsavedToast => 'Retiré de tes sujets enregistrés';

  @override
  String get takeSaveFailed => 'Impossible d\'enregistrer. Réessaie.';

  @override
  String get profileSavedTitle => 'Enregistrés';

  @override
  String get profileSavedEmpty =>
      'Les sujets que tu enregistres apparaissent ici.';

  @override
  String get listShare => 'Partager la liste';

  @override
  String listShareText(String name, String owner) {
    return '$name — une liste de $owner sur Film Wise';
  }

  @override
  String get listSave => 'Enregistrer la liste';

  @override
  String get listUnsave => 'Retirer des enregistrées';

  @override
  String get listSavedToast => 'Liste enregistrée sur ton profil';

  @override
  String get listUnsavedToast => 'Liste retirée de tes listes enregistrées';

  @override
  String get listSaveFailed => 'Impossible d\'enregistrer la liste. Réessaie.';

  @override
  String get listEdit => 'Modifier la liste';

  @override
  String get listEditTitle => 'Modifier la liste';

  @override
  String get listSaveChanges => 'Enregistrer les modifications';

  @override
  String get savedListsTitle => 'Listes enregistrées';

  @override
  String get savedListsHint => 'Les listes des autres que tu as gardées';

  @override
  String get listMenuTooltip => 'Plus';

  @override
  String get listShareNoFriends =>
      'Ajoute des amis pour leur envoyer des listes.';

  @override
  String get chatListShared => 'A partagé une liste';

  @override
  String get chatYouSharedList => 'Tu as partagé une liste';

  @override
  String get notificationsMarkAllRead => 'Tout marquer comme lu';

  @override
  String get notificationsTabAll => 'Tout';

  @override
  String get notificationsTabTakes => 'Avis';

  @override
  String get notificationsTabMentions => 'Mentions';

  @override
  String get notificationsTabRequests => 'Demandes';

  @override
  String get notificationsGroupRequests => 'Demandes d\'ami';

  @override
  String get notificationsGroupNew => 'Nouveau';

  @override
  String get notificationsGroupEarlier => 'Plus tôt';

  @override
  String get notificationsNowFriends => 'Vous êtes maintenant amis';

  @override
  String notificationsRequestDeclined(String name) {
    return 'Demande de $name refusée';
  }

  @override
  String get notificationsUndo => 'Annuler';

  @override
  String get notificationsNothingHere => 'Rien ici pour l\'instant.';

  @override
  String get notificationsTimeNow => 'à l\'instant';

  @override
  String notificationsTimeMinutes(int count) {
    return '$count min';
  }

  @override
  String notificationsTimeHours(int count) {
    return '$count h';
  }

  @override
  String get notificationsTimeYesterday => 'Hier';

  @override
  String notificationsTimeDays(int count) {
    return '$count j';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count non lus';
  }
}
