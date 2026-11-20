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
  String get homeFriendsFilmsTitle => 'Популярно у друзей';

  @override
  String get homeFriendsReviewsTitle => 'Последние мнения друзей';

  @override
  String get homeMyTakesTitle => 'Мои мнения';

  @override
  String get homeComingSoon => 'Скоро';

  @override
  String get homeInboxTitle => 'Входящие';

  @override
  String get homeInboxSoonTitle => 'В разработке';

  @override
  String get homeInboxSoonBody => 'Скоро здесь появятся сообщения от друзей.';

  @override
  String get homeFriendsReviewsEmpty => 'Друзья ещё не поделились мнениями.';

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
  String get exploreReviewButton => 'Мнение';

  @override
  String get exploreSubtitle =>
      'Открывай мнения, обсуждения и вопросы о фильмах.';

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
  String get exploreFilterReviews => 'Мнения';

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
  String get homeFeedTitle => 'Мнения из твоих коллекций';

  @override
  String get homeFeedEmpty => 'Пока нет мнений о фильмах из твоих коллекций.';

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
  String get overviewReviewsTitle => 'Мнения';

  @override
  String get overviewAddReviewHint => 'Поделиться мнением...';

  @override
  String get overviewYourReview => 'Твоё мнение';

  @override
  String get overviewFriendsReviews => 'Мнения друзей';

  @override
  String get overviewPopularReviews => 'Популярные мнения';

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
  String get reviewDetailTitle => 'Мнение';

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
    return 'Мнение от $name, $date';
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
  String get profileStatReviews => 'Мнения';

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
  String get profileThemeButton => 'Оформление';

  @override
  String get profileThemeDialogTitle => 'Оформление';

  @override
  String get profileThemeSystem => 'Как в системе';

  @override
  String get profileThemeLight => 'Светлое';

  @override
  String get profileThemeDark => 'Тёмное';

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
      'Хочешь начать дебаты об этом мнении? Выбери собеседника из этой переписки.';

  @override
  String get angelBirdPickPerson => 'С кем ты хочешь поспорить?';

  @override
  String get angelBirdNoPeople =>
      'Пока не с кем спорить. Дождись комментария к этому мнению.';

  @override
  String get angelBirdPeopleFailed =>
      'Не удалось загрузить участников этого мнения.';

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
  String get topicTagReview => 'Мнение';

  @override
  String get topicTagQuestion => 'Вопрос';

  @override
  String get topicTagDiscussion => 'Обсуждение';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint => 'Для мнения нужна твоя реакция на фильм.';

  @override
  String get topicBodyHint => 'Напиши мнение, вопрос или тему для обсуждения';

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
  String get leaderboardTabLabel => 'Рейтинг';

  @override
  String get leaderboardTitle => 'Лучшие критики';

  @override
  String get leaderboardSubtitle => 'Рейтинг по реакциям на их мнения';

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
      other: '$count мнения',
      many: '$count мнений',
      few: '$count мнения',
      one: '$count мнение',
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
  String get howStep1Title => 'Поделитесь мнением';

  @override
  String get howStep1Body =>
      'Поделитесь мнением о любом фильме. Оно появится в разделах «Обзор» и «Друзья».';

  @override
  String get howStep2Title => 'Соберите реакции';

  @override
  String get howStep2Body =>
      'Читатели реагируют на вашу рецензию. Каждая реакция стоит одно очко.';

  @override
  String get howStep3Title => 'Поднимайтесь в рейтинге';

  @override
  String get howStep3Body =>
      'Критики с наибольшим числом реакций за период займут пьедестал.';

  @override
  String get howNoteReset =>
      'Эта неделя сбрасывается каждый понедельник в 00:00. «Этот месяц» и «За всё время» продолжают считаться.';

  @override
  String get howNoteOncePerReview =>
      'Каждый может отреагировать один раз на мнение. Реакция на собственное мнение не засчитывается.';

  @override
  String get howNoteTie =>
      'Если у двух критиков равный счёт, выше тот, кто первым набрал это число.';

  @override
  String get howNotePodium =>
      'Первые три получают рамку пьедестала (золото, синий, бронза) в рейтинге за выбранный период.';

  @override
  String get howLevelsTitle => 'Уровни и XP';

  @override
  String get howXpReview => 'Поделиться мнением';

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
      'Станьте первым, кто поделится мнением о фильме.';

  @override
  String get achFilmCriticTitle => 'Киновед';

  @override
  String achFilmCriticDesc(int count) {
    return 'Поделитесь $count мнениями.';
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
    return 'Поделитесь мнением о $count тунисских фильмах.';
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
  String overviewFriendStoryNew(String name, String feeling) {
    return '$name, новое: $feeling';
  }

  @override
  String overviewFriendStorySeen(String name, String feeling) {
    return '$name: $feeling';
  }

  @override
  String filmPersonFeelings(String feelings) {
    return 'Чувства: $feelings';
  }

  @override
  String filmTakeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '1 комментарий',
      zero: 'Нет комментариев',
    );
    return '$_temp0';
  }

  @override
  String get filmFeelingsDone => 'Готово';

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

  @override
  String get takeSkinTitle => 'Оформление карточки';

  @override
  String get takeSkinNormal => 'Обычное';

  @override
  String get takeSkinElectricThunder => 'Электрическая гроза';

  @override
  String get takeSkinPreview => 'Предпросмотр';

  @override
  String get takeSkinPreviewEmpty => 'Здесь появится ваше мнение.';

  @override
  String get takeSkinWriteTitle => 'Напишите своё мнение';

  @override
  String get reviewAlreadyShared => 'Вы уже поделились мнением об этом фильме.';

  @override
  String get reviewNeedsFeeling =>
      'Сначала выберите, что вы почувствовали, затем поделитесь мнением.';

  @override
  String get reviewYourTake => 'Ваше мнение — другие на него реагируют';

  @override
  String get reviewBeFirstComment => 'Прокомментируйте это мнение первым.';

  @override
  String get takeMenuTooltip => 'Ещё';

  @override
  String get takeActionShare => 'Отправить друзьям';

  @override
  String get takeActionEdit => 'Изменить';

  @override
  String get takeActionDelete => 'Удалить';

  @override
  String get takeActionReport => 'Пожаловаться';

  @override
  String get takeEdited => 'изменено';

  @override
  String get takeCancel => 'Отмена';

  @override
  String get takeEditTitle => 'Изменить мнение';

  @override
  String get takeEditSave => 'Сохранить';

  @override
  String get takeEditSaved => 'Мнение обновлено.';

  @override
  String get takeEditFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get takeDeleteTitle => 'Удалить это мнение?';

  @override
  String get takeDeleteBody => 'Оно исчезнет для всех вместе с комментариями.';

  @override
  String get takeDeleted => 'Мнение удалено.';

  @override
  String get takeDeleteFailed => 'Не удалось удалить. Попробуйте ещё раз.';

  @override
  String get takeReportTitle => 'Пожаловаться на мнение';

  @override
  String get takeReportHint =>
      'Почему вы жалуетесь? Жалобы видят только модераторы.';

  @override
  String get takeReportSpam => 'Спам';

  @override
  String get takeReportHarassment => 'Травля или оскорбления';

  @override
  String get takeReportHate => 'Язык вражды';

  @override
  String get takeReportSpoiler => 'Спойлер без пометки';

  @override
  String get takeReportOther => 'Другое';

  @override
  String get takeReportDetailsHint => 'Подробности (необязательно)';

  @override
  String get takeReportSend => 'Отправить жалобу';

  @override
  String get takeReportThanks => 'Спасибо. Мы всё проверим.';

  @override
  String get takeReportFailed =>
      'Не удалось отправить жалобу. Попробуйте ещё раз.';

  @override
  String get takeShareTitle => 'Отправить друзьям';

  @override
  String get takeShareMessageHint => 'Сообщение (необязательно)';

  @override
  String get takeShareNoFriends =>
      'Добавьте друзей, чтобы отправлять им мнения.';

  @override
  String get takeShareFriendsFailed => 'Не удалось загрузить друзей.';

  @override
  String get takeShareFailed => 'Не удалось отправить. Попробуйте ещё раз.';

  @override
  String get notificationTakeGone => 'Это мнение больше недоступно.';

  @override
  String get mentionSuggestionsLabel => 'Упомянуть друга';

  @override
  String takeShareSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправить друзьям: $count',
      one: 'Отправить 1 другу',
      zero: 'Отправить',
    );
    return '$_temp0';
  }

  @override
  String takeShareSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправлено друзьям: $count',
      one: 'Отправлено 1 другу',
    );
    return '$_temp0';
  }

  @override
  String notificationTakeShared(String name) {
    return '$name отправил(а) вам мнение';
  }

  @override
  String notificationTakeMention(String name) {
    return '$name упомянул(а) вас в комментарии';
  }

  @override
  String get takeSpoilerTitle => 'Есть ли спойлеры?';

  @override
  String get takeSpoilerNo => 'Без спойлеров';

  @override
  String get takeSpoilerHint =>
      'Выберите вариант, чтобы читатели знали, чего ждать.';

  @override
  String get takeSpoilerRequired =>
      'Перед публикацией укажите, есть ли в отзыве спойлеры.';

  @override
  String get takeSpoilerBlurNote =>
      'Другие увидят его размытым, пока не нажмут, чтобы открыть.';

  @override
  String get reviewVoteUp => 'За';

  @override
  String get reviewVoteDraw => 'Ничья';

  @override
  String get reviewVoteDown => 'Против';

  @override
  String storyTake(String film) {
    return 'Поделился мнением о $film';
  }

  @override
  String storyQuestion(String film) {
    return 'Спросил о $film';
  }

  @override
  String storyDiscussion(String film) {
    return 'Начал обсуждение $film';
  }

  @override
  String storyHotTake(String film) {
    return 'Высказал смелое мнение о $film';
  }

  @override
  String storyPoll(String film) {
    return 'Создал опрос о $film';
  }

  @override
  String storyScene(String film) {
    return 'Поделился сценой из $film';
  }

  @override
  String storyComment(String film) {
    return 'Прокомментировал пост о $film';
  }

  @override
  String get storyUnknownFilm => 'фильм';

  @override
  String get storyOpen => 'Открыть';

  @override
  String get storyClose => 'Закрыть';

  @override
  String storyRingLabel(String name) {
    return 'История $name';
  }

  @override
  String get storiesTitle => 'Истории друзей';

  @override
  String get inboxSearch => 'Поиск';

  @override
  String get inboxSearchHint => 'Поиск по чатам';

  @override
  String get inboxCloseSearch => 'Закрыть поиск';

  @override
  String get inboxUnreadOnly => 'Только непрочитанные';

  @override
  String get inboxAddFriend => 'Добавить друга';

  @override
  String get inboxCreate => 'Новый чат';

  @override
  String get inboxNewMessage => 'Новое сообщение';

  @override
  String get inboxCreateGroup => 'Создать группу';

  @override
  String get inboxCreateTopic => 'Создать приватную тему';

  @override
  String get inboxPrivateTopics => 'Приватные темы';

  @override
  String get inboxNoTopics => 'Тем пока нет. Начните с друзьями.';

  @override
  String get inboxNewTopic => 'Новая приватная тема';

  @override
  String get inboxAllChats => 'Все чаты';

  @override
  String get inboxEmptyTitle => 'Пока нет чатов';

  @override
  String get inboxEmptyBody => 'Напишите другу, чтобы начать.';

  @override
  String get inboxNoResults => 'Чаты не найдены';

  @override
  String get inboxLoadFailed => 'Не удалось загрузить сообщения.';

  @override
  String inboxYouSaid(String text) {
    return 'Вы: $text';
  }

  @override
  String get inboxNoMessagesYet => 'Сообщений пока нет';

  @override
  String get inboxGroupName => 'Название группы';

  @override
  String get inboxTopicName => 'Название темы';

  @override
  String get inboxPickFriends => 'Выберите друзей';

  @override
  String get inboxPickFriend => 'Написать другу';

  @override
  String get inboxNoFriends => 'Сначала добавьте друзей.';

  @override
  String get inboxCreateAction => 'Создать';

  @override
  String get inboxCancel => 'Отмена';

  @override
  String get inboxCreateFailed => 'Не удалось создать. Попробуйте снова.';

  @override
  String inboxMembers(int count) {
    return 'Участников: $count';
  }

  @override
  String get inboxGroupPhoto => 'Добавить фото группы';

  @override
  String get inboxGroupDescription => 'Описание (необязательно)';

  @override
  String get inboxPhotoFailed => 'Создано, но фото не загрузилось.';

  @override
  String get chatOpenInfo => 'О группе';

  @override
  String get groupInfoTitle => 'О группе';

  @override
  String get groupInfoTopicTitle => 'О теме';

  @override
  String get groupInfoDescription => 'Описание';

  @override
  String get groupInfoNoDescription => 'Описания пока нет.';

  @override
  String groupInfoMembers(int count) {
    return 'Участники · $count';
  }

  @override
  String get groupInfoYou => 'Вы';

  @override
  String get groupInfoCreator => 'Создатель';

  @override
  String inboxUnreadLabel(int count) {
    return 'Непрочитанных: $count';
  }

  @override
  String get chatHint => 'Сообщение';

  @override
  String get chatSend => 'Отправить';

  @override
  String get chatStart => 'Начните разговор';

  @override
  String get chatSendFailed => 'Сообщение не отправлено. Попробуйте снова.';

  @override
  String get chatPrivateTopic => 'Приватная тема · видна только участникам';

  @override
  String get inboxSelectChat => 'Выберите чат, чтобы начать переписку';

  @override
  String get chatMenu => 'Меню группы';

  @override
  String get chatShareGroup => 'Поделиться группой';

  @override
  String get chatBoostGroup => 'Продвинуть группу';

  @override
  String get chatReport => 'Пожаловаться';

  @override
  String get chatLeaveGroup => 'Покинуть группу';

  @override
  String get chatShareBody => 'Отправьте группу в чат.';

  @override
  String chatSharedTo(String name) {
    return 'Отправлено в $name';
  }

  @override
  String chatBoosted(String name) {
    return 'Продвижение $name запущено';
  }

  @override
  String get chatReportTitle => 'Пожаловаться на группу';

  @override
  String get chatReportBody => 'Расскажите, что не так. Участники не узнают.';

  @override
  String get chatReportSpam => 'Спам или мошенничество';

  @override
  String get chatReportHarassment => 'Травля';

  @override
  String get chatReportOther => 'Другое';

  @override
  String get chatReportSent => 'Жалоба отправлена';

  @override
  String get chatCancel => 'Отмена';

  @override
  String get chatClose => 'Закрыть';

  @override
  String get chatBack => 'Назад';

  @override
  String get chatActionFailed => 'Не получилось. Попробуйте ещё раз.';

  @override
  String get chatPinned => 'Закреплено';

  @override
  String chatPinnedCount(int count) {
    return 'Закреплено ($count)';
  }

  @override
  String get chatReply => 'Ответить';

  @override
  String chatReplyingTo(String name) {
    return 'Ответ $name';
  }

  @override
  String get chatCancelReply => 'Отменить ответ';

  @override
  String get chatPin => 'Закрепить сообщение';

  @override
  String get chatUnpin => 'Открепить сообщение';

  @override
  String get chatMessagePinned => 'Сообщение закреплено';

  @override
  String get chatMessageUnpinned => 'Сообщение откреплено';

  @override
  String chatMention(String name) {
    return 'Упомянуть $name';
  }

  @override
  String get chatViewProfile => 'Открыть профиль';

  @override
  String get chatMoreReactions => 'Другие реакции';

  @override
  String chatNotified(String names) {
    return 'Уведомлены: $names';
  }

  @override
  String get chatNoMatch => 'Никого не найдено';

  @override
  String get chatAdd => 'Добавить фото, видео, фильм или опрос';

  @override
  String get chatEmojiButton => 'Эмодзи, GIF и стикеры';

  @override
  String get chatAddTitle => 'Добавить в чат';

  @override
  String get chatPhoto => 'Фото';

  @override
  String get chatPhotoBody => 'Выберите фото на устройстве.';

  @override
  String get chatVideo => 'Видео';

  @override
  String get chatVideoBody => 'Выберите видео на устройстве.';

  @override
  String get chatMovie => 'Фильм';

  @override
  String get chatMovieBody => 'Найдите фильм и отправьте его карточкой.';

  @override
  String get chatPoll => 'Опрос';

  @override
  String get chatPollBody => 'Задайте группе вопрос.';

  @override
  String get chatSendPhoto => 'Отправить фото';

  @override
  String get chatSendVideo => 'Отправить видео';

  @override
  String get chatShareMovie => 'Поделиться фильмом';

  @override
  String get chatNewPoll => 'Новый опрос';

  @override
  String get chatCaption => 'Добавьте подпись';

  @override
  String get chatPollQuestion => 'Задайте вопрос';

  @override
  String chatPollOption(int number) {
    return 'Вариант $number';
  }

  @override
  String get chatAddOption => 'Добавить вариант';

  @override
  String get chatAllowedReactions => 'Разрешённые реакции';

  @override
  String get chatAllowedReactionsBody =>
      'Участники могут реагировать выбранными эмодзи. Они видят их, удерживая сообщение.';

  @override
  String get chatPollInvalid => 'Добавьте вопрос и хотя бы два варианта';

  @override
  String get chatFileTooBig => 'Файл слишком большой (максимум 12 МБ)';

  @override
  String get chatSearchMovie => 'Найти фильм';

  @override
  String get chatSearchMovieHint => 'Название фильма';

  @override
  String get chatNoMovie => 'Фильм не найден.';

  @override
  String chatVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count голоса',
      many: '$count голосов',
      few: '$count голоса',
      one: '1 голос',
    );
    return '$_temp0';
  }

  @override
  String get chatPlayVideo => 'Смотреть видео';

  @override
  String get chatGif => 'GIF';

  @override
  String get chatSticker => 'Стикер';

  @override
  String get chatTabEmoji => 'Эмодзи';

  @override
  String get chatTabGif => 'GIF';

  @override
  String get chatTabStickers => 'Стикеры';

  @override
  String get chatSearchEmoji => 'Найдите нужный эмодзи';

  @override
  String get chatSearchGif => 'Поиск GIF';

  @override
  String get chatSearchStickers => 'Поиск стикеров';

  @override
  String chatNothingFound(String query) {
    return 'По запросу «$query» ничего нет.';
  }

  @override
  String get chatCatFrequent => 'Часто используемые';

  @override
  String get chatCatFaces => 'Лица';

  @override
  String get chatCatHands => 'Руки';

  @override
  String get chatCatObjects => 'Предметы';

  @override
  String get chatCatSymbols => 'Символы';

  @override
  String get chatClosePicker => 'Закрыть панель';

  @override
  String sysPinned(String name) {
    return '$name закрепил(а) сообщение';
  }

  @override
  String sysRemoved(String name, String target) {
    return '$name удалил(а) $target из группы';
  }

  @override
  String sysLeft(String name) {
    return '$name покинул(а) группу';
  }

  @override
  String sysHeritage(String name, String target) {
    return '$name сделал(а) $target наследным создателем';
  }

  @override
  String sysPassed(String name, String target) {
    return '$name передал(а) роль создателя $target и вышел(а)';
  }

  @override
  String sysVoteStarted(String name) {
    return '$name начал(а) голосование о судьбе группы';
  }

  @override
  String sysVoteCancelled(String name) {
    return '$name отменил(а) голосование';
  }

  @override
  String get sysVoteKeep =>
      'Большинство решило оставить группу. Теперь выберите нового владельца.';

  @override
  String sysVoteOwnerWon(String target) {
    return '$target победил(а) в голосовании и стал(а) наследным создателем';
  }

  @override
  String get voteKeepTitle => 'Оставить группу?';

  @override
  String voteKeepBody(String name, String time) {
    return '$name хочет уйти. На голосование осталось $time. Решает большинство; при ничьей группа остаётся.';
  }

  @override
  String get voteStay => 'Оставить';

  @override
  String get voteDelete => 'Удалить';

  @override
  String voteKeepTally(int stay, int delete) {
    return 'Оставить $stay · Удалить $delete';
  }

  @override
  String get voteOwnPoll => 'Нельзя голосовать в своём опросе.';

  @override
  String get voteCancel => 'Отменить опрос и остаться создателем';

  @override
  String get voteOwnerTitle => 'Кто будет владельцем группы?';

  @override
  String voteOwnerBody(String time) {
    return 'Группа остаётся. Выберите участника, кроме себя. Осталось $time.';
  }

  @override
  String get voteOwnerHint => 'Нажмите на участника, чтобы проголосовать.';

  @override
  String get voteOwnerChange => 'Голос можно изменить до конца опроса.';

  @override
  String voteTimeLeft(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String get voteRunning => 'Голосование уже идёт';

  @override
  String get leaveCreatorTitle => 'Вы создали эту группу';

  @override
  String get leaveCreatorBody =>
      'Прежде чем уйти, решите, что будет с группой.';

  @override
  String get leavePass => 'Передать роль создателя';

  @override
  String get leavePassBody => 'Выберите участника. Он сразу станет главным.';

  @override
  String get leaveVote => 'Пусть решит группа';

  @override
  String get leaveVoteBody =>
      'Участники голосуют, оставить ли группу, а затем выбирают владельца. Каждое голосование длится 24 часа.';

  @override
  String get leavePickTitle => 'Кто станет главным?';

  @override
  String get leavePickBody =>
      'Он получит роль наследного создателя и сохранит жалобы, отправку и продвижение.';

  @override
  String get leaveContinue => 'Продолжить';

  @override
  String leavePassConfirmTitle(String name) {
    return 'Передать роль $name и уйти?';
  }

  @override
  String leavePassConfirmBody(String name) {
    return '$name сразу станет наследным создателем. Вы покинете группу.';
  }

  @override
  String get leavePassConfirm => 'Передать роль и уйти';

  @override
  String get leaveVoteConfirmTitle => 'Начать голосование?';

  @override
  String get leaveVoteConfirmBody =>
      'Шаг 1: 24 часа участники голосуют, оставить или удалить группу. Если большинство за, на шаге 2 они ещё 24 часа выбирают нового владельца. До конца вы остаётесь создателем.';

  @override
  String get leaveVoteConfirm => 'Начать голосование';

  @override
  String leaveSimpleTitle(String group) {
    return 'Покинуть $group?';
  }

  @override
  String get leaveSimpleBody =>
      'Вы больше не будете видеть сообщения этой группы.';

  @override
  String confirmType(String name) {
    return 'Для подтверждения введите $name';
  }

  @override
  String get groupInfoSearch => 'Поиск участников';

  @override
  String groupInfoNoMatch(String query) {
    return 'Нет участников по запросу «$query».';
  }

  @override
  String get groupInfoHeritage => 'Наследный создатель';

  @override
  String memberViewProfileBody(String name) {
    return 'Фильмы и коллекции $name.';
  }

  @override
  String get memberMakeHeritage => 'Сделать наследным создателем';

  @override
  String memberMakeHeritageBody(String name) {
    return '$name станет главным в группе. Вы станете обычным участником.';
  }

  @override
  String get memberRemove => 'Удалить из группы';

  @override
  String memberRemoveBody(String name) {
    return '$name потеряет доступ к группе и её сообщениям.';
  }

  @override
  String memberMakeHeritageTitle(String name) {
    return 'Сделать $name наследным создателем?';
  }

  @override
  String memberMakeHeritageConfirmBody(String name) {
    return '$name получит роль наследного создателя и сможет жаловаться, делиться и продвигать группу. Вы останетесь обычным участником.';
  }

  @override
  String memberRemoveTitle(String name) {
    return 'Удалить $name?';
  }

  @override
  String memberRemoveConfirmBody(String name, String group) {
    return '$name потеряет доступ к $group и не увидит новых сообщений.';
  }

  @override
  String memberRemoveConfirm(String name) {
    return 'Удалить $name';
  }

  @override
  String get chatVideoFailed => 'Не удалось воспроизвести видео.';

  @override
  String get chatPauseVideo => 'Пауза';

  @override
  String get chatFullScreen => 'Во весь экран';

  @override
  String get chatMute => 'Без звука';

  @override
  String get chatUnmute => 'Включить звук';

  @override
  String get chatMutedToast => 'Чат без звука';

  @override
  String get chatUnmutedToast => 'Звук включён';

  @override
  String get chatPinChat => 'Закрепить вверху';

  @override
  String get chatUnpinChat => 'Открепить';

  @override
  String get chatMarkUnread => 'Отметить непрочитанным';

  @override
  String get chatMarkRead => 'Отметить прочитанным';

  @override
  String get chatClearHistory => 'Очистить историю';

  @override
  String get chatClearTitle => 'Очистить историю?';

  @override
  String get chatClearBody =>
      'Все сообщения до этого момента исчезнут у вас. Остальные их по-прежнему видят.';

  @override
  String get chatCleared => 'История очищена';

  @override
  String get chatDeleteChat => 'Удалить чат';

  @override
  String get chatDeleteChatTitle => 'Удалить этот чат?';

  @override
  String chatDeleteChatBody(String name) {
    return 'Чат исчезнет из входящих, а история очистится у вас. Он вернётся, если $name напишет снова.';
  }

  @override
  String get chatChatDeleted => 'Чат удалён';

  @override
  String chatBlock(String name) {
    return 'Заблокировать $name';
  }

  @override
  String chatUnblock(String name) {
    return 'Разблокировать $name';
  }

  @override
  String chatBlockTitle(String name) {
    return 'Заблокировать $name?';
  }

  @override
  String get chatBlockBody =>
      'Вы не сможете писать друг другу, пока вы не разблокируете его. Он не узнает об этом.';

  @override
  String chatBlockedToast(String name) {
    return '$name заблокирован';
  }

  @override
  String chatUnblockedToast(String name) {
    return '$name разблокирован';
  }

  @override
  String chatYouBlocked(String name) {
    return 'Вы заблокировали $name.';
  }

  @override
  String get chatBlockedYou => 'Вы не можете ответить в этом чате.';

  @override
  String get chatBlockedPeople => 'Заблокированные';

  @override
  String get chatNoBlocked => 'Вы никого не заблокировали.';

  @override
  String get chatUnblockShort => 'Разблокировать';

  @override
  String get chatCopy => 'Копировать текст';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get chatEdit => 'Изменить';

  @override
  String get chatEditing => 'Редактирование';

  @override
  String get chatCancelEdit => 'Отменить редактирование';

  @override
  String get chatDeleteMessage => 'Удалить';

  @override
  String get chatDeleteMessageTitle => 'Удалить это сообщение?';

  @override
  String get chatDeleteMessageBody => 'Оно удалится у всех в чате.';

  @override
  String get chatMessageDeleted => 'Сообщение удалено';

  @override
  String get chatEdited => 'изменено';

  @override
  String get chatReportMessage => 'Пожаловаться';

  @override
  String get chatReportHate => 'Язык вражды';

  @override
  String get chatReportNsfw => 'Сексуальный контент';

  @override
  String get chatSeen => 'Просмотрено';

  @override
  String get chatAddMembers => 'Добавить участников';

  @override
  String chatAddMembersTitle(String name) {
    return 'Добавить в $name';
  }

  @override
  String get chatAddMembersNone => 'Все ваши друзья уже здесь.';

  @override
  String get chatAddSelected => 'Добавить';

  @override
  String get chatMembersAdded => 'Участники добавлены';

  @override
  String get chatConfirm => 'Подтвердить';

  @override
  String get chatViewProfileMenu => 'Открыть профиль';

  @override
  String inboxChatOptions(String name) {
    return 'Действия для $name';
  }

  @override
  String get inboxPinnedLabel => 'Закреплён';

  @override
  String get inboxMutedLabel => 'Без звука';

  @override
  String sysAdded(String name, String target) {
    return '$name добавил(а) $target';
  }

  @override
  String get homeTopicFirstReply => 'Ответьте первым';

  @override
  String get homeFriendsActivityTitle => 'Активность друзей';

  @override
  String get homeFriendsActivityResize => 'Изменить размер блока друзей';

  @override
  String get topicTitleHint => 'Заголовок (необязательно)';

  @override
  String get topicSeeMore => 'Ещё';

  @override
  String get topicCommentsExpand => 'Развернуть комментарии';

  @override
  String get topicCommentsShrink => 'Свернуть комментарии';

  @override
  String get chatTakeShared => 'Поделился мнением';

  @override
  String get chatTopicShared => 'Поделился темой';

  @override
  String get chatTaggedYou => 'Отметил вас в комментарии';

  @override
  String get chatYouTagged => 'Вы отметили его в комментарии';

  @override
  String get chatTaggedThem => 'Отметили в комментарии';

  @override
  String get chatYouSharedTopic => 'Вы поделились темой';

  @override
  String get chatYouSharedTake => 'Вы поделились мнением';

  @override
  String get commentAddPhoto => 'Добавить фото';

  @override
  String get commentRemovePhoto => 'Убрать фото';

  @override
  String get takeFeltLabel => 'Чувства';

  @override
  String homeEditList(String list) {
    return 'Изменить: $list';
  }

  @override
  String get homeEditListAdd => 'Добавить фильм';

  @override
  String homeEditListRemove(String title) {
    return 'Убрать «$title»';
  }

  @override
  String get homeEditListEmpty => 'Здесь пока нет фильмов.';

  @override
  String get homeEditListFull =>
      'Ваш топ-5 заполнен. Уберите фильм, чтобы добавить другой.';

  @override
  String get homeWatchedHint => 'Фильмы, которые ты уже посмотрел';

  @override
  String get homeWatchlistHint => 'Фильмы, которые ты хочешь посмотреть';

  @override
  String get homeLensHint => 'Проведи пальцем по обложкам';

  @override
  String homeLensOpen(String title) {
    return 'Открыть «$title»';
  }

  @override
  String get homeListMore => 'Ещё';

  @override
  String get homeListShare => 'Поделиться списком';

  @override
  String get homeListRandom => 'Случайный выбор';

  @override
  String get homeListShuffle => 'Выбрать другой';

  @override
  String homeListShareText(String list) {
    return 'Мой список «$list» в FilmSage:';
  }

  @override
  String get takeHeartLike => 'Нравится';

  @override
  String takeHeartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отметки',
      many: '$count отметок',
      few: '$count отметки',
      one: '$count отметка',
      zero: 'Нет отметок',
    );
    return '$_temp0';
  }

  @override
  String get myListsTitle => 'Мои списки';

  @override
  String get myListsHint => 'Списки, которые ты создал и опубликовал';

  @override
  String get friendsListsTitle => 'Списки друзей';

  @override
  String get friendsListsHint => 'Что собрали твои друзья';

  @override
  String get listNew => 'Новый список';

  @override
  String get listsEmptyMine =>
      'Создай первый список: дай ему название и выбери фильмы.';

  @override
  String get listCreateTitle => 'Новый список';

  @override
  String get listNameLabel => 'Название списка';

  @override
  String get listNameHint => 'Лучшие фильмы об ограблениях';

  @override
  String get listSearchHint => 'Найди фильмы, чтобы добавить';

  @override
  String listAddFilm(String title) {
    return 'Добавить «$title»';
  }

  @override
  String listRemoveFilm(String title) {
    return 'Убрать «$title»';
  }

  @override
  String get listPost => 'Опубликовать';

  @override
  String listFilmCount(int count) {
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
  String listBy(String name) {
    return 'Автор: $name';
  }

  @override
  String get listCommentsTitle => 'Комментарии';

  @override
  String get listCommentHint => 'Написать комментарий';

  @override
  String get listCommentsEmpty =>
      'Комментариев пока нет. Скажи, что думаешь об этом списке.';

  @override
  String listCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
      zero: 'Нет комментариев',
    );
    return '$_temp0';
  }

  @override
  String get listDelete => 'Удалить список';

  @override
  String get listDeleteConfirm => 'Удалить этот список? Это нельзя отменить.';

  @override
  String get listCancel => 'Отмена';

  @override
  String get listPostFailed =>
      'Не удалось опубликовать список. Попробуй ещё раз.';

  @override
  String get listLoadFailed => 'Не удалось загрузить списки.';

  @override
  String listPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count фильма',
      many: 'Выбрано $count фильмов',
      few: 'Выбрано $count фильма',
      one: 'Выбран $count фильм',
      zero: 'Пока нет фильмов',
    );
    return '$_temp0';
  }

  @override
  String get listSearchEmpty => 'Фильмы не найдены.';

  @override
  String get listSendFailed => 'Не удалось отправить. Попробуй ещё раз.';

  @override
  String get takeActionSave => 'Сохранить';

  @override
  String get takeActionUnsave => 'Убрать из сохранённого';

  @override
  String get takeSavedToast => 'Сохранено в профиле';

  @override
  String get takeUnsavedToast => 'Убрано из сохранённых тем';

  @override
  String get takeSaveFailed => 'Не удалось сохранить. Попробуй ещё раз.';

  @override
  String get profileSavedTitle => 'Сохранённое';

  @override
  String get profileSavedEmpty =>
      'Темы, которые ты сохраняешь, появятся здесь.';

  @override
  String get listShare => 'Поделиться списком';

  @override
  String listShareText(String name, String owner) {
    return '$name — список от $owner в Film Wise';
  }

  @override
  String get listSave => 'Сохранить список';

  @override
  String get listUnsave => 'Убрать из сохранённого';

  @override
  String get listSavedToast => 'Список сохранён в профиле';

  @override
  String get listUnsavedToast => 'Список убран из сохранённых';

  @override
  String get listSaveFailed => 'Не удалось сохранить список. Попробуй ещё раз.';

  @override
  String get listEdit => 'Изменить список';

  @override
  String get listEditTitle => 'Изменить список';

  @override
  String get listSaveChanges => 'Сохранить изменения';

  @override
  String get savedListsTitle => 'Сохранённые списки';

  @override
  String get savedListsHint => 'Чужие списки, которые ты сохранил';

  @override
  String get listMenuTooltip => 'Ещё';

  @override
  String get listShareNoFriends => 'Добавь друзей, чтобы отправлять им списки.';

  @override
  String get chatListShared => 'Поделился списком';

  @override
  String get chatYouSharedList => 'Ты поделился списком';

  @override
  String get notificationsMarkAllRead => 'Прочитать все';

  @override
  String get notificationsTabAll => 'Все';

  @override
  String get notificationsTabTakes => 'Мнения';

  @override
  String get notificationsTabMentions => 'Упоминания';

  @override
  String get notificationsTabRequests => 'Заявки';

  @override
  String get notificationsGroupRequests => 'Заявки в друзья';

  @override
  String get notificationsGroupNew => 'Новые';

  @override
  String get notificationsGroupEarlier => 'Ранее';

  @override
  String get notificationsNowFriends => 'Теперь вы друзья';

  @override
  String notificationsRequestDeclined(String name) {
    return 'Заявка от $name отклонена';
  }

  @override
  String get notificationsUndo => 'Отменить';

  @override
  String get notificationsNothingHere => 'Здесь пока ничего нет.';

  @override
  String get notificationsTimeNow => 'сейчас';

  @override
  String notificationsTimeMinutes(int count) {
    return '$count мин';
  }

  @override
  String notificationsTimeHours(int count) {
    return '$count ч';
  }

  @override
  String get notificationsTimeYesterday => 'Вчера';

  @override
  String notificationsTimeDays(int count) {
    return '$count д';
  }

  @override
  String notificationsUnreadCount(int count) {
    return 'Непрочитанных: $count';
  }
}
