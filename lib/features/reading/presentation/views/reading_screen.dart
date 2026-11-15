import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/reading_view_model.dart';
import '../../domain/use_cases/reader_preferences_service.dart';
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
    return MultiProvider(
      providers: [
        Provider<ReadingViewModel>(
          create: (context) =>
              sl<ReadingViewModel>()
                ..loadChapter(chapterId, initialPage: initialPage),
          dispose: (_, viewModel) => viewModel.dispose(),
        ),
        Provider<ReaderPreferencesService>.value(
          value: sl<ReaderPreferencesService>(),
        ),
      ],
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
  /// The "still offline" message, closed once the offline view goes away (a
  /// reconnect opened the chapter, or the reader left).
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _stillOffline;
  late final StreamSubscription<ReadingState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    _stateSubscription = context.read<ReadingViewModel>().stateStream.listen((
      state,
    ) {
      if (!state.isOfflineMiss) _closeStillOffline();
    });
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _closeStillOffline();
    super.dispose();
  }

  /// Closes the message if it is still up; one that timed out already
  /// cleared [_stillOffline] (closing it again would hide another SnackBar).
  void _closeStillOffline() {
    final shown = _stillOffline;
    _stillOffline = null;
    shown?.close();
  }

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
    final viewModel = context.read<ReadingViewModel>();
    return StreamBuilder<ReadingState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return ReadingTemplate(
          isLoading: state.isLoading,
          error: state.error,
          chapter: state.chapter,
          isOfflineMiss: state.isOfflineMiss,
          isRetrying: state.isRetrying,
          onOfflineRetry: () => _retryOffline(viewModel),
          onRetry: viewModel.retry,
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

  /// Says so when the server is still unreachable: the offline view itself
  /// does not change, and a SnackBar is announced to screen readers.
  Future<void> _retryOffline(ReadingViewModel viewModel) async {
    final reachable = await viewModel.retryOffline();
    if (reachable || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _closeStillOffline();
    final shown = ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.readingStillOffline)));
    _stillOffline = shown;
    shown.closed.whenComplete(() {
      if (identical(_stillOffline, shown)) _stillOffline = null;
    });
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
