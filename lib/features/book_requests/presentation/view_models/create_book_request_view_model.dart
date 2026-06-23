import 'package:flutter/foundation.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/repositories/book_requests_repository.dart';

class CreateBookRequestViewModel extends ChangeNotifier {
  final BookRequestsRepository _repository;

  CreateBookRequestViewModel({required BookRequestsRepository repository})
      : _repository = repository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _error;
  String? get error => _error;

  Future<bool> submitRequest({
    required String title,
    required String url,
    String? reason,
  }) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createBookRequest(
        title: title,
        url: url,
        reason: reason,
      );
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      return false;
    } on AppExceptions catch (e) {
      _error = e.message;
      AppLogger.e('Failed to create book request', e, null, 'BOOK_REQUESTS');
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      AppLogger.e('Unexpected error creating request', e, null, 'BOOK_REQUESTS');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
