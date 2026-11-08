import 'package:go_router/go_router.dart';
import 'presentation/views/signin_screen.dart';
import 'presentation/views/mfa_challenge_screen.dart';
import 'presentation/views/signup_screen.dart';
import '../../../core/router/router_keys.dart';

final List<GoRoute> authRoutes = [
  GoRoute(
    path: '/auth/signin',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final redirect = state.uri.queryParameters['redirect'];
      return SignInPage(redirectUrl: redirect);
    },
  ),
  GoRoute(
    path: '/auth/signup',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final redirect = state.uri.queryParameters['redirect'];
      return SignUpPage(redirectUrl: redirect);
    },
  ),
  GoRoute(
    path: '/auth/mfa',
    parentNavigatorKey: rootNavigatorKey,
    redirect: (context, state) =>
        state.extra is MfaChallengeArgs ? null : '/auth/signin',
    builder: (context, state) {
      final args = state.extra! as MfaChallengeArgs;
      return MfaChallengePage(
        mfaToken: args.mfaToken,
        redirectUrl: args.redirectUrl,
      );
    },
  ),
];
