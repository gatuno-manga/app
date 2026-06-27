import 'package:gatuno/features/book_requests/domain/value_objects/request_reason.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_url.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_title.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/book_requests/data/repositories/book_requests_repository_impl.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late BookRequestsRepositoryImpl repository;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

    setUpAll(() {
    registerFallbackValue(RequestTitle('dummy'));
    registerFallbackValue(RequestUrl('https://dummy.com'));
    registerFallbackValue(const RequestReason('dummy'));
  });

setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    repository = BookRequestsRepositoryImpl(mockDioClient);
  });

  group('getBookRequests', () {
    test('returns list of BookRequestEntity when successful', () async {
      when(() => mockDio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'data': [
                    {
                      'id': '1',
                      'title': 'Test Book',
                      'url': 'https://example.com/book',
                      'reason': 'Test Reason',
                      'status': 'PENDING',
                      'userId': 'user1',
                      'adminId': null,
                      'rejectionMessage': null,
                      'createdAt': '2023-01-01T00:00:00Z',
                      'updatedAt': '2023-01-01T00:00:00Z',
                    }
                  ]
                },
              ));

      final result = await repository.getBookRequests();

      expect(result.length, 1);
      expect(result.first.title.value, 'Test Book');
      expect(result.first.url.value, 'https://example.com/book');
      expect(result.first.status, RequestStatus.pending);
    });

    test('throws ServerException on unexpected error', () async {
      when(() => mockDio.get<dynamic>(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception());

      expect(() => repository.getBookRequests(), throwsA(isA<ServerException>()));
    });
  });

  group('createBookRequest', () {
    test('completes successfully on successful creation', () async {
      when(() => mockDio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'message': 'Book request submitted successfully'
                },
              ));

      await repository.createBookRequest(
        title: RequestTitle('New Book'),
        url: RequestUrl('https://example.com/newbook'),
        reason: RequestReason('Good book'),
      );
    });

    test('throws ValidationException on 400', () async {
      when(() => mockDio.post<Map<String, dynamic>>(any(), data: any(named: 'data')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Validation failed'},
        ),
      ));

      expect(() => repository.createBookRequest(title: RequestTitle('dummy'), url: RequestUrl('dummy')),
          throwsA(isA<ValidationException>()));
    });
  });
}
