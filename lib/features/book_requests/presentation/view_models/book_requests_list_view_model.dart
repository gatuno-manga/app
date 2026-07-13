import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/repositories/book_requests_repository.dart';
import 'package:equatable/equatable.dart';

class BookRequestsListState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<BookRequestEntity> requests;
  final int currentPage;
  final bool hasMore;

  const BookRequestsListState({
    required this.isLoading,
    this.error,
    required this.requests,
    required this.currentPage,
    required this.hasMore,
  });

  factory BookRequestsListState.initial() {
    return const BookRequestsListState(
      isLoading: false,
      error: null,
      requests: [],
      currentPage: 1,
      hasMore: true,
    );
  }

  BookRequestsListState copyWith({
    bool? isLoading,
    String? Function()? error,
    List<BookRequestEntity>? requests,
    int? currentPage,
    bool? hasMore,
  }) {
    return BookRequestsListState(
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      requests: requests ?? this.requests,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, requests, currentPage, hasMore];
}

class BookRequestsListViewModel extends BaseStreamViewModel<BookRequestsListState> {
  final BookRequestsRepository _repository;

  BookRequestsListViewModel({required BookRequestsRepository repository})
      : _repository = repository,
        super(BookRequestsListState.initial());

  bool get isLoading => state.isLoading;
  String? get error => state.error;
  List<BookRequestEntity> get requests => state.requests;
  bool get hasMore => state.hasMore;

  Future<void> fetchRequests({bool refresh = false}) async {
    if (state.isLoading) return;
    
    var currentState = state;
    if (refresh) {
      currentState = BookRequestsListState.initial();
      emit(currentState);
    }

    if (!currentState.hasMore) return;

    emit(currentState.copyWith(isLoading: true));

    try {
      final newRequests = await _repository.getBookRequests(
        page: currentState.currentPage, 
        limit: 20
      );
      
      final hasMore = newRequests.isNotEmpty && newRequests.length >= 20;
      final updatedRequests = List<BookRequestEntity>.from(currentState.requests)..addAll(newRequests);
      
      emit(currentState.copyWith(
        isLoading: false,
        requests: updatedRequests,
        currentPage: currentState.currentPage + 1,
        hasMore: hasMore,
        error: () => null,
      ));
    } on AppExceptions catch (e) {
      AppLogger.e('Failed to fetch book requests', e, null, 'BOOK_REQUESTS');
      emit(currentState.copyWith(isLoading: false, error: () => e.message));
    } catch (e) {
      AppLogger.e('Unexpected error fetching requests', e, null, 'BOOK_REQUESTS');
      emit(currentState.copyWith(isLoading: false, error: () => 'An unexpected error occurred'));
    }
  }
}
