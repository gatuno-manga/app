import 'dart:async';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/theme/app_theme_choice.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/use_cases/settings_service.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../downloads/domain/entities/download_totals.dart';
import '../../../downloads/domain/repositories/download_service.dart';
import '../../../users/data/models/user_model.dart';
import '../../../users/domain/use_cases/user_service.dart';

import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String? apiUrl;
  final bool sensitiveContentEnabled;
  final AppThemeChoice themeChoice;
  final bool isAuthenticated;
  final UserModel user;
  final bool isLoading;

  const SettingsState({
    this.apiUrl,
    required this.sensitiveContentEnabled,
    required this.themeChoice,
    required this.isAuthenticated,
    required this.user,
    required this.isLoading,
  });

  factory SettingsState.initial() {
    return SettingsState(
      apiUrl: null,
      sensitiveContentEnabled: false,
      themeChoice: AppThemeChoice.system,
      isAuthenticated: false,
      user: UserModel.guest,
      isLoading: false,
    );
  }

  SettingsState copyWith({
    String? Function()? apiUrl,
    bool? sensitiveContentEnabled,
    AppThemeChoice? themeChoice,
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
  }) {
    return SettingsState(
      apiUrl: apiUrl != null ? apiUrl() : this.apiUrl,
      sensitiveContentEnabled:
          sensitiveContentEnabled ?? this.sensitiveContentEnabled,
      themeChoice: themeChoice ?? this.themeChoice,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    apiUrl,
    sensitiveContentEnabled,
    themeChoice,
    isAuthenticated,
    user,
    isLoading,
  ];
}

/// Outcome of saving a server URL from the settings form.
enum ApiUrlUpdateResult {
  /// The URL answered and is now the configured server.
  saved,

  /// The URL did not answer, or saving it failed.
  failed,

  /// The user kept the current server instead of deleting their downloads.
  cancelled,
}

/// Asks the user to confirm that switching servers deletes their downloads.
/// [totals] is null when the downloads could not be counted. Returns whether
/// to go ahead.
typedef ConfirmServerChange = Future<bool> Function(DownloadTotals? totals);

class SettingsViewModel extends BaseStreamViewModel<SettingsState> {
  static const String _logTag = 'SettingsViewModel';
  final SettingsService _settingsService;
  final AuthService _authService;
  final UserService _userService;
  final DownloadService _downloadService;
  late final StreamSubscription<void> _settingsSubscription;
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<UserModel> _profileSubscription;

  SettingsViewModel({
    required SettingsService settingsService,
    required AuthService authService,
    required UserService userService,
    required DownloadService downloadService,
  }) : _settingsService = settingsService,
       _authService = authService,
       _userService = userService,
       _downloadService = downloadService,
       super(SettingsState.initial()) {
    _settingsSubscription = _settingsService.settingsStream.listen(
      (_) => _syncState(),
    );
    _authSubscription = _authService.authStateStream.listen(
      (_) => _syncState(),
    );
    _profileSubscription = _userService.profileStream.listen(
      (user) => emit(state.copyWith(user: user)),
    );
    _syncState();
  }

  void _syncState() {
    emit(
      state.copyWith(
        apiUrl: () => _settingsService.apiUrl,
        sensitiveContentEnabled: _settingsService.sensitiveContentEnabled,
        themeChoice: _settingsService.themeChoice,
        isAuthenticated: _authService.authenticated,
      ),
    );
  }

  @override
  void dispose() {
    _settingsSubscription.cancel();
    _authSubscription.cancel();
    _profileSubscription.cancel();
    super.dispose();
  }

  Future<void> setSensitiveContentEnabled(bool enabled) async {
    await _settingsService.setSensitiveContentEnabled(enabled);
  }

  /// Fire-and-forget from the picker: a failed write is logged, and the
  /// previous choice stays selected because the state never changed.
  Future<void> setThemeChoice(AppThemeChoice choice) async {
    try {
      await _settingsService.setThemeChoice(choice);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error setting theme choice in ViewModel',
        e,
        stackTrace,
        'SettingsViewModel',
      );
    }
  }

  /// Validates [url] and makes it the server. When it is a different server
  /// and downloads exist (or cannot be counted), [confirmServerChange] is
  /// asked first, since the switch deletes them.
  Future<ApiUrlUpdateResult> updateApiUrl(
    String url, {
    required ConfirmServerChange confirmServerChange,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isValid = await _settingsService.validateApiUrl(url);
      if (!isValid) return ApiUrlUpdateResult.failed;

      final formattedUrl = url.endsWith('/')
          ? url.substring(0, url.length - 1)
          : url;
      if (_settingsService.isDifferentServer(formattedUrl)) {
        final totals = await _downloadTotals();
        final needsConfirmation = totals == null || totals.chapters > 0;
        if (needsConfirmation) {
          // Not loading while the user decides: the form behind the dialog
          // should not claim work is running.
          emit(state.copyWith(isLoading: false));
          if (!await confirmServerChange(totals)) {
            return ApiUrlUpdateResult.cancelled;
          }
          emit(state.copyWith(isLoading: true));
        }
      }
      await _settingsService.setApiUrl(formattedUrl);
      return ApiUrlUpdateResult.saved;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error updating API URL in ViewModel',
        e,
        stackTrace,
        _logTag,
      );
      return ApiUrlUpdateResult.failed;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Null when the count fails: the caller then still asks, without numbers,
  /// so downloads are never deleted without a confirmation.
  Future<DownloadTotals?> _downloadTotals() async {
    try {
      return await _downloadService.totals();
    } catch (e, stackTrace) {
      AppLogger.e('Could not count downloads', e, stackTrace, _logTag);
      return null;
    }
  }
}
