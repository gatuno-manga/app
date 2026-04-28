import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/certificates_view_model.dart';
import '../components/templates/certificates_template.dart';
import '../components/organisms/certificate_list.dart';
import '../components/molecules/certificate_add_dialog.dart';
import '../../exceptions/certificates_exceptions.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  late CertificatesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<CertificatesViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.error != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      String message;

      final error = _viewModel.error;
      if (error is CertificateInvalidFormatException) {
        message = l10n.certErrorInvalidFormat;
      } else if (error is CertificateFileMissingException) {
        message = l10n.certErrorFileMissing;
      } else if (error is CertificateDecodingException) {
        message = l10n.certErrorDecoding;
      } else if (error is CertificateEmptyFingerprintException) {
        message = l10n.certErrorEmptyFingerprint;
      } else {
        message = l10n.certErrorUnknown;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      _viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<CertificatesViewModel>();

    return CertificatesTemplate(
      title: Text(l10n.settingsCertificatesSection),
      tabs: [
        Tab(text: l10n.certTrustedTab),
        Tab(text: l10n.certIgnoredTab),
      ],
      tabViews: [
        CertificateList(
          certificates: viewModel.trustedCertificates,
          emptyMessage: l10n.certEmptyTrusted,
          onDelete: (fingerprint) => viewModel.deleteCertificate(fingerprint),
        ),
        CertificateList(
          certificates: viewModel.ignoredCertificates,
          emptyMessage: l10n.certEmptyIgnored,
          onDelete: (fingerprint) => viewModel.deleteCertificate(fingerprint),
        ),
      ],
      onAddPressed: () => CertificateAddDialog.show(
        context,
        (String name) => viewModel.addCertificateFromFile(name),
      ),
    );
  }
}
