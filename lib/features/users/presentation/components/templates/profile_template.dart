import 'package:flutter/material.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';
import 'package:gatuno/shared/components/organisms/app_top_bar.dart';
import 'package:gatuno/shared/components/templates/app_top_bar_scaffold.dart';

class ProfileTemplate extends StatelessWidget {
  final String title;
  final Widget header;
  final Widget settings;
  final bool isLoading;

  const ProfileTemplate({
    super.key,
    required this.title,
    required this.header,
    required this.settings,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTopBarScaffold(
      topBar: AppTopBar(title: title, showBack: true),
      slivers: [
        if (isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: AppLoadingIndicator.large()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  header,
                  const SizedBox(height: 32),
                  settings,
                ],
              ),
            ),
          ),
      ],
    );
  }
}
