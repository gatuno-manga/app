import 'package:flutter/material.dart';

/// Owns one [ScrollController] per bottom-bar branch so re-tapping the active
/// tab can scroll its root list back to the top.
///
/// Created by `NavigationShell`; branch navigators read their controller
/// through [BranchScrollScope].
class BranchScrollRegistry {
  final Map<int, ScrollController> _controllers = {};

  ScrollController controllerFor(int branchIndex) =>
      _controllers.putIfAbsent(branchIndex, ScrollController.new);

  /// Animates the branch's root list to offset 0. Returns false when no list
  /// is attached (an empty state, or a root that does not opt in).
  bool scrollToTop(int branchIndex) {
    final controller = _controllers[branchIndex];
    if (controller == null || !controller.hasClients) return false;
    for (final position in controller.positions) {
      position.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    return true;
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// Makes a [BranchScrollRegistry] available to the branch navigators.
class BranchScrollRegistryScope extends InheritedWidget {
  final BranchScrollRegistry registry;

  const BranchScrollRegistryScope({
    super.key,
    required this.registry,
    required super.child,
  });

  static BranchScrollRegistry? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BranchScrollRegistryScope>()
      ?.registry;

  @override
  bool updateShouldNotify(BranchScrollRegistryScope oldWidget) =>
      registry != oldWidget.registry;
}

/// The scroll controller of the branch a subtree lives in.
class BranchScrollScope extends InheritedWidget {
  final ScrollController controller;

  const BranchScrollScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static ScrollController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BranchScrollScope>()
      ?.controller;

  @override
  bool updateShouldNotify(BranchScrollScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Wrap a tab root with this so its main vertical list becomes the one that
/// scrolls to the top on re-tap.
///
/// Only the root is wrapped: screens pushed on top of it stay outside, so the
/// controller never has two lists attached.
class TabRootScrollScope extends StatelessWidget {
  final Widget child;

  const TabRootScrollScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = BranchScrollScope.maybeOf(context);
    if (controller == null) return child;
    return PrimaryScrollController(controller: controller, child: child);
  }
}
