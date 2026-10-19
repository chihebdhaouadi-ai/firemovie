import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../find/data/movie.dart';
import '../../find/views/find_film_screen.dart';
import '../../find/views/find_route_args.dart';
import '../data/onboarding_repository.dart';

enum OnboardingStep { avatar, cover, bio, top5, watched, watchlist }

/// Step-by-step profile setup shown once after registration.
///
/// Every step can be skipped and finished later from the profile page. Photos
/// upload as soon as they are picked; the bio is saved when the user continues.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.repository, this.pickImage});

  final OnboardingRepository? repository;
  final Future<String?> Function()? pickImage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = OnboardingStep.values;

  late final OnboardingRepository _repository;
  final _bioController = TextEditingController();

  OnboardingStep _step = OnboardingStep.avatar;
  OnboardingCounts? _counts;
  bool _busy = false;
  bool _failed = false;
  bool _avatarSaved = false;
  bool _coverSaved = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? OnboardingRepository();
    _refreshCounts();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _refreshCounts() async {
    try {
      final counts = await _repository.fetchCounts();
      if (!mounted) return;
      setState(() => _counts = counts);
    } catch (_) {
      // Counts are informational; keep the last known values.
    }
  }

  bool get _isLast => _step.index == _steps.length - 1;

  void _goToNext() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _step = _steps[_step.index + 1];
      _failed = false;
    });
  }

  void _finish() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }

  Future<void> _continue() async {
    if (_step == OnboardingStep.bio) {
      final bio = _bioController.text.trim();
      if (bio.isNotEmpty) {
        final saved = await _run(() => _repository.saveBio(bio));
        if (!saved) return;
      }
    }
    _goToNext();
  }

  Future<bool> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
      if (mounted) setState(() => _busy = false);
      return true;
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
      return false;
    }
  }

  Future<void> _pickAndUpload({required bool avatar}) async {
    final path = await (widget.pickImage ?? _defaultPickImage)();
    if (path == null || !mounted) return;
    final saved = await _run(
      () => avatar
          ? _repository.uploadAvatar(path)
          : _repository.uploadCover(path),
    );
    if (!saved || !mounted) return;
    setState(() {
      if (avatar) {
        _avatarSaved = true;
      } else {
        _coverSaved = true;
      }
    });
  }

  static Future<String?> _defaultPickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    return file?.path;
  }

  Future<void> _openFind(AddTarget target) async {
    await Navigator.of(context).push(
      FindFilmScreen.route(FindFilmRouteArgs(target: target)),
    );
    if (!mounted) return;
    await _refreshCounts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _busy ? null : _finish,
            child: Text(l10n.onboardingFinishLater),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
                    children: [
                      SizedBox(height: tokens.spaceSm),
                      LinearProgressIndicator(
                        value: (_step.index + 1) / _steps.length,
                        color: AppColors.accentGlow,
                        backgroundColor: AppColors.surfaceRaised,
                      ),
                      SizedBox(height: tokens.spaceSm),
                      Text(
                        l10n.onboardingStepCounter(
                          _step.index + 1,
                          _steps.length,
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: tokens.spaceMd),
                      Text(
                        _titleFor(l10n),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: tokens.spaceXs),
                      Text(
                        _bodyFor(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: tokens.spaceLg),
                      _stepBody(l10n),
                      if (_failed) ...[
                        SizedBox(height: tokens.spaceMd),
                        Text(
                          l10n.onboardingSaveFailed,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _footer(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleFor(AppLocalizations l10n) => switch (_step) {
        OnboardingStep.avatar => l10n.onboardingAvatarTitle,
        OnboardingStep.cover => l10n.onboardingCoverTitle,
        OnboardingStep.bio => l10n.onboardingBioTitle,
        OnboardingStep.top5 => l10n.onboardingTop5Title,
        OnboardingStep.watched => l10n.onboardingWatchedTitle,
        OnboardingStep.watchlist => l10n.onboardingWatchlistTitle,
      };

  String _bodyFor(AppLocalizations l10n) => switch (_step) {
        OnboardingStep.avatar => l10n.onboardingAvatarBody,
        OnboardingStep.cover => l10n.onboardingCoverBody,
        OnboardingStep.bio => l10n.onboardingBioBody,
        OnboardingStep.top5 => l10n.onboardingTop5Body,
        OnboardingStep.watched => l10n.onboardingWatchedBody,
        OnboardingStep.watchlist => l10n.onboardingWatchlistBody,
      };

  Widget _stepBody(AppLocalizations l10n) => switch (_step) {
        OnboardingStep.avatar => _PhotoStep(
            busy: _busy,
            saved: _avatarSaved,
            chooseLabel: l10n.onboardingChoosePhoto,
            savedLabel: l10n.onboardingPhotoSaved,
            onPick: () => _pickAndUpload(avatar: true),
          ),
        OnboardingStep.cover => _PhotoStep(
            busy: _busy,
            saved: _coverSaved,
            chooseLabel: l10n.onboardingChooseCover,
            savedLabel: l10n.onboardingCoverSaved,
            onPick: () => _pickAndUpload(avatar: false),
          ),
        OnboardingStep.bio => TextField(
            controller: _bioController,
            enabled: !_busy,
            maxLength: 280,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.onboardingBioHint),
          ),
        OnboardingStep.top5 => _MoviesStep(
            busy: _busy,
            summary: l10n.onboardingTop5Progress(_counts?.top5 ?? 0),
            buttonLabel: l10n.onboardingSearchFilms,
            onSearch: () => _openFind(AddTarget.top5),
          ),
        OnboardingStep.watched => _MoviesStep(
            busy: _busy,
            summary: l10n.onboardingFilmsAdded(_counts?.watched ?? 0),
            buttonLabel: l10n.onboardingSearchFilms,
            onSearch: () => _openFind(AddTarget.watched),
          ),
        OnboardingStep.watchlist => _MoviesStep(
            busy: _busy,
            summary: l10n.onboardingFilmsAdded(_counts?.watchlist ?? 0),
            buttonLabel: l10n.onboardingSearchFilms,
            onSearch: () => _openFind(AddTarget.watchlist),
          ),
      };

  Widget _footer(AppLocalizations l10n) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.all(tokens.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _busy ? null : _goToNext,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(0, tokens.minTouchTarget),
              ),
              child: Text(l10n.onboardingSkip),
            ),
          ),
          SizedBox(width: tokens.spaceSm),
          Expanded(
            child: FilledButton(
              onPressed: _busy ? null : _continue,
              style: FilledButton.styleFrom(
                minimumSize: Size(0, tokens.minTouchTarget),
              ),
              child: Text(
                  _isLast ? l10n.onboardingFinish : l10n.onboardingContinue),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  const _PhotoStep({
    required this.busy,
    required this.saved,
    required this.chooseLabel,
    required this.savedLabel,
    required this.onPick,
  });

  final bool busy;
  final bool saved;
  final String chooseLabel;
  final String savedLabel;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (saved) ...[
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: tokens.iconSmall,
                color: AppColors.accentGlow,
              ),
              SizedBox(width: tokens.spaceXs),
              Text(
                savedLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
        ],
        OutlinedButton.icon(
          onPressed: busy ? null : onPick,
          icon: const Icon(Icons.photo_library_outlined),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, tokens.minTouchTarget),
          ),
          label: Text(chooseLabel),
        ),
      ],
    );
  }
}

class _MoviesStep extends StatelessWidget {
  const _MoviesStep({
    required this.busy,
    required this.summary,
    required this.buttonLabel,
    required this.onSearch,
  });

  final bool busy;
  final String summary;
  final String buttonLabel;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.accentGlow,
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        OutlinedButton.icon(
          onPressed: busy ? null : onSearch,
          icon: const Icon(Icons.search),
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, tokens.minTouchTarget),
          ),
          label: Text(buttonLabel),
        ),
      ],
    );
  }
}
