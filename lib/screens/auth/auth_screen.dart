import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../v2/presentation/widgets/v2_page_scaffold.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final String? redirectTo;

  const AuthScreen({super.key, this.redirectTo});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String get _targetPath {
    final redirectTo = widget.redirectTo;
    if (redirectTo == null ||
        redirectTo.isEmpty ||
        !redirectTo.startsWith('/')) {
      return '/today';
    }
    return redirectTo;
  }

  bool get _willReturnToSource => _targetPath != '/today';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authService = ref.watch(authServiceProvider);
    final authAvailable = authService != null;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: AppColors.errorRed,
              ),
            );
          ref.read(authProvider.notifier).clearMessages();
        });
      }

      if (next.feedbackMessage != null &&
          next.feedbackMessage != prev?.feedbackMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next.feedbackMessage!),
                backgroundColor: AppColors.successGreen,
              ),
            );
          ref.read(authProvider.notifier).clearMessages();
        });
      }

      if (next.status == AuthStatus.authenticated &&
          prev?.status != AuthStatus.authenticated) {
        context.go(_targetPath);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientCanvas),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_willReturnToSource) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: V2Pill(
                          label: '完成后返回原页面',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    V2InfoCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          if (_willReturnToSource) ...[
                            const _InfoCard(
                              title: '登录后会回到刚才的页面',
                              body: '这次登录不会把你带回首页，而是继续你刚才的操作，完成后会自动返回。',
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (!authAvailable) ...[
                            const _InfoCard(
                              title: '当前是本地体验模式',
                              body:
                                  '这个环境还没有接入正式账号服务，所以暂时不能真实注册、登录或找回密码。不过你仍然可以先继续体验课程、口语练习和本地学习进度。',
                            ),
                            const SizedBox(height: 12),
                            const _InfoCard(
                              title: '这个页面之后会承接什么',
                              body:
                                  '正式接入后，这里会启用邮箱登录、第三方登录、账号资料同步，以及后续的会员和学习报告入口。',
                            ),
                          ] else ...[
                            _buildForm(authState),
                            const SizedBox(height: 14),
                            _buildSubmitButton(authState),
                            const SizedBox(height: 20),
                            _buildDivider(),
                            const SizedBox(height: 20),
                            _buildOAuthButtons(authState),
                            const SizedBox(height: 16),
                            _buildToggleMode(),
                          ],
                          const SizedBox(height: 12),
                          _buildSkipButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.record_voice_over_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '声临其境 Speak Master',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _isLogin
              ? '登录后可以同步学习进度、口音偏好和发音练习记录。'
              : '创建账号，把你的课程轨迹、测评结果和每日学习计划保留下来。',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '昵称',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (!_isLogin && (value == null || value.trim().isEmpty)) {
                  return '请输入昵称';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '邮箱',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入邮箱';
              }
              if (!value.contains('@')) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码至少需要 6 位';
              }
              return null;
            },
          ),
          if (_isLogin) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: authState.isLoading ? null : _handleForgotPassword,
                child: const Text('忘记密码？', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AuthState authState) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: authState.isLoading ? null : _handleSubmit,
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isLogin ? '登录并同步' : '创建账号',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '或使用第三方账号',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildOAuthButtons(AuthState authState) {
    return Column(
      children: [
        SizedBox(
          height: 46,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authProvider.notifier).signInWithGoogle(),
            icon: const Text(
              'G',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.accent,
              ),
            ),
            label: const Text('使用 Google 登录'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 46,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authProvider.notifier).signInWithApple(),
            icon: const Icon(Icons.apple, size: 22),
            label: const Text('使用 Apple 登录'),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? '还没有账号？' : '已经有账号？',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => setState(() => _isLogin = !_isLogin),
          child: Text(
            _isLogin ? '去注册' : '去登录',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.go(_targetPath),
        child: Text(
          _willReturnToSource ? '先返回上一页' : '先跳过，继续体验',
          style: const TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isLogin) {
      await ref.read(authProvider.notifier).signInWithEmail(email, password);
      return;
    }

    await ref
        .read(authProvider.notifier)
        .signUpWithEmail(email, password, name.isEmpty ? null : name);
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先在邮箱栏输入你的邮箱地址')));
      return;
    }

    await ref.read(authProvider.notifier).resetPassword(email);
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.glassBorder.withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
