import '../../../reading/domain/entities/reading_enums.dart';
import '../entities/download_network.dart';

/// Which network downloads of each book type may use.
abstract class DownloadNetworkPolicy {
  Future<DownloadNetwork> requirementFor(BookType type);

  /// Fires when a requirement changed; pending downloads are rescheduled.
  Stream<void> get changes;
}
