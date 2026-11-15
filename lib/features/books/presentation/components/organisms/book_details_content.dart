import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';
import '../../../../../shared/components/atoms/app_text_button.dart';
import '../../../domain/entities/book.dart';
import '../../view_models/book_details_view_model.dart';
import '../../view_models/book_downloads_view_model.dart';
import '../../views/book_downloads_flows.dart';
import '../atoms/book_cover_large.dart';
import '../molecules/book_action_buttons.dart';
import '../molecules/book_details_header.dart';
import '../molecules/book_tags_list.dart';
import '../molecules/book_description.dart';
import '../molecules/chapter_selection_actions.dart';
import '../molecules/chapter_selection_bar.dart';
import '../templates/book_details_template.dart';
import 'chapter_list.dart';

class BookDetailsContent extends StatelessWidget {
  final BookDetailsViewModel viewModel;
  final BookDownloadsViewModel downloadsViewModel;
  final BookDownloadsState downloads;
  final Book book;
  final ScrollController scrollController;

  const BookDetailsContent({
    super.key,
    required this.viewModel,
    required this.downloadsViewModel,
    required this.downloads,
    required this.book,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flows = BookDownloadsFlows(downloadsViewModel);
    final chapters = viewModel.chapterList?.data ?? [];
    final selecting = downloads.selecting;
    final allLoadedSelected =
        chapters.isNotEmpty &&
        chapters.every((c) => downloads.selection.contains(c.id));

    return BookDetailsTemplate(
      scrollController: scrollController,
      appBarOverlaysBody: !selecting,
      appBar: selecting
          ? ChapterSelectionBar(
              countLabel: l10n.booksSelectionCount(downloads.selection.length),
              closeTooltip: l10n.booksSelectionClose,
              selectLoadedTooltip: l10n.booksSelectionSelectLoaded,
              onClose: downloadsViewModel.clearSelection,
              onSelectLoaded: allLoadedSelected
                  ? null
                  : () =>
                        downloadsViewModel.selectAll(chapters.map((c) => c.id)),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: AppIconButton(
                icon: Icons.arrow_back,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
      cover: BookCoverLarge(coverUrl: book.cover?.value),
      header: BookDetailsHeader(
        title: book.title.value,
        authors: book.authors,
        totalChapters: book.totalChapters?.value,
        publicationYear: book.publication?.value,
      ),
      actionButtons: BookActionButtons(
        hasProgress: viewModel.hasReadingProgress,
        onStartReading: () async {
          final chapterId = viewModel.getResumeChapterId();
          if (chapterId != null) {
            final pageIndex = viewModel.getResumePageIndex();
            if (pageIndex > 0) {
              await context.push('/chapters/$chapterId/page/$pageIndex');
            } else {
              await context.push('/chapters/$chapterId');
            }
            await viewModel.refreshReadStatus();
          }
        },
        onMenuPressed: () => flows.openBookOptions(context),
        menuTooltip: l10n.booksMoreOptions,
      ),
      tags: BookTagsList(tags: book.tags),
      description: BookDescription(description: book.description?.value),
      downloadSummary: BookDownloadsFlows.summary(
        context,
        downloads,
        totalChapters: book.totalChapters?.value,
        onAction: downloadsViewModel.runStripAction,
      ),
      chapterControls: selecting || chapters.isEmpty
          ? null
          : AppTextButton(
              text: l10n.booksSelect,
              icon: Icons.check_circle_outline,
              onPressed: downloadsViewModel.startSelection,
            ),
      chapterList: ChapterList(
        chapters: chapters,
        isLoading: viewModel.isLoadingChapters,
        hasNextPage: viewModel.chapterList?.hasNextPage ?? false,
        onChapterTap: (chapter) async {
          if (chapter.lastPage.value > 0 && !chapter.completed) {
            await context.push(
              '/chapters/${chapter.id}/page/${chapter.lastPage.value}',
            );
          } else {
            await context.push('/chapters/${chapter.id}');
          }
          await viewModel.refreshReadStatus();
        },
        error: viewModel.chaptersError,
        onRetry: viewModel.fetchChapters,
        downloadStatusOf: (chapter) => downloads.statusOf(chapter.id),
        downloadProgressOf: (chapter) =>
            downloads.chapter(chapter.id)?.progress ?? 0,
        onDownloadTap: (chapter) => flows.tapIndicator(context, chapter),
        selecting: selecting,
        isSelected: (chapter) => downloads.selection.contains(chapter.id),
        onToggleSelected: (chapter) =>
            downloadsViewModel.toggleSelection(chapter.id),
        onLongPress: (chapter) => downloadsViewModel.startSelection(chapter.id),
        bottomPadding: selecting
            ? ChapterSelectionActions.height +
                  MediaQuery.paddingOf(context).bottom
            : 0,
      ),
      bottomBar: selecting ? flows.selectionActions(context, downloads) : null,
    );
  }
}
