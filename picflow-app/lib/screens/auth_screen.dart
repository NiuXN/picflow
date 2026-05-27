import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/api_config.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/snackbar_utils.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int _tabIndex = 0;

  // Login fields
  final _loginUsername = TextEditingController();
  final _loginPassword = TextEditingController();

  // Phone login fields
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSending = false;
  int _countdown = 0;

  // Register fields
  final _regNickname = TextEditingController();
  final _regUsername = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirmPassword = TextEditingController();

  @override
  void dispose() {
    _loginUsername.dispose();
    _loginPassword.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _regNickname.dispose();
    _regUsername.dispose();
    _regPassword.dispose();
    _regConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Text('PicFlow', style: AppTypography.heading.copyWith(fontSize: 32)),
              const SizedBox(height: 8),
              Text('治愈系排版工具', style: AppTypography.caption),
              const SizedBox(height: 48),
              // Tab bar
              Row(
                children: [
                  _TabItem(label: '登录', isActive: _tabIndex == 0, onTap: () {
                    authNotifier.clearError();
                    setState(() => _tabIndex = 0);
                  }),
                  const SizedBox(width: 32),
                  _TabItem(label: '注册', isActive: _tabIndex == 1, onTap: () {
                    authNotifier.clearError();
                    setState(() => _tabIndex = 1);
                  }),
                ],
              ),
              const SizedBox(height: 24),
              // Error message
              if (authState.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(authState.error!, style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
                ),
              // Password login form
              if (_tabIndex == 0) _buildLoginForm(authState, authNotifier),
              // Phone login form
              if (_tabIndex == 1) _buildPhoneLoginForm(authState, authNotifier),
              // Register form
              if (_tabIndex == 2) _buildRegisterForm(authState, authNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState, AuthNotifier authNotifier) {
    return Column(
      children: [
        TextField(
          controller: _loginUsername,
          decoration: _inputDecoration('用户名'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPassword,
          obscureText: true,
          decoration: _inputDecoration('密码'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isSubmitting ? null : () => _handleLogin(authNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inversePrimary,
              foregroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: authState.isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surfaceContainerLowest))
                : Text('登录', style: AppTypography.labelLarge),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLoginForm(AuthState authState, AuthNotifier authNotifier) {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: _inputDecoration('手机号'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _inputDecoration('验证码'),
                style: AppTypography.bodyRegular,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _codeSending || _countdown > 0 ? null : () => _handleSendCode(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inversePrimary,
                  foregroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _countdown > 0 ? '${_countdown}s' : '获取验证码',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.surfaceContainerLowest),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isSubmitting ? null : () => _handlePhoneLogin(authNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inversePrimary,
              foregroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: authState.isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surfaceContainerLowest))
                : Text('登录 / 注册', style: AppTypography.labelLarge),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 11) {
      AppSnackbar.error(context, '请输入正确的手机号');
      return;
    }
    setState(() => _codeSending = true);
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final res = await dio.post('/auth/send-code', data: {'phone': phone});
      final code = res.data['data']?['code'] ?? '';
      setState(() { _codeSending = false; _countdown = 60; });
      if (mounted) AppSnackbar.success(context, '验证码已发送（开发环境: $code）');
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _codeSending = false);
      if (mounted) AppSnackbar.error(context, '发送失败，请重试');
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_countdown > 0) _countdown--; });
      return _countdown > 0;
    });
  }

  Future<void> _handlePhoneLogin(AuthNotifier authNotifier) async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length != 11) { AppSnackbar.error(context, '请输入正确的手机号'); return; }
    if (code.length < 4) { AppSnackbar.error(context, '请输入验证码'); return; }
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
      final res = await dio.post('/auth/phone-login', data: {'phone': phone, 'code': code});
      final data = res.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId = (data['user'] as Map<String, dynamic>)['id'];
      await authNotifier.phoneLogin(token, userId as int);
      if (mounted) { AppSnackbar.success(context, '登录成功'); context.go('/'); }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, '验证码错误或已过期');
    }
  }

  Widget _buildRegisterForm(AuthState authState, AuthNotifier authNotifier) {
    return Column(
      children: [
        TextField(
          controller: _regNickname,
          decoration: _inputDecoration('昵称'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regUsername,
          decoration: _inputDecoration('用户名'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regPassword,
          obscureText: true,
          decoration: _inputDecoration('密码'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _regConfirmPassword,
          obscureText: true,
          decoration: _inputDecoration('确认密码'),
          style: AppTypography.bodyRegular,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isSubmitting ? null : () => _handleRegister(authNotifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.inversePrimary,
              foregroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: authState.isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surfaceContainerLowest))
                : Text('注册', style: AppTypography.labelLarge),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin(AuthNotifier authNotifier) async {
    if (_loginUsername.text.trim().isEmpty || _loginPassword.text.isEmpty) {
      AppSnackbar.error(context, '请填写用户名和密码');
      return;
    }
    final error = await authNotifier.login(_loginUsername.text.trim(), _loginPassword.text);
    if (error == null && mounted) {
      AppSnackbar.success(context, '登录成功');
      context.go('/');
    }
  }

  Future<void> _handleRegister(AuthNotifier authNotifier) async {
    if (_regNickname.text.trim().isEmpty) {
      AppSnackbar.error(context, '请输入昵称');
      return;
    }
    if (_regUsername.text.trim().isEmpty) {
      AppSnackbar.error(context, '请输入用户名');
      return;
    }
    if (_regPassword.text.length < 6) {
      AppSnackbar.error(context, '密码至少6位');
      return;
    }
    if (_regPassword.text != _regConfirmPassword.text) {
      AppSnackbar.error(context, '两次密码不一致');
      return;
    }
    final error = await authNotifier.register(
      _regUsername.text.trim(),
      _regPassword.text,
      _regNickname.text.trim(),
    );
    if (error == null && mounted) {
      AppSnackbar.success(context, '注册成功');
      context.go('/');
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyRegular.copyWith(color: AppColors.onSurfaceVariant),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.h2.copyWith(
              color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.inversePrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
