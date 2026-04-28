import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

class CertificateAddDialog extends StatefulWidget {
  final void Function(String name) onAddFromFile;

  const CertificateAddDialog({super.key, required this.onAddFromFile});

  @override
  State<CertificateAddDialog> createState() => _CertificateAddDialogState();

  static Future<void> show(
    BuildContext context,
    void Function(String name) onAddFromFile,
  ) {
    return showDialog(
      context: context,
      builder: (context) => CertificateAddDialog(onAddFromFile: onAddFromFile),
    );
  }
}

class _CertificateAddDialogState extends State<CertificateAddDialog> {
  final _nameController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.certAddTitle),
      content: TextField(
        controller: _nameController,
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
                  final name = _nameController.text.trim();
                  Navigator.pop(context);
                  widget.onAddFromFile(name);
                }
              : null,
          child: Text(l10n.certAddFileButton),
        ),
      ],
    );
  }
}
