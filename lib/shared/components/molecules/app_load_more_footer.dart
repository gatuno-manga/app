import 'package:flutter/material.dart';

import '../atoms/app_loading_indicator.dart';

/// Loading row appended to a list while the next page is fetched.
class AppLoadMoreFooter extends StatelessWidget {
  const AppLoadMoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: AppLoadingIndicator(size: 24)),
    );
  }
}
