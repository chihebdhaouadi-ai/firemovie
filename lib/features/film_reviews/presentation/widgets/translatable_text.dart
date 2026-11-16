import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/translation_repository.dart';

final _defaultRepository = ApiTranslationRepository();

class TranslatableText extends StatefulWidget {
  const TranslatableText({
    super.key,
    required this.text,
    this.style,
    this.format,
    this.repository,
    this.linkStyle,
  });

  final String text;
  final TextStyle? style;
  final String Function(String text)? format;
  final TranslationRepository? repository;

  /// Style of the Translate / Show original link; underlined blue if null.
  final TextStyle? linkStyle;

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  String? _targetLanguage;
  String? _translation;
  bool _showTranslation = false;
  bool _loading = false;
  bool _failed = false;
  bool _sameLanguage = false;
  int _request = 0;

  TranslationRepository get _repository =>
      widget.repository ?? _defaultRepository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final target = Localizations.localeOf(context).languageCode;
    if (target != _targetLanguage) {
      _targetLanguage = target;
      _reset();
    }
  }

  @override
  void didUpdateWidget(TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _reset();
  }

  void _reset() {
    _request++;
    _translation = null;
    _showTranslation = false;
    _loading = false;
    _failed = false;
    _sameLanguage = false;
  }

  Future<void> _onLinkTap() async {
    final translation = _translation;
    if (translation != null) {
      setState(() => _showTranslation = !_showTranslation);
      return;
    }
    final target = _targetLanguage;
    if (target == null) return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result =
          await _repository.translate(widget.text, targetLanguage: target);
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        if (result.sourceLanguage == target) {
          _sameLanguage = true;
        } else {
          _translation = result.text;
          _showTranslation = true;
        }
      });
    } on Exception {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final translation = _translation;
    final showingTranslation = _showTranslation && translation != null;
    final shown = showingTranslation ? translation : widget.text;
    final display = widget.format?.call(shown) ?? shown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(display, style: widget.style),
        if (!_sameLanguage)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              InkWell(
                onTap: _loading ? null : _onLinkTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    showingTranslation
                        ? l10n.reviewShowOriginal
                        : l10n.reviewTranslate,
                    style: widget.linkStyle ??
                        theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.accentGlow,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.accentGlow,
                        ),
                  ),
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accentGlow,
                  ),
                ),
              if (_failed)
                Text(
                  l10n.reviewTranslateFailed,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
