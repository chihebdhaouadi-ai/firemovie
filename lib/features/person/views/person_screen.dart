import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/luxe_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../find/data/movie.dart';
import '../../find/views/film_detail_screen.dart';
import '../bloc/person_cubit.dart';
import '../data/person_repository.dart';
import '../domain/person.dart';

const _bioPreviewLines = 5;
const _photoWidth = 120.0;
const _photoHeight = 168.0;
const _posterAspect = 2 / 3;

/// A cast or crew member's page: photo, height, biography and their films.
///
/// [name] and [subtitle] (the character or job from the film the person was
/// opened from) show straight away while the rest loads.
class PersonScreen extends StatelessWidget {
  const PersonScreen({
    super.key,
    required this.personId,
    required this.name,
    this.subtitle,
    this.repository,
  });

  final String personId;
  final String name;
  final String? subtitle;
  final PersonRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PersonCubit(
        personId: personId,
        repository: repository ?? ApiPersonRepository(),
      )..load(),
      child: Scaffold(
        backgroundColor: LuxeColors.bg,
        appBar: AppBar(
          backgroundColor: LuxeColors.bg,
          surfaceTintColor: Colors.transparent,
          foregroundColor: LuxeColors.text,
          elevation: 0,
        ),
        body: BlocBuilder<PersonCubit, PersonState>(
          builder: (context, state) => switch (state) {
            PersonLoading() => _PersonBody(
                name: name,
                subtitle: subtitle,
                loading: true,
              ),
            PersonFailed() => _PersonError(name: name),
            PersonLoaded(:final person) => _PersonBody(
                name: person.name.isEmpty ? name : person.name,
                subtitle: subtitle,
                person: person,
              ),
          },
        ),
      ),
    );
  }
}

class _PersonBody extends StatelessWidget {
  const _PersonBody({
    required this.name,
    this.subtitle,
    this.person,
    this.loading = false,
  });

  final String name;
  final String? subtitle;
  final PersonDetail? person;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final person = this.person;
    final biography = person?.biography;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.tokens.maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            _Header(
              name: name,
              subtitle: subtitle,
              person: person,
              loading: loading,
            ),
            const SizedBox(height: 24),
            if (loading)
              const _SkeletonBlock(height: 120)
            else if (biography != null) ...[
              _SectionTitle(l10n.personBiography),
              _Card(child: _Biography(text: biography)),
              const SizedBox(height: 24),
            ],
            if (!loading && person != null) ...[
              _SectionTitle(l10n.personFilmography),
              if (person.knownFor.isEmpty)
                _Card(
                  child: Text(
                    l10n.personNoFilms,
                    style: TextStyle(color: LuxeColors.muted),
                  ),
                )
              else
                _Filmography(credits: person.knownFor),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.loading,
    this.subtitle,
    this.person,
  });

  final String name;
  final String? subtitle;
  final PersonDetail? person;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final person = this.person;
    final subtitle = this.subtitle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Photo(url: person?.photoUrl, name: name),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: LuxeColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: LuxeColors.accent, fontSize: 14),
                ),
              ],
              const SizedBox(height: 14),
              if (loading)
                const _SkeletonBlock(height: 64)
              else if (person != null)
                ..._facts(context, l10n, person),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _facts(
    BuildContext context,
    AppLocalizations l10n,
    PersonDetail person,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dates = DateFormat.yMMMd(locale);
    final born = person.birthDate;
    final died = person.deathDate;
    return [
      if (person.heightDisplay case final height?)
        _Fact(
            icon: BootstrapIcons.arrows_vertical,
            label: l10n.personHeight,
            value: height),
      if (born != null)
        _Fact(
          icon: BootstrapIcons.cake,
          label: l10n.personBorn,
          value: dates.format(born),
        ),
      if (person.birthPlace case final place?)
        _Fact(icon: BootstrapIcons.geo_alt, label: null, value: place),
      if (died != null)
        _Fact(
          icon: BootstrapIcons.flower1,
          label: l10n.personDied,
          value: dates.format(died),
        ),
    ];
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.name});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final fallback = Container(
      color: LuxeColors.surface2,
      alignment: Alignment.center,
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        style: TextStyle(
          color: LuxeColors.accent,
          fontSize: 40,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: _photoWidth,
        height: _photoHeight,
        child: url == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: (_photoWidth * 3).round(),
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: LuxeColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (label != null)
                    TextSpan(
                      text: '$label  ',
                      style: TextStyle(color: LuxeColors.muted),
                    ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: LuxeColors.text),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _Biography extends StatefulWidget {
  const _Biography({required this.text});

  final String text;

  @override
  State<_Biography> createState() => _BiographyState();
}

class _BiographyState extends State<_Biography> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = TextStyle(color: LuxeColors.text, fontSize: 14, height: 1.5);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _bioPreviewLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : _bioPreviewLines,
                overflow: _expanded ? null : TextOverflow.fade,
              ),
            ),
            if (overflows || _expanded)
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: LuxeColors.accent,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? l10n.overviewShowLess : l10n.overviewShowMore,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Filmography extends StatelessWidget {
  const _Filmography({required this.credits});

  final List<PersonCredit> credits;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 600 ? 5 : 3;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 16,
          children: [
            for (final credit in credits)
              SizedBox(width: width, child: _CreditTile(credit: credit)),
          ],
        );
      },
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({required this.credit});

  final PersonCredit credit;

  void _open(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FilmDetailScreen(
          movie: Movie(
            id: credit.filmId,
            title: credit.title,
            year: credit.year,
            posterUrl: credit.posterUrl,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final poster = credit.posterUrl;
    final part = credit.isCast
        ? (credit.characters.isEmpty
            ? null
            : l10n.personAsCharacter(credit.characters.join(', ')))
        : credit.job;
    final fallback = Container(
      color: LuxeColors.surface2,
      alignment: Alignment.center,
      child: Icon(BootstrapIcons.film, color: LuxeColors.muted),
    );

    return Semantics(
      button: true,
      label: credit.title,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _posterAspect,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: poster == null
                    ? fallback
                    : CachedNetworkImage(
                        imageUrl: poster,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        placeholder: (_, __) => fallback,
                        errorWidget: (_, __, ___) => fallback,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              credit.title,
              maxLines: 2,
              style: TextStyle(
                color: LuxeColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (credit.year case final year?)
              Text(
                '$year',
                style: TextStyle(color: LuxeColors.muted, fontSize: 12),
              ),
            if (part != null)
              Text(
                part,
                maxLines: 2,
                style: TextStyle(color: LuxeColors.accent, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _PersonError extends StatelessWidget {
  const _PersonError({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: LuxeColors.text,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.personLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: LuxeColors.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<PersonCubit>().load(),
              child: Text(l10n.reviewRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: LuxeColors.text,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuxeColors.hair),
      ),
      child: child,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: LuxeColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
