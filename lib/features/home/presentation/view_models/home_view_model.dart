import '../../../../core/base/safe_change_notifier.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../users/domain/use_cases/user_service.dart';
import '../../../users/data/models/user_model.dart';

class HomeViewModel extends SafeChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  UserModel _user = UserModel.guest;

  HomeViewModel(this._authService, this._userService) {
    _authService.addListener(_onAuthChanged);
    _loadUser();
  }

  void _onAuthChanged() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (isDisposed) return;

    _user = await _userService.getCurrentUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  bool get isAuthenticated => _authService.authenticated;
  bool get isInitialized => _authService.isInitialized;
  String? get displayName => _user.isGuest ? null : _user.displayName;
}
