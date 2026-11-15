import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../downloads/domain/entities/download_network.dart';
import '../../../downloads/domain/repositories/download_network_rules.dart';
import '../../../reading/domain/entities/reading_enums.dart';

class DownloadSettingsState extends Equatable {
  /// The rule of every book type; empty until they are loaded.
  final Map<BookType, DownloadNetwork> rules;

  const DownloadSettingsState({required this.rules});

  factory DownloadSettingsState.initial() =>
      const DownloadSettingsState(rules: {});

  bool get isLoaded => rules.isNotEmpty;

  DownloadSettingsState copyWith({Map<BookType, DownloadNetwork>? rules}) =>
      DownloadSettingsState(rules: rules ?? this.rules);

  @override
  List<Object?> get props => [rules];
}

/// The download network rule of each book type, for /settings/download.
class DownloadSettingsViewModel
    extends BaseStreamViewModel<DownloadSettingsState> {
  static const String _logTag = 'DownloadSettingsViewModel';

  final DownloadNetworkRules _rules;
  late final StreamSubscription<Map<BookType, DownloadNetwork>> _subscription;

  DownloadSettingsViewModel({required DownloadNetworkRules rules})
    : _rules = rules,
      super(DownloadSettingsState.initial()) {
    _subscription = _rules.watch().listen(
      (rules) => emit(state.copyWith(rules: rules)),
      onError: (Object e, StackTrace stackTrace) =>
          AppLogger.e('Network rules unavailable', e, stackTrace, _logTag),
    );
  }

  /// Saves the rule of [type]. Returns false when it was not saved: the
  /// previous rule stays selected, since the state follows what is stored,
  /// and the screen tells the user.
  Future<bool> setRule(BookType type, DownloadNetwork network) async {
    try {
      await _rules.set(type, network);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('Network rule not saved', e, stackTrace, _logTag);
      return false;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
