import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../view_models/reading_view_model.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../components/organisms/image_reader.dart';
import '../components/organisms/text_reader.dart';
import '../components/organisms/document_reader.dart';
import '../components/templates/reading_template.dart';

class ReadingScreen extends StatelessWidget {
  final String chapterId;
  final int initialPage;

  const ReadingScreen({
    super.key,
    required this.chapterId,
    this.initialPage = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          sl<ReadingViewModel>()
            ..loadChapter(chapterId, initialPage: initialPage),
      child: _ReadingScreenContent(
        chapterId: chapterId,
        initialPage: initialPage,
      ),
    );
  }
}

class _ReadingScreenContent extends StatefulWidget {
  final String chapterId;
  final int initialPage;

  const _ReadingScreenContent({
    required this.chapterId,
    required this.initialPage,
  });

  @override
  State<_ReadingScreenContent> createState() => _ReadingScreenContentState();
}

class _ReadingScreenContentState extends State<_ReadingScreenContent> {
  @override
  void didUpdateWidget(_ReadingScreenContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId) {
      context.read<ReadingViewModel>().loadChapter(
        widget.chapterId,
        initialPage: widget.initialPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReadingViewModel>(
      builder: (context, viewModel, child) {
        return ReadingTemplate(
          isLoading: viewModel.isLoading,
          error: viewModel.error,
          chapter: viewModel.chapter,
          onRetry: () => viewModel.loadChapter(widget.chapterId),
          onGoBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          readerBuilder: _buildReader,
        );
      },
    );
  }

  Widget _buildReader(ReadingChapter chapter) {
    switch (chapter.contentType) {
      case ContentType.image:
        return ImageReader(chapter: chapter, initialIndex: widget.initialPage);
      case ContentType.text:
        return TextReader(chapter: chapter);
      case ContentType.document:
        return DocumentReader(chapter: chapter);
    }
  }
}
