import 'package:flutter/material.dart';

import '../../../../core/l10n_context.dart';
import 'section_header.dart';
import 'section_status.dart';

class ComingSoonSection extends StatelessWidget {
  const ComingSoonSection({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        SectionStatusCard(
          message: context.l10n.homeComingSoon,
          actionIcon: Icons.schedule,
        ),
      ],
    );
  }
}
