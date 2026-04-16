import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/service_providers.dart';
import '../../application/providers/v2_providers.dart';
import '../../domain/models/learner_models.dart';
import '../widgets/v2_page_scaffold.dart';

class ProfileScreenV2 extends ConsumerWidget {
  const ProfileScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final learner = ref.watch(v2LearnerProfileProvider);

    return V2PageScaffold(
      title: learner.displayName,
      subtitle: 'Manage account status, accent preference, onboarding profile, and V2 operations shortcuts.',
      actions: [
        TextButton(
          onPressed: () => context.push('/ops'),
          child: const Text('Ops'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          V2InfoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.status == AuthStatus.authenticated ? 'Signed in' : 'Guest mode',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auth.status == AuthStatus.authenticated
                            ? 'Profile sync and cloud-ready progress are available.'
                            : 'You can keep exploring locally, then connect an account later.',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (auth.status == AuthStatus.authenticated)
                  OutlinedButton(
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                    child: const Text('Sign out'),
                  )
                else
                  FilledButton(
                    onPressed: () => context.push('/auth?from=%2Fprofile'),
                    child: const Text('Sign in'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const V2SectionTitle(
            title: 'Accent preference',
            subtitle: 'Reference audio and recognition should respect the learner accent setting.',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['american', 'british'].map((accent) {
              return ChoiceChip(
                label: Text(accent),
                selected: learner.accentPreference == accent,
                onSelected: (_) async {
                  await ref.read(storageServiceProvider).saveAccentPreference(accent);
                  if (ref.read(authProvider).status == AuthStatus.authenticated) {
                    await ref.read(authProvider.notifier).updateAccentPreference(accent);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          V2InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Learner setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    V2Pill(label: learner.goal.title, color: AppColors.primary),
                    V2Pill(label: learner.placementLevel.title, color: AppColors.secondary),
                    V2Pill(label: '${learner.dailyMinutes} min/day', color: AppColors.accentOrange),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () => context.go('/onboarding'),
                  child: const Text('Edit learner setup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
