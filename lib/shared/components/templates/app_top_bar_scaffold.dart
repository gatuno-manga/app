import 'package:flutter/material.dart';

import '../organisms/app_top_bar.dart';

/// A [Scaffold] whose body is a [CustomScrollView] starting with the shared
/// top bar. Every screen in the shell uses it, so the bar hides on scroll in
/// one place.
///
/// The scroll view uses the primary controller, which is how a tab root's
/// `TabRootScrollScope` scrolls it to the top on a tab re-tap.
class AppTopBarScaffold extends StatelessWidget {
  /// Usually an [AppTopBar]; book detail passes its selection bar here.
  final Widget topBar;
  final List<Widget> slivers;
  final Widget? bottomBar;

  /// Wraps the scroll view, for a `RefreshIndicator`.
  final Widget Function(Widget scrollView)? wrap;

  const AppTopBarScaffold({
    super.key,
    required this.topBar,
    required this.slivers,
    this.bottomBar,
    this.wrap,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(slivers: [topBar, ...slivers]);
    return Scaffold(
      body: wrap == null ? scrollView : wrap!(scrollView),
      bottomNavigationBar: bottomBar,
    );
  }
}
