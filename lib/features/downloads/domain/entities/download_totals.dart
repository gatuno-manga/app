import 'package:equatable/equatable.dart';

/// How much is downloaded: every chapter download, whatever its state, and
/// the bytes they hold on disk.
class DownloadTotals extends Equatable {
  final int chapters;
  final int bytes;

  const DownloadTotals({required this.chapters, required this.bytes});

  static const DownloadTotals empty = DownloadTotals(chapters: 0, bytes: 0);

  @override
  List<Object?> get props => [chapters, bytes];
}
