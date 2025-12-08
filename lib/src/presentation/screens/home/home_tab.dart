import 'package:flutter/material.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/media_item.dart';
import '../../../logic/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';

/// Main verification screen. Uses simulated upload/link input.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _linkCtrl = TextEditingController();
  MediaItem? _selectedMedia;

  @override
  void dispose() {
    _linkCtrl.dispose();
    super.dispose();
  }

  void _simulateUpload() {
    setState(() {
      _selectedMedia = MediaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Uploaded media',
        url: 'local-upload://placeholder',
        type: 'image',
        thumbnailAsset: 'assets/images/logo.png',
      );
    });
  }

  void _startAnalysis() {
    final url = _linkCtrl.text.trim();
    if (_selectedMedia == null && url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload media or paste a link to analyze.')),
      );
      return;
    }
    if (url.isNotEmpty && !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid URL starting with http/https.')),
      );
      return;
    }

    final media = _selectedMedia ??
        MediaItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Instagram Link',
          url: url,
          type: 'link',
        );

    Navigator.pushNamed(
      context,
      AppRoutes.analysisProgress,
      arguments: media,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = ServiceLocator.appState.userName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DeepShield',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: -0.1,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $name!',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Verify content authenticity with cutting-edge AI.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardOverlay,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [AppShadows.medium],
                border: Border.all(color: AppColors.subtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: _selectedMedia != null ? 'Media Selected' : 'Upload Media',
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    onPressed: _simulateUpload,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Supports images and videos from your device gallery.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _linkCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link_rounded),
                      hintText: 'Paste post or reel link',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Analyze Link',
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _startAnalysis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter a valid Instagram URL for verification.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
