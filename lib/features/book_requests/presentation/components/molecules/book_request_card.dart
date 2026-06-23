import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/components/atoms/app_status_badge.dart';
import '../../../domain/entities/book_request_entity.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequestEntity request;

  const BookRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (request.status) {
      case RequestStatus.approved:
        statusColor = Colors.green;
        break;
      case RequestStatus.rejected:
        statusColor = Colors.red;
        break;
      case RequestStatus.pending:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.title.value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                AppStatusBadge(
                  label: request.status.name.toUpperCase(),
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${request.url.value}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (request.reason.value != null && request.reason.value!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${request.reason.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (request.rejectionMessage.value != null && request.rejectionMessage.value!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Rejection Message: ${request.rejectionMessage.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Requested on: ${DateFormat.yMMMd().format(request.createdAt)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
