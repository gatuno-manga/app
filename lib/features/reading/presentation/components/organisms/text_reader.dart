import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/entities/reading_enums.dart';

class TextReader extends StatelessWidget {
  final ReadingChapter chapter;

  const TextReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final content = chapter.content ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chapter.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                chapter.title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          _buildTextContent(context, content),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, String content) {
    switch (chapter.contentFormat) {
      case ContentFormat.html:
        return Html(data: content);
      case ContentFormat.markdown:
        return MarkdownBody(data: content);
      case ContentFormat.plain:
      default:
        return Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
        );
    }
  }
}
