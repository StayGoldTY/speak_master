import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  bool _isReady = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    _displayNameController.text = profile?.displayName ?? '';
    _usernameController.text = profile?.username ?? '';
    _avatarUrlController.text = profile?.avatarUrl ?? '';
    _isReady = true;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final avatarUrl = _avatarUrlController.text.trim();
    final hasAvatar = avatarUrl.isNotEmpty;

    if (authState.status != AuthStatus.authenticated || profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('账号资料')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('当前未登录', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text(
                      '账号资料页需要登录后才能使用。登录后你可以修改昵称、用户名、头像链接，并把偏好同步到云端。',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.7),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.push('/auth?from=%2Fsettings%2Faccount'),
                      child: const Text('去登录'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('账号资料')),
      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _HeroCard(
                      displayName: profile.displayName,
                      fallbackLetter: profile.displayName.isEmpty ? 'S' : profile.displayName[0],
                      avatarUrl: hasAvatar ? avatarUrl : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _displayNameController,
                              decoration: const InputDecoration(
                                labelText: '昵称',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入昵称';
                                }
                                if (value.trim().length < 2) {
                                  return '昵称至少 2 个字符';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: '用户名（可选）',
                                prefixIcon: Icon(Icons.alternate_email),
                                helperText: '3-20 位，仅支持字母、数字和下划线',
                              ),
                              validator: (value) {
                                final input = value?.trim() ?? '';
                                if (input.isEmpty) {
                                  return null;
                                }
                                if (!_usernamePattern.hasMatch(input)) {
                                  return '用户名需为 3-20 位字母、数字或下划线';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _avatarUrlController,
                              decoration: const InputDecoration(
                                labelText: '头像链接（可选）',
                                prefixIcon: Icon(Icons.link_outlined),
                                helperText: '当前支持保存 http/https 图片链接，暂不支持直接上传',
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                final input = value?.trim() ?? '';
                                if (input.isEmpty) {
                                  return null;
                                }
                                final uri = Uri.tryParse(input);
                                if (uri == null || !uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
                                  return '请输入有效的 http 或 https 图片链接';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              initialValue: authState.user?.email ?? '',
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: '邮箱',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ReadonlyTile(
                              label: '加入时间',
                              value: _formatDate(profile.createdAt),
                            ),
                            const SizedBox(height: 10),
                            _ReadonlyTile(
                              label: '口音偏好',
                              value: profile.accentPreference == 'british' ? '英式偏好' : '美式偏好',
                            ),
                            const SizedBox(height: 18),
                            const _SyncNote(),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('保存资料'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
          displayName: _displayNameController.text.trim(),
          username: _usernameController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim(),
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '账号资料已更新' : '保存失败，请稍后再试'),
        backgroundColor: success ? AppColors.successGreen : AppColors.errorRed,
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _HeroCard extends StatelessWidget {
  final String displayName;
  final String fallbackLetter;
  final String? avatarUrl;

  const _HeroCard({
    required this.displayName,
    required this.fallbackLetter,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            foregroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
            child: !hasAvatar
                ? Text(
                    fallbackLetter,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '把你的账号资料整理清楚',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前昵称：$displayName',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                const Text(
                  '这里负责的是“身份信息”和“云端资料同步”这条线，不和练习页、课程页混在一起。保持它简单、可靠，比花哨更重要。',
                  style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyTile extends StatelessWidget {
  final String label;
  final String value;

  const _ReadonlyTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SyncNote extends StatelessWidget {
  const _SyncNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '保存后会尝试同步到当前账号的云端资料，并更新昵称、用户名、头像链接与口音偏好。这里不会伪装成“已接入头像上传”或“已支持邮箱改绑”；当前真实可用的只有资料字段同步。',
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
      ),
    );
  }
}
