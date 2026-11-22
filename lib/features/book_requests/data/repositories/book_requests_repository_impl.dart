import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/repositories/book_requests_repository.dart';
import '../models/book_request_model.dart';
import '../models/create_book_request_dto.dart';
import '../../domain/value_objects/request_title.dart';
import '../../domain/value_objects/request_url.dart';
import '../../domain/value_objects/request_reason.dart';

class BookRequestsRepositoryImpl implements BookRequestsRepository {
  final DioClient _dioClient;

  BookRequestsRepositoryImpl(this._dioClient);

  @override
  Future<List<BookRequestEntity>> getBookRequests({int page = 1, int limit = 20}) async {
    try {
      final response = await _dioClient.dio.get<dynamic>(
        '/book-requests/me',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      List<dynamic> itemsList;
      if (response.data is List) {
        itemsList = response.data as List;
      } else if (response.data is Map && response.data['items'] != null) {
        itemsList = response.data['items'] as List;
      } else if (response.data is Map && response.data['data'] != null) {
        itemsList = response.data['data'] as List;
      } else {
        itemsList = [];
      }

      return itemsList
          .map((json) => BookRequestModel.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(message: 'Failed to parse book requests: $e');
    }
  }

  @override
  Future<void> createBookRequest({
    required RequestTitle title,
    required RequestUrl url,
    RequestReason? reason,
  }) async {
    try {
      final dto = CreateBookRequestDto(
        title: title,
        url: url,
        reason: reason,
      );

      await _dioClient.dio.post<Map<String, dynamic>>(
        '/book-requests',
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      throw ApiExceptionHandler.handle(e);
    } catch (e) {
      throw ServerException(message: 'Failed to create book request: $e');
    }
  }
}
