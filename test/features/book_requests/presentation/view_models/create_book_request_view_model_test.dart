import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/book_requests/domain/repositories/book_requests_repository.dart';
import 'package:gatuno/features/book_requests/presentation/view_models/create_book_request_view_model.dart';
import 'package:gatuno/features/book_requests/domain/entities/book_request_entity.dart';

class MockBookRequestsRepository extends Mock implements BookRequestsRepository {}

void main() {
  late CreateBookRequestViewModel viewModel;
  late MockBookRequestsRepository mockRepository;

  setUp(() {
    mockRepository = MockBookRequestsRepository();
    viewModel = CreateBookRequestViewModel(repository: mockRepository);
  });

  group('submitRequest', () {
    test('returns true on success', () async {
      final request = BookRequestEntity(
        id: RequestIdVO('1'),
        title: RequestTitleVO('Title'),
        url: RequestUrlVO('https://example.com'),
        reason: const RequestReasonVO(null),
        status: RequestStatus.pending,
        userId: 'user1',
        adminId: null,
        rejectionMessage: const RequestRejectionMessageVO(null),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.createBookRequest(
            title: any(named: 'title'),
            url: any(named: 'url'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => request);

      final result = await viewModel.submitRequest(title: 'T', url: 'https://example.com');

      expect(result, true);
      expect(viewModel.isSubmitting, false);
      expect(viewModel.error, null);
    });
  });
}
