import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import 'core/router/v2_router.dart';

class SpeakMasterV2App extends StatelessWidget {
  final ThemeData theme;

  const SpeakMasterV2App({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${AppConstants.appName} V2',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: V2Router.router,
    );
  }
}
