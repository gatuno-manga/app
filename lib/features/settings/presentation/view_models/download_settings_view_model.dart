import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../downloads/domain/entities/download_network.dart';
import '../../../downloads/domain/repositories/download_network_rules.dart';
import '../../../reading/domain/entities/reading_enums.dart';

class DownloadSettingsState extends Equatable {
  /// The rule shown for every book type.
  final Map<BookType, DownloadNetwork> rules;

  /// False until the saved rules arrive; the choices are disabled until then.
  final bool isLoaded;

  const DownloadSettingsState({required this.rules, required this.isLoaded});

  factory DownloadSettingsState.initial() => DownloadSettingsState(
    rules: {
      for (final type in BookType.values)
        type: DownloadNetworkRules.defaultRule,
    },
    isLoaded: false,
  );

  DownloadSettingsState copyWith({
    Map<BookType, DownloadNetwork>? rules,
    bool? isLoaded,
  }) => DownloadSettingsState(
    rules: rules ?? this.rules,
    isLoaded: isLoaded ?? this.isLoaded,
  );

  @override
  List<Object?> get props => [rules, isLoaded];
}

/// The download network rule of each book type, for /settings/download.
class DownloadSettingsViewModel
    extends BaseStreamViewModel<DownloadSettingsState> {
  static const String _logTag = 'DownloadSettingsViewModel';

  final DownloadNetworkRules _rules;
  late final StreamSubscription<Map<BookType, DownloadNetwork>> _subscription;

  /// What is saved, to restore a choice whose save failed.
  Map<BookType, DownloadNetwork> _stored = const {};

  /// Choices shown before their save lands, kept over the saved rules so a
  /// save of another type does not flip them back meanwhile.
  final Map<BookType, DownloadNetwork> _pending = {};

  DownloadSettingsViewModel({required DownloadNetworkRules rules})
    : _rules = rules,
      super(DownloadSettingsState.initial()) {
    _subscription = _rules.watch().listen((rules) {
      _stored = rules;
      _show();
    });
  }

  /// Shows [network] for [type] at once and saves it. Returns false when
  /// it was not saved: the saved rule is shown again, and the screen tells
  /// the user.
  Future<bool> setRule(BookType type, DownloadNetwork network) async {
    _pending[type] = network;
    _show();
    try {
      await _rules.set(type, network);
      // Saved: the watch stream may report it a little later.
      if (_stored.isNotEmpty) _stored = {..._stored, type: network};
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('Network rule not saved', e, stackTrace, _logTag);
      return false;
    } finally {
      // A later tap on the same type owns the pending value now.
      if (_pending[type] == network) _pending.remove(type);
      _show();
    }
  }

  void _show() {
    if (_stored.isEmpty) {
      emit(state.copyWith(rules: {...state.rules, ..._pending}));
      return;
    }
    emit(state.copyWith(rules: {..._stored, ..._pending}, isLoaded: true));
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
