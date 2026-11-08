import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/components/atoms/app_status_badge.dart';
import '../../../domain/entities/book_request_entity.dart';
import '../../../domain/value_objects/request_status.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequestEntity request;

  const BookRequestCard({super.key, required this.request});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Color statusColor;
    String statusLabel;

    switch (request.status) {
      case RequestStatus.approved:
        statusColor = theme.successColor;
        statusLabel = l10n.bookRequestStatusApproved;
        break;
      case RequestStatus.rejected:
        statusColor = theme.colorScheme.error;
        statusLabel = l10n.bookRequestStatusRejected;
        break;
      case RequestStatus.pending:
        statusColor = theme.warningColor;
        statusLabel = l10n.bookRequestStatusPending;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.title.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppStatusBadge(
                  label: statusLabel,
                  color: statusColor,
                  textColor: theme.legible(statusColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchUrl(request.url.value),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.url.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (request.reason.value != null &&
                request.reason.value!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: theme.mutedColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.bookRequestsCardReason}: ${request.reason.value}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (request.rejectionMessage.value != null &&
                request.rejectionMessage.value!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.bookRequestsCardRejection}: ${request.rejectionMessage.value}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: theme.mutedColor),
                const SizedBox(width: 6),
                Text(
                  l10n.bookRequestsCardDate(
                    DateFormat.yMMMd().format(request.createdAt.value),
                  ),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: theme.mutedColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
