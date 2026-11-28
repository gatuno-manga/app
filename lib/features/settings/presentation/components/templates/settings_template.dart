import 'package:flutter/material.dart';

import '../../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../../shared/components/templates/app_top_bar_scaffold.dart';

class SettingsTemplate extends StatelessWidget {
  final String title;
  final Widget profileCard;

  /// The 'Solicitar livro' row; null for guests.
  final Widget? bookRequestsTile;
  final Widget generalSectionHeader;
  final Widget themePicker;
  final Widget sensitiveContentToggle;
  final Widget appLockTile;
  final Widget readingSectionHeader;
  final Widget readingControls;
  final Widget downloadsSectionHeader;
  final Widget downloadNetworkTile;
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
    required this.title,
    required this.profileCard,
    this.bookRequestsTile,
    required this.generalSectionHeader,
    required this.themePicker,
    required this.sensitiveContentToggle,
    required this.appLockTile,
    required this.readingSectionHeader,
    required this.readingControls,
    required this.downloadsSectionHeader,
    required this.downloadNetworkTile,
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
    return AppTopBarScaffold(
      topBar: AppTopBar(title: title, showBack: true),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              profileCard,
              ?bookRequestsTile,
              const Divider(height: 32),
              generalSectionHeader,
              themePicker,
              const SizedBox(height: 16),
              sensitiveContentToggle,
              appLockTile,
              ?securityTile,
              const Divider(height: 32),
              readingSectionHeader,
              readingControls,
              const Divider(height: 32),
              downloadsSectionHeader,
              const SizedBox(height: 8),
              downloadNetworkTile,
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
            ]),
          ),
        ),
      ],
    );
  }
}
