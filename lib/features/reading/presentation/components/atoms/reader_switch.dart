import 'package:flutter/material.dart';

/// The on/off control of the reader settings (Figma `switch`). [label] is
/// what a screen reader announces for it.
class ReaderSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const ReaderSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}
