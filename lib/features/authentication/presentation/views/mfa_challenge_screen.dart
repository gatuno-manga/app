import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/atoms/app_text_field.dart';
import '../../../../core/di/injection.dart';
import '../../domain/use_cases/auth_service.dart';
import '../view_models/mfa_challenge_view_model.dart';
import '../view_models/mfa_error.dart';

String mfaErrorText(AppLocalizations l10n, MfaError error) => switch (error) {
  MfaError.invalidCode => l10n.mfaErrorInvalidCode,
  MfaError.tooManyAttempts => l10n.mfaErrorTooManyAttempts,
  MfaError.challengeExpired => l10n.mfaErrorChallengeExpired,
  MfaError.network => l10n.mfaErrorNetwork,
  MfaError.unknown => l10n.mfaErrorUnknown,
};

class MfaChallengeArgs {
  final String mfaToken;
  final String? redirectUrl;

  const MfaChallengeArgs({required this.mfaToken, this.redirectUrl});
}

class MfaChallengePage extends StatefulWidget {
  final String mfaToken;
  final String? redirectUrl;
  final MfaChallengeViewModel? viewModel;

  const MfaChallengePage({
    super.key,
    required this.mfaToken,
    this.redirectUrl,
    this.viewModel,
  });

  @override
  State<MfaChallengePage> createState() => _MfaChallengePageState();
}

class _MfaChallengePageState extends State<MfaChallengePage> {
  late final MfaChallengeViewModel _viewModel;
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        MfaChallengeViewModel(sl<AuthService>(), widget.mfaToken);
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await _viewModel.verify(_controller.text);
    if (!mounted) return;
    if (ok) {
      context.go(widget.redirectUrl ?? '/home');
    } else if (_viewModel.state.error == MfaError.challengeExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mfaErrorText(l10n, MfaError.challengeExpired))),
      );
      context.go('/auth/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.mfaChallengeTitle)),
      body: SafeArea(
        child: StreamBuilder<MfaChallengeState>(
          stream: _viewModel.stateStream,
          initialData: _viewModel.state,
          builder: (context, snapshot) {
            final state = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  l10n.mfaChallengeDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: _controller,
                    label: l10n.mfaCodeLabel,
                    prefixIcon: const Icon(Icons.shield_outlined),
                    autofillHints: const [AutofillHints.oneTimeCode],
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.mfaCodeRequired
                        : null,
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      mfaErrorText(l10n, state.error!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  text: l10n.mfaVerifyButton,
                  onPressed: _submit,
                  isLoading: state.isLoading,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
