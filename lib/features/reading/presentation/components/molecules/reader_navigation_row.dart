import 'package:flutter/material.dart';

import 'reader_setting_row.dart';

/// A [ReaderSettingRow] that opens another screen or sheet when tapped.
class ReaderNavigationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ReaderNavigationRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$title. $subtitle',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ReaderSettingRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
