import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/branch_scroll_scope.dart';
import '../../presentation/view_models/navigation_view_model.dart';
import '../../../core/di/injection.dart';
import '../molecules/app_bottom_nav_bar.dart';
import '../molecules/app_offline_banner.dart';

/// `StatefulShellRoute.navigatorContainerBuilder` for [NavigationShell]: the
/// default indexed stack, with each branch inside its [BranchScrollScope].
Widget buildShellBranches(
  BuildContext context,
  StatefulNavigationShell navigationShell,
  List<Widget> children,
) {
  final registry = BranchScrollRegistryScope.maybeOf(context);
  return IndexedStack(
    index: navigationShell.currentIndex,
    children: [
      for (var i = 0; i < children.length; i++)
        Offstage(
          offstage: i != navigationShell.currentIndex,
          child: TickerMode(
            enabled: i == navigationShell.currentIndex,
            child: registry == null
                ? children[i]
                : BranchScrollScope(
                    controller: registry.controllerFor(i),
                    child: children[i],
                  ),
          ),
        ),
    ],
  );
}

class NavigationShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({super.key, required this.navigationShell});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  final BranchScrollRegistry _scrollRegistry = BranchScrollRegistry();

  @override
  void dispose() {
    _scrollRegistry.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    final shell = widget.navigationShell;
    if (index != shell.currentIndex) {
      shell.goBranch(index);
      return;
    }
    // Re-tap: pop to the tab root, and once there scroll it to the top.
    final navigator = shell.route.branches[index].navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      shell.goBranch(index, initialLocation: true);
    } else {
      _scrollRegistry.scrollToTop(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<NavigationViewModel>(
      create: (_) => sl<NavigationViewModel>(),
      dispose: (_, viewModel) => viewModel.dispose(),
      child: Builder(
        builder: (context) {
          final viewModel = context.read<NavigationViewModel>();
          return StreamBuilder<NavigationState>(
            stream: viewModel.stateStream,
            initialData: viewModel.state,
            builder: (context, snapshot) {
              return Scaffold(
                body: BranchScrollRegistryScope(
                  registry: _scrollRegistry,
                  child: widget.navigationShell,
                ),
                bottomNavigationBar: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppOfflineBanner(offline: snapshot.data!.isOffline),
                    AppBottomNavBar(
                      currentIndex: widget.navigationShell.currentIndex,
                      onTap: _onTap,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
