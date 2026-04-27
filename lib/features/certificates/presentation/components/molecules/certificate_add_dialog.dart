import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

class CertificateAddDialog extends StatefulWidget {
  final void Function(String host) onAddFromFile;

  const CertificateAddDialog({
    super.key,
    required this.onAddFromFile,
  });

  @override
  State<CertificateAddDialog> createState() => _CertificateAddDialogState();

  static Future<void> show(BuildContext context, void Function(String host) onAddFromFile) {
    return showDialog(
      context: context,
      builder: (context) => CertificateAddDialog(onAddFromFile: onAddFromFile),
    );
  }
}

class _CertificateAddDialogState extends State<CertificateAddDialog> {
  final _hostController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _isValid = _hostController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.certAddTitle),
      content: TextField(
        controller: _hostController,
        onChanged: (_) => _validate(),
        decoration: InputDecoration(
          labelText: l10n.certAddLabel,
          hintText: l10n.certAddHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  final host = _hostController.text.trim();
                  Navigator.pop(context);
                  widget.onAddFromFile(host);
                }
              : null,
          child: Text(l10n.certAddFileButton),
        ),
      ],
    );
  }
}
