import 'package:flutter/material.dart';

import '../../../core/l10n_context.dart';
import '../../../core/theme/app_theme.dart';
import '../../find/views/widgets/empty_error_views.dart';

/// Placeholder for the FilmSage info pages (New here?, Contact, Terms…)
/// until their content is ready.
class InfoPageScreen extends StatelessWidget {
  const InfoPageScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(title),
      ),
      body: FindMessageView(
        icon: icon,
        title: l10n.browseComingSoonTitle,
        body: l10n.browseComingSoonBody,
      ),
    );
  }
}
