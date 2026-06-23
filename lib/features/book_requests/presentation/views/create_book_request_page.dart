import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/organisms/create_book_request_form.dart';

class CreateBookRequestPage extends StatelessWidget {
  const CreateBookRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookRequestsCreateTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: CreateBookRequestForm(
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.bookRequestsSuccess)),
            );
            context.pop(); // Go back to list
          },
        ),
      ),
    );
  }
}
