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
  final Widget? floatingActionButton;

  /// For screens that load more near the end of the list. Leave null on tab
  /// roots so the primary controller keeps scrolling to the top on re-tap.
  final ScrollController? controller;

  /// Wraps the scroll view, for a `RefreshIndicator`.
  final Widget Function(Widget scrollView)? wrap;

  const AppTopBarScaffold({
    super.key,
    required this.topBar,
    required this.slivers,
    this.bottomBar,
    this.floatingActionButton,
    this.controller,
    this.wrap,
  });

  @override
  Widget build(BuildContext context) {
    final scrollView = CustomScrollView(
      // The floating bar can hide a focused search field; dragging the list
      // closes the keyboard instead of typing into a hidden field.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      controller: controller,
      // Pull to refresh needs a drag even when the content is short.
      physics: wrap == null ? null : const AlwaysScrollableScrollPhysics(),
      slivers: [topBar, ...slivers],
    );
    return Scaffold(
      body: wrap == null ? scrollView : wrap!(scrollView),
      bottomNavigationBar: bottomBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
