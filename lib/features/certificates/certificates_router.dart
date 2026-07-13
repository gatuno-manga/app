import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'presentation/views/certificates_screen.dart';
import 'presentation/view_models/certificates_view_model.dart';
import 'domain/use_cases/certificates_service.dart';
import '../../../core/di/injection.dart';

final certificatesRoutes = [
  GoRoute(
    path: 'certificates',
    builder: (context, state) => Provider<CertificatesViewModel>(
      create: (_) => CertificatesViewModel(sl<CertificatesService>()),
      child: const CertificatesPage(),
    ),
  ),
];
