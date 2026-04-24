import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../view_models/reading_view_model.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../components/organisms/image_reader.dart';
import '../components/organisms/text_reader.dart';
import '../components/organisms/document_reader.dart';
import '../components/organisms/reading_overlay.dart';

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
      child: Scaffold(
        body: Consumer<ReadingViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.loadChapter(widget.chapterId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final chapter = viewModel.chapter;
            if (chapter == null) {
              return const Center(child: Text('No chapter found'));
            }

            return Stack(
              children: [
                GestureDetector(
                  onTap: _toggleOverlay,
                  child: _buildReader(chapter),
                ),
                if (_showOverlay) ReadingOverlay(chapter: chapter),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReader(ReadingChapter chapter) {
    switch (chapter.contentType) {
      case ContentType.image:
        return ImageReader(
          chapter: chapter,
          initialIndex: widget.initialPage,
        );
      case ContentType.text:
        return TextReader(chapter: chapter);
      case ContentType.document:
        return DocumentReader(chapter: chapter);
    }
  }
}
