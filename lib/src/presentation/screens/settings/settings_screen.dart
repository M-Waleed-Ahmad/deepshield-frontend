import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../../data/models/health_status.dart';

/// Settings/Profile screen with fake data and logout.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = true;

  HealthStatus? _healthStatus;
  bool _isLoadingHealth = false;

  @override
  void initState() {
    super.initState();
    _fetchHealth();
  }

  Future<void> _fetchHealth() async {
    setState(() => _isLoadingHealth = true);
    try {
      final status = await ServiceLocator.deepfakeService.checkHealth();
      if (!mounted) return;
      setState(() {
        _healthStatus = status;
        _isLoadingHealth = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _healthStatus = null;
        _isLoadingHealth = false;
      });
    }
  }

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
            Text('Backend Status', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _buildHealthCard(),

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
                'DeepShield detects AI-generated forgeries and anchors reports on-chain for verification. This build consumes the locally running FastAPI backend.',
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

  Widget _buildHealthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardOverlay,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoadingHealth)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_healthStatus == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Backend unreachable', style: TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: _fetchHealth,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('Retry')
                )
              ],
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 6),
                    Text('Status: ${_healthStatus!.status}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]
                ),
                TextButton(
                  onPressed: _fetchHealth,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                  child: const Text('Re-check')
                )
              ],
            ),
            const SizedBox(height: 8),
            _metaRow('UCF Model', _healthStatus!.ucfLoaded ? 'Loaded' : 'Not Loaded'),
            _metaRow('Xception Model', _healthStatus!.xceptionLoaded ? 'Loaded' : 'Not Loaded'),
            _metaRow('AI Service', _healthStatus!.aiService),
            _metaRow('Last Checked', DateFormat('h:mm:ss a').format(_healthStatus!.lastChecked!)),
          ]
        ],
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

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

