import 'package:flutter/material.dart';
import 'package:gatuno/core/theme/theme.dart';

class BookDetailsTemplate extends StatelessWidget {
  /// The first sliver: the pinned transparent top bar, or the selection bar.
  final Widget topBar;
  final Widget cover;
  final Widget header;
  final Widget actionButtons;
  final Widget tags;
  final Widget description;

  /// The download summary, between the description and the chapters.
  final Widget? downloadSummary;

  /// Controls above the chapter list (the Select button).
  final Widget? chapterControls;
  final Widget chapterList;

  /// A bar fixed to the bottom (selection actions).
  final Widget? bottomBar;
  final ScrollController? scrollController;

  const BookDetailsTemplate({
    super.key,
    required this.topBar,
    required this.cover,
    required this.header,
    required this.actionButtons,
    required this.tags,
    required this.description,
    this.downloadSummary,
    this.chapterControls,
    required this.chapterList,
    this.bottomBar,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final gatunoColors = Theme.of(context).extension<GatunoColors>();
    final downloadSummary = this.downloadSummary;
    final chapterControls = this.chapterControls;

    return Scaffold(
      // The selection bar floats over the list, which pads its end for it.
      extendBody: true,
      bottomNavigationBar: bottomBar,
      body: Container(
        decoration: BoxDecoration(gradient: gatunoColors?.degrader),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            topBar,
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Center(child: cover),
                    const SizedBox(height: 32),
                    header,
                    const SizedBox(height: 24),
                    actionButtons,
                    const SizedBox(height: 24),
                    tags,
                    const SizedBox(height: 24),
                    description,
                    const SizedBox(height: 32),
                    if (downloadSummary != null) ...[
                      SizedBox(width: double.infinity, child: downloadSummary),
                      const SizedBox(height: 16),
                    ],
                    if (chapterControls != null)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: chapterControls,
                      ),
                  ],
                ),
              ),
            ),
            chapterList,
          ],
        ),
      ),
    );
  }
}
