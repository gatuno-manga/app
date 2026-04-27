import 'package:get_it/get_it.dart';
import 'data/data_sources/certificates_local_data_source.dart';
import 'domain/use_cases/certificates_service.dart';

void initCertificatesInjection(GetIt sl) {
  sl.registerLazySingleton<CertificatesStorage>(() => CertificatesStorage());
  sl.registerLazySingleton<CertificatesService>(
    () => CertificatesService(sl<CertificatesStorage>()),
  );
}
