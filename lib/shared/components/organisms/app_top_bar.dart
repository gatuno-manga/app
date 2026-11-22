import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../atoms/app_icon_button.dart';

/// The top app bar of every screen in the shell (`App/Organism/Shell/Barra
/// superior`): one 64 dp row with the title (or the logo) on the left and up
/// to three 48 dp actions on the right, plus an optional 56 dp search row.
///
/// It is a sliver: place it first in a [CustomScrollView] (see
/// `AppTopBarScaffold`). It floats, so it hides on scroll down and returns on
/// scroll up, search row included. [pinned] keeps it on screen (book detail).
class AppTopBar extends StatelessWidget {
  static const double rowHeight = 64;
  static const double searchRowHeight = 56;

  final String? title;

  /// Swaps the title for the logo (Home).
  final bool showLogo;

  /// Shows the back button (pushed screens). [onBack] defaults to popping,
  /// or going Home when there is nothing to pop.
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;

  /// Field shown in its own row under the bar; it hides with the bar.
  final Widget? searchField;

  /// Draws over the content instead of on the page background.
  final bool transparent;
  final bool pinned;

  const AppTopBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBack = false,
    this.onBack,
    this.actions = const [],
    this.searchField,
    this.transparent = false,
    this.pinned = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: !pinned,
      snap: !pinned,
      pinned: pinned,
      automaticallyImplyLeading: false,
      toolbarHeight: rowHeight,
      centerTitle: false,
      titleSpacing: showBack ? 0 : 16,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: transparent ? Colors.transparent : null,
      leading: showBack
          ? AppIconButton(
              icon: Icons.arrow_back,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack ?? () => _defaultBack(context),
            )
          : null,
      title: showLogo
          ? Semantics(
              header: true,
              label: title,
              child: ExcludeSemantics(
                child: Image.asset('assets/icon.png', height: 32),
              ),
            )
          : (title == null
                ? null
                : Semantics(
                    header: true,
                    child: Text(title!, style: theme.textTheme.titleLarge),
                  )),
      actions: actions,
      bottom: searchField == null
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(searchRowHeight),
              child: SizedBox(
                height: searchRowHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: searchField,
                ),
              ),
            ),
    );
  }

  static void _defaultBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }
}

/// Pins a ready-made bar (a selection bar, for instance) in the place of the
/// [AppTopBar] sliver.
class AppPinnedBarSliver extends StatelessWidget {
  final PreferredSizeWidget bar;

  const AppPinnedBarSliver({super.key, required this.bar});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedBarDelegate(bar),
    );
  }
}

class _PinnedBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget bar;

  _PinnedBarDelegate(this.bar);

  @override
  double get minExtent => bar.preferredSize.height;

  @override
  double get maxExtent => bar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => bar;

  @override
  bool shouldRebuild(_PinnedBarDelegate oldDelegate) => oldDelegate.bar != bar;
}
