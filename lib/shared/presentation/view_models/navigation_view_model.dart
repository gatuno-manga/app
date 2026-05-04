import 'package:flutter/foundation.dart';
import '../../../../core/base/safe_change_notifier.dart';
import '../../../../features/users/domain/use_cases/user_service.dart';
import '../../../../features/users/data/models/user_model.dart';
import '../../../../features/authentication/domain/use_cases/auth_service.dart';

class NavigationViewModel extends SafeChangeNotifier {
  final UserService _userService;
  final AuthService _authService;

  UserModel _user = UserModel.guest;

  NavigationViewModel(this._userService, this._authService) {
    _authService.addListener(_onAuthStateChanged);
    _loadUser();
  }

  UserModel get user => _user;
  bool get isAuthenticated => _authService.authenticated;

  void _onAuthStateChanged() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await _userService.getCurrentUser();
    } catch (e) {
      _user = UserModel.guest;
    } finally {
      notifyListeners();
    }
  }

  @visibleForTesting
  Future<void> loadUser() => _loadUser();

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
