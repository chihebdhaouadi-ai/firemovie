import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Auto-focused search field with a clear button and a search-text keyboard.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    this.clearLabel,
    this.submitLabel,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final String? clearLabel;
  final String? submitLabel;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _update(String value) {
    widget.onChanged(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasText = widget.controller.text.isNotEmpty;
    final clearLabel = widget.clearLabel ?? '';

    return Semantics(
      textField: true,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        autocorrect: true,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintMaxLines: 1,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted,
              ),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: clearLabel,
                  onPressed: () {
                    widget.controller.clear();
                    _update('');
                  },
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsetsDirectional.symmetric(
            vertical: tokens.spaceMd,
            horizontal: tokens.spaceMd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
        onChanged: _update,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
