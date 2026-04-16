import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'v2/v2_app.dart';

class SpeakMasterApp extends ConsumerWidget {
  const SpeakMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpeakMasterV2App(theme: AppTheme.light);
  }
}
