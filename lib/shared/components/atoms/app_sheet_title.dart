import 'package:flutter/material.dart';

/// Title row of a bottom sheet.
class AppSheetTitle extends StatelessWidget {
  final String text;

  const AppSheetTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}
