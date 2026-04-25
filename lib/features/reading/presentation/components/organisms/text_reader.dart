import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/entities/reading_enums.dart';
import 'reader_overlay_wrapper.dart';

class TextReader extends StatefulWidget {
  final ReadingChapter chapter;

  const TextReader({super.key, required this.chapter});

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  late Widget _textContent;

  @override
  void initState() {
    super.initState();
    _textContent = _buildTextContent(widget.chapter.content ?? '');
  }

  @override
  void didUpdateWidget(TextReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapter.content != widget.chapter.content ||
        oldWidget.chapter.contentFormat != widget.chapter.contentFormat) {
      _textContent = _buildTextContent(widget.chapter.content ?? '');
    }
  }

  Widget _buildTextContent(String content) {
    switch (widget.chapter.contentFormat) {
      case ContentFormat.html:
        return Html(data: content);
      case ContentFormat.markdown:
        return MarkdownBody(data: content);
      case ContentFormat.plain:
      default:
        return Builder(
          builder: (context) => Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReaderOverlayWrapper(
      chapter: widget.chapter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chapter.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  widget.chapter.title!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _textContent,
          ],
        ),
      ),
    );
  }
}
