import 'package:fl_lib/fl_lib.dart';
import 'package:flutter/material.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CardX(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Column(children: children),
          ],
        ),
      ),
    );
  }
}
