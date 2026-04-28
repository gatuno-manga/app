import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/certificates_view_model.dart';
import '../components/templates/certificates_template.dart';
import '../components/organisms/certificate_list.dart';
import '../components/molecules/certificate_add_dialog.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

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
