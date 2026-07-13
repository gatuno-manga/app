import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/icons/icons.dart';
import '../components/organisms/signin_form.dart';
import '../components/templates/auth_template.dart';
import '../../domain/use_cases/auth_service.dart';
import '../view_models/signin_view_model.dart';
import '../../../../core/di/injection.dart';

class SignInPage extends StatefulWidget {
  final String? redirectUrl;

  const SignInPage({super.key, this.redirectUrl});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final SignInViewModel _viewModel;
  late final StreamSubscription<SignInState> _subscription;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel(sl<AuthService>());
    _subscription = _viewModel.stateStream.listen(_onStateChanged);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged(SignInState state) {
    if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      _viewModel.clearError();
    }
  }

  void _handleSignIn(String email, String password) async {
    final success = await _viewModel.signIn(email, password);

    if (success && mounted) {
      TextInput.finishAutofillContext(shouldSave: true);
      if (widget.redirectUrl != null) {
        context.go(widget.redirectUrl!);
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<SignInState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return AuthTemplate(
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          logo: AppIcons.logo(height: 80),
          title: Text(
            l10n.authSignInTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          form: SignInForm(
            onSubmit: _handleSignIn,
            onSignUp: () {
              if (widget.redirectUrl != null) {
                context.go('/auth/signup?redirect=${widget.redirectUrl}');
              } else {
                context.go('/auth/signup');
              }
            },
            isLoading: state.isLoading,
          ),
        );
      },
    );
  }
}
