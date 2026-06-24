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
import 'package:gatuno/features/book_requests/presentation/view_models/create_book_request_view_model.dart';
import 'package:gatuno/features/book_requests/domain/entities/book_request_entity.dart';

class MockBookRequestsRepository extends Mock implements BookRequestsRepository {}

void main() {
  late CreateBookRequestViewModel viewModel;
  late MockBookRequestsRepository mockRepository;

    setUpAll(() {
    registerFallbackValue(RequestTitle('dummy'));
    registerFallbackValue(RequestUrl('https://dummy.com'));
    registerFallbackValue(const RequestReason('dummy'));
  });

setUp(() {
    mockRepository = MockBookRequestsRepository();
    viewModel = CreateBookRequestViewModel(repository: mockRepository);
  });

  group('submitRequest', () {
    test('returns true on success', () async {
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

      when(() => mockRepository.createBookRequest(
            title: any(named: 'title'),
            url: any(named: 'url'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => request);

      final result = await viewModel.submitRequest(title: 'Title', url: 'https://example.com');

      expect(result, true);
      expect(viewModel.isSubmitting, false);
      expect(viewModel.error, null);
    });
  });
}
