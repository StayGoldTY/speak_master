import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/service_providers.dart';
import '../../services/storage_service.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  ReminderPreference _preference = const ReminderPreference(enabled: false, hour: 20, minute: 0);
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPreference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提醒设置')),
      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const _ReminderIntro(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('每日朗读提醒'),
                            subtitle: const Text('当前阶段只保存提醒偏好，还不会真正发送系统通知。'),
                            value: _preference.enabled,
                            onChanged: (value) => setState(() {
                              _preference = _preference.copyWith(enabled: value);
                            }),
                          ),
                          const Divider(height: 24),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('提醒时间'),
                            subtitle: Text(_preference.label),
                            trailing: OutlinedButton(
                              onPressed: _pickTime,
                              child: const Text('修改时间'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        '为什么先做这个？很多学习者真正缺的不是更多资料，而是一个固定时间把自己拉回练习节奏。当前阶段先把时间偏好存下来，等通知能力接好后就能直接用。',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.65),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _savePreference,
                      child: const Text('保存提醒设置'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _loadPreference() async {
    final storage = ref.read(storageServiceProvider);
    await storage.init();
    if (!mounted) {
      return;
    }

    setState(() {
      _preference = storage.loadReminderPreference();
      _isReady = true;
    });
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _preference.hour, minute: _preference.minute),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _preference = _preference.copyWith(hour: result.hour, minute: result.minute);
    });
  }

  Future<void> _savePreference() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveReminderPreference(_preference);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _preference.enabled ? '提醒时间已保存为 ${_preference.label}。' : '已关闭每日朗读提醒。',
        ),
      ),
    );
  }
}

class _ReminderIntro extends StatelessWidget {
  const _ReminderIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientSuccess,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '练习不是靠一时兴起',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            '把朗读练习固定在一个你最容易执行的时间点，通常比“等有空再学”更有效。这里先保存你的提醒偏好，方便后续通知能力接入。',
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.7),
          ),
        ],
      ),
    );
  }
}
