import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../view_models/reading_view_model.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../components/organisms/image_reader.dart';
import '../components/organisms/text_reader.dart';
import '../components/organisms/document_reader.dart';
import '../components/templates/reading_template.dart';

class ReadingScreen extends StatefulWidget {
  final String chapterId;
  final int initialPage;

  const ReadingScreen({
    super.key,
    required this.chapterId,
    this.initialPage = 0,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late final ReadingViewModel _viewModel;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ReadingViewModel>();
    _viewModel.loadChapter(widget.chapterId, initialPage: widget.initialPage);
  }

  @override
  void didUpdateWidget(ReadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterId != widget.chapterId) {
      _viewModel.loadChapter(widget.chapterId, initialPage: widget.initialPage);
    }
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ReadingViewModel>(
        builder: (context, viewModel, child) {
          return ReadingTemplate(
            isLoading: viewModel.isLoading,
            error: viewModel.error,
            chapter: viewModel.chapter,
            showOverlay: _showOverlay,
            onToggleOverlay: _toggleOverlay,
            onRetry: () => viewModel.loadChapter(widget.chapterId),
            readerBuilder: _buildReader,
          );
        },
      ),
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
