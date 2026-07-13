import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../settings/domain/use_cases/settings_service.dart';
import 'package:equatable/equatable.dart';

class WelcomeState extends Equatable {
  final bool isLoading;
  final String? error;

  const WelcomeState({
    required this.isLoading,
    this.error,
  });

  factory WelcomeState.initial() {
    return const WelcomeState(
      isLoading: false,
      error: null,
    );
  }

  WelcomeState copyWith({
    bool? isLoading,
    String? Function()? error,
  }) {
    return WelcomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}

class WelcomeViewModel extends BaseStreamViewModel<WelcomeState> {
  final SettingsService _settingsService;

  WelcomeViewModel(this._settingsService) : super(WelcomeState.initial());

  Future<bool> validateAndSaveUrl(String url) async {
    if (url.isEmpty) {
      emit(state.copyWith(error: () => 'Please enter a URL'));
      return false;
    }

    emit(state.copyWith(isLoading: true, error: () => null));

    try {
      final isValid = await _settingsService.validateApiUrl(url);

      if (isValid) {
        final formattedUrl = url.endsWith('/')
            ? url.substring(0, url.length - 1)
            : url;
        await _settingsService.setApiUrl(formattedUrl);
        return true;
      } else {
        emit(state.copyWith(error: () => 'Could not connect to the server. Please check the URL and certificate.'));
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error during validateAndSaveUrl in ViewModel',
        e,
        stackTrace,
        'WelcomeViewModel',
      );
      emit(state.copyWith(error: () => 'An unexpected error occurred while saving the URL.'));
      return false;
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
