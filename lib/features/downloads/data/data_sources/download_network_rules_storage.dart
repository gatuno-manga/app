import 'package:shared_preferences/shared_preferences.dart';

import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/download_network.dart';
import '../../exceptions/download_exceptions.dart';

/// The network rule of each book type. Not sensitive, so it lives in
/// shared_preferences, one key per type.
class DownloadNetworkRulesStorage {
  static String _key(BookType type) => 'download_network_${type.value}';

  /// The stored rule of [type], or null when none is stored or the stored
  /// value is not a known rule.
  Future<DownloadNetwork?> read(BookType type) async {
    final prefs = await SharedPreferences.getInstance();
    return DownloadNetwork.values.asNameMap()[prefs.getString(_key(type))];
  }

  Future<void> write(BookType type, DownloadNetwork network) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key(type), network.name)) {
      throw NetworkRuleNotSavedException(type.value);
    }
  }
}
