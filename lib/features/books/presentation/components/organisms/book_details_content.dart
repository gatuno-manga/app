import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';
import '../../../domain/entities/book.dart';
import '../../models/download_display.dart';
import '../../view_models/book_details_view_model.dart';
import '../atoms/book_cover_large.dart';
import '../molecules/book_action_buttons.dart';
import '../molecules/book_details_header.dart';
import '../molecules/book_tags_list.dart';
import '../molecules/book_description.dart';
import '../templates/book_details_template.dart';
import 'chapter_list.dart';

class BookDetailsContent extends StatelessWidget {
  final BookDetailsViewModel viewModel;
  final Book book;
  final ScrollController scrollController;

  /// Replaces the back button while selection mode is on.
  final PreferredSizeWidget? selectionBar;

  /// The download summary, between the description and the chapters.
  final Widget? downloadSummary;

  /// Controls above the chapter list (the Select button).
  final Widget? chapterControls;

  /// Fixed to the bottom (the selection actions).
  final Widget? bottomBar;

  /// Download indicators and selection mode of the chapter list.
  final ChapterListDownloads? chapterDownloads;

  /// Opens the book's ⋮ sheet.
  final VoidCallback? onMenuPressed;

  const BookDetailsContent({
    super.key,
    required this.viewModel,
    required this.book,
    required this.scrollController,
    this.selectionBar,
    this.downloadSummary,
    this.chapterControls,
    this.bottomBar,
    this.chapterDownloads,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BookDetailsTemplate(
      scrollController: scrollController,
      appBar:
          selectionBar ??
          AppBar(
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
        onMenuPressed: onMenuPressed,
        menuTooltip: l10n.booksMoreOptions,
      ),
      tags: BookTagsList(tags: book.tags),
      description: BookDescription(description: book.description?.value),
      downloadSummary: downloadSummary,
      chapterControls: chapterControls,
      chapterList: ChapterList(
        chapters: viewModel.chapterList?.data ?? [],
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
        downloads: chapterDownloads,
      ),
      bottomBar: bottomBar,
    );
  }
}
