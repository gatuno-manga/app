import 'package:flutter/material.dart';
import 'package:gatuno/features/certificates/domain/entities/certificate_item.dart';
import '../atoms/certificate_empty_state.dart';
import '../molecules/certificate_item_tile.dart';

class CertificateList extends StatelessWidget {
  final List<CertificateItem> certificates;
  final String emptyMessage;
  final void Function(String fingerprint) onDelete;

  const CertificateList({
    super.key,
    required this.certificates,
    required this.emptyMessage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (certificates.isEmpty) {
      return CertificateEmptyState(message: emptyMessage);
    }

    return ListView.separated(
      itemCount: certificates.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final cert = certificates[index];
        return CertificateItemTile(certificate: cert, onDelete: onDelete);
      },
    );
  }
}
