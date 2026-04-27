import 'package:flutter/material.dart';

class CertificatesTemplate extends StatelessWidget {
  final Widget title;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final VoidCallback onAddPressed;

  const CertificatesTemplate({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: title,
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: tabViews,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onAddPressed,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
