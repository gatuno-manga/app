import 'package:flutter/material.dart';

import '../../../../../shared/components/molecules/app_stepper.dart';
import 'reader_setting_row.dart';

/// A [ReaderSettingRow] whose control is an [AppStepper]. A null callback
/// disables that side.
class ReaderStepperRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementTooltip;
  final String incrementTooltip;

  const ReaderStepperRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementTooltip,
    required this.incrementTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ReaderSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      liveTitle: true,
      trailing: AppStepper(
        onDecrement: onDecrement,
        onIncrement: onIncrement,
        decrementTooltip: decrementTooltip,
        incrementTooltip: incrementTooltip,
      ),
    );
  }
}
