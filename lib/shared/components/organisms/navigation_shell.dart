import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/view_models/navigation_view_model.dart';
import '../../../core/di/injection.dart';
import '../molecules/app_bottom_nav_bar.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Provider<NavigationViewModel>(
      create: (_) => sl<NavigationViewModel>(),
      child: Builder(
        builder: (context) {
          final viewModel = context.read<NavigationViewModel>();
          return StreamBuilder<NavigationState>(
            stream: viewModel.stateStream,
            initialData: viewModel.state,
            builder: (context, snapshot) {
              return Scaffold(
                body: navigationShell,
                bottomNavigationBar: AppBottomNavBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => _onTap(context, index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
