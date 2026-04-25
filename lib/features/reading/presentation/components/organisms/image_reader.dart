import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/components/organisms/app_scrollable_positioned_list.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../view_models/reading_view_model.dart';
import '../molecules/image_reader_item.dart';
import 'reader_overlay_wrapper.dart';

class ImageReader extends StatelessWidget {
  final ReadingChapter chapter;
  final int initialIndex;

  const ImageReader({super.key, required this.chapter, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ReaderOverlayWrapper(
      chapter: chapter,
      child: AppScrollablePositionedList(
        initialIndex: initialIndex,
        itemCount: chapter.pages.length,
        onVisibleIndexChanged: (index) {
          context.read<ReadingViewModel>().setCurrentPage(index);
          context.replace('/chapters/${chapter.id}/page/$index');
        },
        itemBuilder: (context, index) {
          return ImageReaderItem(page: chapter.pages[index]);
        },
      ),
    );
  }
}
