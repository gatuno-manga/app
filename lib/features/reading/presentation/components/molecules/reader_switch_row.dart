import 'package:flutter/material.dart';

import '../atoms/reader_switch.dart';
import 'reader_setting_row.dart';

/// A [ReaderSettingRow] whose control is a [ReaderSwitch].
class ReaderSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ReaderSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReaderSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: ReaderSwitch(value: value, onChanged: onChanged, label: title),
    );
  }
}
