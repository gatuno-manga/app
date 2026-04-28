import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

enum CertificateTrustAction { trust, ignore }

class CertificateTrustResult {
  final CertificateTrustAction action;
  final String? name;

  const CertificateTrustResult({required this.action, this.name});
}

class CertificateTrustDialog extends StatefulWidget {
  final String host;

  const CertificateTrustDialog({super.key, required this.host});

  @override
  State<CertificateTrustDialog> createState() => _CertificateTrustDialogState();

  static Future<CertificateTrustResult?> show(
    BuildContext context,
    String host,
  ) {
    return showDialog<CertificateTrustResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CertificateTrustDialog(host: host),
    );
  }
}

class _CertificateTrustDialogState extends State<CertificateTrustDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.host);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.certTrustDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.certTrustDialogMessage(widget.host)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.certAddLabel,
              hintText: l10n.certAddHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            const CertificateTrustResult(action: CertificateTrustAction.ignore),
          ),
          child: Text(l10n.certTrustDialogIgnore),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            Navigator.pop(
              context,
              CertificateTrustResult(
                action: CertificateTrustAction.trust,
                name: name.isNotEmpty ? name : widget.host,
              ),
            );
          },
          child: Text(l10n.certTrustDialogTrust),
        ),
      ],
    );
  }
}
