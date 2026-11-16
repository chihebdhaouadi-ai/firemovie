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
  String get homeFriendsFilmsTitle => 'Films de tes amis cette semaine';

  @override
  String get homeFriendsReviewsTitle => 'Dernières critiques de tes amis';

  @override
  String get homeMyTakesTitle => 'Mes critiques';

  @override
  String get homeComingSoon => 'Bientôt disponible';

  @override
  String get homeFriendsReviewsEmpty =>
      'Tes amis n\'ont pas encore publié de critique.';

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
  String get exploreReviewButton => 'Critique';

  @override
  String get exploreSubtitle =>
      'Découvre des critiques, des discussions et des questions sur les films.';

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
  String get exploreFilterReviews => 'Critiques';

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
  String get homeFeedTitle => 'Critiques de tes collections';

  @override
  String get homeFeedEmpty =>
      'Aucune critique sur les films de tes collections pour le moment.';

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
  String get overviewReviewsTitle => 'Critiques';

  @override
  String get overviewAddReviewHint => 'Ajoute une critique…';

  @override
  String get overviewYourReview => 'Ta critique';

  @override
  String get overviewFriendsReviews => 'Critiques de tes amis';

  @override
  String get overviewPopularReviews => 'Critiques populaires';

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
  String get reviewDetailTitle => 'Critiques';

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
    return 'Critique de $name le $date';
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
  String get profileStatReviews => 'Critiques';

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
  String get topicTagReview => 'Critique';

  @override
  String get topicTagQuestion => 'Question';

  @override
  String get topicTagDiscussion => 'Discussion';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint =>
      'Les critiques nécessitent ta réaction au film.';

  @override
  String get topicBodyHint =>
      'Écris ta critique, ta question ou ton sujet de discussion';

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
  String get createWriteReviewTitle => 'Write your review';

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
      'Your review appears on that movie\'s page.';

  @override
  String get createFeelTitle => 'How did it make you feel?';

  @override
  String get createFeelHint => 'Pick one reaction. It shows with your review.';

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
  String get leaderboardSubtitle => 'Classés par réactions à leurs critiques';

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
      other: '$count critiques',
      one: '1 critique',
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
  String get howStep1Title => 'Écrire une critique';

  @override
  String get howStep1Body =>
      'Critiquez n\'importe quel film. Elle apparaît dans Explorer et Amis.';

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
      'Chaque personne ne peut réagir qu\'une fois par critique. Réagir à votre propre critique ne compte pas.';

  @override
  String get howNoteTie =>
      'En cas d\'égalité, le critique qui a atteint le total en premier est mieux classé.';

  @override
  String get howNotePodium =>
      'Les trois premiers portent un cadre de podium (or, bleu, bronze) sur le classement de la période affichée.';

  @override
  String get howLevelsTitle => 'Niveaux et XP';

  @override
  String get howXpReview => 'Écrire une critique';

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
  String get badgeFirstTakeDesc => 'Soyez le premier à critiquer un film.';

  @override
  String get achFilmCriticTitle => 'Critique de films';

  @override
  String achFilmCriticDesc(int count) {
    return 'Écrivez $count critiques.';
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
    return 'Critiquez $count films tunisiens.';
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
  String get authReasonExplore => 'Log in to explore reviews and takes';

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
}
