import 'package:flutter/material.dart';
import '../../../../../shared/components/atoms/app_image.dart';
import '../../../../../shared/utils/image_aspect_ratio_cache.dart';
import '../../../domain/entities/reading_chapter.dart';

class ImageReaderItem extends StatefulWidget {
  final ReadingPage page;

  const ImageReaderItem({super.key, required this.page});

  @override
  State<ImageReaderItem> createState() => _ImageReaderItemState();
}

class _ImageReaderItemState extends State<ImageReaderItem> {
  late double _aspectRatio;

  @override
  void initState() {
    super.initState();
    _updateAspectRatio();
  }

  @override
  void didUpdateWidget(ImageReaderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.url != widget.page.url) {
      _updateAspectRatio();
    }
  }

  void _updateAspectRatio() {
    // 1. Check in-memory global cache
    final cached = ImageAspectRatioCache.get(widget.page.url);
    if (cached != null) {
      _aspectRatio = cached;
      return;
    }

    // 2. Fallback to API dimensions
    if (widget.page.width != null &&
        widget.page.height != null &&
        widget.page.width! > 0 &&
        widget.page.height! > 0) {
      _aspectRatio = widget.page.width! / widget.page.height!;
    } else {
      // 3. Default fallback
      _aspectRatio = 0.7;
    }
  }

  void _onImageLoaded(Size size) {
    if (!mounted) return;

    final newAspectRatio = ImageAspectRatioCache.updateFromSize(
      widget.page.url,
      size,
    );

    setState(() {
      _aspectRatio = newAspectRatio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: AppImage(
        imageUrl: widget.page.url,
        blurHash: widget.page.metadata?.blurHash,
        fit: BoxFit.fill,
        width: double.infinity,
        onImageLoaded: _onImageLoaded,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
