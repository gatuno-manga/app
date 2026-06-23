import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../shared/components/atoms/app_button.dart';
import '../../../../../shared/components/atoms/app_text_field.dart';
import '../../view_models/create_book_request_view_model.dart';
import 'package:gatuno/l10n/app_localizations.dart';

class CreateBookRequestForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const CreateBookRequestForm({super.key, required this.onSuccess});

  @override
  State<CreateBookRequestForm> createState() => _CreateBookRequestFormState();
}

class _CreateBookRequestFormState extends State<CreateBookRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onInputChanged);
    _urlController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onInputChanged);
    _urlController.removeListener(_onInputChanged);
    _titleController.dispose();
    _urlController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();
    if (title.isEmpty) return false;
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
    return true;
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<CreateBookRequestViewModel>();
    final success = await viewModel.submitRequest(
      title: _titleController.text,
      url: _urlController.text,
      reason: _reasonController.text.isEmpty ? null : _reasonController.text,
    );

    if (success && mounted) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateBookRequestViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          AppTextField(
            controller: _titleController,
            label: l10n.bookRequestsFormTitle,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? val) {
              if (val == null || val.trim().isEmpty) {
                return l10n.bookRequestsFormTitleRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _urlController,
            label: l10n.bookRequestsFormUrl,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? val) {
              if (val == null || val.trim().isEmpty) {
                return l10n.bookRequestsFormUrlRequired;
              }
              final uri = Uri.tryParse(val.trim());
              if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                return l10n.bookRequestsFormUrlInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _reasonController,
            label: l10n.bookRequestsFormReason,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 32),
          AppButton(
            text: l10n.bookRequestsFormSubmit,
            onPressed: _isFormValid ? _submit : null,
            isLoading: viewModel.isSubmitting,
          ),
        ],
      ),
    );
  }
}
