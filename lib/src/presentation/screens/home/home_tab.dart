import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/models/media_item.dart';
import '../../../data/models/deepfake_request.dart';
import '../../../core/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../widgets/primary_button.dart';

/// Main verification screen. Uses local file upload to call deepfake APIs.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _filePath;
  String? _fileName;
  bool _isPicking = false;
  
  bool _isHealthy = false;
  bool _healthCheckDone = false;
  String _healthMessage = 'Checking backend connection...';

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    try {
      await ServiceLocator.deepfakeService.checkHealth();
      if (!mounted) return;
      setState(() {
        _isHealthy = true;
        _healthMessage = 'Backend connected';
        _healthCheckDone = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isHealthy = false;
        _healthMessage = 'Backend unreachable — analysis unavailable';
        _healthCheckDone = true;
      });
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );
    setState(() => _isPicking = false);

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _filePath = result.files.single.path!;
      _fileName = result.files.single.name;
    });
  }

  void _startAnalysis() {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload a file to analyze.')),
      );
      return;
    }

    final isVideo = _isVideoFile(_filePath!);
    final media = MediaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _fileName ?? 'Uploaded media',
      url: _filePath!,
      type: isVideo ? 'video' : 'image',
      thumbnailAsset: 'assets/images/logo.png',
    );

    final request = DeepfakeRequest(
      filePath: _filePath!,
      mediaType: isVideo ? 'video' : 'image',
      mediaTitle: media.title,
    );

    Navigator.pushNamed(
      context,
      AppRoutes.analysisProgress,
      arguments: request,
    );
  }

  bool _isVideoFile(String path) {
    final lower = path.toLowerCase();
    const videoExts = ['.mp4', '.mov', '.mkv', '.avi', '.wmv', '.flv'];
    return videoExts.any((ext) => lower.endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    final name = ServiceLocator.appState.userName;
    final canUpload = _healthCheckDone && _isHealthy;

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
            
            // Health indicator
            if (_healthCheckDone)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isHealthy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _isHealthy ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                      color: _isHealthy ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _healthMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _isHealthy ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

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
                    label: _filePath != null
                        ? 'File Selected: ${_fileName ?? 'Unnamed'}'
                        : _isPicking
                            ? 'Picking...'
                            : 'Upload Media',
                    icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    onPressed: (_isPicking || !canUpload) ? null : _pickFile,
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
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Analyze File',
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _startAnalysis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We securely transmit your media to our powerful backend analysis engine.',
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

