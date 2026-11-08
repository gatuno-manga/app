import 'dart:async';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/theme/app_theme_choice.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/use_cases/settings_service.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
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

class SettingsViewModel extends BaseStreamViewModel<SettingsState> {
  final SettingsService _settingsService;
  final AuthService _authService;
  final UserService _userService;
  late final StreamSubscription<void> _settingsSubscription;
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<UserModel?> _profileSubscription;

  SettingsViewModel({
    required SettingsService settingsService,
    required AuthService authService,
    required UserService userService,
  }) : _settingsService = settingsService,
       _authService = authService,
       _userService = userService,
       super(SettingsState.initial()) {
    _settingsSubscription = _settingsService.settingsStream.listen(
      (_) => _syncState(),
    );
    _authSubscription = _authService.authStateStream.listen(
      (_) => _syncState(),
    );
    _profileSubscription = _userService.profileStream.listen(
      (user) => emit(state.copyWith(user: user ?? UserModel.guest)),
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
    _loadUser();
  }

  /// The cached profile carries the image URLs the JWT does not.
  Future<void> _loadUser() async {
    emit(state.copyWith(user: await _userService.getCurrentUser()));
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
