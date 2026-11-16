import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../film_reviews/data/api_review_repository.dart';
import '../../film_reviews/data/review_repository.dart';
import '../../film_reviews/domain/film_reaction.dart';
import '../../film_reviews/domain/take_tag.dart';
import '../../film_reviews/presentation/widgets/reaction_button.dart';
import '../../find/data/find_repository.dart';
import '../../find/data/movie.dart';
import '../../home/data/home_models.dart';
import '../../home/views/widgets/film_tile.dart';
import '../../../core/widgets/game_button.dart';

/// Steps of the create flow. Reviews go type → write → movie → feeling;
/// questions and discussions go type → write → movie or photo.
/// Pops with `true` once the post is saved.
class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({
    super.key,
    this.reviews,
    this.finder,
    this.pickPhoto,
  });

  final ReviewRepository? reviews;
  final FindRepository? finder;

  /// Overrides the photo picker, for tests.
  final Future<XFile?> Function()? pickPhoto;

  static Route<bool> route({ReviewRepository? reviews}) =>
      MaterialPageRoute<bool>(
        builder: (_) => CreateTopicScreen(reviews: reviews),
      );

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

enum _Step { type, write, movie, feeling, subject, options, scene }

enum _Subject { movie, photo }

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  static const _searchDebounce = Duration(milliseconds: 350);
  static const _maxBodyLength = 280;

  final _query = TextEditingController();
  final _body = TextEditingController();
  final _sceneName = TextEditingController();
  final _timecode = TextEditingController();
  final List<TextEditingController> _options = [
    TextEditingController(),
    TextEditingController(),
  ];
  late final ReviewRepository _reviews =
      widget.reviews ?? ApiReviewRepository();
  late final FindRepository _finder = widget.finder ?? FindRepository();

  Timer? _debounce;
  int _searchRevision = 0;
  List<Movie> _results = const [];
  bool _searching = false;
  bool _searchFailed = false;

  int _stepIndex = 0;
  TakeTag? _tag;
  Movie? _film;
  FilmReaction? _reaction;
  _Subject _subject = _Subject.movie;
  XFile? _photo;
  bool _spoiler = false;
  bool _posting = false;

  static const _maxOptionLength = 80;
  static const _maxOptions = 4;

  /// Poll choices as typed, without blank rows.
  List<String> get _pollOptions => [
        for (final option in _options)
          if (option.text.trim().isNotEmpty) option.text.trim(),
      ];

  List<_Step> get _steps {
    final tag = _tag;
    if (tag == null) return const [_Step.type];
    if (tag == TakeTag.review) {
      return const [_Step.type, _Step.write, _Step.movie, _Step.feeling];
    }
    if (tag == TakeTag.poll) {
      return const [_Step.type, _Step.write, _Step.options];
    }
    if (tag == TakeTag.scene) {
      return const [_Step.type, _Step.movie, _Step.scene];
    }
    return const [_Step.type, _Step.write, _Step.subject];
  }

  _Step get _currentStep => _steps[_stepIndex];

  bool get _isLastStep => _stepIndex == _steps.length - 1;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    _body.dispose();
    _sceneName.dispose();
    _timecode.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  bool get _bodyFilled => _body.text.trim().isNotEmpty;

  /// Whether the current step has what it needs to move on.
  bool get _stepComplete => switch (_currentStep) {
        _Step.type => _tag != null,
        _Step.write => _bodyFilled,
        _Step.movie => _film != null,
        _Step.feeling => _reaction != null,
        _Step.subject =>
          _subject == _Subject.movie ? _film != null : _photo != null,
        _Step.options => _pollOptions.length >= 2,
        _Step.scene => _sceneName.text.trim().isNotEmpty && _bodyFilled,
      };

  void _chooseTag(TakeTag tag) {
    setState(() {
      _tag = tag;
      _spoiler = false;
      _stepIndex = 1;
    });
  }

  void _addOption() {
    if (_options.length >= _maxOptions) return;
    setState(() => _options.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_options.length <= 2) return;
    final removed = _options.removeAt(index);
    setState(() {});
    // Dispose once the field that used it has left the tree.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  void _next() {
    if (!_stepComplete || _isLastStep) return;
    _debounce?.cancel();
    setState(() => _stepIndex++);
  }

  void _back() {
    _debounce?.cancel();
    setState(() {
      _stepIndex = _stepIndex > 0 ? _stepIndex - 1 : 0;
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _searchRevision++;
      setState(() {
        _results = const [];
        _searching = false;
        _searchFailed = false;
      });
      return;
    }
    _debounce = Timer(_searchDebounce, () => _runSearch(trimmed));
  }

  Future<void> _runSearch(String query) async {
    final revision = ++_searchRevision;
    setState(() {
      _searching = true;
      _searchFailed = false;
    });
    try {
      final page = await _finder.search(query);
      if (!mounted || revision != _searchRevision) return;
      setState(() {
        _results = page.results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || revision != _searchRevision) return;
      setState(() {
        _results = const [];
        _searching = false;
        _searchFailed = true;
      });
    }
  }

  void _selectFilm(Movie movie) {
    _debounce?.cancel();
    setState(() {
      _film = movie;
      _results = const [];
      _searching = false;
    });
  }

  void _clearFilm() => setState(() => _film = null);

  void _chooseSubject(_Subject subject) {
    setState(() {
      _subject = subject;
      // Only one subject is posted, so switching clears the other.
      if (subject == _Subject.movie) {
        _photo = null;
      } else {
        _film = null;
        _results = const [];
      }
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await (widget.pickPhoto ?? _defaultPickPhoto)();
      if (!mounted || file == null) return;
      setState(() => _photo = file);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.createPhotoFailed)),
      );
    }
  }

  static Future<XFile?> _defaultPickPhoto() => ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );

  Future<void> _post() async {
    final tag = _tag;
    if (tag == null || !_stepComplete || _posting) return;
    setState(() => _posting = true);
    try {
      switch (tag) {
        case TakeTag.review:
          final film = _film!;
          // The backend only accepts a review once the film has a reaction.
          await _reviews.setReaction(film.id, _reaction);
          await _reviews.postTake(
            film.id,
            body: _body.text.trim(),
            tag: TakeTag.review,
          );
        case TakeTag.scene:
          final timecode = _timecode.text.trim();
          await _reviews.postTopic(
            filmId: _film!.id,
            body: _body.text.trim(),
            tag: TakeTag.scene,
            scene: _sceneName.text.trim(),
            timecode: timecode.isEmpty ? null : timecode,
            spoiler: _spoiler,
          );
        case TakeTag.poll:
          await _reviews.postTopic(
            body: _body.text.trim(),
            tag: TakeTag.poll,
            options: _pollOptions,
            spoiler: _spoiler,
          );
        case TakeTag.question:
        case TakeTag.discussion:
        case TakeTag.hotTake:
          final usePhoto = _subject == _Subject.photo;
          await _reviews.postTopic(
            filmId: usePhoto ? null : _film?.id,
            body: _body.text.trim(),
            tag: tag,
            image: usePhoto ? _photo : null,
            spoiler: _spoiler,
          );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _posting = false);
      final message = error is FindFailure && error.message.isNotEmpty
          ? error.message
          : context.l10n.topicPostFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _writeTitle(AppLocalizations l10n) => switch (_tag) {
        TakeTag.question => l10n.createWriteQuestionTitle,
        TakeTag.discussion => l10n.createWriteDiscussionTitle,
        TakeTag.hotTake => l10n.createWriteHotTakeTitle,
        TakeTag.poll => l10n.createWritePollTitle,
        _ => l10n.createWriteReviewTitle,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final steps = _steps;
    final isLast = _isLastStep;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.topicCreateTitle),
        leading: _stepIndex == 0
            ? null
            : BackButton(onPressed: _posting ? null : _back),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Column(
              children: [
                if (steps.length > 1)
                  LinearProgressIndicator(
                    value: (_stepIndex + 1) / steps.length,
                    color: AppColors.accentGlow,
                    backgroundColor: AppColors.surfaceRaised,
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(tokens.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_buildStep(l10n, tokens)],
                    ),
                  ),
                ),
                if (_currentStep != _Step.type)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spaceLg,
                      0,
                      tokens.spaceLg,
                      tokens.spaceLg,
                    ),
                    child: GameButton(
                      onPressed: !_stepComplete || _posting
                          ? null
                          : (isLast ? _post : _next),
                      style: GameButtonStyle.blue,
                      label: isLast ? l10n.topicPostButton : l10n.createNext,
                      child: _posting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AppLocalizations l10n, AppTokens tokens) {
    return switch (_currentStep) {
      _Step.type => _TypeStep(onChoose: _chooseTag),
      _Step.write => _WriteStep(
          title: _writeTitle(l10n),
          controller: _body,
          maxLength: _maxBodyLength,
          hint: _tag == TakeTag.poll
              ? l10n.createPollQuestionHint
              : l10n.topicBodyHint,
          onChanged: () => setState(() {}),
          showSpoiler: _tag != TakeTag.review,
          spoiler: _spoiler,
          onSpoilerChanged: (value) => setState(() => _spoiler = value),
        ),
      _Step.options => _OptionsStep(
          title: l10n.createPollOptionsTitle,
          hint: l10n.createPollOptionsHint,
          options: _options,
          canAdd: _options.length < _maxOptions,
          maxLength: _maxOptionLength,
          onAdd: _addOption,
          onRemove: _removeOption,
          onChanged: () => setState(() {}),
        ),
      _Step.scene => _SceneStep(
          title: l10n.createSceneTitle,
          sceneName: _sceneName,
          timecode: _timecode,
          body: _body,
          maxBodyLength: _maxBodyLength,
          onChanged: () => setState(() {}),
          spoiler: _spoiler,
          onSpoilerChanged: (value) => setState(() => _spoiler = value),
        ),
      _Step.movie => _MovieStep(
          title: l10n.createReviewMovieTitle,
          hint: _tag == TakeTag.scene
              ? l10n.createSceneMovieHint
              : l10n.createReviewMovieHint,
          film: _film,
          query: _query,
          results: _results,
          searching: _searching,
          failed: _searchFailed,
          onQueryChanged: _onQueryChanged,
          onSubmitted: (value) {
            _debounce?.cancel();
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) _runSearch(trimmed);
          },
          onSelect: _selectFilm,
          onClear: _clearFilm,
        ),
      _Step.feeling => _FeelingStep(
          title: l10n.createFeelTitle,
          hint: l10n.createFeelHint,
          reaction: _reaction,
          onChanged: (reaction) => setState(() => _reaction = reaction),
        ),
      _Step.subject => _SubjectStep(
          subject: _subject,
          onChooseSubject: _chooseSubject,
          film: _film,
          query: _query,
          results: _results,
          searching: _searching,
          failed: _searchFailed,
          onQueryChanged: _onQueryChanged,
          onSubmitted: (value) {
            _debounce?.cancel();
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) _runSearch(trimmed);
          },
          onSelect: _selectFilm,
          onClear: _clearFilm,
          photo: _photo,
          onPickPhoto: _pickPhoto,
        ),
    };
  }
}

/// Step 1: what kind of post this is.
class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.onChoose});

  final ValueChanged<TakeTag> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.topicTypeLabel, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceXs),
        Text(
          l10n.createTypeTitle,
          style:
              theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: tokens.spaceLg),
        _TypeCard(
          icon: Icons.rate_review_outlined,
          title: l10n.topicTagReview,
          subtitle: l10n.createTypeReviewSubtitle,
          onTap: () => onChoose(TakeTag.review),
        ),
        SizedBox(height: tokens.spaceMd),
        _TypeCard(
          icon: Icons.help_outline,
          title: l10n.topicTagQuestion,
          subtitle: l10n.createTypeQuestionSubtitle,
          onTap: () => onChoose(TakeTag.question),
        ),
        SizedBox(height: tokens.spaceMd),
        _TypeCard(
          icon: Icons.forum_outlined,
          title: l10n.topicTagDiscussion,
          subtitle: l10n.createTypeDiscussionSubtitle,
          onTap: () => onChoose(TakeTag.discussion),
        ),
        SizedBox(height: tokens.spaceMd),
        _TypeCard(
          icon: Icons.local_fire_department_outlined,
          title: l10n.topicTagHotTake,
          subtitle: l10n.createTypeHotTakeSubtitle,
          onTap: () => onChoose(TakeTag.hotTake),
        ),
        SizedBox(height: tokens.spaceMd),
        _TypeCard(
          icon: Icons.bar_chart_outlined,
          title: l10n.topicTagPoll,
          subtitle: l10n.createTypePollSubtitle,
          onTap: () => onChoose(TakeTag.poll),
        ),
        SizedBox(height: tokens.spaceMd),
        _TypeCard(
          icon: Icons.movie_outlined,
          title: l10n.topicTagScene,
          subtitle: l10n.createTypeSceneSubtitle,
          onTap: () => onChoose(TakeTag.scene),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surfaceRaised,
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceLg),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGlow, size: tokens.iconLarge),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spaceXs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 2: the text of the post.
class _WriteStep extends StatelessWidget {
  const _WriteStep({
    required this.title,
    required this.controller,
    required this.maxLength,
    required this.hint,
    required this.onChanged,
    this.showSpoiler = false,
    this.spoiler = false,
    this.onSpoilerChanged,
  });

  final String title;
  final TextEditingController controller;
  final int maxLength;
  final String hint;
  final VoidCallback onChanged;
  final bool showSpoiler;
  final bool spoiler;
  final ValueChanged<bool>? onSpoilerChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceMd),
        TextField(
          controller: controller,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          maxLength: maxLength,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
          ),
        ),
        if (showSpoiler && onSpoilerChanged != null)
          _SpoilerCheckbox(value: spoiler, onChanged: onSpoilerChanged!),
      ],
    );
  }
}

/// Opt-in flag: the post body is hidden until a reader taps to reveal it.
class _SpoilerCheckbox extends StatelessWidget {
  const _SpoilerCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      title: Text(context.l10n.topicSpoilerLabel),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// Poll, step 3: two to four choices. Blank rows are ignored.
class _OptionsStep extends StatelessWidget {
  const _OptionsStep({
    required this.title,
    required this.hint,
    required this.options,
    required this.canAdd,
    required this.maxLength,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final List<TextEditingController> options;
  final bool canAdd;
  final int maxLength;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceXs),
        Text(
          hint,
          style:
              theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: tokens.spaceMd),
        for (var i = 0; i < options.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spaceSm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: options[i],
                    maxLength: maxLength,
                    onChanged: (_) => onChanged(),
                    decoration: InputDecoration(
                      hintText: l10n.createPollOptionLabel(i + 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                      ),
                    ),
                  ),
                ),
                if (options.length > 2)
                  IconButton(
                    tooltip: l10n.createPollRemoveOption,
                    onPressed: () => onRemove(i),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
              ],
            ),
          ),
        if (canAdd)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, tokens.minTouchTarget),
              ),
              label: Text(l10n.createPollAddOption),
            ),
          ),
      ],
    );
  }
}

/// Scene, step 3: the moment, where it is, and why it works.
class _SceneStep extends StatelessWidget {
  const _SceneStep({
    required this.title,
    required this.sceneName,
    required this.timecode,
    required this.body,
    required this.maxBodyLength,
    required this.onChanged,
    required this.spoiler,
    required this.onSpoilerChanged,
  });

  final String title;
  final TextEditingController sceneName;
  final TextEditingController timecode;
  final TextEditingController body;
  final int maxBodyLength;
  final VoidCallback onChanged;
  final bool spoiler;
  final ValueChanged<bool> onSpoilerChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    InputDecoration decoration(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceMd),
        TextField(
          controller: sceneName,
          maxLength: 120,
          onChanged: (_) => onChanged(),
          decoration: decoration(
            l10n.createSceneNameLabel,
            l10n.createSceneNameHint,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        TextField(
          controller: timecode,
          maxLength: 20,
          decoration: decoration(
            l10n.createSceneTimecodeLabel,
            l10n.createSceneTimecodeHint,
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        TextField(
          controller: body,
          minLines: 4,
          maxLines: 8,
          maxLength: maxBodyLength,
          onChanged: (_) => onChanged(),
          decoration: decoration(
            l10n.createSceneExplainLabel,
            l10n.createSceneExplainHint,
          ),
        ),
        _SpoilerCheckbox(value: spoiler, onChanged: onSpoilerChanged),
      ],
    );
  }
}

/// Reviews, step 3: the film the review is about.
class _MovieStep extends StatelessWidget {
  const _MovieStep({
    required this.title,
    required this.hint,
    required this.film,
    required this.query,
    required this.results,
    required this.searching,
    required this.failed,
    required this.onQueryChanged,
    required this.onSubmitted,
    required this.onSelect,
    required this.onClear,
  });

  final String title;
  final String hint;
  final Movie? film;
  final TextEditingController query;
  final List<Movie> results;
  final bool searching;
  final bool failed;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Movie> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceXs),
        Text(
          hint,
          style:
              theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: tokens.spaceMd),
        _MovieSelector(
          film: film,
          query: query,
          results: results,
          searching: searching,
          failed: failed,
          onQueryChanged: onQueryChanged,
          onSubmitted: onSubmitted,
          onSelect: onSelect,
          onClear: onClear,
        ),
      ],
    );
  }
}

/// Topics, step 3: a movie or a photo.
class _SubjectStep extends StatelessWidget {
  const _SubjectStep({
    required this.subject,
    required this.onChooseSubject,
    required this.film,
    required this.query,
    required this.results,
    required this.searching,
    required this.failed,
    required this.onQueryChanged,
    required this.onSubmitted,
    required this.onSelect,
    required this.onClear,
    required this.photo,
    required this.onPickPhoto,
  });

  final _Subject subject;
  final ValueChanged<_Subject> onChooseSubject;
  final Movie? film;
  final TextEditingController query;
  final List<Movie> results;
  final bool searching;
  final bool failed;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Movie> onSelect;
  final VoidCallback onClear;
  final XFile? photo;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.createSubjectTitle, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceMd),
        SegmentedButton<_Subject>(
          segments: [
            ButtonSegment(
              value: _Subject.movie,
              icon: const Icon(Icons.movie_outlined),
              label: Text(l10n.createSubjectMovie),
            ),
            ButtonSegment(
              value: _Subject.photo,
              icon: const Icon(Icons.photo_outlined),
              label: Text(l10n.createSubjectPhoto),
            ),
          ],
          selected: {subject},
          onSelectionChanged: (selection) => onChooseSubject(selection.first),
        ),
        SizedBox(height: tokens.spaceLg),
        if (subject == _Subject.movie)
          _MovieSelector(
            film: film,
            query: query,
            results: results,
            searching: searching,
            failed: failed,
            onQueryChanged: onQueryChanged,
            onSubmitted: onSubmitted,
            onSelect: onSelect,
            onClear: onClear,
          )
        else
          _PhotoSelector(photo: photo, onPick: onPickPhoto),
      ],
    );
  }
}

/// Movie search, or the chosen movie with a button to change it.
class _MovieSelector extends StatelessWidget {
  const _MovieSelector({
    required this.film,
    required this.query,
    required this.results,
    required this.searching,
    required this.failed,
    required this.onQueryChanged,
    required this.onSubmitted,
    required this.onSelect,
    required this.onClear,
  });

  final Movie? film;
  final TextEditingController query;
  final List<Movie> results;
  final bool searching;
  final bool failed;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<Movie> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = film;
    if (current != null) {
      return _SelectedMovie(
        movie: current,
        changeLabel: l10n.topicChangeMovie,
        onChange: onClear,
      );
    }
    return _MovieSearch(
      controller: query,
      onChanged: onQueryChanged,
      onSubmitted: onSubmitted,
      searching: searching,
      failed: failed,
      results: results,
      emptyLabel: query.text.trim().isEmpty ? null : l10n.topicNoResults,
      onSelect: onSelect,
    );
  }
}

/// Photo picker for a topic that is not about a movie.
class _PhotoSelector extends StatelessWidget {
  const _PhotoSelector({required this.photo, required this.onPick});

  final XFile? photo;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final file = photo;

    if (file == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, tokens.minTouchTarget),
        ),
        label: Text(l10n.createAddPhoto),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
              onPressed: onPick, child: Text(l10n.createChangePhoto)),
        ),
      ],
    );
  }
}

/// Reviews, step 4: how the film made the writer feel.
class _FeelingStep extends StatelessWidget {
  const _FeelingStep({
    required this.title,
    required this.hint,
    required this.reaction,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final FilmReaction? reaction;
  final ValueChanged<FilmReaction> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.spaceXs),
        Text(
          hint,
          style:
              theme.textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: tokens.spaceMd),
        ReactionButton(selected: reaction, onChanged: onChanged),
      ],
    );
  }
}

/// Movie search field and results, shared by the review and topic steps.
class _MovieSearch extends StatelessWidget {
  const _MovieSearch({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.searching,
    required this.failed,
    required this.results,
    required this.onSelect,
    this.emptyLabel,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool searching;
  final bool failed;
  final List<Movie> results;
  final String? emptyLabel;
  final ValueChanged<Movie> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: l10n.topicSearchHint,
            prefixIcon: Icon(Icons.search, size: tokens.iconSmall),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
          ),
        ),
        if (searching)
          Padding(
            padding: EdgeInsets.only(top: tokens.spaceLg),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (failed)
          Padding(
            padding: EdgeInsets.only(top: tokens.spaceMd),
            child: Text(
              l10n.topicSearchFailed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.error,
              ),
            ),
          )
        else if (results.isEmpty && emptyLabel != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spaceMd),
            child: Text(
              emptyLabel!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          )
        else
          for (final movie in results)
            _MovieRow(movie: movie, onTap: () => onSelect(movie)),
      ],
    );
  }
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final subtitle = movie.year?.toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radiusMd),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spaceSm),
        child: Row(
          children: [
            _Poster(movie: movie),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedMovie extends StatelessWidget {
  const _SelectedMovie({
    required this.movie,
    required this.changeLabel,
    required this.onChange,
  });

  final Movie movie;
  final String changeLabel;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Row(
        children: [
          _Poster(movie: movie),
          SizedBox(width: tokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (movie.year != null)
                  Text(
                    '${movie.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(changeLabel)),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusSm),
      child: FilmPoster(
        film: Film(
          imdbId: movie.id,
          title: movie.title,
          posterUrl: movie.posterUrl,
        ),
        width: 48,
        height: 72,
        radius: 0,
      ),
    );
  }
}
