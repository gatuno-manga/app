import '../entities/book_request_entity.dart';

abstract class BookRequestsRepository {
  Future<List<BookRequestEntity>> getBookRequests({int page = 1, int limit = 20});
  Future<BookRequestEntity> createBookRequest({
    required String title,
    required String url,
    String? reason,
  });
}
