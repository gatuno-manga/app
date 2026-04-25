import 'package:flutter/material.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';

class SettingsAllowedUrlItem extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;

  const SettingsAllowedUrlItem({
    super.key,
    required this.url,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(url, style: Theme.of(context).textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      trailing: AppIconButton(
        icon: Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
        onPressed: onRemove,
      ),
    );
  }
}
