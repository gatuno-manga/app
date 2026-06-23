import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import 'data/repositories/book_requests_repository_impl.dart';
import 'domain/repositories/book_requests_repository.dart';
import 'presentation/view_models/book_requests_list_view_model.dart';
import 'presentation/view_models/create_book_request_view_model.dart';

void initBookRequestsInjection(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<BookRequestsRepository>(
    () => BookRequestsRepositoryImpl(sl<DioClient>()),
  );

  // View Models
  sl.registerFactory<BookRequestsListViewModel>(
    () => BookRequestsListViewModel(repository: sl<BookRequestsRepository>()),
  );
  sl.registerFactory<CreateBookRequestViewModel>(
    () => CreateBookRequestViewModel(repository: sl<BookRequestsRepository>()),
  );
}
