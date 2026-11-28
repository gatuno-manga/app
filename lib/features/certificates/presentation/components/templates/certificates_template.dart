import 'package:flutter/material.dart';

import '../../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../../shared/components/templates/app_top_bar_scaffold.dart';

class CertificatesTemplate extends StatelessWidget {
  final String title;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final VoidCallback onAddPressed;

  const CertificatesTemplate({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    required this.onAddPressed,
  }) : assert(
         tabs.length == tabViews.length,
         'The number of tabs must match the number of tabViews.',
       );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: AppTopBarScaffold(
        topBar: AppTopBar(title: title, showBack: true),
        slivers: [
          SliverFillRemaining(
            child: Column(
              children: [
                TabBar(tabs: tabs),
                Expanded(child: TabBarView(children: tabViews)),
              ],
            ),
          ),
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: onAddPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
