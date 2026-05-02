import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/authenticated_http.dart';
import '../../../core/utils/service_locator.dart';
import '../../../routes/app_router.dart';
import '../../../data/models/deepfake_request.dart';
import '../../../data/services/deepfake_service.dart';

/// Animated analysis status screen that calls the deepfake backend.
class AnalysisProgressScreen extends StatefulWidget {
  const AnalysisProgressScreen({super.key, required this.request});

  final DeepfakeRequest request;

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen> {
  bool uploadingDone = false;
  bool aiDone = false;
  bool reportDone = false;
  bool chainDone = false;
  bool hasError = false;
  bool _isRunning = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      uploadingDone = false;
      aiDone = false;
      reportDone = false;
      chainDone = false;
      hasError = false;
      errorMessage = null;
      _isRunning = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => uploadingDone = true);

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => aiDone = true);

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => reportDone = true);

      final result = await ServiceLocator.deepfakeService.analyze(
        widget.request,
      );
      if (!mounted) return;
      setState(() => chainDone = true);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: result,
      );
    } on UnauthorizedException {
      if (!mounted) return;
      await handleUnauthorized(context);
    } catch (e) {
      if (!mounted) return;

      final rawError = e.toString();
      final displayError = rawError.startsWith('Exception: ')
          ? rawError.substring('Exception: '.length)
          : rawError;

      setState(() {
        hasError = true;
        errorMessage = displayError;
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.request.mediaType.toLowerCase() == 'video';

    return Scaffold(
      appBar: AppBar(title: const Text('Content Analysis')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, _) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.primary,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.surface,
                        child: Icon(
                          Icons.shield_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analyzing Content',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isVideo
                  ? 'Analyzing video - this may take a moment...'
                  : 'Analyzing image...',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: chainDone
                    ? 1
                    : reportDone
                    ? 0.8
                    : aiDone
                    ? 0.6
                    : uploadingDone
                    ? 0.3
                    : 0.1,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: ListView(
                children: [
                  _stepTile(
                    icon: Icons.upload_rounded,
                    label: 'Uploading',
                    done: uploadingDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.psychology_alt_outlined,
                    label: 'AI Analysis',
                    done: aiDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.description_outlined,
                    label: 'Generating Report',
                    done: reportDone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _stepTile(
                    icon: Icons.shield_outlined,
                    label: 'Blockchain Anchoring',
                    done: chainDone,
                    inProgress: _isRunning && !chainDone && !hasError,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Do not close this window. Analysis may take up a few minutes.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      errorMessage ?? 'Something went wrong.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _runAnalysis,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go back'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTile({
    required IconData icon,
    required String label,
    required bool done,
    bool inProgress = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: done ? Colors.green : AppColors.primary,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (done)
            const Icon(Icons.check_circle, color: Colors.greenAccent)
          else if (inProgress && !hasError)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
