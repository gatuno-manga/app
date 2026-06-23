import 'package:flutter/foundation.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/repositories/book_requests_repository.dart';

class BookRequestsListViewModel extends ChangeNotifier {
  final BookRequestsRepository _repository;

  BookRequestsListViewModel({required BookRequestsRepository repository})
      : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final List<BookRequestEntity> _requests = [];
  List<BookRequestEntity> get requests => _requests;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchRequests({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _requests.clear();
      _error = null;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newRequests = await _repository.getBookRequests(page: _currentPage, limit: 20);
      
      if (newRequests.isEmpty || newRequests.length < 20) {
        _hasMore = false;
      }
      
      _requests.addAll(newRequests);
      _currentPage++;
      _error = null;
    } on AppExceptions catch (e) {
      _error = e.message;
      AppLogger.e('Failed to fetch book requests', e, null, 'BOOK_REQUESTS');
    } catch (e) {
      _error = 'An unexpected error occurred';
      AppLogger.e('Unexpected error fetching requests', e, null, 'BOOK_REQUESTS');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
