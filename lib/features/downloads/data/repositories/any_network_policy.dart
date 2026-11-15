import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/download_network.dart';
import '../../domain/repositories/download_network_policy.dart';

/// Every book type downloads on any network. The default until a user setting
/// replaces it.
class AnyNetworkPolicy implements DownloadNetworkPolicy {
  const AnyNetworkPolicy();

  @override
  Future<DownloadNetwork> requirementFor(BookType type) async =>
      DownloadNetwork.any;

  @override
  Stream<void> get changes => const Stream.empty();
}
