import 'package:flutter/material.dart';
import '../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../shared/components/templates/app_top_bar_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/organisms/create_book_request_form.dart';

class CreateBookRequestPage extends StatelessWidget {
  const CreateBookRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBarScaffold(
      topBar: AppTopBar(title: l10n.bookRequestsCreateTitle, showBack: true),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverToBoxAdapter(
            child: CreateBookRequestForm(
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.bookRequestsSuccess)),
                );
                context.pop(); // Go back to list
              },
            ),
          ),
        ),
      ],
    );
  }
}
