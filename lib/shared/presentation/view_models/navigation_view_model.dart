import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../features/users/domain/use_cases/user_service.dart';
import '../../../../features/users/data/models/user_model.dart';
import '../../../../features/authentication/domain/use_cases/auth_service.dart';

import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final UserModel user;
  final bool isAuthenticated;

  /// The server cannot be reached; screens show saved data.
  final bool isOffline;

  const NavigationState({
    required this.user,
    required this.isAuthenticated,
    this.isOffline = false,
  });

  factory NavigationState.initial() {
    return NavigationState(user: UserModel.guest, isAuthenticated: false);
  }

  NavigationState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isOffline,
  }) {
    return NavigationState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [user, isAuthenticated, isOffline];
}

class NavigationViewModel extends BaseStreamViewModel<NavigationState> {
  final UserService _userService;
  final AuthService _authService;
  late final StreamSubscription<AuthState> _authSubscription;
  late final StreamSubscription<ConnectivityStatus> _connectivitySubscription;
  late final StreamSubscription<UserModel> _profileSubscription;

  NavigationViewModel(
    this._userService,
    this._authService,
    ConnectivityService connectivity,
  ) : super(NavigationState.initial()) {
    _authSubscription = _authService.authStateStream.listen(
      (_) => _onAuthStateChanged(),
    );
    _connectivitySubscription = connectivity.statusStream.listen(
      (status) =>
          emit(state.copyWith(isOffline: status == ConnectivityStatus.offline)),
    );
    // A new photo or name from the profile screen shows in the bar at once.
    _profileSubscription = _userService.profileStream.listen(
      (user) => emit(state.copyWith(user: user)),
    );
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
    _connectivitySubscription.cancel();
    _profileSubscription.cancel();
    super.dispose();
  }
}
