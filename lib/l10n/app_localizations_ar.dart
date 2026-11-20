// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String homePointsLabel(int points) {
    return '$points نقطة';
  }

  @override
  String get homeTop5Title => 'أفضل 5 خاصتك';

  @override
  String get homeTop5Hint => 'اختر خمسة أفلام تحبها';

  @override
  String get homeTop5AddLabel => 'أضف فيلماً إلى أفضل 5 خاصتك';

  @override
  String get homeCollectionsTitle => 'المجموعات';

  @override
  String get homeTabYou => 'أنت';

  @override
  String get homeTabFriends => 'الأصدقاء';

  @override
  String get homeTabExplore => 'استكشف';

  @override
  String get homeTabFilms => 'الأفلام';

  @override
  String get homePopularTakesTitle => 'الآراء الأكثر تفاعلاً';

  @override
  String get homeTrendingTopicsTitle => 'المواضيع الرائجة';

  @override
  String get homeTrendingEmpty => 'No questions or discussions this week yet.';

  @override
  String get homeLatestArticlesTitle => 'أحدث المقالات';

  @override
  String get homeUpcomingThisMonthTitle => 'أفلام قادمة';

  @override
  String upcomingNotOutYet(String title, String date) {
    return '$title لم يُعرض بعد. موعد العرض $date.';
  }

  @override
  String get homePopularThisWeekTitle => 'أفلام شائعة';

  @override
  String get homeFriendsFilmsTitle => 'الأكثر شعبية بين الأصدقاء';

  @override
  String get homeFriendsReviewsTitle => 'أحدث آراء الأصدقاء';

  @override
  String get homeMyTakesTitle => 'آرائي';

  @override
  String get homeComingSoon => 'قريباً';

  @override
  String get homeInboxTitle => 'الرسائل';

  @override
  String get homeInboxSoonTitle => 'قيد الإنشاء';

  @override
  String get homeInboxSoonBody => 'ستصل رسائلك مع أصدقائك إلى هنا قريبًا.';

  @override
  String get homeFriendsReviewsEmpty => 'لم يشارك أصدقاؤك أي آراء بعد.';

  @override
  String get homeMyTakesEmpty => 'لم تشارك أي آراء بعد.';

  @override
  String get homeUnderConstruction => 'هذا القسم قيد الإنشاء.';

  @override
  String get exploreSkipStamp => 'تخطي';

  @override
  String get exploreOpenStamp => 'فتح';

  @override
  String get exploreCaughtUp => 'لقد شاهدت كل شيء';

  @override
  String get exploreReviewButton => 'رأي';

  @override
  String get exploreSubtitle => 'اكتشف آراء ونقاشات وأسئلة حول الأفلام.';

  @override
  String get createSceneMovieHint => 'يظهر مشهدك في نقاش هذا الفيلم.';

  @override
  String get createPollQuestionHint => 'ما السؤال الذي تريد طرحه؟';

  @override
  String get exploreFilterAll => 'الكل';

  @override
  String get exploreFilterConversations => 'محادثات';

  @override
  String get exploreFilterPolls => 'استطلاعات';

  @override
  String get exploreFilterScenes => 'مشاهد';

  @override
  String get exploreFilterQuestions => 'أسئلة';

  @override
  String get exploreFilterReviews => 'آراء';

  @override
  String get exploreSpoilerReveal => 'اضغط للكشف';

  @override
  String get topicTagPoll => 'استطلاع';

  @override
  String get topicTagScene => 'مشهد';

  @override
  String get topicSpoilerLabel => 'يحتوي على حرق للأحداث';

  @override
  String get pollVoteHint => 'اضغط على خيار للتصويت';

  @override
  String get pollChangeVoteHint => 'اضغط على خيار آخر لتغيير تصويتك';

  @override
  String pollVoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صوت',
      few: '$count أصوات',
      two: 'صوتان',
      one: 'صوت واحد',
    );
    return '$_temp0';
  }

  @override
  String get createTypePollSubtitle => 'دع الناس يصوّتون بين خيارين و4 خيارات.';

  @override
  String get createTypeSceneSubtitle =>
      'اختر لحظة واحدة من فيلم واشرح لماذا تنجح.';

  @override
  String get createWritePollTitle => 'اكتب سؤال الاستطلاع';

  @override
  String get createPollOptionsTitle => 'أضف الخيارات';

  @override
  String get createPollOptionsHint =>
      'قدّم من خيارين إلى 4 خيارات. يختار الناس واحدًا.';

  @override
  String createPollOptionLabel(int number) {
    return 'الخيار $number';
  }

  @override
  String get createPollAddOption => 'إضافة خيار';

  @override
  String get createPollRemoveOption => 'إزالة الخيار';

  @override
  String get createSceneTitle => 'صف المشهد';

  @override
  String get createSceneNameLabel => 'المشهد';

  @override
  String get createSceneNameHint => 'غرفة الاستجواب';

  @override
  String get createSceneTimecodeLabel => 'التوقيت (اختياري)';

  @override
  String get createSceneTimecodeHint => '1 س 12 د';

  @override
  String get createSceneExplainLabel => 'لماذا تنجح';

  @override
  String get createSceneExplainHint => 'قل ما الذي يجعل هذه اللحظة مميزة';

  @override
  String exploreRepliesButton(int count) {
    return 'عرض الردود وعددها $count';
  }

  @override
  String get exploreStripConversation => 'محادثة';

  @override
  String exploreRepliesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ردود',
      one: 'رد واحد',
    );
    return '$_temp0';
  }

  @override
  String get exploreNoRepliesYet => 'لا توجد ردود بعد';

  @override
  String get exploreBeFirstRespond => 'كن أول من يرد';

  @override
  String explorePeopleTalking(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص يتحدثون',
      one: 'شخص واحد يتحدث',
    );
    return '$_temp0';
  }

  @override
  String exploreLastReply(String time) {
    return 'آخر رد $time';
  }

  @override
  String get exploreNoVotesYet => 'لا توجد أصوات بعد';

  @override
  String exploreAgreePercent(int percent) {
    return '$percent% موافق';
  }

  @override
  String exploreDisagreePercent(int percent) {
    return '$percent% غير موافق';
  }

  @override
  String get exploreFor => 'مع';

  @override
  String get exploreAgainst => 'ضد';

  @override
  String exploreBeFirstArgue(String side) {
    return 'كن أول من يناقش $side';
  }

  @override
  String explorePickedBy(String name) {
    return 'اختاره $name';
  }

  @override
  String get exploreThanksVoting => 'شكراً لتصويتك';

  @override
  String get exploreJoinConversation => 'انضم إلى المحادثة';

  @override
  String get homeCollectionsResizeLabel => 'تغيير حجم المجموعات';

  @override
  String get homeFeedTitle => 'الآراء من مجموعاتك';

  @override
  String get homeFeedEmpty => 'لا توجد آراء حول الأفلام في مجموعاتك بعد.';

  @override
  String get homeFeedShowAsRow => 'عرض أفقي';

  @override
  String get homeFeedShowAsColumn => 'عرض عمودي';

  @override
  String get homeQuickActionsLabel => 'إجراءات سريعة';

  @override
  String get homeQuickActionSearch => 'بحث';

  @override
  String get homeQuickActionAddFilm => 'إضافة فيلم';

  @override
  String get homeWatchedTitle => 'شاهدتها';

  @override
  String get homeWatchlistTitle => 'قائمة المشاهدة';

  @override
  String get homePopularTitle => 'شائع بين أصدقائك';

  @override
  String homeFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فيلماً',
      one: 'فيلم واحد',
    );
    return '$_temp0';
  }

  @override
  String homeAddTileLabel(String section) {
    return 'إضافة إلى $section';
  }

  @override
  String homeFilmTileSemantics(String title, String section) {
    return '$title، $section';
  }

  @override
  String homeRemoveFilm(String title) {
    return 'إزالة $title';
  }

  @override
  String get homeSectionEmptyTitle => 'لا شيء هنا بعد';

  @override
  String get homeSectionEmptyAction => 'إضافة فيلم';

  @override
  String get homeSectionErrorTitle => 'تعذّر تحميل هذه القائمة';

  @override
  String get homeSectionErrorRetry => 'أعد المحاولة';

  @override
  String homeRemovedSnackbar(String title) {
    return 'تمت إزالة $title';
  }

  @override
  String get homeUndo => 'تراجع';

  @override
  String get homeTop5FullSnackbar => 'أفضل 5 خاصتك ممتلئة. أزل فيلماً أولاً.';

  @override
  String get homeGenericErrorSnackbar => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get findTitleTop5 => 'أضف إلى أفضل 5';

  @override
  String get findTitleWatched => 'أضف إلى المشاهَدة';

  @override
  String get findTitleWatchlist => 'أضف إلى قائمة المشاهدة';

  @override
  String get findTitleSearch => 'ابحث عن فيلم';

  @override
  String get findBodySearch => 'كل الأفلام';

  @override
  String get findSearchHint => 'اسم الفيلم…';

  @override
  String get findSearchClear => 'مسح البحث';

  @override
  String get findSearchSubmit => 'بحث';

  @override
  String get findMinCharsTitle => 'استمر في الكتابة';

  @override
  String get findMinCharsBody => 'اكتب حرفين على الأقل للبحث.';

  @override
  String get findLoadingTitle => 'جارٍ البحث عن الأفلام…';

  @override
  String findEmptyTitle(String query) {
    return 'لا توجد نتائج لـ «$query»';
  }

  @override
  String get findEmptyTip1 => 'تحقق من الإملاء أو جرّب عنواناً آخر.';

  @override
  String get findEmptyTip2 => 'جرّب كلمة مفتاحية أقصر أو اسم المخرج.';

  @override
  String get findErrorTitle => 'تعذّر البحث الآن';

  @override
  String get findErrorRetry => 'أعد المحاولة';

  @override
  String get findOfflineTitle => 'أنت غير متصل';

  @override
  String get findOfflineBody => 'البحث والإضافة معطّلان أثناء عدم الاتصال.';

  @override
  String get findNoMoreResults => 'انتهت النتائج';

  @override
  String get findLoadMore => 'تحميل المزيد';

  @override
  String get findRecentTitle => 'عمليات البحث الأخيرة';

  @override
  String get findRecentClear => 'مسح';

  @override
  String get findRecentSwipeDelete => 'إزالة عملية البحث الأخيرة';

  @override
  String get findRecentEmpty => 'لا توجد عمليات بحث أخيرة بعد.';

  @override
  String get findDirectedBy => 'إخراج';

  @override
  String get findGenreChip => 'النوع';

  @override
  String get findAddToTop5 => 'أضف إلى أفضل 5';

  @override
  String get findAddToWatched => 'أضف إلى المشاهَدة';

  @override
  String get findAddToWatchlist => 'أضف إلى قائمة المشاهدة';

  @override
  String findResultSemantics(
      String title, String year, String director, String action) {
    return '$title، $year، من إخراج $director. $action';
  }

  @override
  String findAddedSemantics(String title, String target) {
    return '$title موجود بالفعل في $target';
  }

  @override
  String findResultDetailsAction(String title) {
    return 'فتح تفاصيل $title';
  }

  @override
  String get findViewDetails => 'التفاصيل';

  @override
  String get findSendToFriend => 'أرسل إلى صديق';

  @override
  String findAddedSnackbar(String target) {
    return 'تمت الإضافة إلى $target';
  }

  @override
  String get findUndo => 'تراجع';

  @override
  String findRemovedSnackbar(String target) {
    return 'تمت الإزالة من $target';
  }

  @override
  String get findMovedToWatched => 'تم النقل إلى المشاهَدة';

  @override
  String findReplaceSlotTitle(String current) {
    return 'استبدال $current؟';
  }

  @override
  String findReplaceSlotBody(String current, String replacement) {
    return 'هذه الخانة مشغولة بالفعل بـ $current. هل تريد استبدالها بـ $replacement؟';
  }

  @override
  String get findReplace => 'استبدال';

  @override
  String get findCancel => 'إلغاء';

  @override
  String get findTop5FullTitle => 'أفضل 5 ممتلئة';

  @override
  String get findTop5FullBody => 'أزل فيلماً قبل إضافة فيلم إلى أفضل 5 خاصتك.';

  @override
  String get findAlreadyWatchedTitle => 'تمت مشاهدته بالفعل';

  @override
  String get findAlreadyWatchedBody =>
      'لا يمكنك إضافة فيلم شاهدته بالفعل إلى قائمة المشاهدة.';

  @override
  String get findAlreadyInListTitle => 'مضاف بالفعل';

  @override
  String findAlreadyInListBody(String title, String target) {
    return '$title موجود بالفعل في $target.';
  }

  @override
  String get findGenericErrorTitle => 'حدث خطأ ما';

  @override
  String get findGenericErrorBody => 'حاول مرة أخرى.';

  @override
  String get findDetailsErrorTitle => 'تعذّر تحميل الفيلم';

  @override
  String get findDetailsRetry => 'أعد المحاولة';

  @override
  String get findDetailsCast => 'طاقم التمثيل';

  @override
  String get findDetailsOverview => 'الملخص';

  @override
  String findDetailsRuntime(int minutes) {
    return '$minutes د';
  }

  @override
  String findDetailsVote(String value) {
    return '$value نجوم';
  }

  @override
  String get findWatchNow => 'شاهد الآن';

  @override
  String get findAttribution =>
      'بيانات الأفلام وصورها من TMDB. توفّر المنصات من JustWatch.';

  @override
  String get overviewBack => 'رجوع';

  @override
  String overviewRating(String value) {
    return '$value / 10';
  }

  @override
  String get overviewNoRating => 'لا يوجد تقييم بعد';

  @override
  String get overviewWhereToWatch => 'أين تشاهده؟';

  @override
  String get overviewNoStreaming => 'لم يتم العثور على منصات بث';

  @override
  String overviewRatingsCount(int count) {
    return 'التقييمات: $count من filmwiser';
  }

  @override
  String overviewStarsValue(String value) {
    return '$value من 5 نجوم';
  }

  @override
  String get overviewTrailer => 'المقدمة الدعائية';

  @override
  String get overviewNoGenres => 'لا توجد أنواع مدرجة';

  @override
  String get overviewTabGenres => 'الأنواع';

  @override
  String get overviewTabCast => 'الممثلون';

  @override
  String get overviewTabCrew => 'فريق العمل';

  @override
  String get overviewTabProd => 'الإنتاج';

  @override
  String get overviewActivityTitle => 'نشاط أصدقائك';

  @override
  String get overviewWantsToWatch => 'يريد المشاهدة';

  @override
  String get overviewNoFriendActivity => 'لا يوجد نشاط من أصدقائك بعد.';

  @override
  String get overviewShowMore => 'المزيد';

  @override
  String get overviewShowLess => 'أقل';

  @override
  String get overviewReviewsTitle => 'الآراء';

  @override
  String get overviewAddReviewHint => 'أضف رأيًا…';

  @override
  String get overviewYourReview => 'رأيك';

  @override
  String get overviewFriendsReviews => 'آراء أصدقائك';

  @override
  String get overviewPopularReviews => 'الآراء الشائعة';

  @override
  String get overviewSeeAll => 'عرض الكل';

  @override
  String get reviewTrustedLabel => 'من مشاهدين موثوقين';

  @override
  String reviewEveryoneTogether(String value) {
    return 'الجميع معاً: $value';
  }

  @override
  String get reviewMostFelt => 'الشعور الأبرز:';

  @override
  String get reviewWhatIsTrusted => 'ما معنى «موثوق»؟';

  @override
  String get reviewTrustedNote =>
      'يكتسب المشاهدون الثقة عندما يجد الآخرون آراءهم مدعومة بالحجج. أصواتهم تُحتسب بوزن أكبر قليلاً، ليبقى التقييم عادلاً ومدروساً.';

  @override
  String get reviewReactionTitle => 'كيف جعلك تشعر؟';

  @override
  String get reviewReactionHint => 'اضغط على الأنسب لك.';

  @override
  String get reviewReactionLoved => 'أحببته';

  @override
  String get reviewReactionBrokeHeart => 'أوجع قلبي';

  @override
  String get reviewReactionBlewMind => 'أذهلني';

  @override
  String get reviewReactionMadeCry => 'أبكاني';

  @override
  String get reviewReactionShocked => 'صدمني';

  @override
  String get reviewReactionMadeLaugh => 'أضحكني';

  @override
  String get reviewReactionBored => 'أصابني بالملل';

  @override
  String get reviewReactionDisappointed => 'خيّب أملي';

  @override
  String get reviewReactionMadeThink => 'جعلني أفكر';

  @override
  String get reviewReactionMasterpiece => 'تحفة';

  @override
  String get reviewReactionTapToReact => 'اضغط للتفاعل';

  @override
  String get reviewReactionChange => 'تغيير';

  @override
  String get reviewReactionPickOne => 'اختر واحداً';

  @override
  String get reviewReactionClose => 'إغلاق';

  @override
  String get reviewWhyPrompt => 'هل تريد إضافة سطر عن السبب؟ هذا اختياري.';

  @override
  String get reviewWhyHint => 'ما الذي بقي في ذهنك؟';

  @override
  String get reviewShare => 'مشاركة';

  @override
  String get reviewNoThanks => 'لا، شكراً';

  @override
  String get reviewSharedThanks => 'شكراً على مشاركة رأيك!';

  @override
  String get reviewCountedThanks => 'شكراً! تم احتساب تفاعلك.';

  @override
  String get reviewReactionFailed => 'تعذّر حفظ تفاعلك. حاول مرة أخرى.';

  @override
  String get reviewSummaryFailed => 'تعذّر تحميل التفاعلات.';

  @override
  String get reviewDetailTitle => 'رأي';

  @override
  String get reviewTakesTitle => 'ماذا قال الناس';

  @override
  String get reviewTakesHint => 'آراء قصيرة من مشاهدين آخرين.';

  @override
  String get reviewMostHelpful => 'أكثر رأي مفيد';

  @override
  String get sageNavUnread => 'توجد رسائل غير مقروءة';

  @override
  String get sageNavCloseMenu => 'إغلاق القائمة';

  @override
  String get reviewWriterBadge => 'كاتب';

  @override
  String reviewCommentsButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'التعليقات $count',
      zero: 'تعليق',
    );
    return '$_temp0';
  }

  @override
  String get reviewCommentHint => 'أضف تعليقاً';

  @override
  String get reviewSend => 'إرسال';

  @override
  String get reviewCommentsFailed => 'تعذّر تحميل التعليقات.';

  @override
  String get reviewCommentFailed => 'تعذّر نشر هذا التعليق. حاول مرة أخرى.';

  @override
  String get reviewReply => 'رد';

  @override
  String reviewReplyingTo(String name) {
    return 'رداً على $name';
  }

  @override
  String get reviewCancelReply => 'إلغاء الرد';

  @override
  String reviewShowReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count ردود',
      one: 'عرض رد واحد',
    );
    return '$_temp0';
  }

  @override
  String get reviewHideReplies => 'إخفاء الردود';

  @override
  String get reviewTimeJustNow => 'الآن';

  @override
  String reviewTimeMinutes(int count) {
    return 'منذ $count د';
  }

  @override
  String reviewTimeHours(int count) {
    return 'منذ $count س';
  }

  @override
  String reviewTimeDays(int count) {
    return 'منذ $count ي';
  }

  @override
  String get reviewVoteChangedMyMind => 'غيّرت رأيي';

  @override
  String get reviewVoteWellArgued => 'حجج جيدة';

  @override
  String get reviewVoteDisagreeFair => 'لا أوافق لكنه منصف';

  @override
  String get reviewVoteFailed => 'تعذّر تحديث هذا التصويت. حاول مرة أخرى.';

  @override
  String get reviewTakeFailed => 'تعذّر النشر. حاول مرة أخرى.';

  @override
  String get reviewTakesEmpty => 'لا توجد آراء هنا بعد.';

  @override
  String get reviewTakesFailed => 'تعذّر تحميل الآراء.';

  @override
  String get reviewRetry => 'أعد المحاولة';

  @override
  String overviewReviewBy(String name, String date) {
    return 'رأي $name بتاريخ $date';
  }

  @override
  String get homeOpenProfile => 'فتح الملف الشخصي';

  @override
  String get profileBack => 'رجوع';

  @override
  String get profileSearchTooltip => 'بحث';

  @override
  String get profileMoreTooltip => 'خيارات إضافية';

  @override
  String get profileLogout => 'تسجيل الخروج';

  @override
  String get profileFollowers => 'المتابِعون';

  @override
  String get profileFollowing => 'المتابَعون';

  @override
  String get profileBioHint => 'عدّل نبذتك…';

  @override
  String get profileChat => 'محادثة';

  @override
  String get profileFollow => 'متابعة';

  @override
  String get profileSend => 'إرسال';

  @override
  String get profileAchievementsTitle => 'الإنجازات';

  @override
  String get profileAchievementRookie => 'مبتدئ سينمائي';

  @override
  String get profileAchievementMaster => 'خبير سينمائي';

  @override
  String get profileAchievementLegend => 'أسطورة سينمائية';

  @override
  String profileAchievementFilms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فيلماً',
      one: 'فيلم واحد',
    );
    return '$_temp0';
  }

  @override
  String get profileClaim => 'استلام';

  @override
  String get profileStatisticsTitle => 'الإحصائيات';

  @override
  String get profileStatWatched => 'شاهدتها';

  @override
  String get profileStatWatchlist => 'قائمة المشاهدة';

  @override
  String get profileStatReviews => 'الآراء';

  @override
  String get profileStatRewards => 'المكافآت';

  @override
  String get profileBlockTitle => 'هل تريد حظر هذا المستخدم؟';

  @override
  String get profileBlockReasonHint => 'لماذا؟…';

  @override
  String get profileBlockYes => 'نعم';

  @override
  String get profileBlockNo => 'لا';

  @override
  String get profileErrorTitle => 'تعذّر تحميل ملفك الشخصي.';

  @override
  String get profileRetry => 'أعد المحاولة';

  @override
  String get profileLanguageButton => 'إدارة اللغات';

  @override
  String get profileLanguageDialogTitle => 'لغة التطبيق';

  @override
  String get profileLanguageSystem => 'لغة النظام';

  @override
  String get profileThemeButton => 'المظهر';

  @override
  String get profileThemeDialogTitle => 'المظهر';

  @override
  String get profileThemeSystem => 'حسب النظام';

  @override
  String get profileThemeLight => 'فاتح';

  @override
  String get profileThemeDark => 'داكن';

  @override
  String get onboardingFinishLater => 'إنهاء لاحقاً';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingContinue => 'متابعة';

  @override
  String get onboardingFinish => 'إنهاء';

  @override
  String get onboardingSkip => 'تخطَّ الآن';

  @override
  String get onboardingSaveFailed =>
      'تعذّر الحفظ. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get onboardingAvatarTitle => 'أضف صورة شخصية';

  @override
  String get onboardingAvatarBody =>
      'اختر صورة ليتمكن الآخرون من التعرف عليك. JPG أو PNG أو WebP، بحد أقصى 5 ميغابايت.';

  @override
  String get onboardingChoosePhoto => 'اختيار صورة';

  @override
  String get onboardingPhotoSaved => 'تم حفظ الصورة الشخصية';

  @override
  String get onboardingCoverTitle => 'أضف صورة غلاف';

  @override
  String get onboardingCoverBody => 'صورة عريضة تظهر خلف ترويسة ملفك الشخصي.';

  @override
  String get onboardingChooseCover => 'اختيار الغلاف';

  @override
  String get onboardingCoverSaved => 'تم حفظ الغلاف';

  @override
  String get onboardingBioTitle => 'اكتب نبذة قصيرة';

  @override
  String get onboardingBioBody => 'أخبر الآخرين بنوع الأفلام التي تحبها.';

  @override
  String get onboardingBioHint => 'بضع كلمات عن ذوقك في الأفلام';

  @override
  String get onboardingTop5Title => 'اختر أفضل 5 أفلام';

  @override
  String get onboardingTop5Body => 'أفلامك المفضلة، تظهر أولاً في ملفك الشخصي.';

  @override
  String onboardingTop5Progress(int count) {
    return 'تم اختيار $count من 5';
  }

  @override
  String get onboardingWatchedTitle => 'أضف الأفلام التي شاهدتها';

  @override
  String get onboardingWatchedBody => 'سجّل الأفلام التي سبق أن شاهدتها.';

  @override
  String get onboardingWatchlistTitle => 'أضف أفلاماً لمشاهدتها';

  @override
  String get onboardingWatchlistBody =>
      'احفظ الأفلام التي تخطط لمشاهدتها لاحقاً.';

  @override
  String onboardingFilmsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count فيلماً',
      one: 'تمت إضافة فيلم واحد',
    );
    return '$_temp0';
  }

  @override
  String get onboardingSearchFilms => 'ابحث عن أفلام';

  @override
  String get profileNotificationsTooltip => 'الإشعارات';

  @override
  String get profileEditPhoto => 'تعديل الصورة';

  @override
  String get profileEditCover => 'تعديل الغلاف';

  @override
  String get profileEditBio => 'تعديل النبذة';

  @override
  String get profileEditBioTitle => 'عدّل نبذتك';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileSaveFailed => 'تعذّر الحفظ. حاول مرة أخرى.';

  @override
  String get profileNoConnections => 'لا يوجد أحد هنا بعد.';

  @override
  String get friendAdd => 'إضافة صديق';

  @override
  String get friendCancelRequest => 'إلغاء الطلب';

  @override
  String get friendAccept => 'قبول';

  @override
  String get friendDecline => 'رفض';

  @override
  String get friendFriends => 'أصدقاء';

  @override
  String get friendRequestSent => 'تم إرسال طلب الصداقة.';

  @override
  String get friendActionFailed => 'تعذّر تحديث طلب الصداقة. حاول مرة أخرى.';

  @override
  String get friendRequestGone => 'لم يعد هذا الطلب متاحاً.';

  @override
  String get friendAlreadyConnected => 'أنتما صديقان بالفعل أو يوجد طلب معلّق.';

  @override
  String get searchPeopleTitle => 'ابحث عن أشخاص';

  @override
  String get searchPeopleHint => 'ابحث باسم المستخدم';

  @override
  String get searchPeopleMinChars => 'اكتب حرفين على الأقل.';

  @override
  String get searchPeopleEmpty => 'لم يتم العثور على مستخدمين.';

  @override
  String get searchPeopleFailed => 'تعذّر البحث الآن. حاول مرة أخرى.';

  @override
  String get suggestMovieAction => 'اقترح فيلماً';

  @override
  String get suggestionTitle => 'اقترح فيلماً';

  @override
  String get suggestionSearchHint => 'ابحث عن عنوان فيلم';

  @override
  String get suggestionSearchMinChars => 'اكتب حرفين على الأقل.';

  @override
  String get suggestionSearchEmpty => 'لم يتم العثور على أفلام.';

  @override
  String get suggestionSearchFailed => 'تعذّر البحث الآن. حاول مرة أخرى.';

  @override
  String get suggestionMovieSection => 'الفيلم';

  @override
  String get suggestionPickMovie => 'اختر فيلماً لاقتراحه.';

  @override
  String get suggestionChangeMovie => 'تغيير الفيلم';

  @override
  String get suggestionRecipientsSection => 'إرسال إلى';

  @override
  String get suggestionSelectAll => 'تحديد الكل';

  @override
  String get suggestionNoFriends => 'أضف أصدقاء أولاً لترسل لهم اقتراحات.';

  @override
  String get suggestionFriendsFailed => 'تعذّر تحميل أصدقائك.';

  @override
  String get suggestionCommentHint => 'أضف تعليقاً (اختياري)';

  @override
  String get suggestionSend => 'إرسال الاقتراح';

  @override
  String get suggestionSent => 'تم إرسال الاقتراح.';

  @override
  String get suggestionFailed => 'تعذّر إرسال الاقتراح. حاول مرة أخرى.';

  @override
  String get suggestionNotFriends =>
      'يمكنك اقتراح الأفلام على أصدقائك فقط. عدّل اختيارك وحاول مرة أخرى.';

  @override
  String notificationMovieSuggestion(String name, String title) {
    return 'اقترح عليك $name فيلم $title.';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد.';

  @override
  String get notificationsFailed => 'تعذّر تحميل الإشعارات.';

  @override
  String notificationFriendRequest(String name) {
    return 'أرسل إليك $name طلب صداقة.';
  }

  @override
  String notificationFriendAccepted(String name) {
    return 'قبِل $name طلب صداقتك.';
  }

  @override
  String get angelBirdQuestion =>
      'هل تريد الانضمام إلى نقاش حول أحد أفلامك الخمسة المفضلة؟ يسعد مجتمع Sage بسماع رأيك.';

  @override
  String get angelBirdYes => 'نعم، لنناقش';

  @override
  String get angelBirdNotNow => 'ليس الآن';

  @override
  String get angelBirdPickFilm => 'اختر فيلماً للنقاش';

  @override
  String get angelBirdEmptyTop5 =>
      'قائمة أفضل 5 فارغة. أضف خمسة أفلام لبدء نقاش.';

  @override
  String get angelBirdLoadFailed => 'تعذّر تحميل قائمة أفضل 5 الخاصة بك.';

  @override
  String get angelBirdRetry => 'أعد المحاولة';

  @override
  String get angelBirdReviewQuestion =>
      'هل تريد فتح نقاش حول هذا الرأي؟ اختر شخصاً من المحادثة لتتحدث معه.';

  @override
  String get angelBirdPickPerson => 'مع من تريد أن تناقش؟';

  @override
  String get angelBirdNoPeople =>
      'لا يوجد أحد للنقاش بعد. انتظر تعليقاً على هذا الرأي.';

  @override
  String get angelBirdPeopleFailed => 'تعذّر تحميل الأشخاص في هذا الرأي.';

  @override
  String debateWaitingTitle(String name) {
    return 'في انتظار $name';
  }

  @override
  String debateWaitingBody(String name) {
    return 'تم إرسال دعوتك. يبدأ النقاش بمجرد أن يقبل $name.';
  }

  @override
  String debateDeclined(String name) {
    return 'لا يستطيع $name النقاش الآن. جرّب شخصاً آخر من المحادثة.';
  }

  @override
  String get debateInviteFailed => 'تعذّر إرسال دعوتك. أعد المحاولة.';

  @override
  String get debateLoadFailed => 'تعذّر تحميل الأسئلة. أعد المحاولة.';

  @override
  String get debateSubmitFailed => 'تعذّر إرسال إجاباتك. أعد المحاولة.';

  @override
  String get debateRetry => 'أعد المحاولة';

  @override
  String get debateCancel => 'إلغاء';

  @override
  String get debateDone => 'تم';

  @override
  String debateVsTitle(String name) {
    return 'أنت ضد $name';
  }

  @override
  String debateQuestionCounter(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get debateResultWon => 'فزت بالنقاش!';

  @override
  String debateResultLost(String name) {
    return 'فاز $name بهذه الجولة.';
  }

  @override
  String get debateResultTied => 'تعادل.';

  @override
  String debateScoreLine(int mine, String name, int theirs) {
    return 'أنت $mine · $name $theirs';
  }

  @override
  String debateSagePointsWon(int points) {
    return '+$points نقطة Sage';
  }

  @override
  String debateSagePointsLost(int points, String name) {
    return '$points نقطة Sage تذهب إلى $name.';
  }

  @override
  String get authTagline => 'أطلق شغفك السينمائي الداخلي';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authNoAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authUsername => 'اسم المستخدم';

  @override
  String get authRepeatPassword => 'أعد كتابة كلمة المرور';

  @override
  String get authHaveAccountPrompt => 'لديك حساب بالفعل؟';

  @override
  String get authEmailRequired => 'أدخل بريدك الإلكتروني';

  @override
  String get authEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get authPasswordRequired => 'أدخل كلمة المرور';

  @override
  String get authPasswordTooShort =>
      'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get authUsernameRequired => 'أدخل اسم المستخدم';

  @override
  String get authUsernameTooShort =>
      'يجب أن يحتوي اسم المستخدم على 6 أحرف على الأقل';

  @override
  String get authHidePassword => 'إخفاء كلمة المرور';

  @override
  String get authShowPassword => 'إظهار كلمة المرور';

  @override
  String get authAccountCreated =>
      'تم إنشاء الحساب بنجاح. سجّل الدخول للمتابعة.';

  @override
  String get authOr => 'أو';

  @override
  String get authContinueWithApple => 'المتابعة مع Apple';

  @override
  String get authContinueWithGoogle => 'المتابعة مع Google';

  @override
  String get authContinueWithReddit => 'المتابعة مع Reddit';

  @override
  String get authWelcomeBack => 'مرحباً بعودتك';

  @override
  String get authSignInSubtitle => 'سجّل الدخول لمتابعة ما توقفت عنده.';

  @override
  String get authCreateAccountSubtitle =>
      'انضم إلى المجتمع وشارك آراءك السينمائية.';

  @override
  String get authMinLengthHint => '6 أحرف على الأقل';

  @override
  String get authErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get authErrorRegisterFailed => 'تعذّر إنشاء حسابك. حاول مرة أخرى.';

  @override
  String get authErrorNetwork =>
      'تعذّر الوصول إلى الخادم. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get appWindowTitle => 'تطبيقي';

  @override
  String get findActionAdd => 'إضافة';

  @override
  String get findActionAdded => 'تمت الإضافة';

  @override
  String get reviewTranslate => 'ترجمة';

  @override
  String get reviewShowOriginal => 'عرض الأصل';

  @override
  String get reviewTranslateFailed => 'تعذّرت الترجمة الآن.';

  @override
  String reviewQuote(String body) {
    return '“$body”';
  }

  @override
  String get exploreCreateButton => 'إنشاء';

  @override
  String get topicCreateTitle => 'إنشاء موضوع';

  @override
  String get topicFindMovie => 'ابحث عن فيلم';

  @override
  String get topicSearchHint => 'ابحث عن أفلام';

  @override
  String get topicNoResults => 'لم يتم العثور على أفلام';

  @override
  String get topicChangeMovie => 'تغيير';

  @override
  String get topicTypeLabel => 'النوع';

  @override
  String get topicTagReview => 'رأي';

  @override
  String get topicTagQuestion => 'سؤال';

  @override
  String get topicTagDiscussion => 'نقاش';

  @override
  String get topicTagHotTake => 'Hot Take';

  @override
  String get topicReviewHint => 'يتطلب الرأي تفاعلك مع الفيلم.';

  @override
  String get topicBodyHint => 'اكتب رأيك أو سؤالك أو نقطة النقاش';

  @override
  String get topicPostButton => 'نشر';

  @override
  String get topicPostFailed => 'تعذّر النشر. حاول مرة أخرى.';

  @override
  String get topicSearchFailed => 'فشل البحث. حاول مرة أخرى.';

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
  String get leaderboardTabLabel => 'المتصدرون';

  @override
  String get leaderboardTitle => 'أفضل النقاد';

  @override
  String get leaderboardSubtitle => 'مرتبون حسب التفاعلات على آرائهم';

  @override
  String get leaderboardHowItWorks => 'كيف يعمل';

  @override
  String get leaderboardPeriodWeek => 'هذا الأسبوع';

  @override
  String get leaderboardPeriodMonth => 'هذا الشهر';

  @override
  String get leaderboardPeriodAll => 'كل الوقت';

  @override
  String get leaderboardReactionsLabel => 'تفاعلات';

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
      other: '$count آراء',
      one: 'رأي واحد',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardYouSuffix => '(أنت)';

  @override
  String get leaderboardEmpty => 'لا توجد تفاعلات في هذه الفترة بعد.';

  @override
  String get leaderboardLoadFailed => 'تعذر تحميل المتصدرين.';

  @override
  String get leaderboardRetry => 'حاول مرة أخرى';

  @override
  String get howRankingTitle => 'كيف يعمل الترتيب';

  @override
  String get howStep1Title => 'اكتب رأيًا';

  @override
  String get howStep1Body =>
      'شارك رأيك في أي فيلم. سيظهر في الاستكشاف والأصدقاء.';

  @override
  String get howStep2Title => 'اجمع التفاعلات';

  @override
  String get howStep2Body =>
      'يتفاعل القراء مع رأيك. كل تفاعل يساوي نقطة واحدة.';

  @override
  String get howStep3Title => 'تسلّق القائمة';

  @override
  String get howStep3Body => 'يصعد النقاد الأكثر تفاعلاً في الفترة إلى المنصة.';

  @override
  String get howNoteReset =>
      'يُعاد ضبط هذا الأسبوع كل يوم اثنين في الساعة 00:00. يستمر هذا الشهر وكل الوقت في الحساب.';

  @override
  String get howNoteOncePerReview =>
      'يمكن لكل شخص التفاعل مرة واحدة لكل رأي. التفاعل مع رأيك لا يُحتسب.';

  @override
  String get howNoteTie => 'إذا تعادل ناقدان، يتقدم من وصل إلى المجموع أولاً.';

  @override
  String get howNotePodium =>
      'يرتدي الثلاثة الأوائل إطار المنصة (ذهبي، أزرق، برونزي) في القائمة للفترة المعروضة.';

  @override
  String get howLevelsTitle => 'المستويات والخبرة';

  @override
  String get howXpReview => 'كتابة رأي';

  @override
  String get howXpComment => 'اكتب تعليقًا';

  @override
  String get howXpReaction => 'تلقي تفاعل';

  @override
  String howXpValue(int xp) {
    return '+$xp خبرة';
  }

  @override
  String get howLevelFoot => 'يحتاج كل مستوى إلى 50 خبرة أكثر من سابقه.';

  @override
  String get profileBadgesTitle => 'الشارات';

  @override
  String get badgeWellArguedTitle => 'حجة قوية';

  @override
  String badgeWellArguedDesc(int count) {
    return 'احصل على $count تفاعلاً « حجة قوية ».';
  }

  @override
  String get badgeChangedMindTitle => 'غيّرت رأيي';

  @override
  String badgeChangedMindDesc(int count) {
    return 'احصل على $count تفاعلاً « غيّرت رأيي ».';
  }

  @override
  String get badgeDisagreeTitle => 'أختلف لكن بإنصاف';

  @override
  String badgeDisagreeDesc(int count) {
    return 'احصل على $count تفاعلاً « أختلف لكن بإنصاف ».';
  }

  @override
  String get badgeTopCriticTitle => 'أفضل ناقد';

  @override
  String get badgeTopCriticDesc => 'أنهِ ضمن أفضل 3 هذا الأسبوع.';

  @override
  String get badgeFirstTakeTitle => 'أول رأي';

  @override
  String get badgeFirstTakeDesc => 'كن أول من يشارك رأيه في فيلم.';

  @override
  String get achFilmCriticTitle => 'ناقد أفلام';

  @override
  String achFilmCriticDesc(int count) {
    return 'اكتب $count رأيًا.';
  }

  @override
  String get achDebaterTitle => 'محاور';

  @override
  String achDebaterDesc(int count) {
    return 'احصل على $count تفاعلاً « حجة قوية ».';
  }

  @override
  String get achLocalCinemaTitle => 'السينما المحلية';

  @override
  String achLocalCinemaDesc(int count) {
    return 'شارك رأيك في $count فيلمًا تونسيًا.';
  }

  @override
  String get achComingSoon => 'قريبًا';

  @override
  String get frameNewcomerTitle => 'مبتدئ';

  @override
  String get frameExplorerTitle => 'مستكشف';

  @override
  String get frameDebaterTitle => 'محاور';

  @override
  String get frameTopCriticTitle => 'أفضل ناقد';

  @override
  String get frameLegendTitle => 'أسطورة';

  @override
  String get frameAlwaysUnlocked => 'يبدأ الجميع بهذا الإطار.';

  @override
  String frameLevelRequirement(int level) {
    return 'صل إلى المستوى $level.';
  }

  @override
  String frameDebaterRequirement(int count) {
    return 'احصل على $count تفاعلاً « حجة قوية ».';
  }

  @override
  String get frameEquipped => 'مُفعّل';

  @override
  String get frameTapToEquip => 'اضغط للتفعيل';

  @override
  String get frameUnlocked => 'مفتوح';

  @override
  String get frameLocked => 'مقفل';

  @override
  String get frameUpdateFailed => 'تعذّر تفعيل هذا الإطار. حاول مرة أخرى.';

  @override
  String profileLevelLabel(int level) {
    return 'المستوى $level';
  }

  @override
  String get profileStatComments => 'التعليقات';

  @override
  String get profileStatReactions => 'التفاعلات';

  @override
  String get profileFramesTitle => 'الإطارات';

  @override
  String profileXpProgress(int into, int span, int next) {
    return '$into / $span خبرة للمستوى $next';
  }

  @override
  String get topicDetailTitle => 'الموضوع';

  @override
  String topicCommentsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'التعليقات $count',
      zero: 'لا توجد تعليقات بعد',
    );
    return '$_temp0';
  }

  @override
  String get topicAboutFilm => 'عن هذا الفيلم';

  @override
  String get topicBeFirst => 'كن أول من يجيب.';

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
  String get browseSectionDiscover => 'اكتشف';

  @override
  String get browseTopTakes => 'أفضل 100 رأي';

  @override
  String get browsePopularFilms => 'الأفلام الأكثر شعبية';

  @override
  String get browseByYear => 'تصفح حسب السنة';

  @override
  String get browseByStreaming => 'تصفح حسب منصة البث';

  @override
  String get browseSectionTopics => 'المواضيع الأكثر شعبية';

  @override
  String get browsePolls => 'استطلاعات';

  @override
  String get browseConversations => 'محادثات';

  @override
  String get browseScenes => 'مشاهد';

  @override
  String get browseQuestions => 'أسئلة';

  @override
  String get browseHotTakes => 'آراء جريئة';

  @override
  String get browseSectionFilmSage => 'FilmSage';

  @override
  String get browseNewHere => 'جديد هنا؟';

  @override
  String get browseSocialMedia => 'وسائل التواصل الاجتماعي';

  @override
  String get browseFollowUs => 'تابعنا';

  @override
  String get browseGifts => 'هدايا';

  @override
  String get browseContact => 'اتصل بنا';

  @override
  String get browseTerms => 'شروط الاستخدام / سياسة المجتمع';

  @override
  String get browseYearsTitle => 'اختر سنة';

  @override
  String browseDecade(String decade) {
    return 'عقد $decade';
  }

  @override
  String get browseServicesTitle => 'اختر منصة بث';

  @override
  String get browseServicesEmpty => 'لا توجد منصات بث متاحة.';

  @override
  String get browseFilmsEmpty => 'لا توجد أفلام هنا بعد.';

  @override
  String get browseTakesEmpty => 'لم يُنشر شيء هنا بعد.';

  @override
  String get browseComingSoonTitle => 'قريبًا';

  @override
  String get browseComingSoonBody => 'ما زلنا نعمل على هذه الصفحة. عد قريبًا.';

  @override
  String get browseByGenre => 'تصفح حسب النوع';

  @override
  String get browseByCountry => 'تصفح حسب البلد';

  @override
  String get browseByLanguage => 'تصفح حسب اللغة';

  @override
  String get browseGenresTitle => 'اختر نوعًا';

  @override
  String get browseCountriesTitle => 'اختر بلدًا';

  @override
  String get browseCountriesHint => 'الأفلام الشائعة المتاحة للبث في كل بلد.';

  @override
  String browseStreamingIn(String country) {
    return 'متاح للبث في $country';
  }

  @override
  String get browseLanguagesTitle => 'اختر لغة';

  @override
  String get browsePickEmpty => 'لا توجد خيارات حاليًا.';

  @override
  String get browseLanguageEn => 'الإنجليزية';

  @override
  String get browseLanguageFr => 'الفرنسية';

  @override
  String get browseLanguageEs => 'الإسبانية';

  @override
  String get browseLanguageIt => 'الإيطالية';

  @override
  String get browseLanguageDe => 'الألمانية';

  @override
  String get browseLanguagePt => 'البرتغالية';

  @override
  String get browseLanguageRu => 'الروسية';

  @override
  String get browseLanguageAr => 'العربية';

  @override
  String get browseLanguageTr => 'التركية';

  @override
  String get browseLanguageHi => 'الهندية';

  @override
  String get browseLanguageKo => 'الكورية';

  @override
  String get browseLanguageJa => 'اليابانية';

  @override
  String get browseLanguageZh => 'الصينية';

  @override
  String get browseLanguageSv => 'السويدية';

  @override
  String get overviewPlayTrailer => 'تشغيل الإعلان';

  @override
  String get overviewTrailerUnavailable => 'تعذّر فتح الإعلان.';

  @override
  String get overviewLoading => 'جارٍ التحميل…';

  @override
  String get overviewNoCastCrew => 'لا توجد معلومات عن طاقم العمل بعد.';

  @override
  String get overviewOfferStream => 'بث';

  @override
  String get overviewOfferFree => 'مجانًا';

  @override
  String get overviewOfferTvProvider => 'مع مزوّد تلفزيون';

  @override
  String get overviewOfferRent => 'استئجار';

  @override
  String get overviewOfferBuy => 'شراء';

  @override
  String get overviewCloseTrailer => 'إغلاق الإعلان';

  @override
  String get filmSuggest => 'اقترح';

  @override
  String get filmListFailed => 'تعذّر تحديث قائمتك. حاول مجددًا.';

  @override
  String get filmFeelingsEmpty => 'اضغط لتخبرنا بما شعرت';

  @override
  String get filmFeelingsHint => 'اختر حتى 3 مشاعر.';

  @override
  String filmFeelingsCount(String count) {
    return 'تم اختيار $count من 3';
  }

  @override
  String get filmFeelingsSave => 'حفظ';

  @override
  String get filmFeelingsClear => 'مسح';

  @override
  String get filmAudienceTitle => 'الجمهور';

  @override
  String get filmAudienceEmpty =>
      'لا توجد تفاعلات بعد. كن أول من يخبرنا بما شعر.';

  @override
  String get filmAudiencePositive => 'استمتعوا به';

  @override
  String filmAudiencePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تفاعل $count أشخاص',
      one: 'تفاعل شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get filmYourTakeTitle => 'رأيك';

  @override
  String filmTakeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آراء',
      one: 'رأي واحد',
    );
    return '$_temp0';
  }

  @override
  String get filmTopTake => 'أفضل رأي';

  @override
  String filmShowMoreTakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عرض $count آراء أخرى',
      one: 'عرض رأي آخر',
    );
    return '$_temp0';
  }

  @override
  String get filmShowLessTakes => 'عرض أقل';

  @override
  String get filmShareYourTake => 'شارك رأيك';

  @override
  String get filmAddTake => 'أضف رأيًا';

  @override
  String overviewFriendStoryNew(String name, String feeling) {
    return '$name، جديد: $feeling';
  }

  @override
  String overviewFriendStorySeen(String name, String feeling) {
    return '$name: $feeling';
  }

  @override
  String filmPersonFeelings(String feelings) {
    return 'الشعور: $feelings';
  }

  @override
  String filmTakeComments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تعليقات',
      one: 'تعليق واحد',
      zero: 'لا تعليقات',
    );
    return '$_temp0';
  }

  @override
  String get filmFeelingsDone => 'تم';

  @override
  String get personBiography => 'السيرة الذاتية';

  @override
  String get personFilmography => 'الأفلام';

  @override
  String get personHeight => 'الطول';

  @override
  String get personBorn => 'تاريخ الميلاد';

  @override
  String get personDied => 'تاريخ الوفاة';

  @override
  String get personNoFilms => 'لا توجد أفلام لهذا الشخص بعد.';

  @override
  String get personLoadFailed => 'تعذّر تحميل صفحة هذا الشخص.';

  @override
  String personAsCharacter(String character) {
    return 'بدور $character';
  }

  @override
  String get takeSkinTitle => 'مظهر البطاقة';

  @override
  String get takeSkinNormal => 'عادي';

  @override
  String get takeSkinElectricThunder => 'رعد كهربائي';

  @override
  String get takeSkinPreview => 'معاينة';

  @override
  String get takeSkinPreviewEmpty => 'سيظهر رأيك هنا.';

  @override
  String get takeSkinWriteTitle => 'اكتب رأيك';

  @override
  String get reviewAlreadyShared => 'لقد شاركت رأيك في هذا الفيلم من قبل.';

  @override
  String get reviewNeedsFeeling =>
      'اختر أولاً شعورك تجاه الفيلم، ثم شارك رأيك.';

  @override
  String get reviewYourTake => 'رأيك — يتفاعل معه الآخرون';

  @override
  String get reviewBeFirstComment => 'كن أول من يعلّق على هذا الرأي.';

  @override
  String get takeMenuTooltip => 'خيارات أخرى';

  @override
  String get takeActionShare => 'إرسال إلى الأصدقاء';

  @override
  String get takeActionEdit => 'تعديل';

  @override
  String get takeActionDelete => 'حذف';

  @override
  String get takeActionReport => 'إبلاغ';

  @override
  String get takeEdited => 'مُعدَّل';

  @override
  String get takeCancel => 'إلغاء';

  @override
  String get takeEditTitle => 'تعديل رأيك';

  @override
  String get takeEditSave => 'حفظ';

  @override
  String get takeEditSaved => 'تم تحديث رأيك.';

  @override
  String get takeEditFailed => 'تعذّر حفظ التعديلات. حاول مرة أخرى.';

  @override
  String get takeDeleteTitle => 'حذف هذا الرأي؟';

  @override
  String get takeDeleteBody => 'سيُحذف للجميع مع تعليقاته.';

  @override
  String get takeDeleted => 'تم حذف الرأي.';

  @override
  String get takeDeleteFailed => 'تعذّر الحذف. حاول مرة أخرى.';

  @override
  String get takeReportTitle => 'الإبلاغ عن هذا الرأي';

  @override
  String get takeReportHint => 'لماذا تبلّغ عنه؟ المشرفون فقط يرون البلاغات.';

  @override
  String get takeReportSpam => 'رسائل مزعجة';

  @override
  String get takeReportHarassment => 'تحرّش أو تنمّر';

  @override
  String get takeReportHate => 'خطاب كراهية';

  @override
  String get takeReportSpoiler => 'حرق أحداث دون تنبيه';

  @override
  String get takeReportOther => 'سبب آخر';

  @override
  String get takeReportDetailsHint => 'أضف تفاصيل (اختياري)';

  @override
  String get takeReportSend => 'إرسال البلاغ';

  @override
  String get takeReportThanks => 'شكرًا. سيراجعه فريقنا.';

  @override
  String get takeReportFailed => 'تعذّر إرسال البلاغ. حاول مرة أخرى.';

  @override
  String get takeShareTitle => 'إرسال إلى الأصدقاء';

  @override
  String get takeShareMessageHint => 'أضف رسالة (اختياري)';

  @override
  String get takeShareNoFriends => 'أضف أصدقاء لترسل لهم الآراء.';

  @override
  String get takeShareFriendsFailed => 'تعذّر تحميل أصدقائك.';

  @override
  String get takeShareFailed => 'تعذّر الإرسال. حاول مرة أخرى.';

  @override
  String get notificationTakeGone => 'هذا الرأي لم يعد متاحًا.';

  @override
  String get mentionSuggestionsLabel => 'أشر إلى صديق';

  @override
  String takeShareSend(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إرسال إلى $count أصدقاء',
      one: 'إرسال إلى صديق واحد',
      zero: 'إرسال',
    );
    return '$_temp0';
  }

  @override
  String takeShareSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُرسل إلى $count أصدقاء',
      one: 'أُرسل إلى صديق واحد',
    );
    return '$_temp0';
  }

  @override
  String notificationTakeShared(String name) {
    return 'أرسل لك $name رأيًا';
  }

  @override
  String notificationTakeMention(String name) {
    return 'أشار إليك $name في تعليق';
  }

  @override
  String get takeSpoilerTitle => 'هل يحتوي على حرق للأحداث؟';

  @override
  String get takeSpoilerNo => 'لا حرق للأحداث';

  @override
  String get takeSpoilerHint => 'اختر واحدًا ليعرف القراء ما ينتظرهم.';

  @override
  String get takeSpoilerRequired =>
      'حدّد إن كان رأيك يحتوي على حرق للأحداث قبل المشاركة.';

  @override
  String get takeSpoilerBlurNote => 'سيراه الآخرون ضبابيًا حتى يضغطوا للكشف.';

  @override
  String get reviewVoteUp => 'مع';

  @override
  String get reviewVoteDraw => 'تعادل';

  @override
  String get reviewVoteDown => 'ضد';

  @override
  String storyTake(String film) {
    return 'شارك رأيًا عن $film';
  }

  @override
  String storyQuestion(String film) {
    return 'سأل عن $film';
  }

  @override
  String storyDiscussion(String film) {
    return 'بدأ نقاشًا حول $film';
  }

  @override
  String storyHotTake(String film) {
    return 'طرح رأيًا جريئًا عن $film';
  }

  @override
  String storyPoll(String film) {
    return 'أنشأ استطلاعًا عن $film';
  }

  @override
  String storyScene(String film) {
    return 'شارك مشهدًا من $film';
  }

  @override
  String storyComment(String film) {
    return 'علّق على منشور عن $film';
  }

  @override
  String get storyUnknownFilm => 'فيلم';

  @override
  String get storyOpen => 'فتح';

  @override
  String get storyClose => 'إغلاق';

  @override
  String storyRingLabel(String name) {
    return 'قصة $name';
  }

  @override
  String get storiesTitle => 'قصص الأصدقاء';

  @override
  String get inboxSearch => 'بحث';

  @override
  String get inboxSearchHint => 'ابحث في المحادثات';

  @override
  String get inboxCloseSearch => 'إغلاق البحث';

  @override
  String get inboxUnreadOnly => 'غير المقروءة فقط';

  @override
  String get inboxAddFriend => 'إضافة صديق';

  @override
  String get inboxCreate => 'محادثة جديدة';

  @override
  String get inboxNewMessage => 'رسالة جديدة';

  @override
  String get inboxCreateGroup => 'إنشاء مجموعة';

  @override
  String get inboxCreateTopic => 'إنشاء موضوع خاص';

  @override
  String get inboxPrivateTopics => 'مواضيع خاصة';

  @override
  String get inboxNoTopics => 'لا مواضيع بعد. ابدأ واحدًا مع أصدقائك.';

  @override
  String get inboxNewTopic => 'موضوع خاص جديد';

  @override
  String get inboxAllChats => 'كل المحادثات';

  @override
  String get inboxEmptyTitle => 'لا محادثات بعد';

  @override
  String get inboxEmptyBody => 'راسل صديقًا لتبدأ الدردشة.';

  @override
  String get inboxNoResults => 'لا توجد محادثات';

  @override
  String get inboxLoadFailed => 'تعذّر تحميل رسائلك.';

  @override
  String inboxYouSaid(String text) {
    return 'أنت: $text';
  }

  @override
  String get inboxNoMessagesYet => 'لا رسائل بعد';

  @override
  String get inboxGroupName => 'اسم المجموعة';

  @override
  String get inboxTopicName => 'اسم الموضوع';

  @override
  String get inboxPickFriends => 'اختر أصدقاء';

  @override
  String get inboxPickFriend => 'راسل صديقًا';

  @override
  String get inboxNoFriends => 'أضف أصدقاء أولًا للدردشة معهم.';

  @override
  String get inboxCreateAction => 'إنشاء';

  @override
  String get inboxCancel => 'إلغاء';

  @override
  String get inboxCreateFailed => 'تعذّر الإنشاء. حاول مجددًا.';

  @override
  String inboxMembers(int count) {
    return '$count أعضاء';
  }

  @override
  String get inboxGroupPhoto => 'أضف صورة للمجموعة';

  @override
  String get inboxGroupDescription => 'الوصف (اختياري)';

  @override
  String get inboxPhotoFailed => 'تم الإنشاء، لكن الصورة لم تُرفع.';

  @override
  String get chatOpenInfo => 'معلومات المجموعة';

  @override
  String get groupInfoTitle => 'معلومات المجموعة';

  @override
  String get groupInfoTopicTitle => 'معلومات الموضوع';

  @override
  String get groupInfoDescription => 'الوصف';

  @override
  String get groupInfoNoDescription => 'لا يوجد وصف بعد.';

  @override
  String groupInfoMembers(int count) {
    return 'الأعضاء · $count';
  }

  @override
  String get groupInfoYou => 'أنت';

  @override
  String get groupInfoCreator => 'المنشئ';

  @override
  String inboxUnreadLabel(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get chatHint => 'اكتب رسالة';

  @override
  String get chatSend => 'إرسال';

  @override
  String get chatStart => 'ابدأ المحادثة';

  @override
  String get chatSendFailed => 'لم تُرسل الرسالة. حاول مجددًا.';

  @override
  String get chatPrivateTopic => 'موضوع خاص · يراه الأعضاء فقط';

  @override
  String get inboxSelectChat => 'اختر محادثة لتبدأ الدردشة';

  @override
  String get chatMenu => 'قائمة المجموعة';

  @override
  String get chatShareGroup => 'مشاركة المجموعة';

  @override
  String get chatBoostGroup => 'ترويج المجموعة';

  @override
  String get chatReport => 'إبلاغ';

  @override
  String get chatLeaveGroup => 'مغادرة المجموعة';

  @override
  String get chatShareBody => 'أرسل المجموعة إلى محادثة.';

  @override
  String chatSharedTo(String name) {
    return 'تمت المشاركة في $name';
  }

  @override
  String chatBoosted(String name) {
    return 'بدأ ترويج $name';
  }

  @override
  String get chatReportTitle => 'الإبلاغ عن هذه المجموعة';

  @override
  String get chatReportBody => 'أخبرنا بما هو خطأ. لن يتم إعلام الأعضاء.';

  @override
  String get chatReportSpam => 'رسائل مزعجة أو احتيال';

  @override
  String get chatReportHarassment => 'تحرش';

  @override
  String get chatReportOther => 'شيء آخر';

  @override
  String get chatReportSent => 'تم إرسال البلاغ';

  @override
  String get chatCancel => 'إلغاء';

  @override
  String get chatClose => 'إغلاق';

  @override
  String get chatBack => 'رجوع';

  @override
  String get chatActionFailed => 'لم ينجح ذلك. حاول مرة أخرى.';

  @override
  String get chatPinned => 'مثبّتة';

  @override
  String chatPinnedCount(int count) {
    return 'مثبّتة ($count)';
  }

  @override
  String get chatReply => 'رد';

  @override
  String chatReplyingTo(String name) {
    return 'رد على $name';
  }

  @override
  String get chatCancelReply => 'إلغاء الرد';

  @override
  String get chatPin => 'تثبيت الرسالة';

  @override
  String get chatUnpin => 'إلغاء تثبيت الرسالة';

  @override
  String get chatMessagePinned => 'تم تثبيت الرسالة';

  @override
  String get chatMessageUnpinned => 'تم إلغاء تثبيت الرسالة';

  @override
  String chatMention(String name) {
    return 'الإشارة إلى $name';
  }

  @override
  String get chatViewProfile => 'عرض الملف الشخصي';

  @override
  String get chatMoreReactions => 'تفاعلات أكثر';

  @override
  String chatNotified(String names) {
    return 'تم إعلام $names';
  }

  @override
  String get chatNoMatch => 'لا يوجد تطابق';

  @override
  String get chatAdd => 'إضافة صورة أو فيديو أو فيلم أو استطلاع';

  @override
  String get chatEmojiButton => 'إيموجي وصور متحركة وملصقات';

  @override
  String get chatAddTitle => 'إضافة إلى المحادثة';

  @override
  String get chatPhoto => 'صورة';

  @override
  String get chatPhotoBody => 'اختر صورة من جهازك.';

  @override
  String get chatVideo => 'فيديو';

  @override
  String get chatVideoBody => 'اختر فيديو من جهازك.';

  @override
  String get chatMovie => 'فيلم';

  @override
  String get chatMovieBody => 'ابحث عن فيلم وشاركه كبطاقة.';

  @override
  String get chatPoll => 'استطلاع';

  @override
  String get chatPollBody => 'اطرح سؤالًا على المجموعة.';

  @override
  String get chatSendPhoto => 'إرسال الصورة';

  @override
  String get chatSendVideo => 'إرسال الفيديو';

  @override
  String get chatShareMovie => 'مشاركة الفيلم';

  @override
  String get chatNewPoll => 'استطلاع جديد';

  @override
  String get chatCaption => 'أضف تعليقًا';

  @override
  String get chatPollQuestion => 'اطرح سؤالًا';

  @override
  String chatPollOption(int number) {
    return 'الخيار $number';
  }

  @override
  String get chatAddOption => 'إضافة خيار';

  @override
  String get chatAllowedReactions => 'التفاعلات المسموح بها على هذا المنشور';

  @override
  String get chatAllowedReactionsBody =>
      'يمكن للأعضاء التفاعل بالإيموجي التي تختارها. يضغطون مطولًا على الرسالة لرؤيتها.';

  @override
  String get chatPollInvalid => 'أضف سؤالًا وخيارين على الأقل';

  @override
  String get chatFileTooBig => 'هذا الملف كبير جدًا (12 ميغابايت كحد أقصى)';

  @override
  String get chatSearchMovie => 'البحث عن فيلم';

  @override
  String get chatSearchMovieHint => 'عنوان الفيلم';

  @override
  String get chatNoMovie => 'لم يتم العثور على فيلم.';

  @override
  String chatVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أصوات',
      one: 'صوت واحد',
    );
    return '$_temp0';
  }

  @override
  String get chatPlayVideo => 'تشغيل الفيديو';

  @override
  String get chatGif => 'صورة متحركة';

  @override
  String get chatSticker => 'ملصق';

  @override
  String get chatTabEmoji => 'إيموجي';

  @override
  String get chatTabGif => 'GIF';

  @override
  String get chatTabStickers => 'ملصقات';

  @override
  String get chatSearchEmoji => 'ابحث عن الإيموجي المناسب';

  @override
  String get chatSearchGif => 'البحث عن صور متحركة';

  @override
  String get chatSearchStickers => 'البحث عن ملصقات';

  @override
  String chatNothingFound(String query) {
    return 'لا نتائج لـ «$query».';
  }

  @override
  String get chatCatFrequent => 'الأكثر استخدامًا';

  @override
  String get chatCatFaces => 'وجوه';

  @override
  String get chatCatHands => 'أيادٍ';

  @override
  String get chatCatObjects => 'أشياء';

  @override
  String get chatCatSymbols => 'رموز';

  @override
  String get chatClosePicker => 'إغلاق اللوحة';

  @override
  String sysPinned(String name) {
    return 'ثبّت $name رسالة';
  }

  @override
  String sysRemoved(String name, String target) {
    return 'أزال $name $target من المجموعة';
  }

  @override
  String sysLeft(String name) {
    return 'غادر $name المجموعة';
  }

  @override
  String sysHeritage(String name, String target) {
    return 'جعل $name $target المنشئ الوريث';
  }

  @override
  String sysPassed(String name, String target) {
    return 'نقل $name دور المنشئ إلى $target وغادر';
  }

  @override
  String sysVoteStarted(String name) {
    return 'بدأ $name تصويتًا على إبقاء هذه المجموعة';
  }

  @override
  String sysVoteCancelled(String name) {
    return 'ألغى $name التصويت';
  }

  @override
  String get sysVoteKeep =>
      'صوّت معظم الأعضاء لإبقاء المجموعة. اختاروا الآن مالكًا جديدًا.';

  @override
  String sysVoteOwnerWon(String target) {
    return 'فاز $target بالتصويت وأصبح المنشئ الوريث';
  }

  @override
  String get voteKeepTitle => 'إبقاء هذه المجموعة؟';

  @override
  String voteKeepBody(String name, String time) {
    return 'طلب $name المغادرة. أمام الأعضاء $time للتصويت. الأغلبية تقرر، والتعادل يبقي المجموعة.';
  }

  @override
  String get voteStay => 'إبقاء';

  @override
  String get voteDelete => 'حذف';

  @override
  String voteKeepTally(int stay, int delete) {
    return 'إبقاء $stay · حذف $delete';
  }

  @override
  String get voteOwnPoll => 'لا يمكنك التصويت في استطلاعك.';

  @override
  String get voteCancel => 'إلغاء التصويت والبقاء منشئًا';

  @override
  String get voteOwnerTitle => 'من يجب أن يملك هذه المجموعة؟';

  @override
  String voteOwnerBody(String time) {
    return 'المجموعة باقية. اختر عضوًا غيرك. المتبقي $time.';
  }

  @override
  String get voteOwnerHint => 'اضغط على عضو للتصويت.';

  @override
  String get voteOwnerChange => 'يمكنك تغيير صوتك حتى نهاية التصويت.';

  @override
  String voteTimeLeft(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get voteRunning => 'هناك تصويت جارٍ بالفعل';

  @override
  String get leaveCreatorTitle => 'أنت أنشأت هذه المجموعة';

  @override
  String get leaveCreatorBody => 'قبل أن تغادر، اختر ماذا يحدث للمجموعة.';

  @override
  String get leavePass => 'نقل دور المنشئ';

  @override
  String get leavePassBody => 'اختر عضوًا. سيتولى المجموعة فورًا.';

  @override
  String get leaveVote => 'دع المجموعة تقرر';

  @override
  String get leaveVoteBody =>
      'يصوّت الأعضاء على إبقاء المجموعة أو حذفها، ثم على مالكها. كل تصويت يستغرق 24 ساعة.';

  @override
  String get leavePickTitle => 'من سيتولى المجموعة؟';

  @override
  String get leavePickBody =>
      'يحصل على دور المنشئ الوريث ويحتفظ بالإبلاغ والمشاركة والترويج.';

  @override
  String get leaveContinue => 'متابعة';

  @override
  String leavePassConfirmTitle(String name) {
    return 'نقل الدور إلى $name والمغادرة؟';
  }

  @override
  String leavePassConfirmBody(String name) {
    return 'يصبح $name المنشئ الوريث فورًا. ستغادر المجموعة.';
  }

  @override
  String get leavePassConfirm => 'نقل الدور والمغادرة';

  @override
  String get leaveVoteConfirmTitle => 'بدء تصويت المجموعة؟';

  @override
  String get leaveVoteConfirmBody =>
      'الخطوة 1: يصوّت الأعضاء على إبقاء المجموعة أو حذفها لمدة 24 ساعة. إذا اختارت الأغلبية الإبقاء، يختارون في الخطوة 2 المالك الجديد لمدة 24 ساعة أخرى. تبقى المنشئ حتى النهاية.';

  @override
  String get leaveVoteConfirm => 'بدء التصويت';

  @override
  String leaveSimpleTitle(String group) {
    return 'مغادرة $group؟';
  }

  @override
  String get leaveSimpleBody => 'لن ترى رسائل هذه المجموعة بعد الآن.';

  @override
  String confirmType(String name) {
    return 'للتأكيد، اكتب $name';
  }

  @override
  String get groupInfoSearch => 'البحث عن أعضاء';

  @override
  String groupInfoNoMatch(String query) {
    return 'لا يوجد أعضاء يطابقون «$query».';
  }

  @override
  String get groupInfoHeritage => 'المنشئ الوريث';

  @override
  String memberViewProfileBody(String name) {
    return 'شاهد أفلام $name ومجموعاته.';
  }

  @override
  String get memberMakeHeritage => 'تعيين منشئ وريث';

  @override
  String memberMakeHeritageBody(String name) {
    return 'يتولى $name المجموعة. تصبح عضوًا عاديًا.';
  }

  @override
  String get memberRemove => 'إزالة من المجموعة';

  @override
  String memberRemoveBody(String name) {
    return 'يفقد $name الوصول إلى المجموعة ورسائلها.';
  }

  @override
  String memberMakeHeritageTitle(String name) {
    return 'تعيين $name منشئًا وريثًا؟';
  }

  @override
  String memberMakeHeritageConfirmBody(String name) {
    return 'يحصل $name على دور المنشئ الوريث ويمكنه الإبلاغ عن المجموعة ومشاركتها وترويجها. تبقى في المجموعة كعضو عادي.';
  }

  @override
  String memberRemoveTitle(String name) {
    return 'إزالة $name؟';
  }

  @override
  String memberRemoveConfirmBody(String name, String group) {
    return 'سيفقد $name الوصول إلى $group ولن يرى الرسائل الجديدة.';
  }

  @override
  String memberRemoveConfirm(String name) {
    return 'إزالة $name';
  }

  @override
  String get chatVideoFailed => 'تعذّر تشغيل هذا الفيديو.';

  @override
  String get chatPauseVideo => 'إيقاف الفيديو مؤقتًا';

  @override
  String get chatFullScreen => 'ملء الشاشة';

  @override
  String get chatMute => 'كتم';

  @override
  String get chatUnmute => 'إلغاء الكتم';

  @override
  String get chatMutedToast => 'تم كتم المحادثة';

  @override
  String get chatUnmutedToast => 'تم إلغاء كتم المحادثة';

  @override
  String get chatPinChat => 'تثبيت في الأعلى';

  @override
  String get chatUnpinChat => 'إلغاء التثبيت';

  @override
  String get chatMarkUnread => 'تعليم كغير مقروء';

  @override
  String get chatMarkRead => 'تعليم كمقروء';

  @override
  String get chatClearHistory => 'مسح السجل';

  @override
  String get chatClearTitle => 'مسح السجل؟';

  @override
  String get chatClearBody =>
      'تختفي كل الرسائل حتى الآن بالنسبة لك. يظل الآخرون يرونها.';

  @override
  String get chatCleared => 'تم مسح السجل';

  @override
  String get chatDeleteChat => 'حذف المحادثة';

  @override
  String get chatDeleteChatTitle => 'حذف هذه المحادثة؟';

  @override
  String chatDeleteChatBody(String name) {
    return 'ستختفي من صندوقك ويُمسح سجلها لديك. ستعود إذا كتب $name مرة أخرى.';
  }

  @override
  String get chatChatDeleted => 'تم حذف المحادثة';

  @override
  String chatBlock(String name) {
    return 'حظر $name';
  }

  @override
  String chatUnblock(String name) {
    return 'إلغاء حظر $name';
  }

  @override
  String chatBlockTitle(String name) {
    return 'حظر $name؟';
  }

  @override
  String get chatBlockBody =>
      'لن يتمكن أي منكما من مراسلة الآخر حتى تلغي الحظر. لن يتم إخباره.';

  @override
  String chatBlockedToast(String name) {
    return 'تم حظر $name';
  }

  @override
  String chatUnblockedToast(String name) {
    return 'تم إلغاء حظر $name';
  }

  @override
  String chatYouBlocked(String name) {
    return 'لقد حظرت $name.';
  }

  @override
  String get chatBlockedYou => 'لا يمكنك الرد على هذه المحادثة.';

  @override
  String get chatBlockedPeople => 'الأشخاص المحظورون';

  @override
  String get chatNoBlocked => 'لم تحظر أحدًا.';

  @override
  String get chatUnblockShort => 'إلغاء الحظر';

  @override
  String get chatCopy => 'نسخ النص';

  @override
  String get chatCopied => 'تم النسخ';

  @override
  String get chatEdit => 'تعديل';

  @override
  String get chatEditing => 'تعديل الرسالة';

  @override
  String get chatCancelEdit => 'إلغاء التعديل';

  @override
  String get chatDeleteMessage => 'حذف';

  @override
  String get chatDeleteMessageTitle => 'حذف هذه الرسالة؟';

  @override
  String get chatDeleteMessageBody => 'ستُحذف لدى الجميع في المحادثة.';

  @override
  String get chatMessageDeleted => 'تم حذف هذه الرسالة';

  @override
  String get chatEdited => 'معدّلة';

  @override
  String get chatReportMessage => 'الإبلاغ عن الرسالة';

  @override
  String get chatReportHate => 'خطاب كراهية';

  @override
  String get chatReportNsfw => 'محتوى جنسي';

  @override
  String get chatSeen => 'شوهدت';

  @override
  String get chatAddMembers => 'إضافة أعضاء';

  @override
  String chatAddMembersTitle(String name) {
    return 'إضافة إلى $name';
  }

  @override
  String get chatAddMembersNone => 'كل أصدقائك هنا بالفعل.';

  @override
  String get chatAddSelected => 'إضافة';

  @override
  String get chatMembersAdded => 'تمت إضافة الأعضاء';

  @override
  String get chatConfirm => 'تأكيد';

  @override
  String get chatViewProfileMenu => 'عرض الملف';

  @override
  String inboxChatOptions(String name) {
    return 'خيارات $name';
  }

  @override
  String get inboxPinnedLabel => 'مثبتة';

  @override
  String get inboxMutedLabel => 'مكتومة';

  @override
  String sysAdded(String name, String target) {
    return 'أضاف $name $target';
  }

  @override
  String get homeTopicFirstReply => 'كن أول من يرد';

  @override
  String get homeFriendsActivityTitle => 'نشاط الأصدقاء';

  @override
  String get homeFriendsActivityResize => 'تغيير حجم نشاط الأصدقاء';

  @override
  String get topicTitleHint => 'العنوان (اختياري)';

  @override
  String get topicSeeMore => 'عرض المزيد';

  @override
  String get topicCommentsExpand => 'توسيع التعليقات';

  @override
  String get topicCommentsShrink => 'تصغير التعليقات';

  @override
  String get chatTakeShared => 'شارك رأيًا';

  @override
  String get chatTopicShared => 'شارك موضوعًا';

  @override
  String get chatTaggedYou => 'أشار إليك في تعليق';

  @override
  String get chatYouTagged => 'أشرت إليه في تعليق';

  @override
  String get chatTaggedThem => 'أشار إليه في تعليق';

  @override
  String get chatYouSharedTopic => 'شاركت موضوعًا';

  @override
  String get chatYouSharedTake => 'شاركت رأيًا';

  @override
  String get commentAddPhoto => 'إضافة صورة';

  @override
  String get commentRemovePhoto => 'إزالة الصورة';

  @override
  String get takeFeltLabel => 'شعر بـ';

  @override
  String homeEditList(String list) {
    return 'تعديل $list';
  }

  @override
  String get homeEditListAdd => 'إضافة فيلم';

  @override
  String homeEditListRemove(String title) {
    return 'إزالة $title';
  }

  @override
  String get homeEditListEmpty => 'لا توجد أفلام هنا بعد.';

  @override
  String get homeEditListFull => 'قائمة أفضل 5 ممتلئة. أزل فيلمًا لإضافة آخر.';

  @override
  String get homeWatchedHint => 'أفلام شاهدتها بالفعل';

  @override
  String get homeWatchlistHint => 'أفلام تريد مشاهدتها';

  @override
  String get homeLensHint => 'مرّر إصبعك فوق الملصقات';

  @override
  String homeLensOpen(String title) {
    return 'فتح $title';
  }

  @override
  String get homeListMore => 'خيارات أخرى';

  @override
  String get homeListShare => 'شارك قائمتك';

  @override
  String get homeListRandom => 'اختيار عشوائي';

  @override
  String get homeListShuffle => 'اختر فيلمًا آخر';

  @override
  String homeListShareText(String list) {
    return 'قائمتي $list على FilmSage:';
  }

  @override
  String get takeHeartLike => 'إعجاب';

  @override
  String takeHeartCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعجاب',
      many: '$count إعجابًا',
      few: '$count إعجابات',
      two: 'إعجابان',
      one: 'إعجاب واحد',
      zero: 'لا إعجابات',
    );
    return '$_temp0';
  }

  @override
  String get myListsTitle => 'قوائمي';

  @override
  String get myListsHint => 'القوائم التي أنشأتها ونشرتها';

  @override
  String get friendsListsTitle => 'قوائم أصدقائك';

  @override
  String get friendsListsHint => 'ما جمعه أصدقاؤك';

  @override
  String get listNew => 'قائمة جديدة';

  @override
  String get listsEmptyMine =>
      'أنشئ قائمتك الأولى: اختر لها اسمًا وبعض الأفلام.';

  @override
  String get listCreateTitle => 'قائمة جديدة';

  @override
  String get listNameLabel => 'اسم القائمة';

  @override
  String get listNameHint => 'أفضل أفلام السرقة';

  @override
  String get listSearchHint => 'ابحث عن أفلام لإضافتها';

  @override
  String listAddFilm(String title) {
    return 'إضافة $title';
  }

  @override
  String listRemoveFilm(String title) {
    return 'إزالة $title';
  }

  @override
  String get listPost => 'نشر القائمة';

  @override
  String listFilmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فيلم',
      many: '$count فيلمًا',
      few: '$count أفلام',
      two: 'فيلمان',
      one: 'فيلم واحد',
    );
    return '$_temp0';
  }

  @override
  String listBy(String name) {
    return 'بواسطة $name';
  }

  @override
  String get listCommentsTitle => 'التعليقات';

  @override
  String get listCommentHint => 'أضف تعليقًا';

  @override
  String get listCommentsEmpty =>
      'لا توجد تعليقات بعد. قل رأيك في هذه القائمة.';

  @override
  String listCommentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تعليق',
      many: '$count تعليقًا',
      few: '$count تعليقات',
      two: 'تعليقان',
      one: 'تعليق واحد',
      zero: 'لا تعليقات',
    );
    return '$_temp0';
  }

  @override
  String get listDelete => 'حذف القائمة';

  @override
  String get listDeleteConfirm => 'حذف هذه القائمة؟ لا يمكن التراجع.';

  @override
  String get listCancel => 'إلغاء';

  @override
  String get listPostFailed => 'تعذّر نشر القائمة. حاول مجددًا.';

  @override
  String get listLoadFailed => 'تعذّر تحميل القوائم.';

  @override
  String listPicked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count فيلم',
      many: 'تم اختيار $count فيلمًا',
      few: 'تم اختيار $count أفلام',
      two: 'تم اختيار فيلمين',
      one: 'تم اختيار فيلم واحد',
      zero: 'لا أفلام بعد',
    );
    return '$_temp0';
  }

  @override
  String get listSearchEmpty => 'لم يتم العثور على أفلام.';

  @override
  String get listSendFailed => 'تعذّر الإرسال. حاول مجددًا.';

  @override
  String get takeActionSave => 'حفظ';

  @override
  String get takeActionUnsave => 'إزالة من المحفوظات';

  @override
  String get takeSavedToast => 'تم الحفظ في ملفك الشخصي';

  @override
  String get takeUnsavedToast => 'تمت الإزالة من مواضيعك المحفوظة';

  @override
  String get takeSaveFailed => 'تعذّر الحفظ. حاول مجددًا.';

  @override
  String get profileSavedTitle => 'المحفوظات';

  @override
  String get profileSavedEmpty => 'المواضيع التي تحفظها تظهر هنا.';

  @override
  String get listShare => 'مشاركة القائمة';

  @override
  String listShareText(String name, String owner) {
    return '$name — قائمة من $owner على Film Wise';
  }

  @override
  String get listSave => 'حفظ القائمة';

  @override
  String get listUnsave => 'إزالة من المحفوظات';

  @override
  String get listSavedToast => 'تم حفظ القائمة في ملفك الشخصي';

  @override
  String get listUnsavedToast => 'تمت إزالة القائمة من قوائمك المحفوظة';

  @override
  String get listSaveFailed => 'تعذّر حفظ القائمة. حاول مجددًا.';

  @override
  String get listEdit => 'تعديل القائمة';

  @override
  String get listEditTitle => 'تعديل القائمة';

  @override
  String get listSaveChanges => 'حفظ التغييرات';

  @override
  String get savedListsTitle => 'القوائم المحفوظة';

  @override
  String get savedListsHint => 'قوائم الآخرين التي احتفظت بها';

  @override
  String get listMenuTooltip => 'المزيد';

  @override
  String get listShareNoFriends => 'أضف أصدقاء لترسل لهم القوائم.';

  @override
  String get chatListShared => 'شارك قائمة';

  @override
  String get chatYouSharedList => 'شاركت قائمة';

  @override
  String get notificationsMarkAllRead => 'تعليم الكل كمقروء';

  @override
  String get notificationsTabAll => 'الكل';

  @override
  String get notificationsTabTakes => 'الآراء';

  @override
  String get notificationsTabMentions => 'الإشارات';

  @override
  String get notificationsTabRequests => 'الطلبات';

  @override
  String get notificationsGroupRequests => 'طلبات الصداقة';

  @override
  String get notificationsGroupNew => 'جديد';

  @override
  String get notificationsGroupEarlier => 'سابقًا';

  @override
  String get notificationsNowFriends => 'أصبحتما صديقين الآن';

  @override
  String notificationsRequestDeclined(String name) {
    return 'تم رفض طلب $name';
  }

  @override
  String get notificationsUndo => 'تراجع';

  @override
  String get notificationsNothingHere => 'لا شيء هنا بعد.';

  @override
  String get notificationsTimeNow => 'الآن';

  @override
  String notificationsTimeMinutes(int count) {
    return '$count د';
  }

  @override
  String notificationsTimeHours(int count) {
    return '$count س';
  }

  @override
  String get notificationsTimeYesterday => 'أمس';

  @override
  String notificationsTimeDays(int count) {
    return '$count ي';
  }

  @override
  String notificationsUnreadCount(int count) {
    return '$count غير مقروء';
  }
}
