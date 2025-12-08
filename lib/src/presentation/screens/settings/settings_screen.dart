import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../logic/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';

/// Settings/Profile screen with fake data and logout.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = true;

  Future<void> _logout() async {
    await ServiceLocator.appState.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = ServiceLocator.appState;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardOverlay,
                borderRadius: AppRadii.card,
                boxShadow: const [AppShadows.soft],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.userName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        appState.userEmail.isNotEmpty
                            ? appState.userEmail
                            : 'user@deepshield.app',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _settingsTile(
              title: 'Notifications',
              subtitle: 'Receive alerts for completed analysis',
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (value) =>
                    setState(() => notificationsEnabled = value),
              ),
            ),
            _settingsTile(
              title: 'Dark Mode',
              subtitle: 'Toggle application theme',
              trailing: Switch(
                value: darkMode,
                onChanged: (value) => setState(() => darkMode = value),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('About DeepShield', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardOverlay,
                borderRadius: AppRadii.card,
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'DeepShield detects AI-generated forgeries and anchors reports on-chain for verification. This build uses simulated data only.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Log out',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardOverlay,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
