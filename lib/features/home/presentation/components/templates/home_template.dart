import 'package:flutter/material.dart';

import '../../../../../shared/components/templates/app_top_bar_scaffold.dart';

/// Home layout: the shared top bar over the scrolling sections.
class HomeTemplate extends StatelessWidget {
  final Widget topBar;
  final List<Widget> slivers;

  const HomeTemplate({super.key, required this.topBar, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return AppTopBarScaffold(topBar: topBar, slivers: slivers);
  }
}
