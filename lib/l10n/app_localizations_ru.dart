// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String homePointsLabel(int points) {
    return 'Баллы: $points';
  }

  @override
  String get homeTop5Title => 'Твой топ-5';

  @override
  String get homeTop5Hint => 'Выбери пять фильмов, которые ты любишь';

  @override
  String get homeTop5AddLabel => 'Добавить фильм в твой топ-5';

  @override
  String get homeCollectionsTitle => 'Коллекции';

  @override
  String get homeTabYou => 'Вы';

  @override
  String get homeTabFriends => 'Друзья';

  @override
  String get homeTabExplore => 'Обзор';

  @override
  String get homeTabFilms => 'Фильмы';

  @override
  String get homePopularTakesTitle => 'Популярные отзывы';

  @override
  String get homeTrendingTopicsTitle => 'Популярные темы';

  @override
  String get homeTrendingEmpty => 'No questions or discussions this week yet.';

  @override
  String get homeLatestArticlesTitle => 'Последние статьи';

  @override
  String get homeUpcomingThisMonthTitle => 'Фильмы, которые скоро выйдут';

  @override
  String upcomingNotOutYet(String title, String date) {
    return '$title ещё не вышел. Премьера: $date.';
  }

  @override
  String get homePopularThisWeekTitle => 'Популярные фильмы';

  @override
  String get homeFriendsFilmsTitle => 'Фильмы друзей за неделю';

  @override
  String get homeFriendsReviewsTitle => 'Последние отзывы друзей';

  @override
  String get homeMyTakesTitle => 'Мои мнения';

  @override
  String get homeComingSoon => 'Скоро';

  @override
  String get homeFriendsReviewsEmpty => 'Друзья ещё не оставили отзывов.';

  @override
  String get homeMyTakesEmpty => 'Ты ещё не делился мнениями.';

  @override
  String get homeUnderConstruction => 'Этот раздел в разработке.';

  @override
  String get exploreSkipStamp => 'ПРОПУСТИТЬ';

  @override
  String get exploreOpenStamp => 'ОТКРЫТЬ';

  @override
  String get exploreCaughtUp => 'Вы всё просмотрели';

  @override
  String get exploreReviewButton => 'Отзыв';

  @override
  String get exploreSubtitle =>
      'Открывай отзывы, обсуждения и вопросы о фильмах.';

  @override
  String get createSceneMovieHint =>
      'Ваша сцена появится в обсуждении этого фильма.';

  @override
  String get createPollQuestionHint => 'Что вы хотите спросить?';

  @override
  String get exploreFilterAll => 'Все';

  @override
  String get exploreFilterConversations => 'Обсуждения';

  @override
  String get exploreFilterPolls => 'Опросы';

  @override
  String get exploreFilterScenes => 'Сцены';

  @override
  String get exploreFilterQuestions => 'Вопросы';

  @override
  String get exploreFilterReviews => 'Отзывы';

  @override
  String get exploreSpoilerReveal => 'Нажмите, чтобы открыть';

  @override
  String get topicTagPoll => 'Опрос';

  @override
  String get topicTagScene => 'Сцена';

  @override
  String get topicSpoilerLabel => 'Есть спойлеры';

  @override
  String get pollVoteHint => 'Нажмите вариант, чтобы проголосовать';

  @override
  String get pollChangeVoteHint =>
      'Нажмите другой вариант, чтобы изменить голос';

  @override
  String pollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count голоса',
      many: '$count голосов',
      few: '$count голоса',
      one: '$count голос',
    );
    return '$_temp0';
  }

  @override
  String get createTypePollSubtitle =>
      'Пусть люди голосуют между 2 и 4 вариантами.';

  @override
  String get createTypeSceneSubtitle =>
      'Выбери один момент из фильма и объясни, почему он работает.';

  @override
  String get createWritePollTitle => 'Напишите вопрос опроса';

  @override
  String get createPollOptionsTitle => 'Добавьте варианты';

  @override
  String get createPollOptionsHint =>
      'Добавьте от 2 до 4 вариантов. Каждый выберет один.';

  @override
  String createPollOptionLabel(int number) {
    return 'Вариант $number';
  }

  @override
  String get createPollAddOption => 'Добавить вариант';

  @override
  String get createPollRemoveOption => 'Удалить вариант';

  @override
  String get createSceneTitle => 'Опишите сцену';

  @override
  String get createSceneNameLabel => 'Сцена';

  @override
  String get createSceneNameHint => 'Комната для допросов';

  @override
  String get createSceneTimecodeLabel => 'Таймкод (необязательно)';

  @override
  String get createSceneTimecodeHint => '1 ч 12 мин';

  @override
  String get createSceneExplainLabel => 'Почему это работает';

  @override
  String get createSceneExplainHint =>
      'Расскажите, что делает этот момент особенным';

  @override
  String exploreRepliesButton(int count) {
    return 'Все ответы: $count';
  }

  @override
  String get exploreStripConversation => 'Беседа';

  @override
  String exploreRepliesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответа',
      many: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
    );
    return '$_temp0';
  }

  @override
  String get exploreNoRepliesYet => 'Ответов пока нет';

  @override
  String get exploreBeFirstRespond => 'Будь первым, кто ответит';

  @override
  String explorePeopleTalking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человека обсуждают',
      many: '$count человек обсуждают',
      few: '$count человека обсуждают',
      one: '$count человек обсуждает',
    );
    return '$_temp0';
  }

  @override
  String exploreLastReply(String time) {
    return 'последний ответ $time';
  }

  @override
  String get exploreNoVotesYet => 'Голосов пока нет';

  @override
  String exploreAgreePercent(int percent) {
    return '$percent% согласны';
  }

  @override
  String exploreDisagreePercent(int percent) {
    return '$percent% не согласны';
  }

  @override
  String get exploreFor => 'За';

  @override
  String get exploreAgainst => 'Против';

  @override
  String exploreBeFirstArgue(String side) {
    return 'Будь первым, кто ответит · $side';
  }

  @override
  String explorePickedBy(String name) {
    return 'выбрал $name';
  }

  @override
  String get exploreThanksVoting => 'Спасибо за голос';

  @override
  String get exploreJoinConversation => 'Присоединиться к беседе';

  @override
  String get homeCollectionsResizeLabel => 'Изменить размер коллекций';

  @override
  String get homeFeedTitle => 'Отзывы из твоих коллекций';

  @override
  String get homeFeedEmpty => 'Пока нет отзывов на фильмы из твоих коллекций.';

  @override
  String get homeFeedShowAsRow => 'Показать в ряд';

  @override
  String get homeFeedShowAsColumn => 'Показать в столбец';

  @override
  String get homeQuickActionsLabel => 'Быстрые действия';

  @override
  String get homeQuickActionSearch => 'Поиск';

  @override
  String get homeQuickActionAddFilm => 'Добавить фильм';

  @override
  String get homeWatchedTitle => 'Просмотрено';

  @override
  String get homeWatchlistTitle => 'Хочу посмотреть';

  @override
  String get homePopularTitle => 'Популярное у друзей';

  @override
  String homeFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фильма',
      many: '$count фильмов',
      few: '$count фильма',
      one: '$count фильм',
    );
    return '$_temp0';
  }

  @override
  String homeAddTileLabel(String section) {
    return 'Добавить в «$section»';
  }

  @override
  String homeFilmTileSemantics(String title, String section) {
    return '$title, $section';
  }

  @override
  String homeRemoveFilm(String title) {
    return 'Удалить $title';
  }

  @override
  String get homeSectionEmptyTitle => 'Здесь пока пусто';

  @override
  String get homeSectionEmptyAction => 'Добавить фильм';

  @override
  String get homeSectionErrorTitle => 'Не удалось загрузить список';

  @override
  String get homeSectionErrorRetry => 'Повторить';

  @override
  String homeRemovedSnackbar(String title) {
    return '$title удалён';
  }

  @override
  String get homeUndo => 'Отменить';

  @override
  String get homeTop5FullSnackbar =>
      'Твой топ-5 заполнен. Сначала удали фильм.';

  @override
  String get homeGenericErrorSnackbar =>
      'Что-то пошло не так. Попробуй ещё раз.';

  @override
  String get findTitleTop5 => 'Добавить в топ-5';

  @override
  String get findTitleWatched => 'Добавить в просмотренные';

  @override
  String get findTitleWatchlist => 'Добавить в «Хочу посмотреть»';

  @override
  String get findTitleSearch => 'Найти фильм';

  @override
  String get findBodySearch => 'Все фильмы';

  @override
  String get findSearchHint => 'Название фильма…';

  @override
  String get findSearchClear => 'Очистить поиск';

  @override
  String get findSearchSubmit => 'Искать';

  @override
  String get findMinCharsTitle => 'Продолжай вводить';

  @override
  String get findMinCharsBody => 'Введи минимум 2 символа для поиска.';

  @override
  String get findLoadingTitle => 'Ищем фильмы…';

  @override
  String findEmptyTitle(String query) {
    return 'Нет результатов по запросу «$query»';
  }

  @override
  String get findEmptyTip1 => 'Проверь написание или попробуй другое название.';

  @override
  String get findEmptyTip2 =>
      'Попробуй более короткое слово или имя режиссёра.';

  @override
  String get findErrorTitle => 'Не удалось выполнить поиск';

  @override
  String get findErrorRetry => 'Повторить';

  @override
  String get findOfflineTitle => 'Нет подключения';

  @override
  String get findOfflineBody => 'Поиск и добавление недоступны без сети.';

  @override
  String get findNoMoreResults => 'Это все результаты';

  @override
  String get findLoadMore => 'Загрузить ещё';

  @override
  String get findRecentTitle => 'Недавние запросы';

  @override
  String get findRecentClear => 'Очистить';

  @override
  String get findRecentSwipeDelete => 'Удалить запрос из истории';

  @override
  String get findRecentEmpty => 'Недавних запросов пока нет.';

  @override
  String get findDirectedBy => 'Режиссёр:';

  @override
  String get findGenreChip => 'Жанр';

  @override
  String get findAddToTop5 => 'Добавить в топ-5';

  @override
  String get findAddToWatched => 'Добавить в просмотренные';

  @override
  String get findAddToWatchlist => 'Добавить в «Хочу посмотреть»';

  @override
  String findResultSemantics(
      String title, String year, String director, String action) {
    return '$title, $year, режиссёр $director. $action';
  }

  @override
  String findAddedSemantics(String title, String target) {
    return '$title уже в списке «$target»';
  }

  @override
  String findResultDetailsAction(String title) {
    return 'Открыть подробности о $title';
  }

  @override
  String get findViewDetails => 'Подробнее';

  @override
  String get findSendToFriend => 'Отправить другу';

  @override
  String findAddedSnackbar(String target) {
    return 'Добавлено в «$target»';
  }

  @override
  String get findUndo => 'Отменить';

  @override
  String findRemovedSnackbar(String target) {
    return 'Удалено из «$target»';
  }

  @override
  String get findMovedToWatched => 'Перенесено в просмотренные';

  @override
  String findReplaceSlotTitle(String current) {
    return 'Заменить $current?';
  }

  @override
  String findReplaceSlotBody(String current, String replacement) {
    return 'Это место уже занято фильмом $current. Заменить его на $replacement?';
  }

  @override
  String get findReplace => 'Заменить';

  @override
  String get findCancel => 'Отмена';

  @override
  String get findTop5FullTitle => 'Топ-5 заполнен';

  @override
  String get findTop5FullBody =>
      'Удали фильм, прежде чем добавлять новый в топ-5.';

  @override
  String get findAlreadyWatchedTitle => 'Уже просмотрено';

  @override
  String get findAlreadyWatchedBody =>
      'Фильм, который ты уже посмотрел, нельзя добавить в «Хочу посмотреть».';

  @override
  String get findAlreadyInListTitle => 'Уже добавлено';

  @override
  String findAlreadyInListBody(String title, String target) {
    return '$title уже в списке «$target».';
  }

  @override
  String get findGenericErrorTitle => 'Что-то пошло не так';

  @override
  String get findGenericErrorBody => 'Попробуй ещё раз.';

  @override
  String get findDetailsErrorTitle => 'Не удалось загрузить фильм';

  @override
  String get findDetailsRetry => 'Повторить';

  @override
  String get findDetailsCast => 'Актёры';

  @override
  String get findDetailsOverview => 'Описание';

  @override
  String findDetailsRuntime(int minutes) {
    return '$minutes мин';
  }

  @override
  String findDetailsVote(String value) {
    return '$value звёзд';
  }

  @override
  String get findWatchNow => 'Смотреть';

  @override
  String get findAttribution =>
      'Данные о фильмах и постеры предоставлены TMDB. Доступность для просмотра — JustWatch.';

  @override
  String get overviewBack => 'Назад';

  @override
  String overviewRating(String value) {
    return '$value / 10';
  }

  @override
  String get overviewNoRating => 'Оценок пока нет';

  @override
  String get overviewWhereToWatch => 'Где посмотреть?';

  @override
  String get overviewNoStreaming => 'Платформы для просмотра не найдены';

  @override
  String overviewRatingsCount(int count) {
    return 'Оценки filmwiser: $count';
  }

  @override
  String overviewStarsValue(String value) {
    return '$value из 5 звёзд';
  }

  @override
  String get overviewTrailer => 'Трейлер';

  @override
  String get overviewNoGenres => 'Жанры не указаны';

  @override
  String get overviewTabGenres => 'ЖАНРЫ';

  @override
  String get overviewTabCast => 'АКТЁРЫ';

  @override
  String get overviewTabCrew => 'СЪЁМОЧНАЯ ГРУППА';

  @override
  String get overviewTabProd => 'ПРОИЗВОДСТВО';

  @override
  String get overviewActivityTitle => 'Активность друзей';

  @override
  String get overviewWantsToWatch => 'Хочет посмотреть';

  @override
  String get overviewNoFriendActivity => 'Пока нет активности друзей.';

  @override
  String get overviewShowMore => 'ещё';

  @override
  String get overviewShowLess => 'свернуть';

  @override
  String get overviewReviewsTitle => 'Отзывы';

  @override
  String get overviewAddReviewHint => 'Написать отзыв...';

  @override
  String get overviewYourReview => 'Твой отзыв';

  @override
  String get overviewFriendsReviews => 'Отзывы друзей';

  @override
  String get overviewPopularReviews => 'Популярные отзывы';

  @override
  String get overviewSeeAll => 'Смотреть все';

  @override
  String get reviewTrustedLabel => 'от доверенных зрителей';

  @override
  String reviewEveryoneTogether(String value) {
    return 'Все вместе: $value';
  }

  @override
  String get reviewMostFelt => 'Сильнее всего:';

  @override
  String get reviewWhatIsTrusted => 'Что значит «доверенный»?';

  @override
  String get reviewTrustedNote =>
      'Зрители получают доверие, когда их мнения признают обоснованными. Их голоса весят немного больше, поэтому оценка выглядит справедливой и взвешенной.';

  @override
  String get reviewReactionTitle => 'Какие эмоции вызвал фильм?';

  @override
  String get reviewReactionHint => 'Выбери подходящий вариант.';

  @override
  String get reviewReactionLoved => 'Понравился';

  @override
  String get reviewReactionBrokeHeart => 'Разбил сердце';

  @override
  String get reviewReactionBlewMind => 'Взорвал мозг';

  @override
  String get reviewReactionMadeCry => 'Заставил плакать';

  @override
  String get reviewReactionShocked => 'Шокировал';

  @override
  String get reviewReactionMadeLaugh => 'Заставил смеяться';

  @override
  String get reviewReactionBored => 'Скучный';

  @override
  String get reviewReactionDisappointed => 'Разочаровал';

  @override
  String get reviewReactionMadeThink => 'Заставил задуматься';

  @override
  String get reviewReactionMasterpiece => 'Шедевр';

  @override
  String get reviewReactionTapToReact => 'Нажми, чтобы отреагировать';

  @override
  String get reviewReactionChange => 'Изменить';

  @override
  String get reviewReactionPickOne => 'Выбери вариант';

  @override
  String get reviewReactionClose => 'Закрыть';

  @override
  String get reviewWhyPrompt =>
      'Хочешь добавить пару слов, почему? Это необязательно.';

  @override
  String get reviewWhyHint => 'Что тебя задело?';

  @override
  String get reviewShare => 'Поделиться';

  @override
  String get reviewNoThanks => 'Нет, спасибо';

  @override
  String get reviewSharedThanks => 'Спасибо за мнение!';

  @override
  String get reviewCountedThanks => 'Спасибо! Твоя реакция учтена.';

  @override
  String get reviewReactionFailed =>
      'Не удалось сохранить реакцию. Попробуй ещё раз.';

  @override
  String get reviewSummaryFailed => 'Не удалось загрузить реакции.';

  @override
  String get reviewDetailTitle => 'Отзывы';

  @override
  String get reviewTakesTitle => 'Что говорят люди';

  @override
  String get reviewTakesHint => 'Короткие мнения других зрителей.';

  @override
  String get reviewMostHelpful => 'Самое полезное мнение';

  @override
  String get sageNavUnread => 'Есть непрочитанные';

  @override
  String get sageNavCloseMenu => 'Закрыть меню';

  @override
  String get reviewWriterBadge => 'Автор';

  @override
  String reviewCommentsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
      zero: 'Комментарий',
    );
    return '$_temp0';
  }

  @override
  String get reviewCommentHint => 'Напиши комментарий';

  @override
  String get reviewSend => 'Отправить';

  @override
  String get reviewCommentsFailed => 'Не удалось загрузить комментарии.';

  @override
  String get reviewCommentFailed =>
      'Не удалось отправить комментарий. Попробуй ещё раз.';

  @override
  String get reviewReply => 'Ответить';

  @override
  String reviewReplyingTo(String name) {
    return 'Ответ для $name';
  }

  @override
  String get reviewCancelReply => 'Отменить ответ';

  @override
  String reviewShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показать $count ответа',
      many: 'Показать $count ответов',
      few: 'Показать $count ответа',
      one: 'Показать $count ответ',
    );
    return '$_temp0';
  }

  @override
  String get reviewHideReplies => 'Скрыть ответы';

  @override
  String get reviewTimeJustNow => 'Только что';

  @override
  String reviewTimeMinutes(int count) {
    return '$count мин назад';
  }

  @override
  String reviewTimeHours(int count) {
    return '$count ч назад';
  }

  @override
  String reviewTimeDays(int count) {
    return '$count д назад';
  }

  @override
  String get reviewVoteChangedMyMind => 'Мнение изменилось';

  @override
  String get reviewVoteWellArgued => 'Хорошо аргументировано';

  @override
  String get reviewVoteDisagreeFair => 'Не согласен, но справедливо';

  @override
  String get reviewVoteFailed =>
      'Не удалось засчитать голос. Попробуй ещё раз.';

  @override
  String get reviewTakeFailed => 'Не удалось опубликовать. Попробуй ещё раз.';

  @override
  String get reviewTakesEmpty => 'Мнений пока нет.';

  @override
  String get reviewTakesFailed => 'Не удалось загрузить мнения.';

  @override
  String get reviewRetry => 'Попробовать снова';

  @override
  String overviewReviewBy(String name, String date) {
    return 'Отзыв от $name, $date';
  }

  @override
  String get homeOpenProfile => 'Открыть профиль';

  @override
  String get profileBack => 'Назад';

  @override
  String get profileSearchTooltip => 'Поиск';

  @override
  String get profileMoreTooltip => 'Ещё';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileFollowers => 'Подписчики';

  @override
  String get profileFollowing => 'Подписки';

  @override
  String get profileBioHint => 'Измени описание…';

  @override
  String get profileChat => 'Чат';

  @override
  String get profileFollow => 'Подписаться';

  @override
  String get profileSend => 'Отправить';

  @override
  String get profileAchievementsTitle => 'Достижения';

  @override
  String get profileAchievementRookie => 'НОВИЧОК КИНОМАНА';

  @override
  String get profileAchievementMaster => 'МАСТЕР КИНОМАНА';

  @override
  String get profileAchievementLegend => 'ЛЕГЕНДА КИНОМАНА';

  @override
  String profileAchievementFilms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фильма',
      many: '$count фильмов',
      few: '$count фильма',
      one: '$count фильм',
    );
    return '$_temp0';
  }

  @override
  String get profileClaim => 'Получить';

  @override
  String get profileStatisticsTitle => 'Статистика';

  @override
  String get profileStatWatched => 'Просмотрено';

  @override
  String get profileStatWatchlist => 'Хочу посмотреть';

  @override
  String get profileStatReviews => 'Отзывы';

  @override
  String get profileStatRewards => 'Награды';

  @override
  String get profileBlockTitle => 'Заблокировать этого пользователя?';

  @override
  String get profileBlockReasonHint => 'Почему?…';

  @override
  String get profileBlockYes => 'Да';

  @override
  String get profileBlockNo => 'Нет';

  @override
  String get profileErrorTitle => 'Не удалось загрузить профиль.';

  @override
  String get profileRetry => 'Попробовать снова';

  @override
  String get profileLanguageButton => 'Управление языками';

  @override
  String get profileLanguageDialogTitle => 'Язык приложения';

  @override
  String get profileLanguageSystem => 'Как в системе';

  @override
  String get onboardingFinishLater => 'Завершить позже';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingFinish => 'Готово';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingSaveFailed =>
      'Не удалось сохранить. Проверь подключение и попробуй ещё раз.';

  @override
  String get onboardingAvatarTitle => 'Добавь фото профиля';

  @override
  String get onboardingAvatarBody =>
      'Выбери фото, чтобы люди могли тебя узнать. JPG, PNG или WebP, до 5 МБ.';

  @override
  String get onboardingChoosePhoto => 'Выбрать фото';

  @override
  String get onboardingPhotoSaved => 'Фото профиля сохранено';

  @override
  String get onboardingCoverTitle => 'Добавь обложку';

  @override
  String get onboardingCoverBody =>
      'Широкое изображение за шапкой твоего профиля.';

  @override
  String get onboardingChooseCover => 'Выбрать обложку';

  @override
  String get onboardingCoverSaved => 'Обложка сохранена';

  @override
  String get onboardingBioTitle => 'Напиши короткое описание';

  @override
  String get onboardingBioBody => 'Расскажи, какие фильмы ты любишь.';

  @override
  String get onboardingBioHint => 'Несколько слов о твоём вкусе в кино';

  @override
  String get onboardingTop5Title => 'Выбери свой топ-5 фильмов';

  @override
  String get onboardingTop5Body =>
      'Твои любимые фильмы будут показаны первыми в профиле.';

  @override
  String onboardingTop5Progress(int count) {
    return 'Выбрано $count из 5';
  }

  @override
  String get onboardingWatchedTitle => 'Добавь просмотренные фильмы';

  @override
  String get onboardingWatchedBody =>
      'Отметь фильмы, которые ты уже посмотрел.';

  @override
  String get onboardingWatchlistTitle => 'Добавь фильмы к просмотру';

  @override
  String get onboardingWatchlistBody =>
      'Сохрани фильмы, которые планируешь посмотреть.';

  @override
  String onboardingFilmsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count фильма',
      many: 'Добавлено $count фильмов',
      few: 'Добавлено $count фильма',
      one: 'Добавлен $count фильм',
    );
    return '$_temp0';
  }

  @override
  String get onboardingSearchFilms => 'Поиск фильмов';

  @override
  String get profileNotificationsTooltip => 'Уведомления';

  @override
  String get profileEditPhoto => 'Изменить фото';

  @override
  String get profileEditCover => 'Изменить обложку';

  @override
  String get profileEditBio => 'Изменить описание';

  @override
  String get profileEditBioTitle => 'Изменить описание';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profileCancel => 'Отмена';

  @override
  String get profileSaveFailed => 'Не удалось сохранить. Попробуй ещё раз.';

  @override
  String get profileNoConnections => 'Пока никого нет.';

  @override
  String get friendAdd => 'Добавить в друзья';

  @override
  String get friendCancelRequest => 'Отменить запрос';

  @override
  String get friendAccept => 'Принять';

  @override
  String get friendDecline => 'Отклонить';

  @override
  String get friendFriends => 'Друзья';

  @override
  String get friendRequestSent => 'Запрос в друзья отправлен.';

  @override
  String get friendActionFailed =>
      'Не удалось обновить запрос в друзья. Попробуй ещё раз.';

  @override
  String get friendRequestGone => 'Этот запрос больше недоступен.';

  @override
  String get friendAlreadyConnected =>
      'Уже в друзьях или запрос ожидает ответа.';

  @override
  String get searchPeopleTitle => 'Найти людей';

  @override
  String get searchPeopleHint => 'Поиск по имени пользователя';

  @override
  String get searchPeopleMinChars => 'Введи минимум 2 символа.';

  @override
  String get searchPeopleEmpty => 'Пользователи не найдены.';

  @override
  String get searchPeopleFailed =>
      'Не удалось выполнить поиск. Попробуй ещё раз.';

  @override
  String get suggestMovieAction => 'Предложить фильм';

  @override
  String get suggestionTitle => 'Предложить фильм';

  @override
  String get suggestionSearchHint => 'Поиск названия фильма';

  @override
  String get suggestionSearchMinChars => 'Введи минимум 2 символа.';

  @override
  String get suggestionSearchEmpty => 'Фильмы не найдены.';

  @override
  String get suggestionSearchFailed =>
      'Не удалось выполнить поиск. Попробуй ещё раз.';

  @override
  String get suggestionMovieSection => 'Фильм';

  @override
  String get suggestionPickMovie => 'Выбери фильм для предложения.';

  @override
  String get suggestionChangeMovie => 'Изменить фильм';

  @override
  String get suggestionRecipientsSection => 'Кому отправить';

  @override
  String get suggestionSelectAll => 'Выбрать всех';

  @override
  String get suggestionNoFriends =>
      'Сначала добавь друзей, чтобы отправлять им предложения.';

  @override
  String get suggestionFriendsFailed => 'Не удалось загрузить друзей.';

  @override
  String get suggestionCommentHint => 'Комментарий (необязательно)';

  @override
  String get suggestionSend => 'Отправить предложение';

  @override
  String get suggestionSent => 'Предложение отправлено.';

  @override
  String get suggestionFailed =>
      'Не удалось отправить предложение. Попробуй ещё раз.';

  @override
  String get suggestionNotFriends =>
      'Фильмы можно предлагать только друзьям. Измени выбор и попробуй снова.';

  @override
  String notificationMovieSuggestion(String name, String title) {
    return '$name предлагает тебе фильм $title.';
  }

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Уведомлений пока нет.';

  @override
  String get notificationsFailed => 'Не удалось загрузить уведомления.';

  @override
  String notificationFriendRequest(String name) {
    return 'Запрос в друзья от $name.';
  }

  @override
  String notificationFriendAccepted(String name) {
    return 'Запрос в друзья от $name принят.';
  }

  @override
  String get angelBirdQuestion =>
      'Хочешь участвовать в дебатах о одном из твоих топ-5 фильмов? Сообщество Sage хотело бы услышать твоё мнение.';

  @override
  String get angelBirdYes => 'Да, давай поспорим';

  @override
  String get angelBirdNotNow => 'Не сейчас';

  @override
  String get angelBirdPickFilm => 'Выбери фильм для дебатов';

  @override
  String get angelBirdEmptyTop5 =>
      'Твой топ-5 пуст. Добавь пять фильмов, чтобы начать дебаты.';

  @override
  String get angelBirdLoadFailed => 'Не удалось загрузить твой топ-5.';

  @override
  String get angelBirdRetry => 'Попробовать снова';

  @override
  String get angelBirdReviewQuestion =>
      'Хочешь начать дебаты об этом отзыве? Выбери собеседника из этой переписки.';

  @override
  String get angelBirdPickPerson => 'С кем ты хочешь поспорить?';

  @override
  String get angelBirdNoPeople =>
      'Пока не с кем спорить. Дождись комментария к этому отзыву.';

  @override
  String get angelBirdPeopleFailed =>
      'Не удалось загрузить участников этого отзыва.';

  @override
  String debateWaitingTitle(String name) {
    return 'Ждём $name';
  }

  @override
  String debateWaitingBody(String name) {
    return 'Приглашение отправлено. Дебаты начнутся, как только $name его примет.';
  }

  @override
  String debateDeclined(String name) {
    return '$name сейчас не может участвовать. Попробуй кого-то другого из переписки.';
  }

  @override
  String get debateInviteFailed =>
      'Не удалось отправить приглашение. Попробуй ещё раз.';

  @override
  String get debateLoadFailed =>
      'Не удалось загрузить вопросы. Попробуй ещё раз.';

  @override
  String get debateSubmitFailed =>
      'Не удалось отправить ответы. Попробуй ещё раз.';

  @override
  String get debateRetry => 'Попробовать снова';

  @override
  String get debateCancel => 'Отмена';

  @override
  String get debateDone => 'Готово';

  @override
  String debateVsTitle(String name) {
    return 'Ты против $name';
  }

  @override
  String debateQuestionCounter(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get debateResultWon => 'Победа в дебатах!';

  @override
  String debateResultLost(String name) {
    return 'В этом раунде победа у $name.';
  }

  @override
  String get debateResultTied => 'Ничья.';

  @override
  String debateScoreLine(int mine, String name, int theirs) {
    return 'Ты $mine · $name $theirs';
  }

  @override
  String debateSagePointsWon(int points) {
    return '+$points очков Sage';
  }

  @override
  String debateSagePointsLost(int points, String name) {
    return '$points очков Sage достаются $name.';
  }

  @override
  String get authTagline => 'РАСКРОЙ В СЕБЕ КИНОМАНА';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authNoAccountPrompt => 'Нет аккаунта?';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authPasswordsMismatch => 'Пароли не совпадают';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authUsername => 'Имя пользователя';

  @override
  String get authRepeatPassword => 'Повтори пароль';

  @override
  String get authHaveAccountPrompt => 'Уже есть аккаунт?';

  @override
  String get authEmailRequired => 'Введи адрес эл. почты';

  @override
  String get authEmailInvalid => 'Введи корректный адрес эл. почты';

  @override
  String get authPasswordRequired => 'Введи пароль';

  @override
  String get authPasswordTooShort => 'Пароль должен быть не короче 6 символов';

  @override
  String get authUsernameRequired => 'Введи имя пользователя';

  @override
  String get authUsernameTooShort =>
      'Имя пользователя должно быть не короче 6 символов';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authAccountCreated => 'Аккаунт создан. Войди, чтобы продолжить.';

  @override
  String get authOr => 'или';

  @override
  String get authContinueWithApple => 'Продолжить с Apple';

  @override
  String get authContinueWithGoogle => 'Продолжить с Google';

  @override
  String get authContinueWithReddit => 'Продолжить с Reddit';

  @override
  String get authWelcomeBack => 'С возвращением';

  @override
  String get authSignInSubtitle =>
      'Войдите, чтобы продолжить с того места, где остановились.';

  @override
  String get authCreateAccountSubtitle =>
      'Присоединяйтесь к сообществу и делитесь своими мнениями о фильмах.';

  @override
  String get authMinLengthHint => 'Не менее 6 символов';

  @override
  String get authErrorInvalidCredentials =>
      'Неверная почта или пароль. Попробуй ещё раз.';

  @override
  String get authErrorRegisterFailed =>
      'Не удалось создать аккаунт. Попробуй ещё раз.';

  @override
  String get authErrorNetwork =>
      'Не удалось связаться с сервером. Проверь подключение и попробуй ещё раз.';

  @override
  String get appWindowTitle => 'Моё приложение';

  @override
  String get findActionAdd => 'Добавить';

  @override
  String get findActionAdded => 'Добавлено';

  @override
  String get reviewTranslate => 'Перевести';

  @override
  String get reviewShowOriginal => 'Показать оригинал';

  @override
  String get reviewTranslateFailed => 'Не удалось перевести. Попробуй ещё раз.';

  @override
  String reviewQuote(String body) {
    return '«$body»';
  }

  @override
  String get exploreCreateButton => 'Создать';

  @override
  String get topicCreateTitle => 'Создать тему';

  @override
  String get topicFindMovie => 'Найти фильм';

  @override
  String get topicSearchHint => 'Поиск фильмов';

  @override
  String get topicNoResults => 'Фильмы не найдены';

  @override
  String get topicChangeMovie => 'Изменить';

  @override
  String get topicTypeLabel => 'Тип';

  @override
  String get topicTagReview => 'Отзыв';

  @override
  String get topicTagQuestion => 'Вопрос';

  @override
  String get topicTagDiscussion => 'Обсуждение';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint => 'Для отзыва нужна твоя реакция на фильм.';

  @override
  String get topicBodyHint => 'Напиши отзыв, вопрос или тему для обсуждения';

  @override
  String get topicPostButton => 'Опубликовать';

  @override
  String get topicPostFailed => 'Не удалось опубликовать. Попробуй ещё раз.';

  @override
  String get topicSearchFailed => 'Поиск не удался. Попробуй ещё раз.';

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
  String get leaderboardTabLabel => 'Рейтинг';

  @override
  String get leaderboardTitle => 'Лучшие рецензенты';

  @override
  String get leaderboardSubtitle => 'Рейтинг по реакциям на их рецензии';

  @override
  String get leaderboardHowItWorks => 'Как это работает';

  @override
  String get leaderboardPeriodWeek => 'Эта неделя';

  @override
  String get leaderboardPeriodMonth => 'Этот месяц';

  @override
  String get leaderboardPeriodAll => 'За всё время';

  @override
  String get leaderboardReactionsLabel => 'реакций';

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
      other: '$count рецензии',
      many: '$count рецензий',
      few: '$count рецензии',
      one: '$count рецензия',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardYouSuffix => '(вы)';

  @override
  String get leaderboardEmpty => 'Пока нет реакций за этот период.';

  @override
  String get leaderboardLoadFailed => 'Не удалось загрузить рейтинг.';

  @override
  String get leaderboardRetry => 'Повторить';

  @override
  String get howRankingTitle => 'Как работает рейтинг';

  @override
  String get howStep1Title => 'Напишите рецензию';

  @override
  String get howStep1Body =>
      'Напишите рецензию на любой фильм. Она появится в разделах «Обзор» и «Друзья».';

  @override
  String get howStep2Title => 'Соберите реакции';

  @override
  String get howStep2Body =>
      'Читатели реагируют на вашу рецензию. Каждая реакция стоит одно очко.';

  @override
  String get howStep3Title => 'Поднимайтесь в рейтинге';

  @override
  String get howStep3Body =>
      'Рецензенты с наибольшим числом реакций за период займут пьедестал.';

  @override
  String get howNoteReset =>
      'Эта неделя сбрасывается каждый понедельник в 00:00. «Этот месяц» и «За всё время» продолжают считаться.';

  @override
  String get howNoteOncePerReview =>
      'Каждый может отреагировать один раз на рецензию. Реакция на собственную рецензию не засчитывается.';

  @override
  String get howNoteTie =>
      'Если у двух рецензентов равный счёт, выше тот, кто первым набрал это число.';

  @override
  String get howNotePodium =>
      'Первые три получают рамку пьедестала (золото, синий, бронза) в рейтинге за выбранный период.';

  @override
  String get howLevelsTitle => 'Уровни и XP';

  @override
  String get howXpReview => 'Написать рецензию';

  @override
  String get howXpComment => 'Написать комментарий';

  @override
  String get howXpReaction => 'Получить реакцию';

  @override
  String howXpValue(int xp) {
    return '+$xp XP';
  }

  @override
  String get howLevelFoot =>
      'Каждому следующему уровню нужно на 50 XP больше, чем предыдущему.';

  @override
  String get profileBadgesTitle => 'Значки';

  @override
  String get badgeWellArguedTitle => 'Убедительно';

  @override
  String badgeWellArguedDesc(int count) {
    return 'Получите $count реакций «Убедительно».';
  }

  @override
  String get badgeChangedMindTitle => 'Я передумал';

  @override
  String badgeChangedMindDesc(int count) {
    return 'Получите $count реакций «Я передумал».';
  }

  @override
  String get badgeDisagreeTitle => 'Не согласен, но справедливо';

  @override
  String badgeDisagreeDesc(int count) {
    return 'Получите $count реакций «Не согласен, но справедливо».';
  }

  @override
  String get badgeTopCriticTitle => 'Лучший критик';

  @override
  String get badgeTopCriticDesc => 'Попадите в топ-3 недели.';

  @override
  String get badgeFirstTakeTitle => 'Первый отзыв';

  @override
  String get badgeFirstTakeDesc =>
      'Станьте первым, кто оставит рецензию на фильм.';

  @override
  String get achFilmCriticTitle => 'Киновед';

  @override
  String achFilmCriticDesc(int count) {
    return 'Напишите $count рецензий.';
  }

  @override
  String get achDebaterTitle => 'Спорщик';

  @override
  String achDebaterDesc(int count) {
    return 'Получите $count реакций «Убедительно».';
  }

  @override
  String get achLocalCinemaTitle => 'Местное кино';

  @override
  String achLocalCinemaDesc(int count) {
    return 'Напишите рецензии на $count тунисских фильмов.';
  }

  @override
  String get achComingSoon => 'Скоро';

  @override
  String get frameNewcomerTitle => 'Новичок';

  @override
  String get frameExplorerTitle => 'Исследователь';

  @override
  String get frameDebaterTitle => 'Спорщик';

  @override
  String get frameTopCriticTitle => 'Лучший критик';

  @override
  String get frameLegendTitle => 'Легенда';

  @override
  String get frameAlwaysUnlocked => 'Эту рамку получает каждый.';

  @override
  String frameLevelRequirement(int level) {
    return 'Достигните уровня $level.';
  }

  @override
  String frameDebaterRequirement(int count) {
    return 'Получите $count реакций «Убедительно».';
  }

  @override
  String get frameEquipped => 'Надето';

  @override
  String get frameTapToEquip => 'Нажмите, чтобы надеть';

  @override
  String get frameUnlocked => 'Открыто';

  @override
  String get frameLocked => 'Заблокировано';

  @override
  String get frameUpdateFailed =>
      'Не удалось надеть рамку. Попробуйте ещё раз.';

  @override
  String profileLevelLabel(int level) {
    return 'УРОВЕНЬ $level';
  }

  @override
  String get profileStatComments => 'Комментарии';

  @override
  String get profileStatReactions => 'Реакции';

  @override
  String get profileFramesTitle => 'Рамки';

  @override
  String profileXpProgress(int into, int span, int next) {
    return '$into / $span XP до уровня $next';
  }

  @override
  String get topicDetailTitle => 'Тема';

  @override
  String topicCommentsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
      zero: 'Комментариев пока нет',
    );
    return '$_temp0';
  }

  @override
  String get topicAboutFilm => 'О фильме';

  @override
  String get topicBeFirst => 'Будь первым, кто ответит.';

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

  @override
  String get browseSectionDiscover => 'Обзор';

  @override
  String get browseTopTakes => 'Топ-100 отзывов';

  @override
  String get browsePopularFilms => 'Самые популярные фильмы';

  @override
  String get browseByYear => 'По году выхода';

  @override
  String get browseByStreaming => 'По стриминговому сервису';

  @override
  String get browseSectionTopics => 'Популярные темы';

  @override
  String get browsePolls => 'Опросы';

  @override
  String get browseConversations => 'Обсуждения';

  @override
  String get browseScenes => 'Сцены';

  @override
  String get browseQuestions => 'Вопросы';

  @override
  String get browseHotTakes => 'Смелые мнения';

  @override
  String get browseSectionFilmSage => 'FilmSage';

  @override
  String get browseNewHere => 'Впервые здесь?';

  @override
  String get browseSocialMedia => 'Соцсети';

  @override
  String get browseFollowUs => 'Подписывайтесь на нас';

  @override
  String get browseGifts => 'Подарки';

  @override
  String get browseContact => 'Контакты';

  @override
  String get browseTerms => 'Условия использования / Правила сообщества';

  @override
  String get browseYearsTitle => 'Выберите год';

  @override
  String browseDecade(String decade) {
    return '$decade-е';
  }

  @override
  String get browseServicesTitle => 'Выберите сервис';

  @override
  String get browseServicesEmpty => 'Нет доступных сервисов.';

  @override
  String get browseFilmsEmpty => 'Здесь пока нет фильмов.';

  @override
  String get browseTakesEmpty => 'Здесь пока ничего нет.';

  @override
  String get browseComingSoonTitle => 'Скоро';

  @override
  String get browseComingSoonBody =>
      'Мы ещё работаем над этой страницей. Загляните позже.';

  @override
  String get browseByGenre => 'По жанру';

  @override
  String get browseByCountry => 'По стране';

  @override
  String get browseByLanguage => 'По языку';

  @override
  String get browseGenresTitle => 'Выберите жанр';

  @override
  String get browseCountriesTitle => 'Выберите страну';

  @override
  String get browseCountriesHint =>
      'Популярные фильмы, доступные для просмотра в каждой стране.';

  @override
  String browseStreamingIn(String country) {
    return 'Смотреть в стране: $country';
  }

  @override
  String get browseLanguagesTitle => 'Выберите язык';

  @override
  String get browsePickEmpty => 'Пока выбрать не из чего.';

  @override
  String get browseLanguageEn => 'Английский';

  @override
  String get browseLanguageFr => 'Французский';

  @override
  String get browseLanguageEs => 'Испанский';

  @override
  String get browseLanguageIt => 'Итальянский';

  @override
  String get browseLanguageDe => 'Немецкий';

  @override
  String get browseLanguagePt => 'Португальский';

  @override
  String get browseLanguageRu => 'Русский';

  @override
  String get browseLanguageAr => 'Арабский';

  @override
  String get browseLanguageTr => 'Турецкий';

  @override
  String get browseLanguageHi => 'Хинди';

  @override
  String get browseLanguageKo => 'Корейский';

  @override
  String get browseLanguageJa => 'Японский';

  @override
  String get browseLanguageZh => 'Китайский';

  @override
  String get browseLanguageSv => 'Шведский';

  @override
  String get overviewPlayTrailer => 'Смотреть трейлер';

  @override
  String get overviewTrailerUnavailable => 'Не удалось открыть трейлер.';

  @override
  String get overviewLoading => 'Загрузка…';

  @override
  String get overviewNoCastCrew =>
      'Пока нет данных об актёрах и съёмочной группе.';

  @override
  String get overviewOfferStream => 'Подписка';

  @override
  String get overviewOfferFree => 'Бесплатно';

  @override
  String get overviewOfferTvProvider => 'С ТВ-провайдером';

  @override
  String get overviewOfferRent => 'Аренда';

  @override
  String get overviewOfferBuy => 'Покупка';

  @override
  String get overviewCloseTrailer => 'Закрыть трейлер';

  @override
  String get filmSuggest => 'Посоветовать';

  @override
  String get filmListFailed =>
      'Не удалось обновить список. Попробуйте ещё раз.';

  @override
  String get filmFeelingsEmpty =>
      'Нажмите, чтобы рассказать, что вы почувствовали';

  @override
  String get filmFeelingsHint => 'Выберите до 3 чувств.';

  @override
  String filmFeelingsCount(String count) {
    return 'Выбрано $count из 3';
  }

  @override
  String get filmFeelingsSave => 'Сохранить';

  @override
  String get filmFeelingsClear => 'Очистить';

  @override
  String get filmAudienceTitle => 'Зрители';

  @override
  String get filmAudienceEmpty =>
      'Реакций пока нет. Будьте первым, кто расскажет о своих чувствах.';

  @override
  String get filmAudiencePositive => 'понравилось';

  @override
  String filmAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отреагировали $count человека',
      many: 'Отреагировали $count человек',
      few: 'Отреагировали $count человека',
      one: 'Отреагировал 1 человек',
    );
    return '$_temp0';
  }

  @override
  String get filmYourTakeTitle => 'Ваше мнение';

  @override
  String filmTakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мнения',
      many: '$count мнений',
      few: '$count мнения',
      one: '1 мнение',
    );
    return '$_temp0';
  }

  @override
  String get filmTopTake => 'ЛУЧШЕЕ МНЕНИЕ';

  @override
  String filmShowMoreTakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё $count мнения',
      many: 'Ещё $count мнений',
      few: 'Ещё $count мнения',
      one: 'Ещё 1 мнение',
    );
    return '$_temp0';
  }

  @override
  String get filmShowLessTakes => 'Свернуть';

  @override
  String get filmShareYourTake => 'Поделиться мнением';

  @override
  String get filmAddTake => 'Добавить мнение';

  @override
  String get personBiography => 'Биография';

  @override
  String get personFilmography => 'Фильмы';

  @override
  String get personHeight => 'Рост';

  @override
  String get personBorn => 'Дата рождения';

  @override
  String get personDied => 'Дата смерти';

  @override
  String get personNoFilms => 'Фильмы этого человека пока не найдены.';

  @override
  String get personLoadFailed =>
      'Не удалось загрузить страницу этого человека.';

  @override
  String personAsCharacter(String character) {
    return 'в роли $character';
  }
}
