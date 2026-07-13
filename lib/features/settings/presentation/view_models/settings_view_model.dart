import 'dart:async';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/use_cases/settings_service.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../users/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String? apiUrl;
  final bool sensitiveContentEnabled;
  final bool isAuthenticated;
  final UserModel user;
  final bool isLoading;

  const SettingsState({
    this.apiUrl,
    required this.sensitiveContentEnabled,
    required this.isAuthenticated,
    required this.user,
    required this.isLoading,
  });

  factory SettingsState.initial() {
    return SettingsState(
      apiUrl: null,
      sensitiveContentEnabled: false,
      isAuthenticated: false,
      user: UserModel.guest,
      isLoading: false,
    );
  }

  SettingsState copyWith({
    String? Function()? apiUrl,
    bool? sensitiveContentEnabled,
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
  }) {
    return SettingsState(
      apiUrl: apiUrl != null ? apiUrl() : this.apiUrl,
      sensitiveContentEnabled: sensitiveContentEnabled ?? this.sensitiveContentEnabled,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        apiUrl,
        sensitiveContentEnabled,
        isAuthenticated,
        user,
        isLoading,
      ];
}

class SettingsViewModel extends BaseStreamViewModel<SettingsState> {
  final SettingsService _settingsService;
  final AuthService _authService;
  late final StreamSubscription<void> _settingsSubscription;
  late final StreamSubscription<AuthState> _authSubscription;

  SettingsViewModel({
    required SettingsService settingsService,
    required AuthService authService,
  }) : _settingsService = settingsService,
       _authService = authService,
       super(SettingsState.initial()) {
    _settingsSubscription = _settingsService.settingsStream.listen((_) => _syncState());
    _authSubscription = _authService.authStateStream.listen((_) => _syncState());
    _syncState();
  }

  void _syncState() {
    emit(state.copyWith(
      apiUrl: () => _settingsService.apiUrl,
      sensitiveContentEnabled: _settingsService.sensitiveContentEnabled,
      isAuthenticated: _authService.authenticated,
      user: _authService.currentUser,
    ));
  }

  @override
  void dispose() {
    _settingsSubscription.cancel();
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> setSensitiveContentEnabled(bool enabled) async {
    await _settingsService.setSensitiveContentEnabled(enabled);
  }

  Future<bool> updateApiUrl(String url) async {
    emit(state.copyWith(isLoading: true));

    try {
      final isValid = await _settingsService.validateApiUrl(url);
      if (isValid) {
        final formattedUrl = url.endsWith('/')
            ? url.substring(0, url.length - 1)
            : url;
        await _settingsService.setApiUrl(formattedUrl);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error updating API URL in ViewModel',
        e,
        stackTrace,
        'SettingsViewModel',
      );
      return false;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
