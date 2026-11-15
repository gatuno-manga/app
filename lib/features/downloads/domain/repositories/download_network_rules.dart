import '../../../reading/domain/entities/reading_enums.dart';
import '../entities/download_network.dart';
import 'download_network_policy.dart';

/// The user's network rule for each book type: the [DownloadNetworkPolicy]
/// the engine reads, plus what the settings screen needs to show and change
/// it.
abstract class DownloadNetworkRules implements DownloadNetworkPolicy {
  /// The rule of a type the user never set: Wi-Fi only, so a large queue
  /// never spends mobile data unless the user allows it.
  static const DownloadNetwork defaultRule = DownloadNetwork.unmetered;

  /// The rule of every [BookType], now and after each change.
  Stream<Map<BookType, DownloadNetwork>> watch();

  /// Saves the rule of [type]. Throws when it cannot be saved; the rule
  /// then stays as it was and [changes] does not fire.
  Future<void> set(BookType type, DownloadNetwork network);
}
