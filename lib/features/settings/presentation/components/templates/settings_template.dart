import 'package:flutter/material.dart';

class SettingsTemplate extends StatelessWidget {
  final Widget appBarTitle;
  final Widget profileCard;
  final Widget generalSectionHeader;
  final Widget themePicker;
  final Widget sensitiveContentToggle;
  final Widget appLockTile;
  final Widget apiSectionHeader;
  final Widget apiForm;
  final Widget? securityTile;
  final Widget certificatesSectionHeader;
  final Widget certificatesTile;
  final Widget diagnosticsSectionHeader;
  final Widget exportLogsTile;
  final Widget openLogsTile;

  const SettingsTemplate({
    super.key,
    required this.appBarTitle,
    required this.profileCard,
    required this.generalSectionHeader,
    required this.themePicker,
    required this.sensitiveContentToggle,
    required this.appLockTile,
    required this.apiSectionHeader,
    required this.apiForm,
    this.securityTile,
    required this.certificatesSectionHeader,
    required this.certificatesTile,
    required this.diagnosticsSectionHeader,
    required this.exportLogsTile,
    required this.openLogsTile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: appBarTitle),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileCard,
          const Divider(height: 32),
          generalSectionHeader,
          themePicker,
          const SizedBox(height: 16),
          sensitiveContentToggle,
          appLockTile,
          ?securityTile,
          const Divider(height: 32),
          apiSectionHeader,
          const SizedBox(height: 8),
          apiForm,
          const Divider(height: 32),
          certificatesSectionHeader,
          const SizedBox(height: 8),
          certificatesTile,
          const Divider(height: 32),
          diagnosticsSectionHeader,
          const SizedBox(height: 8),
          exportLogsTile,
          openLogsTile,
        ],
      ),
    );
  }
}
