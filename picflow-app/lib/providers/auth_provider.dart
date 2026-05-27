import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// GoRouter 监听登录状态变更
class _AuthRouteNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final authRouteNotifier = _AuthRouteNotifier();
bool _isLoggedIn = false;

void updateAuthState(bool loggedIn) {
  _isLoggedIn = loggedIn;
  authRouteNotifier.notify();
}

bool get isLoggedIn => _isLoggedIn;

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    state = state.copyWith(isLoading: true);
    final loggedIn = await _authService.isLoggedIn();
    updateAuthState(loggedIn);
    state = state.copyWith(isLoggedIn: loggedIn, isLoading: false);
  }

  Future<String?> login(String username, String password) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _authService.login(username, password);
      updateAuthState(true);
      return null;
    } catch (e) {
      final msg = e.toString().contains('401') ? '用户名或密码错误' : '登录失败，请检查网络';
      state = state.copyWith(isSubmitting: false, error: msg);
      return msg;
    }
  }

  Future<String?> register(String username, String password, String nickname) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _authService.register(username, password, nickname);
      updateAuthState(true);
      return null;
    } catch (e) {
      final msg = e.toString().contains('409') ? '用户名已存在' : '注册失败，请重试';
      state = state.copyWith(isSubmitting: false, error: msg);
      return msg;
    }
  }

  Future<void> phoneLogin(String token, int userId) async {
    await _authService.saveToken(token);
    await _authService.saveUserId(userId);
    updateAuthState(true);
    state = state.copyWith(isLoggedIn: true);
  }

  Future<void> logout() async {
    await _authService.logout();
    updateAuthState(false);
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}