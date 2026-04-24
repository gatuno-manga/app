import 'package:get_it/get_it.dart';
import 'data/repositories/reading_repository_impl.dart';
import 'domain/repositories/reading_repository.dart';
import 'presentation/view_models/reading_view_model.dart';

void initReadingDI(GetIt sl) {
  // Repositories
  sl.registerLazySingleton<ReadingRepository>(
    () => ReadingRepositoryImpl(sl()),
  );

  // ViewModels
  sl.registerFactory(
    () => ReadingViewModel(sl()),
  );
}
