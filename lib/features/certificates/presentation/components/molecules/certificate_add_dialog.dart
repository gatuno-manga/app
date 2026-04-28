import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/components/atoms/app_text_skeleton.dart';

class CertificateAddDialog extends StatefulWidget {
  final Future<bool> Function(String name) onAddFromFile;

  const CertificateAddDialog({super.key, required this.onAddFromFile});

  @override
  State<CertificateAddDialog> createState() => _CertificateAddDialogState();

  static Future<void> show(
    BuildContext context,
    Future<bool> Function(String name) onAddFromFile,
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
  bool _isLoading = false;

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
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: l10n.certAddLabel,
          hintText: l10n.certAddHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _isValid && !_isLoading
              ? () async {
                  final name = _nameController.text.trim();
                  setState(() => _isLoading = true);
                  final success = await widget.onAddFromFile(name);
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (success) {
                      Navigator.pop(context);
                    }
                  }
                }
              : null,
          child: AppTextSkeleton(
            text: _isLoading ? null : l10n.certAddFileButton,
            width: 120,
            height: 16,
          ),
        ),
      ],
    );
  }
}
