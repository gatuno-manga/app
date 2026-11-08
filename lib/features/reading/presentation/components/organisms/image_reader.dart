import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/components/organisms/app_scrollable_positioned_list.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../view_models/reader_zoom_controller.dart';
import '../../view_models/reading_view_model.dart';
import '../molecules/image_reader_item.dart';
import '../molecules/zoomable_viewport.dart';
import 'reader_overlay_wrapper.dart';

class ImageReader extends StatefulWidget {
  final ReadingChapter chapter;
  final int initialIndex;

  const ImageReader({super.key, required this.chapter, this.initialIndex = 0});

  @override
  State<ImageReader> createState() => _ImageReaderState();
}

class _ImageReaderState extends State<ImageReader> {
  final _scrollController = ScrollController();
  late final _zoom = ReaderZoomController(_scrollController);

  @override
  void didUpdateWidget(ImageReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.id != widget.chapter.id) _zoom.reset();
  }

  @override
  void dispose() {
    _zoom.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    return ReaderOverlayWrapper(
      chapter: chapter,
      onDoubleTap: _zoom.toggleAt,
      child: ZoomableViewport(
        zoom: _zoom,
        builder: (context, physics) => AppScrollablePositionedList(
          controller: _scrollController,
          physics: physics,
          initialIndex: widget.initialIndex,
          itemCount: chapter.pages.length,
          onVisibleIndexChanged: (index) {
            context.read<ReadingViewModel>().setCurrentPage(index);
            context.replace('/chapters/${chapter.id}/page/$index');
          },
          itemBuilder: (context, index) {
            return ImageReaderItem(page: chapter.pages[index]);
          },
        ),
      ),
    );
  }
}
