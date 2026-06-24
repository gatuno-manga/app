import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_rejection_message.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_status.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_id.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_reason.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_url.dart';
import 'package:gatuno/features/book_requests/domain/value_objects/request_title.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/book_requests/domain/repositories/book_requests_repository.dart';
import 'package:gatuno/features/book_requests/presentation/view_models/book_requests_list_view_model.dart';
import 'package:gatuno/features/book_requests/domain/entities/book_request_entity.dart';

class MockBookRequestsRepository extends Mock implements BookRequestsRepository {}

void main() {
  late BookRequestsListViewModel viewModel;
  late MockBookRequestsRepository mockRepository;

    setUpAll(() {
    registerFallbackValue(RequestTitle('dummy'));
    registerFallbackValue(RequestUrl('https://dummy.com'));
    registerFallbackValue(const RequestReason('dummy'));
  });

setUp(() {
    mockRepository = MockBookRequestsRepository();
    viewModel = BookRequestsListViewModel(repository: mockRepository);
  });

  group('fetchRequests', () {
    test('loads requests and updates state', () async {
      final request = BookRequestEntity(
        id: RequestId('1'),
        title: RequestTitle('Title'),
        url: RequestUrl('https://example.com'),
        reason: const RequestReason(null),
        status: RequestStatus.pending,
        userId: UserId('user1'),
        adminId: null,
        rejectionMessage: const RequestRejectionMessage(null),
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      when(() => mockRepository.getBookRequests(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => [request]);

      await viewModel.fetchRequests();

      expect(viewModel.isLoading, false);
      expect(viewModel.requests.length, 1);
      expect(viewModel.hasMore, false); // Length < 20
    });
  });
}
