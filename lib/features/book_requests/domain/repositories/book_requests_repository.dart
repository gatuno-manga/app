import '../entities/book_request_entity.dart';
import '../value_objects/request_title.dart';
import '../value_objects/request_url.dart';
import '../value_objects/request_reason.dart';

abstract class BookRequestsRepository {
  Future<List<BookRequestEntity>> getBookRequests({int page = 1, int limit = 20});
  Future<void> createBookRequest({
    required RequestTitle title,
    required RequestUrl url,
    RequestReason? reason,
  });
}
