import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class CertificateTrustDialog extends StatelessWidget {
  final String host;

  const CertificateTrustDialog({
    super.key,
    required this.host,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.certTrustDialogTitle),
      content: Text(l10n.certTrustDialogMessage(host)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.certTrustDialogIgnore),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.certTrustDialogTrust),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context, String host) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CertificateTrustDialog(host: host),
    );
  }
}
