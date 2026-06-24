import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/components/atoms/app_status_badge.dart';
import '../../../domain/entities/book_request_entity.dart';
import 'package:gatuno/l10n/app_localizations.dart';

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
    Color statusColor;
    String statusLabel;
    
    switch (request.status) {
      case RequestStatus.approved:
        statusColor = Colors.green;
        statusLabel = l10n.bookRequestStatusApproved;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        statusLabel = l10n.bookRequestStatusRejected;
        break;
      case RequestStatus.pending:
        statusColor = Colors.orange;
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
            if (request.reason.value != null && request.reason.value!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
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
                  const Icon(Icons.error_outline, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.bookRequestsCardRejection}: ${request.rejectionMessage.value}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  l10n.bookRequestsCardDate(
                    DateFormat.yMMMd().format(request.createdAt),
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
