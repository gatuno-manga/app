import 'package:flutter/material.dart';
import 'package:gatuno/features/certificates/domain/entities/certificate_item.dart';
import 'package:gatuno/l10n/app_localizations.dart';

class CertificateItemTile extends StatelessWidget {
  final CertificateItem certificate;
  final void Function(String fingerprint) onDelete;

  const CertificateItemTile({
    super.key,
    required this.certificate,
    required this.onDelete,
  });

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.commonDelete),
        content: Text(l10n.certDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        certificate.host,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            certificate.subject,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (certificate.fingerprint.isNotEmpty)
            Text(
              'Fingerprint: ${certificate.fingerprint.substring(0, 12)}...',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
      isThreeLine: certificate.fingerprint.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        color: theme.colorScheme.error,
        onPressed: () async {
          final confirm = await _showDeleteConfirmation(context);
          if (confirm == true) {
            onDelete(certificate.fingerprint);
          }
        },
      ),
    );
  }
}
