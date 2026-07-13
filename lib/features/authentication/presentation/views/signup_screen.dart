import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/icons/icons.dart';
import '../components/organisms/signup_form.dart';
import '../components/templates/auth_template.dart';
import '../../domain/use_cases/auth_service.dart';
import '../view_models/signup_view_model.dart';
import '../../../../core/di/injection.dart';

class SignUpPage extends StatefulWidget {
  final String? redirectUrl;

  const SignUpPage({super.key, this.redirectUrl});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpViewModel _viewModel;
  late final StreamSubscription<SignUpState> _subscription;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel(sl<AuthService>());
    _subscription = _viewModel.stateStream.listen(_onStateChanged);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _onStateChanged(SignUpState state) {
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

  void _handleSignUp(String email, String password) async {
    final success = await _viewModel.signUp(email, password);

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

    return StreamBuilder<SignUpState>(
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
            l10n.authSignUpTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          form: SignUpForm(
            onSubmit: _handleSignUp,
            onSignIn: () {
              if (widget.redirectUrl != null) {
                context.go('/auth/signin?redirect=${widget.redirectUrl}');
              } else {
                context.go('/auth/signin');
              }
            },
            isLoading: state.isLoading,
          ),
        );
      },
    );
  }
}
