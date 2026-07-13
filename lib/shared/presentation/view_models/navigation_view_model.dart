import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/base/base_stream_view_model.dart';
import '../../../../features/users/domain/use_cases/user_service.dart';
import '../../../../features/users/data/models/user_model.dart';
import '../../../../features/authentication/domain/use_cases/auth_service.dart';
import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final UserModel user;
  final bool isAuthenticated;

  const NavigationState({
    required this.user,
    required this.isAuthenticated,
  });

  factory NavigationState.initial() {
    return NavigationState(
      user: UserModel.guest,
      isAuthenticated: false,
    );
  }

  NavigationState copyWith({
    UserModel? user,
    bool? isAuthenticated,
  }) {
    return NavigationState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [user, isAuthenticated];
}

class NavigationViewModel extends BaseStreamViewModel<NavigationState> {
  final UserService _userService;
  final AuthService _authService;
  late final StreamSubscription<AuthState> _authSubscription;

  NavigationViewModel(this._userService, this._authService) : super(NavigationState.initial()) {
    _authSubscription = _authService.authStateStream.listen((_) => _onAuthStateChanged());
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    emit(state.copyWith(isAuthenticated: _authService.authenticated));
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userService.getCurrentUser();
      emit(state.copyWith(user: user));
    } catch (e) {
      emit(state.copyWith(user: UserModel.guest));
    }
  }

  @visibleForTesting
  Future<void> loadUser() => _loadUser();

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
