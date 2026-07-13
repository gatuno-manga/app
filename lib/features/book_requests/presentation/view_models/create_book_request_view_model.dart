import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/repositories/book_requests_repository.dart';
import '../../domain/value_objects/request_title.dart';
import '../../domain/value_objects/request_url.dart';
import '../../domain/value_objects/request_reason.dart';
import 'package:equatable/equatable.dart';

class CreateBookRequestState extends Equatable {
  final bool isSubmitting;
  final String? error;

  const CreateBookRequestState({
    required this.isSubmitting,
    this.error,
  });

  factory CreateBookRequestState.initial() {
    return const CreateBookRequestState(
      isSubmitting: false,
      error: null,
    );
  }

  CreateBookRequestState copyWith({
    bool? isSubmitting,
    String? Function()? error,
  }) {
    return CreateBookRequestState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error];
}

class CreateBookRequestViewModel extends BaseStreamViewModel<CreateBookRequestState> {
  final BookRequestsRepository _repository;

  CreateBookRequestViewModel({required BookRequestsRepository repository})
      : _repository = repository,
        super(CreateBookRequestState.initial());

  bool get isSubmitting => state.isSubmitting;
  String? get error => state.error;

  Future<bool> submitRequest({
    required String title,
    required String url,
    String? reason,
  }) async {
    if (state.isSubmitting) return false;

    emit(state.copyWith(isSubmitting: true, error: () => null));

    try {
      final titleVO = RequestTitle(title);
      final urlVO = RequestUrl(url);
      final reasonVO = RequestReason(reason);

      await _repository.createBookRequest(
        title: titleVO,
        url: urlVO,
        reason: reasonVO,
      );
      
      emit(state.copyWith(isSubmitting: false));
      return true;
    } on ArgumentError catch (e) {
      emit(state.copyWith(isSubmitting: false, error: () => e.message.toString()));
      return false;
    } on ValidationException catch (e) {
      emit(state.copyWith(isSubmitting: false, error: () => e.message));
      return false;
    } on AppExceptions catch (e) {
      AppLogger.e('Failed to create book request', e, null, 'BOOK_REQUESTS');
      emit(state.copyWith(isSubmitting: false, error: () => e.message));
      return false;
    } catch (e) {
      AppLogger.e('Unexpected error creating request', e, null, 'BOOK_REQUESTS');
      emit(state.copyWith(isSubmitting: false, error: () => 'An unexpected error occurred'));
      return false;
    }
  }
}
